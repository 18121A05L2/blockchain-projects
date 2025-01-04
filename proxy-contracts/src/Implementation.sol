// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Implementation {
    uint256 constructorNumber;

    constructor() {
        constructorNumber = 10;
    }

    function getNumber() public pure returns (uint256) {
        return 30;
    }

    function getConstructorNumber() public view returns (uint256) {
        return constructorNumber;
    }
}
