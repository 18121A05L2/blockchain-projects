// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DscScript} from "../../script/DeployDsc.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Constants} from "../../script/Constants.c.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Vm} from "forge-std/Vm.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OpenInvariants is StdInvariant, Test, Constants {
    DscScript deployer;
    DSCEngine dscEngine;
    DecentralizedStableCoin dsc;
    HelperConfig helperConfig;
    address weth;
    address wbtc;

    function setUp() external {
        deployer = new DscScript();
        (dsc, dscEngine, helperConfig) = deployer.run();
        (,, weth, wbtc,) = helperConfig.activeNetworkConfig();
        targetContract(address(dscEngine));
    }

    function invariant_totalCollateralAlwaysMustBeGreatherThanDscMinted() public view {
        uint256 totalDscMinted = dsc.totalSupply();
        uint256 totalWethAmount = IERC20(weth).balanceOf(address(dscEngine));
        uint256 totalWbtcAmount = IERC20(wbtc).balanceOf(address(dscEngine));
        uint256 wethInUsd = dscEngine.getUsdValue(weth, totalWethAmount);
        uint256 wbtcInUsd = dscEngine.getUsdValue(wbtc, totalWbtcAmount);
        uint256 totalCollateral = wethInUsd + wbtcInUsd;

        assert(totalCollateral >= totalDscMinted);
    }
}
