// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// contract contract1 {
//     function f() public pure returns (uint256) {
//         return 1;
//     }

//     function g() public pure returns (uint256) {
//         return 2;
//     }

//     function destruct() public {
//         selfdestruct(payable(address(0)));
//     }

//     function deployContract2() public returns (address) {
//         contract2 c2 = new contract2();
//         return address(c2);
//     }
// }

// contract contract2 {}

// contract SameAddressMalicousContract {
//     constructor() {
//         contract1 c1 = new contract1();
//     }

//     // function deploy
// }
