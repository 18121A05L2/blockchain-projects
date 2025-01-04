// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library Oraclelib {
    error Oraclelib_staleChainkData();

    uint256 public constant MAX_STALE_TIME = 3 hours;

    function staleCheckForLatestRoundData(AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        (roundId, answer, startedAt, updatedAt, answeredInRound) = priceFeed.latestRoundData();
        uint256 staleTime = block.timestamp - updatedAt;
        if (staleTime > MAX_STALE_TIME) {
            revert Oraclelib_staleChainkData();
        }
    }
}
