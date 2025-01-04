// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Constants {

    uint256 public constant LOCALHOST_CHAIN_ID = 31337;
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    string[] public SUPPORTED_COLLATERALS = ["WETH", "WBTC"];
    int256 public constant ETH_PRICE = 3700e8;
    int256 public constant BTC_PRICE = 97000e8;
    uint8 public constant DECIMALS = 8;
    uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
}
