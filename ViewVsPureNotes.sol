/* View vs Pure Functions
view functions can read data from the blockchain
pure functions cannot read data from the blockchain */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.8;

contract  ViewAndPureFunctions {
    uint256 public num;

    function viewFunc() external view returns (uint256) {
        return num;
        // this is a view function because it doesnt modify any state variables (num) or write anything to the blockchain. this is also known as a READ ONLY FUNCTION. it only reads data from the blockchain via the variable "num".
    }

    function pureFunc() external pure returns (uint256) {
        return 1;
        // this is a pure function because it doesnt modify any state variables or write anything to the blockchain. this is also known as a READ ONLY FUNCTION. pure functions CANNOT reads data from the blockchain.
    }

    function addToNum(uint x) external view returns (uint) {
        return num + x; // <- i know this is a "view" function because it DOES READ the state variable num and then adds x to it
    }

    function add(uint x, uint y) external pure returns (uint) {
        return x + y; // <- i know this is a "pure" function because it DOES NOT READ the state variable num. it only adds x to y.
    }
}
