//SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// Inside Function
// Checks
// Effects
// Interactions

pragma solidity ^0.8.0;

import {ERC20, ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DecentralizedStableCoin
 * @author Lakshmi Sanikommu
 * @notice This contract has the ability to mint and burn tokens
 */
contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    error DecentralizedStableCoin_mustBeMoreThanZero(uint256 _amount);
    error DecentralizedStableCoin_mustOwnToBurn();
    error DecentralizedStableCoin_notZeroAddress();

    constructor() ERC20("DecentralizedStableCoin", "DSC") Ownable(msg.sender) {}

    function burn(uint256 _amount) public override {
        if (_amount < 0) {
            revert DecentralizedStableCoin_mustBeMoreThanZero(_amount);
        }

        if (_amount > balanceOf(msg.sender)) {
            revert DecentralizedStableCoin_mustOwnToBurn();
        }

        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) public returns (bool) {
        if (_to == address(0)) {
            revert DecentralizedStableCoin_notZeroAddress();
        }
        if (_amount < 0) {
            revert DecentralizedStableCoin_mustBeMoreThanZero(_amount);
        }

        _mint(_to, _amount);
        return true;
    }
}
