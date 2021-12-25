//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./Base.sol";
import "./StableCoin.sol";
import "./Borrowing.sol";
import "./VaultManager.sol";
import "./StabilityPool.sol";

// Holds eth + lusd debt
contract ActivePool is Base {
    StableCoin stableCoin;
    Borrowing borrowing;
    VaultManager vaultManager;
    StabilityPool stabilityPool;

    address payable stabilityPoolPayableAddr;
    uint256 public totalETHDeposited;
    uint256 public totalLUSDDebt;

    constructor() {
        console.log("Deploying ActivePool");
    }

    function initialize(address _nameRgistry) public override {
        Base.initialize(_nameRgistry);

        (address _stableCoin, ) = getContractInfo("StableCoin");
        stableCoin = StableCoin(_stableCoin);

        (address _borrowing, ) = getContractInfo("Borrowing");
        borrowing = Borrowing(_borrowing);

        (address _vaultManager, ) = getContractInfo("VaultManager");
        vaultManager = VaultManager(_vaultManager);

        (address _stabilityPool, ) = getContractInfo("StabilityPool");
        stabilityPoolPayableAddr = payable(_stabilityPool);
        stabilityPool = StabilityPool(stabilityPoolPayableAddr);
    }

    function getETHDeposited() external view returns (uint256) {
        return totalETHDeposited;
    }

    function getLUSDDebt() external view returns (uint256) {
        return totalLUSDDebt;
    }

    function increaseLUSDDebt(uint256 _amount) external {
        require(
            msg.sender == address(stableCoin),
            "ActivePool::increaseLUSDDebt() Invalid StableCoin Contract"
        );
        totalLUSDDebt += _amount;
    }

    function decreaseLUSDDebt(uint256 _amount) external {
        require(
            msg.sender == address(borrowing) ||
                msg.sender == address(vaultManager) ||
                msg.sender == address(stabilityPool),
            "ActivePool: Invalid caller contract"
        );
        totalLUSDDebt -= _amount;
    }

    function sendETH(address _account, uint256 _amount) external {
        require(
            msg.sender == address(borrowing) ||
                msg.sender == address(vaultManager) ||
                msg.sender == address(stabilityPool),
            "ActivePool: Invalid caller contract"
        );
        totalETHDeposited -= _amount;
        (bool success, ) = _account.call{value: _amount}("");
        require(success, "ActivePool::sendETH() Sending eth to Account failed");
    }

    receive() external payable {
        require(
            msg.sender == address(stableCoin),
            "ActivePool::receive() Invalid StableCoin contract"
        );
        totalETHDeposited += msg.value;
        console.log(
            "ActivePool - Contract balance after receiving eth from StableCoin: %s/%s",
            address(this).balance / DECIMAL_PRECISION,
            address(this).balance
        );
    }
}
