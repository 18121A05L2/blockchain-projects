// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Target, Hack} from "./ready-only-reentrancy.sol";
import {ICurve, IERC20} from "./interfaces.sol";

contract ReadOnlyReentrancyTest is Test {
    Target public target;
    Hack public hack;
    ICurve public constant curve = ICurve(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022); // STETH_POOL
    IERC20 public constant lp = IERC20(0x06325440D014e39736583c165C2963BA99fAf14E); // LP token

    address public constant alice = address(0x1);
    uint256 public constant INITIAL_BALANCE = 100 ether;

    function setUp() public {
        // Deploy the target contract
        target = new Target();
        // Deploy the hack contract
        hack = new Hack(address(target));

        // Fund alice with some ETH
        vm.deal(alice, INITIAL_BALANCE);
    }

    function testStaking() public {
        // Setup initial state
        vm.startPrank(alice);

        // Add liquidity to get LP tokens
        uint256[2] memory amounts = [uint256(10 ether), 0];
        uint256 lpTokens = curve.add_liquidity{value: 10 ether}(amounts, 1);

        // Approve target contract to spend LP tokens
        lp.approve(address(target), lpTokens);

        // Stake LP tokens
        target.stake(lpTokens);

        // Verify staking
        assertEq(target.lpTokenBalance(alice), lpTokens, "LP token balance should match staked amount");
        vm.stopPrank();
    }

    function testUnstaking() public {
        // Setup initial state
        vm.startPrank(alice);
        uint256[2] memory amounts = [uint256(10 ether), 0];
        uint256 lpTokens = curve.add_liquidity{value: 10 ether}(amounts, 1);
        lp.approve(address(target), lpTokens);
        target.stake(lpTokens);

        // Unstake LP tokens
        target.unstake(lpTokens);

        // Verify unstaking
        assertEq(target.lpTokenBalance(alice), 0, "LP token balance should be zero after unstaking");
        vm.stopPrank();
    }

    function testGetReward() public {
        // Setup initial state
        vm.startPrank(alice);
        uint256[2] memory amounts = [uint256(10 ether), 0];
        uint256 lpTokens = curve.add_liquidity{value: 10 ether}(amounts, 1);
        lp.approve(address(target), lpTokens);
        target.stake(lpTokens);

        // Get reward
        uint256 reward = target.getReward();

        // Verify reward calculation
        uint256 expectedReward = (lpTokens * curve.get_virtual_price()) / 1e18;
        assertEq(reward, expectedReward, "Reward calculation should match expected value");
        vm.stopPrank();
    }

    function testHackSetUp() public {
        uint256 amount = 10 ether;
        vm.deal(address(hack), amount);

        // Call setUp on hack contract
        hack.setUp{value: amount}();

        // Verify hack contract's stake in target
        assertTrue(target.lpTokenBalance(address(hack)) > 0, "Hack contract should have staked LP tokens");
    }

    function testHackPwn() public {
        uint256 amount = 10 ether;
        vm.deal(address(hack), amount * 2); // Need extra ETH for pwn

        // Setup initial state
        hack.setUp{value: amount}();

        // Store initial values
        uint256 initialVirtualPrice = curve.get_virtual_price();

        // Execute attack
        hack.pwn{value: amount}();

        // Verify attack impact
        uint256 finalVirtualPrice = curve.get_virtual_price();
        assertTrue(finalVirtualPrice != initialVirtualPrice, "Virtual price should change after attack");
    }

    function testFailUnauthorizedUnstake() public {
        uint256 amount = 10 ether;
        vm.deal(address(hack), amount);

        // Setup initial state
        hack.setUp{value: amount}();

        // Try to unstake from unauthorized address
        vm.prank(alice);
        vm.expectRevert();
        target.unstake(amount);
    }
}
