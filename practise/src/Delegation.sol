// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/Console.sol";

contract Delegate {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function pwn() public {
        console.log("pwned");
        owner = msg.sender;
    }
}

contract Delegation {
    address public owner;
    Delegate delegate;

    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    fallback() external {
        console.log("fallback");
        console.logBytes(msg.data);
        (bool result,) = address(delegate).delegatecall(msg.data);
        if (result) {
            console.log("delegatecall succeeded"); // Log success
            this;
        } else {
            console.log("delegatecall failed"); // Log failure
        }
    }
}
