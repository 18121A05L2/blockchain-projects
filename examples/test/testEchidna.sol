// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Counter {
    int256 public count;

    function inc() public {
        count++;
    }

    function dec() public {
        count--;
    }
}

contract TestEchidna is Counter {
    function echidna_test_alwys_true() public pure returns (bool) {
        return true;
    }

    function echidna_test_counter_gt_five() public view returns (bool) {
        return count <= 20;
    }
}
