// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
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

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}

/*
Notes: 

When you have variables that are only used once or set once there are tools to make them more gas efficient! the owner and minimumUsd variables are set one time so lets make that more efficient with solidity tools! two tips/tools to bring down the gas costs are the "constant" and the "immutable" keywords! constant variables have to be constant at compile time and it has to be assigned where the variable is declared! since minimumUsd will always be $50 in ETH it can be constant. Adding the constant keyword allows for minimumUsd to no longer use storage which makes it easier to read which in return reduces gas costs! Also constant variables should be capitalized for example we should change the variable minimumUsd => MINIMUM_USD (all caps with underscores).

Variables that are set once but are also set outside of the same line theyre declared on can take on the "immutable" keyword! For example we set the "owner" variable inside the constructor but it was declared outside of that constructor @ address public owner;
a good way to name immutable variables is with an "i_" like: "i_owner" and the immutable keyword also helps with gas fees/prices just like constant!

Both of these keywords save gas because instead of storing these variables inside of a storage slot we actually store them directly into the bytecode of the contract! 

original code below:

contract FundMe {
    using PriceConverter for uint256;

    uint public minimumUsd = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;
    constructor() {
        owner = msg.sender;
    }
}

We can also make this contract more gas efficient by updating our "require" keywords! in the code below we have to store the string "Sender is not owner!" as a string array. every character in the error log has to be stored individually which is a lot of storage! since the release of 0.8.4 we can now do custom errors for our reverts. We can declare them at the top using if statements instead of require and then add revert statements. this saves a lot of gas! Notice that "NotOwner()" is actually outside of the contract! we changed our require message on line 36 to if our msg.sender does not equal variable i_owner then revert with a non owner error which is "NotOwner()" on line 7! This saves us gas since we dont have to store and emit such a long string. the revert does the same thing as the require but without the conditional beforehand.

Great example of require => if below:

original version:

modifier onlyOwner {
    require(msg.sender == i_owner, "Sender is not owner!");
    _;

refactored version:

modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
}

Solidity special functions:

recieve()
fallback()

Solidity 0.6.x introduced the receive keyword in order to make contracts more explicit when their fallback functions are called. The receive method is used as a fallback function in a contract and is called when ether is sent to a contract with no calldata. If the receive method does not exist, it will use the fallback function.

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

So how can we use this in our FundMe contract? we can add receive() and fallback() just in case someone sends us contract money instead of calling the fund function properly! if someone accidentally sneds money we can still process the transaction by having it automatically calling the fund function and the same goes for the fallback function. Now that this is set up if someone accidentally sends us money wothout calling the fund function the money will still route them over to our fund function. This also means if someone does not send us enough money the transaction will still get reverted!

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

*/
