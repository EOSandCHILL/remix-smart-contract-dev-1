// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.8;

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
    //function withdraw() {}
}

/*
Oracle notes:
smart contracts cant connect with external systems, data feeds, APIs, existing payment systems or off-chain resources on their own so we need oracles! blockchains are deterministic by design so all the nodes can reach consensus. different data will cause the nodes to not reach consensus.

blockchain oracles like chainlink interact with real world off chain data and brings that external data or computation to smart contracts. we could use a centralized server but we know the issues with that. 
*/
