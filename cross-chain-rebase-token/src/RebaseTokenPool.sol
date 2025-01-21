// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {TokenPool, IERC20} from "@ccip/src/v0.8/ccip/pools/TokenPool.sol";
import {IRMN} from "@ccip/src/v0.8/ccip/interfaces/IRMN.sol";
import {IRouter} from "@ccip/src/v0.8/ccip/interfaces/IRouter.sol";
import {Pool} from "@ccip/src/v0.8/ccip/libraries/Pool.sol";
import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

contract RebaseTokenPool is TokenPool {
    constructor(IERC20 token, address[] memory allowlist, address rmnProxy, address router)
        TokenPool(token, allowlist, rmnProxy, router)
    {}

    function lockOrBurn(Pool.LockOrBurnInV1 calldata lockOrBurnIn)
        external
        returns (Pool.LockOrBurnOutV1 memory lockOrBurnOut)
    {
        _validateLockOrBurn(lockOrBurnIn);
        // address originalSender = abi.decode(lockOrBurnIn.originalSender, (address));
        // we are sending this interest rate to other chain so that use can gain interest on other chain too
        uint256 userInterestRate = IRebaseToken(address(i_token)).getUserInterestRate(lockOrBurnIn.originalSender);
        // IRebaseToken(address(i_token)).burn(address(this),lockOrBurnIn.amount);
        lockOrBurnOut = Pool.LockOrBurnOutV1({
            destTokenAddress: getRemoteToken(lockOrBurnIn.remoteChainSelector),
            destPoolData: abi.encode(userInterestRate)
        });
    }

    function releaseOrMint(Pool.ReleaseOrMintInV1 calldata releaseOrMintIn)
        external
        returns (Pool.ReleaseOrMintOutV1 memory)
    {
        _validateReleaseOrMint(releaseOrMintIn);
        uint256 userInterestRate = abi.decode(releaseOrMintIn.sourcePoolData, (uint256));
        IRebaseToken(address(i_token)).mint(releaseOrMintIn.receiver, releaseOrMintIn.amount, userInterestRate);
        return Pool.ReleaseOrMintOutV1({destinationAmount: releaseOrMintIn.amount});
    }
}
