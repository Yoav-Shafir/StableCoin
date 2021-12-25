//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";

contract Bank {
    mapping(address => uint256) public accounts;

    constructor() {
        console.log("Deploying Bank");
    }

    function totalAssets() external view returns (uint256) {
        return address(this).balance;
    }

    function deposit() external payable {
        require(msg.value > 0, "Must deposit more than 0 MATIC");
        accounts[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount, address _tokenContract) external {
        require(_amount <= accounts[msg.sender], "Insufficient Funds");

        accounts[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);

        Token yieldToken = Token(_tokenContract);
        yieldToken.mint(msg.sender, 1 ether);
    }
}
