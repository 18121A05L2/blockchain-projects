// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {AccountAbstraction} from "../src/Ethereum/AccountAbstraction.sol";
import {Constants} from "../src/Ethereum/Constants.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script, Constants {
    struct NetworkConfig {
        address account;
        address entryPoint;
        address mockErc20Token;
    }

    mapping(uint256 chainId => NetworkConfig) public networkConfig;

    NetworkConfig public activeNetworkConfig;

    constructor() {
        networkConfig[ANVIL_CHAIN_ID] = getLocalOrAnvilConfig();
        networkConfig[SEPOLIA_CHAIN_ID] = getSepoliEthConfig();
        activeNetworkConfig = networkConfig[block.chainid];
    }

    function getSepoliEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({account: REAL_ACCOUNT, entryPoint: SEPOLIA_ENTRY_POINT, mockErc20Token: SEPOLIA_USDC_TOKEN});
    }

    function getLocalOrAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.account != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast(ANVIL_ACCOUNT);

        EntryPoint entryPoint = new EntryPoint();
        ERC20Mock mockErc20Token = new ERC20Mock();
        vm.stopBroadcast();

        NetworkConfig memory config = NetworkConfig({
            account: ANVIL_ACCOUNT,
            entryPoint: address(entryPoint),
            mockErc20Token: address(mockErc20Token)
        });

        return config;
    }
}
