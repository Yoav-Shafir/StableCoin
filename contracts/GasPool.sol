//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./Base.sol";
import "./LUSDToken.sol";

contract GasPool is Base {
    LUSDToken lusdToken;

    constructor() {
        console.log("Deploying GasPool");
    }

    function initialize(address _nameRgistry) public override {
        Base.initialize(_nameRgistry);

        (address _lusdToken, ) = getContractInfo("LUSDToken");
        lusdToken = LUSDToken(_lusdToken);
    }

    function approveSpender(address _spender, uint256 _amount) external {
        lusdToken.approve(_spender, _amount);
    }
}
