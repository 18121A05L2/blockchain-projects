// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/script.sol";
import {Implementation} from "../src/Implementation.sol";

contract DeployImplementation is Script {
    function run() public returns (Implementation implementation) {
        vm.startBroadcast();
        implementation = new Implementation();
        vm.stopBroadcast();
    }
}
