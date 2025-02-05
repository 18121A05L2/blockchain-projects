// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {NaughtCoin, BreakNaughtCoin} from "../src/NaughtCoin.sol";

contract testGatekeeper is Test {
    NaughtCoin naughtCoing;
    BreakNaughtCoin breakNaughtCoin;
    address spender = 0xC2F221048AE8ba9c7b5D7d124E90339980D497ef;
    address owner = 0xE959A2c1c3F108697c244b98C71803b6DcD77764;

    function setUp() external {
        vm.startPrank(owner);
        naughtCoing = new NaughtCoin(owner);
        breakNaughtCoin = new BreakNaughtCoin(address(naughtCoing));
        vm.stopPrank();
    }

    function testTokenApprovalAndTransform() public {
        vm.startPrank(owner);
        uint256 ownerBalance = naughtCoing.balanceOf(owner);
        assertEq(ownerBalance, naughtCoing.INITIAL_SUPPLY());
        assertEq(naughtCoing.allowance(owner, spender), ownerBalance);
        vm.stopPrank();
        // vm.prank(spender);
        // (bool success2) = naughtCoing.transferFrom(owner, spender, ownerBalance);
        // assertEq(success2, true);
        // assertEq(naughtCoing.balanceOf(owner), 0);
    }
}
