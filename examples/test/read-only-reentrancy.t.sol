// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Hack, Target} from "../src/ready-only-reentrancy.sol";
import {console} from "forge-std/console.sol";

contract TestReadOnlyReentrancy {
    Hack public hack;
    Target public target;

    uint256 public constant ETH_FOR_MANIPULATION = 1000 ether;
    uint256 public constant ETH_FOR_LPTOKENS = 1 ether;
    uint256 public constant CURRENT_ETH_PRICE_IN_DOLLARS = 2000;

    function setUp() public {
        target = new Target();
        hack = new Hack(address(target));
    }

    function testPwn() public {
        hack.setUp{value: ETH_FOR_LPTOKENS}();
        hack.pwn{value: ETH_FOR_MANIPULATION}();

        // uint256 hackContractBalance = address(hack).balance;
        // uint256 targetContractBalance = address(target).balance;
        // console.log("hackContractBalance", hackContractBalance, "targetContractBalance", targetContractBalance);
        // uint256 finalProfit = (
        //     (hackContractBalance + targetContractBalance - ETH_FOR_MANIPULATION - ETH_FOR_LPTOKENS)
        //         * CURRENT_ETH_PRICE_IN_DOLLARS
        // ) / 1e18;
        // console.log("Final Profit in Dollars", finalProfit);
    }
}
