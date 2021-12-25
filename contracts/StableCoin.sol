//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./Base.sol";
import "./PriceFeed.sol";
import "./Borrowing.sol";
import "./VaultManager.sol";
import "./GasPool.sol";
import "./StakingPool.sol";
import "./ActivePool.sol";
import "./StabilityPool.sol";
import "./LUSDToken.sol";
import "./LiquityMath.sol";

import {Types} from "../libraries/Types.sol";
import {Enums} from "../libraries/Enums.sol";

contract StableCoin is Base {
    PriceFeed priceFeed;
    Borrowing borrowing;
    VaultManager vaultManager;
    GasPool gasPool;
    StakingPool stakingPool;
    ActivePool activePool;
    StabilityPool stabilityPool;
    LUSDToken lusdToken;

    address payable activePoolPayableAddr;
    address payable stabilityPoolPayableAddr;

    constructor() {
        console.log("Deploying StableCoin");
    }

    function initialize(address _nameRgistry) public override {
        Base.initialize(_nameRgistry);

        (address _priceFeed, ) = getContractInfo("PriceFeed");
        priceFeed = PriceFeed(_priceFeed);

        (address _borrowing, ) = getContractInfo("Borrowing");
        borrowing = Borrowing(_borrowing);

        (address _vaultManager, ) = getContractInfo("VaultManager");
        vaultManager = VaultManager(_vaultManager);

        (address _gasPool, ) = getContractInfo("GasPool");
        gasPool = GasPool(_gasPool);

        (address _stakingPool, ) = getContractInfo("StakingPool");
        stakingPool = StakingPool(_stakingPool);

        (address _activePool, ) = getContractInfo("ActivePool");
        activePoolPayableAddr = payable(_activePool);
        activePool = ActivePool(activePoolPayableAddr);

        (address _stabilityPool, ) = getContractInfo("StabilityPool");
        stabilityPoolPayableAddr = payable(_stabilityPool);
        stabilityPool = StabilityPool(stabilityPoolPayableAddr);

        (address _lusdToken, ) = getContractInfo("LUSDToken");
        lusdToken = LUSDToken(_lusdToken);

        // gasPool.approveSpender(vaultManager.address, 2**256-1);
    }

    function borrow(uint256 _borrowingRequestedAmount) external payable {
        Types.LoanValues memory loanInfo = borrowing.calculateLoanValues(
            msg.value,
            _borrowingRequestedAmount
        );

        /* -------------------------------------------------------------------------- */
        /*                                 StakingPool                                */
        /* -------------------------------------------------------------------------- */

        // Mint amount of Stable coins equal to the calculated `borrowingFee` (0.5%) added
        // to the user's borrowing requested amount and assign them to the StakingPool.
        // e.g for borrowing 100 Stable coins (100000000000000000000),
        // then 0.5% (5000000000000000) `borrowingFee` will be equal to 500000000000000000.
        // These fees are distributed between staketrs TODO:// when?
        lusdToken.mint(address(stakingPool), loanInfo.borrowingFee);
        stakingPool.increaseLUSDFees(loanInfo.borrowingFee);

        console.log(
            "StableCoin - StakingPool balance after minting `borrowingFee`: %s",
            lusdToken.balanceOf(address(stakingPool))
        );

        /* -------------------------------------------------------------------------- */
        /*                                  Borrower                                  */
        /* -------------------------------------------------------------------------- */

        // Mint amount of Stable coins equal to the `borrowingRequestedAmount`
        // and assign them to the user(borrower) account.
        lusdToken.mint(msg.sender, loanInfo.borrowingRequestedAmount);
        console.log(
            "StableCoin - Borrower after minting `borrowingRequestedAmount`: ",
            lusdToken.balanceOf(msg.sender)
        );

        console.log(
            "StableCoin - Creating new vault using the borrower's requested loan info, borrower: %s, collateral(eth sent) %s/%s",
            msg.sender,
            msg.value / DECIMAL_PRECISION,
            msg.value
        );
        console.log(
            "StableCoin - Creating new vault using the loan info `borrowingCompositeDebt`: %s",
            loanInfo.borrowingCompositeDebt
        );

        vaultManager.createVault(
            msg.sender,
            msg.value,
            loanInfo.borrowingCompositeDebt
        );

        /* -------------------------------------------------------------------------- */
        /*                                 ActivePool                                 */
        /* -------------------------------------------------------------------------- */

        // TODO: explain why
        // Send collateral(Eth sent) to ActivePool.
        console.log(
            "StableCoin - Contract balance before sending Eth to ActivePool %s/%s: ",
            address(this).balance / DECIMAL_PRECISION,
            address(this).balance
        );
        (bool success, ) = activePoolPayableAddr.call{value: msg.value}("");
        require(success, "StableCoin - Sending Eth to ActivePool failed");
        console.log(
            "StableCoin - Contract balance after sending Eth to ActivePool %s/%s: ",
            address(this).balance / DECIMAL_PRECISION,
            address(this).balance
        );
        // Increase LUSD debt of ActivePool
        activePool.increaseLUSDDebt(loanInfo.borrowingCompositeDebt);
        console.log(
            "StableCoin - ActivePool Stable coins total debt: ",
            activePool.getLUSDDebt()
        );

        /* -------------------------------------------------------------------------- */
        /*                                   GasPool                                  */
        /* -------------------------------------------------------------------------- */

        // Mint amount of Stable coins equal to the `LUSD_GAS_COMPENSATION`
        // and assign them to the GasPool.
        lusdToken.mint(address(gasPool), LUSD_GAS_COMPENSATION);
        console.log(
            "StableCoin - GasPool Stable coin balance: ",
            lusdToken.balanceOf(address(gasPool))
        );
    }

    function repay() external {
        // get collateral and debt
        Types.Vault memory vault = vaultManager.getVault(msg.sender);
        console.log("StableCoin::repay() vault collateral: ", vault.collateral);
        console.log("StableCoin::repay() vault debt: ", vault.debt);

        // calculate the debt to repay
        uint256 debtToRepay = vault.debt - LUSD_GAS_COMPENSATION;
        console.log("StableCoin - Debt to repay: ", debtToRepay);

        // validate that the user has enough funds (LUSD)
        require(
            lusdToken.balanceOf(msg.sender) >= debtToRepay,
            "StableCoin::repay() Insufficient funds to repay"
        );

        // burn the repaid LUSD debt from the user's balance
        lusdToken.burn(msg.sender, debtToRepay);

        // decrease LUSD debt of the active pool
        activePool.decreaseLUSDDebt(debtToRepay);

        // close vault
        vaultManager.closeVault(msg.sender, Enums.Status.closedByOwner);

        // burn gas compensation from the GasPool
        lusdToken.burn(address(gasPool), LUSD_GAS_COMPENSATION);

        // decrease gas compansation from the LUSD debt
        activePool.decreaseLUSDDebt(LUSD_GAS_COMPENSATION);

        // send collateral back to the user
        activePool.sendETH(msg.sender, vault.collateral);
    }

    function liquidate(address _borrower) external {
        // get the price of the collateral
        uint256 price = priceFeed.getEthPrice();

        // get vault info
        Types.Vault memory vault = vaultManager.getVault(_borrower);
        console.log(
            "StableCoin::liquidate() vault collateral: ",
            vault.collateral
        );
        console.log("StableCoin::liquidate() vault debt: ", vault.debt);

        // calculate the collateral ratio
        uint256 collateralRatio = LiquityMath._computeCR(
            vault.collateral,
            vault.debt,
            price
        );
        console.log(
            "StableCoin::liquidate() collateralRatio: ",
            collateralRatio
        );

        // verify the collateral ratio -> Collateral ratio < 110%
        require(
            collateralRatio < MINIMUN_COLLATERAL_RATIO,
            "StableCoin::liquidate() Cannot liquidate vault"
        );

        // verify we have enough LUSD in the StabilityPool to liquidate the position
        uint256 lusdInStabilityPool = stabilityPool.getTotalLUSDDeposits();
        require(
            lusdInStabilityPool >= vault.debt,
            "StableCoin::liquidate() Insufficent funds to liquidate"
        );
        console.log(
            "StableCoin::liquidate() lusdInStabilityPool: ",
            lusdInStabilityPool
        );

        // calculate collateral compensation for the liquidator
        uint256 collateralCompensation = vault.collateral / PERCENT_DIVISOR; // 0.5% of the collateral liquidated
        console.log(
            "StableCoin::liquidate() collateralCompensation: ",
            collateralCompensation
        );

        uint256 collateralToLiquidate = vault.collateral -
            collateralCompensation;

        // decrease the LUSD debt of the ActivePool
        activePool.decreaseLUSDDebt(vault.debt);

        // close vault
        vaultManager.closeVault(_borrower, Enums.Status.closedByLiquidation);

        // update LUSD deposits in the StabilityPool and burn tokens -> Offset
        stabilityPool.offset(vault.debt);

        // send liquidated ETH to StabilityPool -> This has to be distributed among stability providers
        activePool.sendETH(address(stabilityPool), collateralToLiquidate);

        // send gas compansation to liquidator
        lusdToken.transferFrom(
            address(gasPool),
            msg.sender,
            LUSD_GAS_COMPENSATION
        );

        // send 0.5% of the ETH liquidated to the liquidator
        activePool.sendETH(msg.sender, collateralCompensation);
    }

    function deposit(uint256 _lusdAmount) external {
        stabilityPool.deposit(msg.sender, _lusdAmount);
    }
}
