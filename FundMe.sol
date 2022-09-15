// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/*
The goal of this contract is to:
A) Get funds from users
B) Withdraw Funds
C) Set a minimum funding value in USD
*/

        // first we want to be able to set a min fund amount in usd
        // lets explore how to send ETH to this contract for funding
        // every transaction should include: nonce, gas price, gas limit, to, value, data and v, r, s

contract FundMe { 
    // how do we check if msg.value is greater than the USD equivalent? we need to set the min usd value we want sent along with the fund function. But value refers to ETH and minimumUSD refers to USD so we need an oracle like chainlink to convert the data!

    uint256 public minimumUSD = 50; 
    
    // if we want to send funds to a contract we need to make the function "payable"
    function fund() public payable {
        // if we want someone to send a min amount of funds before executing a function we need to add the require function. require is also known as a checker. this function requires 1 eth so is the value being sent greater than 1 eth?
        require(msg.value >= minimumUSD, "Didnt send enough ETH!!!"); // "msg" is a global keyword in sol. "msg.value" retrieves how much value someone is sending. require() will check if the right amount was sent. if the amount was not enough revert and send message "Didnt send enough ETH!!!". Revert undos any actions that happened before the requirement was not met and sends remaining gas back
        //1e18 == 1 * 10 ** 18 == 1000000000000000000 wei == 1 ETH
        }

        function getPrice() public view {
            // to get price we need a chainlink data feed because were interacting with data outside of the blockchain. So we'll need the contracts ABI and the contracts address (0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419) from the ETH/USD data feed via https://docs.chain.link/docs/ethereum-addresses/ ...now we need the ABI so we need to use the concept known as "interface". We can import the interface just like we did with other contracts, directly from github or from an npm (package manager) package. importing from chainlink example: import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; imported @ line 5
            AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
            (/*uint80 roundId*/,int price, /*uint startedAt*/, /*uint timeStamp*/, /*uint80 answeredInRound*/) = priceFeed.latestRoundData(); // we only want price. the other variables can be deleted but i commented them out. keep commas!
            // above is the price of ETH in terms of USD
        }

        function getVersion() public view returns (uint256) {
            AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
            return priceFeed.version();
        }

        function getConversionRate() public {}

    //function withdraw() {

    // }
}

/*
Oracle notes:
smart contracts cant connect with external systems, data feeds, APIs, existing payment systems or off-chain resources on their own so we need oracles! blockchains are deterministic by design so all the nodes can reach consensus. different data will cause the nodes to not reach consensus.
blockchain oracles like chainlink interact with real world off chain data and brings that external data or computation to smart contracts. we could use a centralized server but we know the issues with that. 

- Chainlink VRF (Verifiable Random Function) is a provably fair and verifiable random number generator (RNG) that enables smart contracts to access random values without compromising security or usability. So when you see nfts that mint random features this is most likely what theyre using to create that randomness. 

- Chainlink Keepers enable conditional execution of your smart contracts functions through a hyper-reliable and decentralized automation platform that uses the same external network of node operators that secures billions in value. Theyre constantly listening for triggers to execute an action. example if you want your defi pool to change roi once and certain level of funds are staked you will need keepers to listen for that event and trigger the next event.

- Connecting to any API with Chainlink enables your contracts to access to any external data source through our decentralized oracle network. GET REQUEST allows devs to make HTTP GET requests to external APIs from smart contracts, using Chainlink's Request & Receive Data cycle.
*/
