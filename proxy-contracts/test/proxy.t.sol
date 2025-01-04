// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Proxy} from "../src/Proxy.sol";
import {DeployProxy} from "../script/DeployProxy.s.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Console.sol";
import {Implementation} from "../src/Implementation.sol";
import {DeployImplementation} from "../script/DeployImplementation.s.sol";
import {BytesLib} from "../src/libraries.l.sol";

contract ProxyTest is Test {
    using BytesLib for bytes;

    Proxy proxy;
    Implementation implementation;

    function setUp() public {
        // do nothing
        DeployProxy deployProxy = new DeployProxy();
        proxy = deployProxy.run();
        DeployImplementation deployImplementation = new DeployImplementation();
        implementation = deployImplementation.run();
    }

    // function testBaseProxyFallback() public {
    //     assertEq(100, proxy.testNumber());
    //     assertEq(0, proxy.fallbackNumber());

    //     // if msg.data is empty receive function triggers
    //     (bool success,) = payable(address(proxy)).call{value: 100}("");
    //     assertEq(success, true);
    //     assertEq(33, proxy.fallbackNumber());
    //     assertEq(address(proxy).balance, 100 wei);

    //     // if msg.data is not empty fallback function will trigger
    //     (bool success2,) = payable(address(proxy)).call{value: 100}("0x1234");
    //     assertEq(success2, true);
    //     assertEq(22, proxy.fallbackNumber());
    //     assertEq(address(proxy).balance, 200 wei);
    // }

    // function testNotExistedFuntion() public {
    //     assertEq(0, proxy.fallbackNumber());
    //     // delegatecall executes code in the context of the caller, not the callee. In this case, Proxy’s storage would not be affected
    //     // (bool success,) = address(proxy).delegatecall(abi.encodeWithSignature("Hello()"));
    //     (bool success,) = address(proxy).call(abi.encodeWithSignature("Hello()"));
    //     assertEq(success, true);
    //     assertEq(22, proxy.fallbackNumber());
    // }

    function testImplementationThroughProxy() public {
        proxy.setImplementation(address(implementation));
        address _impl = proxy.implementationAddress();
        assertEq(address(implementation), _impl);
        vm.roll(block.number + 4);
        vm.warp(block.timestamp + 1000);
        // NOTE : This was not able to get implemetation address
        // (bool success, bytes memory data) = address(proxy).delegatecall(abi.encodeWithSignature("getNumber()"));
        // assertEq(success, true);
        // assertEq(implementation.getNumber(), data.toUint256());

        uint256 testNumber = Implementation(address(proxy)).getNumber();
        assertEq(implementation.getNumber(), testNumber);
    }

    function testImplementaionConstructor() public view {
        assertEq(implementation.getConstructorNumber(), 10);
        uint256 getIndexZero = proxy.loadStorage(103);
        assertEq(getIndexZero, 10);
    }
}
