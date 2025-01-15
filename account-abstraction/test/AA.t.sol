// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {DeployAccountAbstraction} from "../script/DeployAccountAbstraction.sol";
import {HelperConfig} from "../script/HelperConfig.sol";
import {AccountAbstraction} from "../src/Ethereum/AccountAbstraction.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract TestAccountAbstraction is Test {
    address account;
    address entrypoint;
    AccountAbstraction accountAbstraction;
    HelperConfig helperConfig;
    ERC20Mock usdc;

    function setUp() external {
        (accountAbstraction, helperConfig) = new DeployAccountAbstraction().run();
        (account, entrypoint,) = helperConfig.activeNetworkConfig();
        usdc = new ERC20Mock();
    }

    function testMinimalAccountWithOwner() external {
        assertEq(usdc.balanceOf(address(accountAbstraction)), 0);
        uint256 amountToTransfer = 1e18;
        vm.prank(account);
        accountAbstraction.execute(
            address(usdc),
            0,
            abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstraction), amountToTransfer)
        );
        assertEq(usdc.balanceOf(address(accountAbstraction)), amountToTransfer);
    }

    function testValidateUserOps() external {
        vm.startPrank(entrypoint);
        accountAbstraction.validateUserOp();
    }
}
