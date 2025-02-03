// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GatekeeperOne, BreakGateKeeperOne} from "../src/GatekeeperOne.sol";
import {console} from "forge-std/console.sol";

contract testGatekeeper is Test {
    GatekeeperOne gateKeeperOne;
    BreakGateKeeperOne breakGateKeeperOne;

    function setUp() public {
        gateKeeperOne = new GatekeeperOne();
        breakGateKeeperOne = new BreakGateKeeperOne(address(gateKeeperOne));
    }

    function testGas() public {
        bytes8 _gateKey = breakGateKeeperOne.getKey();

        for (uint256 i = 1; i < 8191; i++) {
            try breakGateKeeperOne.breakContract(_gateKey, i) {
                console.log("Success");
                console.log(i);
                return;
            } catch {
            }
        }
    }
}
