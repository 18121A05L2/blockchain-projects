// SPDX-License-Identifier: MIT

import {IAccount, Transaction, MemoryTransactionHelper} from "zkera/contracts/interfaces/IAccount.sol";
import {SystemContractsCaller} from "zkera/contracts/libraries/SystemContractsCaller.sol";
import {NONCE_HOLDER_SYSTEM_CONTRACT, INonceHolder} from "zkera/contracts/Constants.sol";

pragma solidity ^0.8.0;

contract ZkSyncMininalAccount is IAccount {
    using MemoryTransactionHelper for Transaction;

    error ZkSyncMininalAccount_InsufficientBalance();

    function validateTransaction(
        bytes32, /*_txHash*/
        bytes32, /*_suggestedSignedHash*/
        Transaction calldata _transaction
    ) external payable returns (bytes4 magic) {
        //       uint32 gasLimit,
        // address to,
        // uint128 value,
        // bytes memory data
        // system call to increament nounce
        SystemContractsCaller.systemCallWithPropagatedRevert(
            uint32(gasleft()),
            address(NONCE_HOLDER_SYSTEM_CONTRACT),
            0,
            abi.encodeCall(INonceHolder.incrementMinNonceIfEquals, (_transaction.nonce))
        );

        uint256 totalRequiredBalance = _transaction.totalRequiredBalance();
        if (totalRequiredBalance > address(this).balance) {
            revert ZkSyncMininalAccount_InsufficientBalance();
        }
    }

    function executeTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction calldata _transaction)
        external
        payable
    {}

    function executeTransactionFromOutside(Transaction calldata _transaction) external payable {}

    function payForTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction calldata _transaction)
        external
        payable
    {}

    function prepareForPaymaster(bytes32 _txHash, bytes32 _possibleSignedHash, Transaction calldata _transaction)
        external
        payable
    {}
}
