// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {HorseStore} from "../../src/horseStoreV1/HorseStore.sol";

abstract contract Base_Test is Test {
    HorseStore public horseStore;

    function setUp() public virtual {
        horseStore = new HorseStore();
    }

    function testWriteValue() public {
        uint256 expectedNumber = 22;
        horseStore.updateHorseNumber(expectedNumber);
        uint256 horseNumber = horseStore.readNumberOfHorses();
        assertEq(expectedNumber, horseNumber);
    }

    function testReadValue() public view {
        uint256 expectedNumber = 0;
        uint256 horseNumber = horseStore.readNumberOfHorses();
        assertEq(expectedNumber, horseNumber);
    }
}
