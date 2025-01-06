// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base_Test} from "./Base_Test.t.sol";

import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {HorseStore} from "../../src/horseStoreV1/HorseStore.sol";
import {IHorseStore} from "../../src/horseStoreV1/IHorseStore.sol";

contract HuffTest is Base_Test {
    string HUFF_CONTRACT_LOCATION = "horseStoreV1/HorseStore";

    function setUp() public override {
        horseStore = IHorseStore(HuffDeployer.config().deploy(HUFF_CONTRACT_LOCATION));
    }
}
