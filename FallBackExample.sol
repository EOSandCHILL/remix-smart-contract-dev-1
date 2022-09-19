// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FallBackExample {
    uint256 public result;

    receive() external payable { //we dont add the function keyword because solidity knows its a special function
        result = 1;
    }
    fallback() external payable {
            result = 2;
        }
}

/*
Solidity special functions:

recieve()
fallback()

Solidity 0.6.x introduced the receive keyword in order to make contracts more explicit when their fallback functions are called. The receive method is used as a fallback function in a contract and is called when ETH is sent to a contract with NO CALLDATA. If  the receive method does not exist, it will use the fallback function.

As long as theres no data associated with the transaction the receive function will get triggered. the recieve function is triggered anytime we send a transaction to this contract and we dont specify a function and keep the call data blank. if we add call data to the transaction we get an error that fallback function is not defined and this is because whnever data is sent with a transaction solidity knows youre not looking for receive youre looking for another function so it looks for the function. If that function cant be found it looks for a fallback function. if the fallback function isnt defined we get the error "fallback function is not defined"

The fallback function CAN work even when dayta is sent along with the transaction. we also do not need to call fallback a function because solidity knows its a special keyword/function. now if we deploy a new contract with a fallback function and hit transact with data our transaction works because solidity now has a fallback function to refer to.

the "Low Level interaction" area allows us to send ETH directly to test functions. if we initially hit result the output will be 0 but if we hit transact in the "Low Level interaction" area we will create a fake transaction and the result will then change to whatever the variable is equal to which is 1 in this case. 

More on receive() or fallback() below: 
   
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

*/
