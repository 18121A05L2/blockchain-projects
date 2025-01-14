// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {DeployAccountAbstraction} from "../script/DeployAccountAbstraction.sol";
import {HelperConfig} from "../script/HelperConfig.sol";
import {AccountAbstraction} from "../src/Ethereum/AccountAbstraction.sol";

contract TestAccountAbstraction is Test {
    function setUp() external {
        (HelperConfig helperConfig, AccountAbstraction accountAbstraction) = new DeployAccountAbstraction().run();
    }
}
