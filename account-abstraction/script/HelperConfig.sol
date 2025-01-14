// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {AccountAbstraction} from "../src/Ethereum/AccountAbstraction.sol";
import {Constants} from "../src/Ethereum/Constants.sol";

contract HelperConfig is Script, Constants {
    struct NetworkConfig {
        address account;
        address entryPoint;
        address mockErc20Token;
    }

    mapping(uint256 chainId => NetworkConfig) public networkConfig;

    NetworkConfig public activeNetworkConfig;

    constructor() {
        activeNetworkConfig = networkConfig[block.chainid];
    }

    function getActiveNetworkConfig() public view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }
}
