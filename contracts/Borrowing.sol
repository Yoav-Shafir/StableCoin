//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./Base.sol";
import "./StableCoin.sol";
import "./PriceFeed.sol";
import "./VaultManager.sol";

import {Types} from "../libraries/Types.sol";

contract Borrowing is Base {
    StableCoin stableCoin;
    PriceFeed priceFeed;
    VaultManager vaultManager;

    address activePoolAddress;

    constructor() Base() {
        console.log("Deploying Borrowing");
    }

    function initialize(address _nameRgistry) public override {
        Base.initialize(_nameRgistry);

        (address _stableCoin, ) = getContractInfo("StableCoin");
        stableCoin = StableCoin(_stableCoin);

        (address _priceFeed, ) = getContractInfo("PriceFeed");
        priceFeed = PriceFeed(_priceFeed);

        (address _vaultManager, ) = getContractInfo("VaultManager");
        vaultManager = VaultManager(_vaultManager);
    }

    function calculateLoanValues(
        uint256 _ethAmount,
        uint256 _borrowingRequestedAmount
    ) external view returns (Types.LoanValues memory) {
        console.log(
            "Borrowing - ETH/Wei sent: %s/%s",
            _ethAmount / 1e18,
            _ethAmount
        );

        uint256 borrowingRequestedAmount = _borrowingRequestedAmount *
            DECIMAL_PRECISION;
        console.log(
            "Borrowing - LUSD asked to borrow/lusedToBorrow : %s/%s",
            _borrowingRequestedAmount,
            borrowingRequestedAmount
        );

        uint256 ethPrice = priceFeed.getEthPrice();
        console.log(
            "Borrowing - Current Eth price %s/%s",
            ethPrice / 1e18,
            ethPrice
        );

        uint256 collateralRatio = (_ethAmount * ethPrice) /
            borrowingRequestedAmount;
        console.log(
            "Borrowing - Collateral ratio -> (_ethAmount * ethPrice) / borrowingRequestedAmount, %s%:",
            collateralRatio
        );

        require(
            collateralRatio >= MINIMUN_COLLATERAL_RATIO,
            "Borrowing: Invalid collateral ratio"
        );

        // TODO: can we move vaultManager outside to StbleCoin?
        // calculate borrowing fee -> 0.5% + base rate of the lusedToBorrow
        uint256 borrowingFee = vaultManager.calculateBorrowingFee(
            borrowingRequestedAmount
        );
        console.log("Borrowing - borrowingFee %s", borrowingFee);

        // calculate composite debt (borrowing fee + Gas compansation + amount requested)
        uint256 borrowingCompositeDebt = borrowingFee +
            borrowingRequestedAmount +
            LUSD_GAS_COMPENSATION;
        console.log(
            "Borrowing - borrowingCompositeDebt %s",
            borrowingCompositeDebt
        );

        return
            Types.LoanValues(
                ethPrice,
                collateralRatio,
                borrowingFee,
                borrowingRequestedAmount,
                borrowingCompositeDebt
            );
    }
}
