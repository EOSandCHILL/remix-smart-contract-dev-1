// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.8;

import "./PriceConverter.sol";

/*
The goal of this contract is to:
A) Get funds from users
B) Withdraw Funds
C) Set a minimum funding value in USD
*/

contract FundMe { 
    using PriceConverter for uint256;

    uint256 public minimumUSD = 50 * 10 ** 18; // we need to match the standard 18 decimal places

    address[] public funders; // we want to keep track of the acct that fund the contract so well create an array of funders
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;
    
    constructor(){
        owner = msg.sender; // the msg.sender of the constructor function is going to be whomever is deploying the contract or deployed the contract.
    }
    
    // if we want to send funds to a contract we need to make the function "payable"
    function fund() public payable {
        msg.value.getConversionRate(); //<= same as getConversionRate(msg.value)
        require(msg.value.getConversionRate() >= minimumUSD, "Didnt send enough ETH!!!"); 
        //1e18 == 1 * 10 ** 18 == 1000000000000000000 wei == 1 ETH
        funders.push(msg.sender); //msg.sender == the address of whoever calls the fund function
        addressToAmountFunded[msg.sender] = msg.value;
        }

    function withdraw() public {
        
        //for loop structure = starting index, ending index, step amount. this is a way to loop through some type of index object, a range of number, or just do a task a certain amount of times.
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex = funderIndex++) // start funderIndex @ 0 which is first in the array, we want to go the entire length of the array length so add .length method. we want to increase by 1 each loop so add ++ 
        {
             address funder = funders[funderIndex]; //accessing the zeroth element and it should return an address.
             addressToAmountFunded[funder] = 0; // we want to use this to reset our mapping/funders array after withdrawl 
        }
        // reset the array instead of deleting after withdrawl. setting it to zero ensures a new array and also the new keyword deploys and creates a new contract instance.
        funders = new address[](0);
        // how do we actually withdraw the funds and send the funds to whoever is calling this?
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner { //Function Modifiers are used to modify the behaviour of a function.
        require(msg.sender == owner, "Sender is not owner!");
        _; //the contract will execute the modifier 1st and then the rest of the code. the underscore means continue the rest of the code after executing the modifier. So before we withdraw we execute the require statement "msg.sender == owner" first and then call the rest of the code. if the require statement was below the underscore it would tell our function to execute the code before the require statement.
    }
}

/* 
There are 3 different ways to send crpyto via the blockchain: https://solidity-by-example.org/sending-ether/

msg.sender = address but payable(msg.sender) = payable address

transfer => payable (msg.sender).transfer(address(this).balance);
to send ETH we can only work with payable addresses so we add the payable type caster
--the problem with this method is that it is CAPPED @ 2300 GAS! Throws error if failed--

send => bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed");
--the problem with this method is that it is CAPPED @ 2300 GAS! returns bool--

call => 
(bool callSuccess, bytes dataReturned) = payable(msg.sender).call{value: address(this).balance}(""); require(callSuccess, "Call failed");

we will put the function info in parenthesis. this call function returns 2 variables and when 2 variables are returned we can show that by placing them into () on the left hand side. if the function called returns some data or value were gonna need to save that in the dataReturned variable. it will also return a boolean for call success in regard to the function being called succesfully or not. since bytes is an array the data returned needs to be in memory. but were not returning any data this time because were not calling a function so we really just need the callSuccess variable to return true or false.

lower level command thats powerful and can call virtually any function in all of ethereum w/ out having the API. forward all gas or set gas, returns bool.

We want to set it up so that whoever deploys the contract is the owner so we need a constructor! We can also set up some params so that only the owner of the contract can call the withdraw() function! A constructor is the function that gets called immediately whenever you deploy a contract. A Constructor is a special function declared using constructor keyword. It is an optional funtion and is used to initialize state variables of a contract. Since the constructor is called first we can use it set up who the owner of the contract is immediately

after deployement youll notice when you press the owner button that the address is our goerliETH address which is 0x6A3376F34fAa95B8440a86B2eFC0937343A6C6fe

withdraw is orange because were not paying any ETH were gaining ETH (or whatever native blockchain currency)

fund is red because its a payable function

1 press fund
*/ 
