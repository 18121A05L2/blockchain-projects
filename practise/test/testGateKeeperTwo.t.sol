// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GatekeeperTwo, BreakGateKeeperTwo} from "../src/GatekeeperTwo.sol";
import {console} from "forge-std/console.sol";

contract testGatekeeper is Test {
    GatekeeperTwo gateKeeperOne;
    BreakGateKeeperTwo breakGateKeeperOne;

    function setUp() external {
        vm.startPrank(0xE959A2c1c3F108697c244b98C71803b6DcD77764);
        console.log("setup");
        bytes8 _gateKey = bytes8(0);
        gateKeeperOne = new GatekeeperTwo();
        // breakGateKeeperOne = new BreakGateKeeperTwo(address(gateKeeperOne), _gateKey);
        // console.log(address(breakGateKeeperOne));
        vm.stopPrank();
    }

    function testBreakGateKeeperTwo() public {}
}
