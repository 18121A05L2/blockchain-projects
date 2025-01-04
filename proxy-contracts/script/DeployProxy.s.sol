// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/script.sol";
import {Proxy} from "../src/Proxy.sol";

contract DeployProxy is Script {
    function run() public returns (Proxy proxy) {
        vm.startBroadcast();
        proxy = new Proxy();
        vm.stopBroadcast();
    }
}
