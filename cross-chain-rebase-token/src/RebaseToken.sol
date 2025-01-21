// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

/**
 * @title Rebase Token
 * @author Lakshmi Sanikommu
 * @notice This is going to be a cross chain token which is used for lending and borrowing using vault with intrest rates
 * @dev Inspiration from AAave Rebase token
 */
contract RebaseToken is ERC20, Ownable, AccessControl {
    error RebaseToken__IntresetRateCanOnlyDecrease();

    uint256 private constant PRECESION_FACTOR = 1e18;
    bytes32 private constant MINT_AND_BURN_ROLE = keccak256("MINT_AND_BURN_ROLE");
    // This interest rate is per second
    uint256 private s_intrestRate = 5e10;
    mapping(address => uint256) private s_userIntrestRate;
    mapping(address => uint256) private s_lastUpdatedTimeStamp;

    event InterestRateUpdated(uint256 oldInterestRate, uint256 newInterestRate);

    constructor() ERC20("RebaseToken", "RBT") Ownable(msg.sender) {}

    function grantMintAndBurnRole(address account) public onlyOwner {
        grantRole(MINT_AND_BURN_ROLE, account);
    }

    /**
     * @notice intrest rate can only decrease
     * @param _newInterestRate new intrest rate
     */
    function setInterestRate(uint256 _newInterestRate) external {
        // TODO :
        if (_newInterestRate < s_intrestRate) {
            emit InterestRateUpdated(s_intrestRate, _newInterestRate);
            s_intrestRate = _newInterestRate;
        } else {
            revert RebaseToken__IntresetRateCanOnlyDecrease();
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        uint256 userExistingBalance = super.balanceOf(account);
        if (userExistingBalance > 0) {
            return super.balanceOf(account) * _calculateAccumulatedInterestSinceLastUpdate(account) / PRECESION_FACTOR;
        }
        return userExistingBalance;
    }

    function _calculateAccumulatedInterestSinceLastUpdate(address account) internal view returns (uint256) {
        uint256 timeElapsed = block.timestamp - s_lastUpdatedTimeStamp[account];
        return PRECESION_FACTOR + (s_userIntrestRate[account] * timeElapsed);
    }
    /**
     * @dev with this function we will be minting only interest tokens
     * @param account user address
     */

    function _mintAccuredInterest(address account) internal {
        uint256 userBalanceWithOutInterest = super.balanceOf(account);
        uint256 userBalanceWithInterest = balanceOf(account);
        uint256 interestTokenToMint = userBalanceWithInterest - userBalanceWithOutInterest;
        s_lastUpdatedTimeStamp[account] = block.timestamp;
        _mint(account, interestTokenToMint);
    }

    function mint(address to, uint256 amount, uint256 _userInterestRate) public onlyRole(MINT_AND_BURN_ROLE) {
        _mintAccuredInterest(to); // update timestamp
        s_userIntrestRate[to] = _userInterestRate;
        _mint(to, amount);
    }

    function burn(address account, uint256 amount) public onlyRole(MINT_AND_BURN_ROLE) {
        if (amount == type(uint256).max) {
            amount = balanceOf(account);
        }
        _mintAccuredInterest(account);
        _burn(account, amount);
    }

    function transfer(address _recipient, uint256 amount) public override returns (bool) {
        _mintAccuredInterest(msg.sender);
        _mintAccuredInterest(_recipient);
        if (amount == type(uint256).max) {
            amount = balanceOf(msg.sender);
        }
        if (balanceOf(_recipient) == 0) {
            s_userIntrestRate[_recipient] = s_userIntrestRate[msg.sender];
        }
        return super.transfer(_recipient, amount);
    }

    function transferFrom(address _sender, address _recipient, uint256 amount) public override returns (bool) {
        _mintAccuredInterest(_sender);
        _mintAccuredInterest(_recipient);
        if (amount == type(uint256).max) {
            amount = balanceOf(_sender);
        }
        if (balanceOf(_recipient) == 0) {
            s_userIntrestRate[_recipient] = s_userIntrestRate[_sender];
        }
        return super.transferFrom(_sender, _recipient, amount);
    }

    function principalBalanceOf(address account) external view returns (uint256) {
        return super.balanceOf(account);
    }

    function getUserInterestRate(address account) external view returns (uint256) {
        return s_userIntrestRate[account];
    }

    function getInterestRate() external view returns (uint256) {
        return s_intrestRate;
    }
}
