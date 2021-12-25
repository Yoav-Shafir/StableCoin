//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./Base.sol";
import "./StableCoin.sol";
import "./VaultManager.sol";

// Holds borrowing fees rewards + Redemption fees rewards
contract StakingPool is Base {
    StableCoin stableCoin;
    VaultManager vaultManager;

    uint256 public totalLUSDees; // on borrowing
    uint256 public totalETHFees; // on redemption

    constructor() Base() {
        console.log("Deploying StakingPool");
    }

    function initialize(address _nameRgistry) public override {
        Base.initialize(_nameRgistry);

        (address _stableCoin, ) = getContractInfo("StableCoin");
        stableCoin = StableCoin(_stableCoin);

        (address _vaultManager, ) = getContractInfo("VaultManager");
        vaultManager = VaultManager(_vaultManager);
    }

    function increaseLUSDFees(uint256 _amount) external onlyStableCoinContract {
        totalLUSDees += _amount;
    }

    function increaseETHFees(uint256 _amount) external {
        totalETHFees += _amount;
    }

    modifier onlyStableCoinContract() {
        require(
            msg.sender == address(stableCoin),
            "StakingPool: Invalid StableCoin Contract"
        );
        _;
    }

    modifier onlyVaultManagerContract() {
        require(
            msg.sender == address(vaultManager),
            "StakingPool: Invalid VaultManager contract"
        );
        _;
    }
}
