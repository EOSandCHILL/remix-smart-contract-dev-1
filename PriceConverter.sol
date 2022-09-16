// WELCOME TO LIBRARIES!!!

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
            function getPrice() internal view returns (uint256) {
            // to get price we need a chainlink data feed because were interacting with data outside of the blockchain. So we'll need the contracts ABI and the contracts address (0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419) from the ETH/USD data feed via https://docs.chain.link/docs/ethereum-addresses/ ...now we need the ABI so we need to use the concept known as "interface". We can import the interface just like we did with other contracts, directly from github or from an npm (package manager) package. importing from chainlink example: import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; imported @ line 5
            AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
            (/*uint80 roundId*/,int256 price,/*uint startedAt*/,/*uint timeStamp*/,/*uint80 answeredInRound*/) = priceFeed.latestRoundData(); // we only want price. the other variables can be deleted but i commented them out. keep commas! We use int because prices can be negative
            // above is the price of ETH in terms of USD
            return uint256 (price * 1e10); // price feed only has 8 decimal places but we need 18 for wei. so we return uint256 (price * 1e10) so it can match with msg.value
        }

        function getVersion() internal view returns (uint256) {
            AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
            return priceFeed.version();
        }

        function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
            uint256 ethPrice = getPrice(); // capturing get price function into a variable 
            uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // when doing multiplication and division in sol always multiply before you divide! we need to divide by 1e18 because each variable has 18 decimal places so thatd come out to 36 so we have to divide!
            return ethAmountInUsd;
        }
}
