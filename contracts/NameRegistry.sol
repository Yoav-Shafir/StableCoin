//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract NameRegistry {
    constructor() {
        console.log("Deploying NameRegistry");
    }

    // Manages info about the contract info
    struct ContractInfo {
        address owner;
        address contractAddress;
        // The first version added to registry must be >= 1
        // Otherwise the name will not be added
        uint16 version;
    }

    mapping(string => ContractInfo) public nameInfo;

    // Adds the version of the contract to be used by apps
    function registerName(
        string memory name,
        address contractAddress,
        uint16 version
    ) public returns (bool) {
        require(version > 0, "NameRegistry: Version must start with number 1");

        ContractInfo memory contractInfo = nameInfo[name];

        if (contractInfo.contractAddress == address(0)) {
            nameInfo[name] = ContractInfo(msg.sender, contractAddress, version);
        } else {
            if (contractInfo.owner != msg.sender) return false;
            contractInfo.contractAddress = contractAddress;
            contractInfo.version = version;
        }
        return true;
    }

    // Contracts having a dependency on this contract will invoke this function
    function getContractInfo(string memory name)
        public
        view
        returns (address, uint16)
    {
        return (nameInfo[name].contractAddress, nameInfo[name].version);
    }
}
