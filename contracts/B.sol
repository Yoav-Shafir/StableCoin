//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./NameRegistry.sol";
import "./A.sol";

contract B {
    address nameRegistryAddress;

    constructor(address _nameRegistryAddress) {
        console.log("Deploying B");

        nameRegistryAddress = _nameRegistryAddress;
    }

    function foo() external {
        (address aAddress, uint16 version) = NameRegistry(nameRegistryAddress)
            .getContractInfo("A");
        A(aAddress).bar();
    }
}
