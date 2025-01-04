// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {DSCEngineInterface} from "./DSCEngineInterface.i.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {console} from "forge-std/console.sol";
import {Oraclelib} from "./libraries/Oraclelib.sol";

contract DSCEngine is ReentrancyGuard {
    error DSCEngine_mustBeMoreThanZero();
    error DSCEngine_tokenNotAllowed();
    error DSCEngine_tokenAddressMismatchToPriceFeed();
    error DSCEngine_tokenTransferFailed();
    error DSCEngine_HealthFactorIsBroken(uint256 userHealthFactor);
    error DSCEngine_mintFailed();
    error DSCEngine_redeemCollaternalFailed();
    error DSCEngine_userMustOwnTheToken();
    error DSCEngine_healthFacorIsOkay();
    error DSCEngine_healthFacorIsNotImproved();
    error DSCEngine_ReentrancyCallDetected();

    using Oraclelib for AggregatorV3Interface; // Attach OracleLib functions to AggregatorV3Interface

    mapping(address token => address priceFeed) private s_tokenAddToPriceFeed;
    mapping(address user => mapping(address token => uint256 amount)) public s_collateralDeposited;
    mapping(address user => uint256 amountOfDsc) public s_amountOfDscMinted;
    mapping(address => bool) private reentrancyLock;

    address[] s_collateralTokens;

    DecentralizedStableCoin private immutable i_dscContractAddress;
    uint256 public constant LIQUIDATION_THRESHOLD = 75;
    uint256 public constant WARNING_LIQUIDATION_THRESHOLD = 65;
    uint256 public constant LIQUIDATION_PRECISION = 100;
    uint256 public constant LIQUIDATION_BONUS = 10;
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    // Events
    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);
    event CollateralRedeemed(address from, address indexed redeemTo, address token, uint256 amount);
    event NearOverCollateralWarning(address indexed user);

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine_mustBeMoreThanZero();
        }
        _;
    }

    modifier isTokenAllowed(address tokenAddress) {
        if (s_tokenAddToPriceFeed[tokenAddress] == address(0)) {
            revert DSCEngine_tokenNotAllowed();
        }
        _;
    }
    // for cross function reentrancy , need to check how can this happen

    modifier userLock() {
        if (!reentrancyLock[msg.sender]) {
            revert DSCEngine_ReentrancyCallDetected();
        }
        reentrancyLock[msg.sender] = true;
        _;
        reentrancyLock[msg.sender] = false;
    }

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscContractAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine_tokenAddressMismatchToPriceFeed();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_tokenAddToPriceFeed[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        // typecasting dscContractAddress with DecentralizedStableCoin contract
        i_dscContractAddress = DecentralizedStableCoin(dscContractAddress);
    }

    function depositCollateralAndMintDsc(address tokenAddress, uint256 amount, uint256 dscAmountToMint) external {
        depositCollateral(tokenAddress, amount);
        mintDsc(dscAmountToMint);
    }

    function depositCollateral(address tokenAddress, uint256 amount)
        public
        moreThanZero(amount)
        isTokenAllowed(tokenAddress)
        nonReentrant
        returns (bool)
    {
        // how are we sure that user has been paying to us the amount he has been inputing
        s_collateralDeposited[msg.sender][tokenAddress] += amount;
        emit CollateralDeposited(msg.sender, tokenAddress, amount);
        bool success = IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        if (!success) revert DSCEngine_tokenTransferFailed();
        return success;
    }

    function mintDsc(uint256 dscAmountToMint) public moreThanZero(dscAmountToMint) nonReentrant returns (bool) {
        s_amountOfDscMinted[msg.sender] += dscAmountToMint;
        revertIfHealtFactorIsBroken(msg.sender);
        (bool minted) = i_dscContractAddress.mint(msg.sender, dscAmountToMint);
        if (!minted) {
            revert DSCEngine_mintFailed();
        } else {
            return true;
        }
    }

    function _healthFactor(address user) internal returns (uint256) {
        // Health Factor = (Total Collateral Value * Weighted Average Liquidation Threshold) / Total Borrow Value
        uint256 totalDscMinted = s_amountOfDscMinted[user];
        if (totalDscMinted == 0) return type(uint256).max;
        uint256 totalCollateralValueInUsd = getAccountCollateralValue(user);
        uint256 collateralAdjustedForWarning =
            totalCollateralValueInUsd * WARNING_LIQUIDATION_THRESHOLD / LIQUIDATION_PRECISION;
        bool warningPosition = (collateralAdjustedForWarning / totalDscMinted) < MIN_HEALTH_FACTOR;
        // nedd to test his emit event
        if (warningPosition) {
            emit NearOverCollateralWarning(user);
        }
        uint256 collaternalAdjustedForThreshold =
            totalCollateralValueInUsd * LIQUIDATION_THRESHOLD / LIQUIDATION_PRECISION;
        return collaternalAdjustedForThreshold / totalDscMinted;
    }

    function revertIfHealtFactorIsBroken(address user) internal {
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor < MIN_HEALTH_FACTOR) {
            revert DSCEngine_HealthFactorIsBroken(userHealthFactor);
        }
    }

    /**
     * @notice This function will loop through the each collateral token and calculate the total collateral value
     *
     */
    function getAccountCollateralValue(address user) public view returns (uint256 totalCollateralValue) {
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            uint256 amount = s_collateralDeposited[user][s_collateralTokens[i]];
            uint256 amountInUsd = getUsdValue(s_collateralTokens[i], amount);
            totalCollateralValue = totalCollateralValue + amountInUsd;
        }
    }

    /**
     *
     * @param token address of the collateral token
     * @param amount amount to be calculated in USD value
     * @return amount in USD value with DECIMALS Ex : for 1 eth amount this will return 37001e18
     */
    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_tokenAddToPriceFeed[token]);
        (, int256 price,,,) = priceFeed.staleCheckForLatestRoundData();
        uint256 tokenDecimals = uint256(priceFeed.decimals());
        // Solidity's integer division truncates. Thus, performing division before multiplication can lead to precision loss.
        // return ((uint256(price) * (PRECISION / 10 ** tokenDecimals)) * amount) / PRECISION;
        return (uint256(price) * PRECISION * amount) / (PRECISION * 10 ** tokenDecimals);
    }

    /**
     * @param token Collateral token address
     * @param amountUsdInWei this is the amount we will input as in dollars like $100
     */
    function getTokenAmountFromUsd(address token, uint256 amountUsdInWei) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_tokenAddToPriceFeed[token]);
        (, int256 price,,,) = priceFeed.staleCheckForLatestRoundData();
        uint256 tokenDecimals = uint256(priceFeed.decimals());
        // removing precesion to scale down the denominator so that numerator is in scaled up position
        // Solidity's integer division truncates. Thus, performing division before multiplication can lead to precision loss.
        // uint256 denominator = (uint256(price) * (PRECISION / 10 ** tokenDecimals)) / PRECISION;
        uint256 denominator = (uint256(price) * PRECISION) / (PRECISION * 10 ** tokenDecimals);
        return ((amountUsdInWei * PRECISION) / denominator);
    }

    /**
     * To redeem collateral user must have health facor greater than or equal to 1
     */
    function _redeemCollateral(address tokenAddress, uint256 amount, address from, address to)
        private
        isTokenAllowed(tokenAddress)
        moreThanZero(amount)
        nonReentrant
        returns (bool)
    {
        //  if user tries to redeem 1000 from 100 which he deplosited , build in solidity will handle the unsafe overflow
        s_collateralDeposited[from][tokenAddress] -= amount;
        revertIfHealtFactorIsBroken(from);
        bool success = IERC20(tokenAddress).transfer(to, amount);
        if (!success) revert DSCEngine_redeemCollaternalFailed();
        emit CollateralRedeemed(from, to, tokenAddress, amount);
        return success;
    }

    // external redeem function
    function redeemCollateral(address tokenAddress, uint256 amount) public {
        _redeemCollateral(tokenAddress, amount, msg.sender, msg.sender);
    }

    function _burnDsc(uint256 amountToBurn, address onBehalfOf, address dscFrom) private {
        if (s_amountOfDscMinted[onBehalfOf] < amountToBurn) {
            revert DSCEngine_userMustOwnTheToken();
        }
        s_amountOfDscMinted[onBehalfOf] -= amountToBurn;
        // for this user need to approve , but when liquidating user is not going to approve as the liquidator is paying the stable coin tokens
        (bool success) = i_dscContractAddress.transferFrom(dscFrom, address(i_dscContractAddress), amountToBurn);
        if (!success) revert DSCEngine_tokenTransferFailed();
        i_dscContractAddress.burn(amountToBurn);
    }

    // external burn function
    function burnDsc(uint256 amount) public {
        _burnDsc(amount, msg.sender, msg.sender);
    }

    function redeemCollateralForDsc(address tokenAddress, uint256 collateralAmount, uint256 amountOfDscToBurn) public {
        burnDsc(amountOfDscToBurn);
        redeemCollateral(tokenAddress, collateralAmount);
    }

    /**
     * first we will check the user health factor and if it okay then no point in liquadating the user
     */
    function liquidate(address collateral, address user, uint256 debtTocover) public {
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor >= MIN_HEALTH_FACTOR) {
            revert DSCEngine_healthFacorIsOkay();
        }

        uint256 tokenAmountFromDebtCovered = getTokenAmountFromUsd(collateral, debtTocover);

        uint256 bonusAmount = (tokenAmountFromDebtCovered * LIQUIDATION_BONUS) / LIQUIDATION_PRECISION;

        uint256 totalCollateralToRedeem = tokenAmountFromDebtCovered + bonusAmount;

        _redeemCollateral(collateral, totalCollateralToRedeem, user, msg.sender);

        _burnDsc(debtTocover, user, msg.sender);

        uint256 endingUserhealthFactor = _healthFactor(user);
        if (endingUserhealthFactor < MIN_HEALTH_FACTOR) {
            revert DSCEngine_healthFacorIsNotImproved();
        }
        revertIfHealtFactorIsBroken(msg.sender);
    }

    // VIEW functions
    function getPriceFeedForCollateralToken(address collateralAddress) external view returns (address) {
        return s_tokenAddToPriceFeed[collateralAddress];
    }
}
