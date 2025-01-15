// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Constants {
    // public addresses
    address constant ZERO_ADDRESS = address(0);
    address constant RANDOM_ACCOUNT = 0x70997970c51912Dc4A010C7d01b50E0d17dC79C8;
    address constant REAL_ACCOUNT = 0xE959A2c1c3F108697c244b98C71803b6DcD77764;
    address constant ANVIL_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address SEPOLIA_PRICE_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address SEPOLIA_ENTRY_POINT = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    address SEPOLIA_USDC_TOKEN = 0x53844F9577C2334e541Aec7Df7174ECe5dF1fCf0;
    // initial values
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_ANSWER = 340000000000;
    uint256 constant INITIAL_ETH_LOADED = 0.00000001 ether;
    // chanin id
    uint256 constant ANVIL_CHAIN_ID = 31337;
    uint256 SEPOLIA_CHAIN_ID = 11155111;
    uint256 ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 ZKSYNC_MAINNET_CHAIN_ID = 324;
    // slots
    bytes32 constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);
    bytes32 constant OPENZEPPELIN_OWANABLE_SLOT =
        keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Ownable")) - 1)) & ~bytes32(uint256(0xff));
}
