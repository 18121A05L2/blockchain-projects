// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AirdropToken} from "../src/AirdropToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    address ANVIL_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    function run() external returns (MerkleAirdrop merkleAirdrop, AirdropToken airdropToken) {
        bytes32 merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
        vm.startBroadcast(ANVIL_ACCOUNT);
        airdropToken = new AirdropToken();
        merkleAirdrop = new MerkleAirdrop(IERC20(address(airdropToken)), merkleRoot);
        vm.stopBroadcast();
    }
}
