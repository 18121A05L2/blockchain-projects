// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {console} from "forge-std/console.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    error MerkleAirdrop_invalidProof();
    error MerkleAirdrop_userAlreadyClaimed();

    address private immutable i_airDropToken;
    bytes32 private immutable i_merkleRoot;
    IERC20 private airdropToken;

    mapping(address => bool) public userClaimStatus;

    constructor(address _airdropToken, bytes32 _merkleRoot) {
        i_airDropToken = _airdropToken;
        i_merkleRoot = _merkleRoot;
        airdropToken = IERC20(_airdropToken);
    }

    function claim(address account, uint256 amount, bytes32[] calldata _merkleProof) external {
        if (userClaimStatus[account]) revert MerkleAirdrop_userAlreadyClaimed();
        // bytes32 leaf = keccak256(abi.encode(keccak256(abi.encode(account, amount))));
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        bool success = MerkleProof.verify(_merkleProof, i_merkleRoot, leaf);
        if (!success) revert MerkleAirdrop_invalidProof();
        airdropToken.safeTransfer(account, amount);
    }
}
