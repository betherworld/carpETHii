pragma solidity ^0.5.0;

/*
Basic contract just to test connection to the blockchain, not really used in the project
*/

contract Greeter {
    string public greeting;

    constructor(string memory _greeting) public {
        greeting = _greeting;
    }

    function setGreeting(string memory _greeting) public {
        greeting = _greeting;
    }

    function greet() public returns (string memory name) {
        return greeting;
    }
}
