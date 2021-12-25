const hre = require("hardhat");
const fs = require("fs");

const path = "src/.env/contract-address.json";

async function main() {
  const BankContract = await hre.ethers.getContractFactory("Bank");
  const bank = await BankContract.deploy();

  await bank.deployed();
  console.log("BankContract deployed to:", bank.address);

  const TokenContract = await hre.ethers.getContractFactory("Token");
  const token = await TokenContract.deploy(bank.address);

  await token.deployed();
  console.log("TokenContract deployed to:", token.address);

  let addresses = {
    bankContract: bank.address,
    tokenContract: token.address,
  };

  let addressJSON = JSON.stringify(addresses);

  fs.writeFileSync(path, addressJSON);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
