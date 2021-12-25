const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {
  // Registry
  const NameRegistry = await ethers.getContractFactory("NameRegistry");
  const nameRegistry = await NameRegistry.deploy();
  await nameRegistry.deployed();

  // Entities
  const PriceFeed = await ethers.getContractFactory("PriceFeed");
  const priceFeed = await PriceFeed.deploy();
  await priceFeed.deployed();

  const LUSDToken = await ethers.getContractFactory("LUSDToken");
  const lusdToken = await LUSDToken.deploy();
  await lusdToken.deployed();

  const Borrowing = await ethers.getContractFactory("Borrowing");
  const borrowing = await Borrowing.deploy();
  await borrowing.deployed();

  const VaultManager = await ethers.getContractFactory("VaultManager");
  const vaultManager = await VaultManager.deploy();
  await vaultManager.deployed();

  const SortedVaults = await ethers.getContractFactory("SortedVaults");
  const sortedVaults = await SortedVaults.deploy();
  await sortedVaults.deployed();

  // Pools
  const GasPool = await ethers.getContractFactory("GasPool");
  const gasPool = await GasPool.deploy();
  await gasPool.deployed();

  const ActivePool = await ethers.getContractFactory("ActivePool");
  const activePool = await ActivePool.deploy();
  await activePool.deployed();

  const StakingPool = await ethers.getContractFactory("StakingPool");
  const stakingPool = await StakingPool.deploy();
  await stakingPool.deployed();

  const StabilityPool = await ethers.getContractFactory("StabilityPool");
  const stabilityPool = await StabilityPool.deploy();
  await stabilityPool.deployed();

  const StableCoin = await ethers.getContractFactory("StableCoin");
  const stableCoin = await StableCoin.deploy();
  await stableCoin.deployed();

  // Register contracts
  await nameRegistry.registerName("StableCoin", stableCoin.address, 1);
  await nameRegistry.registerName("PriceFeed", priceFeed.address, 1);
  await nameRegistry.registerName("LUSDToken", lusdToken.address, 1);
  await nameRegistry.registerName("Borrowing", borrowing.address, 1);
  await nameRegistry.registerName("VaultManager", vaultManager.address, 1);
  await nameRegistry.registerName("SortedVaults", sortedVaults.address, 1);
  await nameRegistry.registerName("GasPool", gasPool.address, 1);
  await nameRegistry.registerName("ActivePool", activePool.address, 1);
  await nameRegistry.registerName("StakingPool", stakingPool.address, 1);
  await nameRegistry.registerName("StabilityPool", stabilityPool.address, 1);

  priceFeed.initialize(nameRegistry.address);
  lusdToken.initialize(nameRegistry.address);
  borrowing.initialize(nameRegistry.address);
  vaultManager.initialize(nameRegistry.address);
  sortedVaults.initialize(nameRegistry.address);
  gasPool.initialize(nameRegistry.address);
  activePool.initialize(nameRegistry.address);
  stakingPool.initialize(nameRegistry.address);
  stabilityPool.initialize(nameRegistry.address);
  stableCoin.initialize(nameRegistry.address);

  const [address1, address2] = await ethers.getSigners();

  console.log(
    `1. Calling borrow() for 100 LUSD address1: ${address1.address} ETH: 2`
  );
  const eth = ethers.utils.parseEther("150");
  await stableCoin.connect(address1).borrow(100, { value: eth });

  // await stableCoin.connect(address1).repay();

  // console.log("2. Calling borrow() with address: ", address2.address);
  // const eth50 = ethers.utils.parseEther("50");
  // await stableCoin.connect(address2).borrow(500, { value: eth50 });

  // console.log("3. Appove StabilityPool address 2: ");
  // await lusdToken
  //   .connect(address2)
  //   .approve(stabilityPool.address, ethers.utils.parseEther("500"));

  // console.log("3. Deposit() address 2: ", address2.address);
  // console.log("3. Deposit() stabilityPool: ", stabilityPool.address);
  // await stableCoin.connect(address2).deposit(ethers.utils.parseEther("500"));

  // console.log("5. Liquidate address 1 by address 2: ");
  // await priceFeed.setEthPrice(100);
  // await stableCoin.connect(address2).liquidate(address1.address);
  // const balance = await lusdToken.balanceOf(stakingPool.address);
  // console.log("Balance: ", balance);

  // console.log(await sortedVaults.getFirst());
  // console.log(await sortedVaults.getLast());
  // console.log(await sortedVaults.getSize());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
