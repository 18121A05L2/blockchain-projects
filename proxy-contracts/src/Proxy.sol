// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {Implementation} from "../src/implementation.sol";
import {Test} from "./Test.sol";

contract Proxy is Test, Implementation {
    uint256[50] _gap;
    uint256 public fallbackNumber;
    uint256 public testNumber = 100;
    address public implementationAddress;

    function setImplementation(address _impl) public {
        implementationAddress = _impl;
    }

    function loadStorage(uint256 _index) public view returns (uint256 _storage) {
        assembly {
            _storage := sload(_index)
        }
    }

    fallback() external payable {
        // fallbackNumber = 22;  StateChangeDuringStaticCall - If we are calling the not existed function directly
        address _impl = implementationAddress;

        require(_impl != address(0));

        assembly {
            // (1) copy incoming call data
            calldatacopy(0, 0, calldatasize())

            // (2) forward call to logic contract
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)

            // (3) retrieve return data
            returndatacopy(0, 0, returndatasize())

            // (4) forward return data back to caller
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {
        fallbackNumber = 33;
    }
}
