// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MinimalAccount is IAccount, Ownable {
    error MinimalAccount_NotEntrypointContract();
    error MinimalAccount_NotOwnwerOrEntryPointContract();

    address private immutable i_owner;

    address public s_entryPoint;

    modifier onlyEntryPointContract() {
        if (msg.sender != s_entryPoint) revert MinimalAccount_NotEntrypointContract();
        _;
    }

    modifier onlyEntryPointOrOwner() {
        if (msg.sender != s_entryPoint && msg.sender != i_owner) revert MinimalAccount_NotOwnwerOrEntryPointContract();
        _;
    }

    constructor(address _entrypoint) Ownable(msg.sender) {
        i_owner = msg.sender;
        s_entryPoint = _entrypoint;
    }

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        onlyEntryPointContract
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);
        _payPrefund(missingAccountFunds);
    }

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSingnedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        if (i_owner != ECDSA.recover(ethSingnedMessageHash, userOp.signature)) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS;
    }

    function execute() public onlyEntryPointOrOwner {}

    function _payPrefund(uint256 missingAccountFunds) internal {}
}
