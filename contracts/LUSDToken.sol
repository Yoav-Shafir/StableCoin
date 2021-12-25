//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./Base.sol";
import "./StableCoin.sol";
import "./VaultManager.sol";
import "./StabilityPool.sol";

contract LUSDToken is ERC20, Base {
    StableCoin stableCoin;
    VaultManager vaultManager;
    StabilityPool stabilityPool;

    address payable stabilityPoolPayableAddr;

    constructor() ERC20("LUSDToken", "LUSDToken") {
        console.log("Deploying LUSDToken");
    }

    function initialize(address _nameRgistry) public override {
        Base.initialize(_nameRgistry);

        (address _stableCoin, ) = getContractInfo("StableCoin");
        stableCoin = StableCoin(_stableCoin);

        (address _vaultManager, ) = getContractInfo("VaultManager");
        vaultManager = VaultManager(_vaultManager);

        (address _stabilityPool, ) = getContractInfo("StabilityPool");
        stabilityPoolPayableAddr = payable(_stabilityPool);
        stabilityPool = StabilityPool(stabilityPoolPayableAddr);
    }

    function mint(address _account, uint256 _amount) external {
        require(
            msg.sender == address(stableCoin),
            "LUSDToken: Invalid StableCoin Contract"
        );
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) external {
        require(
            msg.sender == address(stableCoin) ||
                msg.sender == address(vaultManager) ||
                msg.sender == address(stabilityPool),
            "LUSDToken: Invalid Contract contract"
        );
        _burn(_account, _amount);
    }
}
