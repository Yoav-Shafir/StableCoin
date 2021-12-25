//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address private bankContract;
    
    constructor(address _bankAddress) ERC20("Yield Token", "YTK") {
        console.log("Deploying Token with bank address", _bankAddress);
        bankContract = _bankAddress;
    }

    function mint(address to, uint256 amount) public onlyBank {
        _mint(to, amount);
    }

    modifier onlyBank() {
        require(
            msg.sender == bankContract,
            "Only the bank can mint new Tokens."
        );
        _;
    }
}
