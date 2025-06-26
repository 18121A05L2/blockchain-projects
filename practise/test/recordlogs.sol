// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Delegation} from "../src/Delegation.sol";
import {console} from "forge-std/Console.sol";
import {Vm} from "forge-std/Vm.sol";

contract TestLogs is Test {
    event LogTopic1(uint256 indexed topic1, bytes data, uint256 num);

    event LogTopic12(uint256 indexed topic1, uint256 indexed topic2, bytes data);

    function testA() public {
        bytes memory testData0 = "Some data";
        bytes memory testData1 = "Other data";

        // Start the recorder
        vm.recordLogs();
        //         struct Log {
        //          bytes32[] topics;
        //          bytes     data;
        //          address   emitter;
        //         }

        emit LogTopic1(10, testData0, 0);
        emit LogTopic12(20, 30, testData1);

        // Notice that your entries are <Interface>.Log[]
        // as opposed to <instance>.Log[]
        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 2);

        // Recall that topics[0] is the event signature
        assertEq(entries[0].topics.length, 2);
        assertEq(entries[0].topics[0], keccak256("LogTopic1(uint256,bytes,uint256)"));
        assertEq(entries[0].topics[1], bytes32(uint256(10)));
        // assertEq won't compare bytes variables. Try with strings instead.
        assertEq(abi.decode(entries[0].data, (string)), string(testData0));
        (, uint256 loggedNum) = abi.decode(entries[0].data, (string, uint256));
        assertEq(loggedNum, 0);

        assertEq(entries[1].topics.length, 3);
        assertEq(entries[1].topics[0], keccak256("LogTopic12(uint256,uint256,bytes)"));
        assertEq(entries[1].topics[1], bytes32(uint256(20)));
        assertEq(entries[1].topics[2], bytes32(uint256(30)));
        assertEq(abi.decode(entries[1].data, (string)), string(testData1));

        // // Emit another event
        // emit LogTopic1(40, testData0, 100);

        // // Your last read consumed the recorded logs,
        // // you will only get the latest emitted even after that call
        // entries = vm.getRecordedLogs();

        // assertEq(entries.length, 1);

        // assertEq(entries[0].topics.length, 2);
        // assertEq(entries[0].topics[0], keccak256("LogTopic1(uint256,bytes)"));
        // assertEq(entries[0].topics[1], bytes32(uint256(40)));
        // assertEq(abi.decode(entries[0].data, (string)), string(testData0));
    }
}
