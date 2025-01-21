// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";
import {Vault} from "../src/Vault.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {CCIPLocalSimulatorFork} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import {Register} from "@chainlink-local/src/ccip/Register.sol";
import {TokenPool, IERC20} from "@ccip/src/v0.8/ccip/pools/TokenPool.sol";

contract CrossChainTest is Test {
    uint256 sepoliaForkId;
    uint256 arbSepoliaForkId;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() public {
        string memory ethSepoliaRpcUrl = vm.envString("RPC_ETH_SEPOLIA");
        string memory arbSepoliaRpcUrl = vm.envString("RPC_ARB_SEPOLIA");
        address[] memory whitelistAllowList = new address[](0);

        sepoliaForkId = vm.createSelectFork(ethSepoliaRpcUrl);
        arbSepoliaForkId = vm.createFork(arbSepoliaRpcUrl);

        CCIPLocalSimulatorFork ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(ccipLocalSimulatorFork));
        // Deploying contracts in both the chains
        Register.NetworkDetails memory sepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
        vm.startPrank(alice);
        RebaseToken sepoliaToken = new RebaseToken();
        Vault sepoliaValut = new Vault(IRebaseToken(address(sepoliaToken)));
        RebaseTokenPool sepoliaTokenPool = new RebaseTokenPool(
            IERC20(address(sepoliaToken)),
            new address[](0),
            sepoliaNetworkDetails.rmnProxyAddress,
            sepoliaNetworkDetails.routerAddress
        );
        sepoliaToken.grantMintAndBurnRole(address(sepoliaValut));
        sepoliaToken.grantMintAndBurnRole(address(sepoliaTokenPool));
        vm.stopPrank();

        Register.NetworkDetails memory arbSepoliaNetworkDetails =
            ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
        vm.startPrank(bob);
        RebaseToken arbSepoliaToken = new RebaseToken();
        RebaseTokenPool arbSepoliaTokenPool = new RebaseTokenPool(
            IERC20(address(arbSepoliaToken)),
            new address[](0),
            arbSepoliaNetworkDetails.rmnProxyAddress,
            arbSepoliaNetworkDetails.routerAddress
        );
        arbSepoliaToken.grantMintAndBurnRole(address(arbSepoliaTokenPool));

        vm.stopPrank();
    }
}
