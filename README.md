# Create project in current folder

npx hardhat

# Help

npx hardhat help

# Compile -> will create the `artifacts` folder

npx hardhat compile

# Run tests

npx hardhat test

##### Deploy

# Ganache - http://localhost:7545

./ganache-2.5.4-linux-x86_64.AppImage
npx hardhat run scripts/deploy.js --network ganache

# Hardhat Network - http://localhost:8545

npx hardhat node
npx hardhat run scripts/deploy.js --network localhost

```shell
npx hardhat accounts
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```
