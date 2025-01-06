// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base_Test} from "./Base_Test.t.sol";
import {HorseStoreYul} from "../../src/horseStoreV1/HorseStoreYul.sol";
import {IHorseStore} from "../../src/horseStoreV1/IHorseStore.sol";

contract YulTest is Base_Test {
    function setUp() public override {
        horseStore = IHorseStore(address(new HorseStoreYul()));
    }
}
