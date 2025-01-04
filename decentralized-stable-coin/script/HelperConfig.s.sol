// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Constants} from "./Constants.c.sol";
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Constants, Script {
    struct NetworkConfig {
        address wethPriceFeed;
        address wbtcPriceFeed;
        address weth;
        address wbtc;
        uint256 deployerKey;
    }

    NetworkConfig public activeNetworkConfig;

    // address[] private tokenAddresses;
    // mapping(address token => address priceFeed) private s_tokenAddToPriceFeed;

    constructor() {
        if (block.chainid == LOCALHOST_CHAIN_ID) {
            activeNetworkConfig = getOrCreateAnvilConfig();
        } else if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaConfig();
        }
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.wethPriceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator wethAgg = new MockV3Aggregator(DECIMALS, ETH_PRICE);
        MockV3Aggregator wbtcAgg = new MockV3Aggregator(DECIMALS, BTC_PRICE);

        ERC20Mock weth = new ERC20Mock();
        ERC20Mock wbtc = new ERC20Mock();
        vm.stopBroadcast();

        return NetworkConfig({
            wethPriceFeed: address(wethAgg),
            wbtcPriceFeed: address(wbtcAgg),
            weth: address(weth),
            wbtc: address(wbtc),
            deployerKey: DEFAULT_ANVIL_KEY
        });
    }

    function getSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            wethPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            wbtcPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            weth: 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9,
            wbtc: 0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getNetworkConfig() external view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }
}
