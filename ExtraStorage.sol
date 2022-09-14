// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "./SimpleStorage.sol";

contract ExtraStorage is SimpleStorage {
    // The "is" keyword (above) allows inheritance to take place. all the functions from SimpleStorage is now in the ExtraStorage contract.
    // in this contract we want to the storage function to add 5 to any number we give the contract so we need to overide the original function.. you cant just override the parent function... we need to perform a "virtual override" 
    /* function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber + 5; <- this will not work because we need to overide the parent function */ 
        function store(uint256 _favoriteNumber) public override { // <- override added now we can overide the parent function
        favoriteNumber = _favoriteNumber + 5;
    }
}
