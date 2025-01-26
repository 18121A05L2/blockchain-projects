// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AirdropToken} from "../src/AirdropToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Console.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    AirdropToken token;
    MerkleAirdrop airdrop;
    address gasPayer;
    address user;
    uint256 userPrivateKey;
    uint256 constant AMOOUNT_TO_CLAIM = 25e18;
    uint256 constant NO_OF_USERS = 4;
    uint256 constant INITIAL_AIRDROP_BALANCE = AMOOUNT_TO_CLAIM * NO_OF_USERS;

    address ANVIL_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32 constant ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 constant PROOF1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 constant PROOF2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] MERKLE_PROOF = [PROOF1, PROOF2];

    function setUp() public {
        (airdrop, token) = new DeployMerkleAirdrop().run();
        vm.prank(ANVIL_ACCOUNT);
        token.mint(address(airdrop), INITIAL_AIRDROP_BALANCE);
        (user, userPrivateKey) = makeAddrAndKey("user");
        (gasPayer) = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        bytes32 digest = airdrop.getSignedMessage(user, AMOOUNT_TO_CLAIM);
        vm.startPrank(user);
        // Sign with the real AIRDRP user
        assertEq(token.balanceOf(user), 0);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        uint256 balanceBefore = token.balanceOf(user);
        vm.stopPrank();

        vm.prank(gasPayer);
        // Claim with Gaspayer
        airdrop.claim(user, AMOOUNT_TO_CLAIM, MERKLE_PROOF, v, r, s);
        uint256 balanceAfter = token.balanceOf(user);
        assertEq(balanceBefore + AMOOUNT_TO_CLAIM, balanceAfter);
    }
}
