//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./Base.sol";
import "./StableCoin.sol";
import "./Borrowing.sol";
import "./SortedVaults.sol";

import {Types} from "../libraries/Types.sol";
import {Enums} from "../libraries/Enums.sol";

contract VaultManager is Base {
    StableCoin stableCoin;
    Borrowing borrowing;
    SortedVaults public sortedVaults;

    uint256 public baseRate;

    mapping(address => Types.Vault) public vaults;

    constructor() Base() {
        console.log("Deploying VaultManager");
    }

    function initialize(address _nameRgistry) public override {
        Base.initialize(_nameRgistry);

        (address _stableCoin, ) = getContractInfo("StableCoin");
        stableCoin = StableCoin(_stableCoin);

        (address _borrowing, ) = getContractInfo("Borrowing");
        borrowing = Borrowing(_borrowing);

        (address _sortedVaults, ) = getContractInfo("SortedVaults");
        sortedVaults = SortedVaults(_sortedVaults);

        baseRate = 0;
    }

    /*
     * Collateral ratio without price => collateral / debt
     *
     * @param
     * @returns
     */
    function getNominalICR(address _borrower) public view returns (uint256) {
        (uint256 currentETH, uint256 currentLUSDDebt) = _getCurrentVaultAmounts(
            _borrower
        );
        if (currentLUSDDebt > 0) {
            return (currentETH * DECIMAL_PRECISION) / currentLUSDDebt;
        } else {
            return 2**256 - 1;
        }
    }

    function _getCurrentVaultAmounts(address _borrower)
        internal
        view
        returns (uint256, uint256)
    {
        uint256 currentETH = vaults[_borrower].collateral;
        uint256 currentLUSDDebt = vaults[_borrower].debt;
        return (currentETH, currentLUSDDebt);
    }

    /*
     * Get borrowing fee in LUSD
     *
     * @param
     * @returns
     */
    function calculateBorrowingFee(uint256 _lusedToBorrow)
        external
        view
        returns (uint256)
    {
        require(
            msg.sender == address(borrowing),
            "VaultManager::getBorrowingFee() Invalid Borrowing Contract"
        );
        console.log("BORROWING_FEE_FLOOR: ", BORROWING_FEE_FLOOR);
        return (baseRate +
            (BORROWING_FEE_FLOOR * _lusedToBorrow) /
            DECIMAL_PRECISION);
    }

    function createVault(
        address _borrower,
        uint256 _ethAmount,
        uint256 _debt
    ) external {
        require(
            msg.sender == address(stableCoin),
            "VaultManager::createVault() Invalid StableCoin Contract"
        );
        vaults[_borrower] = Types.Vault(_ethAmount, _debt, Enums.Status.active);
        sortedVaults.insert(_borrower, getNominalICR(address(_borrower)));
    }

    function getVault(address _borrower)
        external
        view
        returns (Types.Vault memory)
    {
        // TODO: add validation
        return vaults[_borrower];
    }

    function closeVault(address _borrower, Enums.Status _status)
        external
        onlyStableCoinContract
    {
        vaults[_borrower].status = _status;
        vaults[_borrower].collateral = 0;
        vaults[_borrower].debt = 0;

        sortedVaults.remove(_borrower);
    }

    modifier onlyStableCoinContract() {
        require(
            msg.sender == address(stableCoin),
            "VaultManager: Invalid StableCoind Contract"
        );
        _;
    }

    // function _calcBorrowingFee(uint256 _borrowingRate, uint256 _lusdDebt)
    //     internal
    //     pure
    //     returns (uint256)
    // {
    //     return (_borrowingRate * _lusdDebt) / DECIMAL_PRECISION;
    // }

    // function getBorrowingRate() public view returns (uint256) {
    //     return _calcBorrowingRate(baseRate);
    // }

    // function _calcBorrowingRate(uint256 _baseRate)
    //     internal
    //     pure
    //     returns (uint256)
    // {
    //     return
    //         LiquityMath._min(
    //             BORROWING_FEE_FLOOR + _baseRate,
    //             MAX_BORROWING_FEE
    //         );
    // }

    // function getNominalICR(address _nextId) external view returns (uint256) {
    //     return 1;
    // }
}
