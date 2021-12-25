//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./NameRegistry.sol";

contract Base {
    NameRegistry nameRegistry;
    bool initialized = false;

    uint256 public constant ONE_HUNDRED_PERCENT = 1e18; // 100%

    // minimum collateral ratio for individual troves
    uint256 public constant MINIMUN_COLLATERAL_RATIO = 1500000000000000000; // 150%

    // amount of Stable tokens to be locked in the GasPool on opening troves
    uint256 public constant LUSD_GAS_COMPENSATION = 10e18;

    uint256 internal constant DECIMAL_PRECISION = 1e18;
    uint256 public constant BORROWING_FEE_FLOOR =
        (DECIMAL_PRECISION / 1000) * 5; // 0.5% -> 5000000000000000 -> 0.005 (Eth scale)

    uint256 public constant PERCENT_DIVISOR = 200; // dividing by 200 yields 0.5%

    constructor() {}

    function initialize(address _nameRgistry) public virtual onlyOnce {
        nameRegistry = NameRegistry(_nameRgistry);
    }

    function getContractInfo(string memory name)
        public
        view
        returns (address, uint16)
    {
        return nameRegistry.getContractInfo(name);
    }

    modifier onlyOnce() {
        require(initialized == false, "Contract already initialized");
        initialized = true;
        _;
    }
}
