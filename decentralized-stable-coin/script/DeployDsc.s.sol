// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/script.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {Constants} from "./Constants.c.sol";

contract DscScript is Script {
    address[] tokenAddress;
    address[] priceFeedAddresses;

    function run() external returns (DecentralizedStableCoin, DSCEngine, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (address wethPriceFeed, address wbtcPriceFeed, address weth, address wbtc,) = helperConfig.activeNetworkConfig();

        tokenAddress.push(weth);
        tokenAddress.push(wbtc);
        priceFeedAddresses.push(wethPriceFeed);
        priceFeedAddresses.push(wbtcPriceFeed);
        vm.startBroadcast();
        DecentralizedStableCoin dscContract = new DecentralizedStableCoin();
        address dscContractAddress = address(dscContract);
        DSCEngine dscEngine = new DSCEngine(tokenAddress, priceFeedAddresses, dscContractAddress);
        dscContract.transferOwnership(address(dscEngine));

        vm.stopBroadcast();

        return (dscContract, dscEngine, helperConfig);
    }
}
