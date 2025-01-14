// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {AccountAbstraction} from "../src/Ethereum/AccountAbstraction.sol";
import {HelperConfig} from "./HelperConfig.sol";

contract DeployAccountAbstraction is Script {
    HelperConfig.NetworkConfig activeNetworkConfig;

    function run() public returns (AccountAbstraction accountAbstraction, HelperConfig helperConfig) {
        helperConfig = new HelperConfig();
        activeNetworkConfig = helperConfig.getActiveNetworkConfig();
        vm.startBroadcast();
        accountAbstraction = new AccountAbstraction(activeNetworkConfig.entryPoint);
        vm.stopBroadcast();
    }
}
