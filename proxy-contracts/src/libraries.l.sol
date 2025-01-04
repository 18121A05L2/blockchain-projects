//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library BytesLib {
    function toUint256(bytes memory b) internal pure returns (uint256) {
        require(b.length >= 32, "Insufficient bytes length");
        uint256 latestNumber;
        assembly {
            latestNumber := mload(add(b, 0x20))
        }
        return latestNumber;
    }
}
