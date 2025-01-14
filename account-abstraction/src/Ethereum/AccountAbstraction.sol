// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

error AccountAbstraction_InsufficientFunds();
error AccountAbstraction_InvalidEntryPoint();
error AccountAbstraction_InvalidEntryPointOrOwner();
error AccountAbstraction__ExecutionFailed();

contract AccountAbstraction is IAccount, Ownable {
    address[] public authorizedSenders;
    IEntryPoint public immutable i_entryPoint;

    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    modifier onlyEntryPoint() {
        if (msg.sender != address(i_entryPoint)) revert AccountAbstraction_InvalidEntryPoint();
        _;
    }

    modifier requireFromEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) {
            revert AccountAbstraction_InvalidEntryPointOrOwner();
        }
        _;
    }

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        onlyEntryPoint
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);

        if (missingAccountFunds != 0) {
            _payPrefund(missingAccountFunds);
        }
    }

    // EIP-191 form of hash and we need to convert to eth signed message hash
    // userOpHash - is a hash over the content of the userOp (except the signature), the entrypoint and the chainid.
    // Signature in userOp is - abi.encodePacked(r, s, v) - these came from the sign of user with userOp ethSingnedMessageHash
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSingnedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethSingnedMessageHash, userOp.signature);
        if (checkSenderAuthorization(signer)) {
            return SIG_VALIDATION_SUCCESS;
        }
        return SIG_VALIDATION_FAILED;
    }

    function addAuthorizedSender(address sender) external onlyOwner {
        authorizedSenders.push(sender);
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        (bool success,) = payable(msg.sender).call{value: missingAccountFunds}("");
        if (!success) revert AccountAbstraction_InsufficientFunds();
    }

    function checkSenderAuthorization(address signer) internal view returns (bool) {
        for (uint256 i = 0; i < authorizedSenders.length; i++) {
            if (authorizedSenders[i] == signer) {
                return true;
            }
        }
        return false;
    }
    // This is dynamic and we are going to give info to the handleOps function of what function need to call when the validateUserOps succeds

    function execute(address dest, uint256 value, bytes calldata functionData) external requireFromEntryPointOrOwner {
        (bool success,) = dest.call{value: value}(functionData);
        if (!success) {
            revert AccountAbstraction__ExecutionFailed();
        }
    }

    // TODO : add a withdraw function
    // function withdrawTo
}
