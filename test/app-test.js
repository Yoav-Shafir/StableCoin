const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Bank App", () => {
  let priceFeedContract, lUSDToken, sortedVaults;
  let gasPool, activePool, stakingPool, stabilityPool;
  let borrowingContract, vaultManager;

  beforeEach(async () => {
    const PriceFeedContract = await ethers.getContractFactory("PriceFeed");
    priceFeedContract = await PriceFeedContract.deploy();
    await priceFeedContract.deployed();

    const LUSDToken = await ethers.getContractFactory("LUSDToken");
    lUSDToken = await LUSDToken.deploy();
    await lUSDToken.deployed();

    const BorrowingContract = await ethers.getContractFactory("Borrowing");
    borrowingContract = await BorrowingContract.deploy(
      priceFeedContract.address
    );
    await borrowingContract.deployed();

    const SortedVaults = await ethers.getContractFactory("SortedVaults");
    sortedVaults = await SortedVaults.deploy(borrowingContract.address);
    await sortedVaults.deployed();

    // pools
    const GasPool = await ethers.getContractFactory("GasPool");
    gasPool = await GasPool.deploy();
    await gasPool.deployed();

    const ActivePool = await ethers.getContractFactory("ActivePool");
    activePool = await ActivePool.deploy();
    await activePool.deployed();

    const StakingPool = await ethers.getContractFactory("StakingPool");
    stakingPool = await StakingPool.deploy();
    await stakingPool.deployed();

    const StabilityPool = await ethers.getContractFactory("StabilityPool");
    stabilityPool = await StabilityPool.deploy();
    await stabilityPool.deployed();

    const VaultManager = await ethers.getContractFactory("VaultManager");
    vaultManager = await VaultManager.deploy(sortedVaults.address);
    await vaultManager.deployed();
  });

  describe("PriceFeed", () => {
    const eth = ethers.utils.parseEther("1000");

    it("Should have `latestPrice` of 1000", async () => {
      expect(await priceFeedContract.getPrice()).to.equal(eth);
    });
  });
});
// describe("Bank App", () => {
//   let bank, token, owner, address_1, address_2;
//   let addresses;

//   beforeEach(async () => {
//     const BankContract = await ethers.getContractFactory("Bank");
//     bank = await BankContract.deploy();
//     await bank.deployed();

//     const TokenContract = await ethers.getContractFactory("Token");
//     token = await TokenContract.deploy(bank.address);
//     await token.deployed();

//     [owner, address_1, address_2, ...addresses] = await ethers.getSigners();
//   });

//   describe("Deployment", () => {
//     it("Should have `totalAssets` of 0", async () => {
//       expect(await bank.totalAssets()).to.equal("0");
//     });

//     it("Should have 0 tokens and 0 deposit in owner account", async () => {
//       expect(await bank.accounts(owner.address)).to.equal("0");
//       expect(await token.balanceOf(owner.address)).to.equal("0");
//     });

//     it("Should have 0 tokens and 0 deposit in address_1 account", async () => {
//       expect(await bank.accounts(address_1.address)).to.equal("0");
//       expect(await token.balanceOf(address_1.address)).to.equal("0");
//     });

//     it("Should have 0 tokens and 0 deposit in address_2 account", async () => {
//       expect(await bank.accounts(address_2.address)).to.equal("0");
//       expect(await token.balanceOf(address_2.address)).to.equal("0");
//     });
//   });

//   describe("Deposit and Withdrawal", () => {
//     const oneEth = ethers.utils.parseEther("1.0");

//     it("Should let owner deposit 1 unit, then `totalAssets` should be 1 unit and accounts[owner] should have 1 unit", async () => {
//       await bank.connect(owner).deposit({ value: oneEth });
//       expect(await bank.totalAssets()).to.equal(oneEth);
//       expect(await bank.accounts(owner.address)).to.equal(oneEth);
//     });

//     it("Should let account_1 deposit and withdraw 1 unit, then have 1 unit of free token", async () => {
//       await bank.connect(address_1).deposit({ value: oneEth });
//       await bank.connect(address_1).withdraw(oneEth, token.address);
//       expect(await bank.totalAssets()).to.equal("0");
//       expect(await token.balanceOf(address_1.address)).to.equal(oneEth);
//     });

//     it("Should fail when trying to withdraw money one hasnt deposited", async () => {
//       expect(
//         bank.connect(address_2).withdraw(oneEth, token.address)
//       ).to.be.revertedWith("Insufficient Funds");
//     });
//   });
// });
