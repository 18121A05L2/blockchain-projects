// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// https://github.com/Cyfrin/foundry-merkle-airdrop-cu

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {console} from "forge-std/console.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    error MerkleAirdrop_invalidProof();
    error MerkleAirdrop_userAlreadyClaimed();
    error MerkleAirdrop_invalidSignature();

    bytes32 private immutable i_merkleRoot;
    IERC20 private airdropToken;

    mapping(address => bool) public userClaimStatus;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    bytes32 MESSAGE_HASH_TYPE = keccak256("AirdropClaim(address,address)");

    constructor(IERC20 _airdropToken, bytes32 _merkleRoot) EIP712("Merkle Airdrop", "1.0.0") {
        i_merkleRoot = _merkleRoot;
        airdropToken = _airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata _merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        if (userClaimStatus[account]) revert MerkleAirdrop_userAlreadyClaimed();
        if (!_isValidSignature(account, getSignedMessage(account, amount), v, r, s)) {
            revert MerkleAirdrop_invalidSignature();
        }
        // bytes32 leaf = keccak256(abi.encode(keccak256(abi.encode(account, amount))));
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        bool success = MerkleProof.verify(_merkleProof, i_merkleRoot, leaf);
        if (!success) revert MerkleAirdrop_invalidProof();
        airdropToken.safeTransfer(account, amount);
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address signer,,) = ECDSA.tryRecover(digest, v, r, s);
        return signer == account;
    }

    function getSignedMessage(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_HASH_TYPE, AirdropClaim({account: account, amount: amount}))));
    }
}
