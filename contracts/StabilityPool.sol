//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./Base.sol";
import "./StableCoin.sol";
import "./LUSDToken.sol";
import "./VaultManager.sol";
import "./StabilityPool.sol";

// Holds LUSD Deposited + eth liquidated
contract StabilityPool is Base {
    StableCoin stableCoin;
    LUSDToken public lusdToken;
    VaultManager vaultManager;

    uint256 internal totalETHDeposited;
    uint256 internal totalLUSDDeposits;

    mapping(address => uint256) public deposits; // depositor address -> total deposits

    constructor() {
        console.log("Deploying StabilityPool");
    }

    function initialize(address _nameRgistry) public override {
        Base.initialize(_nameRgistry);

        (address _stableCoin, ) = getContractInfo("StableCoin");
        stableCoin = StableCoin(_stableCoin);

        (address _lusdToken, ) = getContractInfo("LUSDToken");
        lusdToken = LUSDToken(_lusdToken);

        (address _vaultManager, ) = getContractInfo("VaultManager");
        vaultManager = VaultManager(_vaultManager);
    }

    // StabilityPool providers need to be able to deposit LUSD into this contract
    function deposit(address _depositor, uint256 _lusdAmount) external {
        console.log("======================");
        console.log("_depositor %s", _depositor);
        console.log("_lusdAmount: ", _lusdAmount);
        console.log("address(this): ", address(this));
        require(
            msg.sender == address(stableCoin),
            "StabilityPool - Invalid StableCoin contract"
        );
        deposits[_depositor] = deposits[_depositor] + _lusdAmount;

        // update deposits
        totalLUSDDeposits += _lusdAmount;

        // transfer LUSD
        lusdToken.transferFrom(_depositor, address(this), _lusdAmount);
    }

    function offset(uint256 _lusdDebt) external {
        require(
            msg.sender == address(vaultManager),
            "StabilityPool::offset() Invalid VaultManager contract"
        );
        // decrease debt
        totalLUSDDeposits -= _lusdDebt;

        // burn LUSD
        lusdToken.burn(address(this), _lusdDebt);
    }

    // Getters
    function getETHDeposited() external view returns (uint256) {
        return totalETHDeposited;
    }

    function getTotalLUSDDeposits() external view returns (uint256) {
        return totalLUSDDeposits;
    }

    receive() external payable {
        require(
            msg.sender == address(stableCoin),
            "ActivePool::receive() Invalid StableCoin Contract"
        );
        totalETHDeposited += msg.value;
        console.log(
            "VaultManager - Contract balance after receiving eth from StableCoin: ",
            address(this).balance
        );
    }
}
