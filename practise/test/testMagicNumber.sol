// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {HuffDeployer} from "../dependencies/foundry-huff/src/HuffDeployer.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Console.sol";

interface IMagicNumber {
    function whatIsTheMeaningOfLife() external view returns (bytes32);
}

contract TestMagicNumber is Test {
    string HUFF_CONTRACT_LOCATION = "MagicNumber";
    IMagicNumber public magicNumberContract;

    function setUp() public {
        magicNumberContract = IMagicNumber(HuffDeployer.config().deploy(HUFF_CONTRACT_LOCATION));
    }

    function testMagicNumber() public view {
        bytes32 expectedNumber = bytes32(uint256(42));
        bytes32 magicNumber = magicNumberContract.whatIsTheMeaningOfLife();
        console.logBytes32(magicNumber);
        assertEq(magicNumber, expectedNumber);
    }
}
