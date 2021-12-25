//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./NameRegistry.sol";
import "./B.sol";

contract A {
    address nameRegistryAddress;

    constructor(address _nameRegistryAddress) {
        console.log("Deploying A");

        nameRegistryAddress = _nameRegistryAddress;
    }

    function bar() external {
        (address bAddress, uint16 version) = NameRegistry(nameRegistryAddress)
            .getContractInfo("B");
        console.log("bar() bAddress: ", bAddress);
        console.log("bar() msg.sender: ", msg.sender);
        // console.log("version: ", nr.address);
        // address b = nameRegistry.getContractInfo("B");
    }
}
