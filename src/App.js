import { useState, useEffect } from "react";
import { ethers } from "ethers";
import addresses from "./.env/contract-address.json";
import Bank from "./artifacts/contracts/Bank.sol/Bank.json";
import Token from "./artifacts/contracts/Token.sol/Token.json";

import logo from "./logo.svg";
import "./App.css";

const CHAIN_ID = 1337;

function App() {
  const [userTotalAssets, setUserTotalAssets] = useState(null);
  const [totalAssets, setTotalAssets] = useState(null);
  const [yieldTokens, setYieldTokens] = useState(null);
  const [signer, setSigner] = useState(null);
  const [bankContract, setBankContract] = useState(null);
  const [tokenContract, setTokenContract] = useState(null);
  const [change, setChange] = useState({});

  useEffect(() => {
    window.onGameChange = (data) => {
      setChange(data);
    };

    const script = document.createElement("script");
    script.src = "/game.js";
    script.async = true;
    document.body.appendChild(script);
  }, []);

  useEffect(() => {
    // Initialize the front end
    const init = async () => {
      await window.ethereum.enable();

      const provider = new ethers.providers.Web3Provider(
        window.ethereum,
        "any"
      );

      const signer = provider.getSigner();

      if ((await signer.getChainId()) !== CHAIN_ID)
        alert("Please change your network to Ganache");

      const bankContract = new ethers.Contract(
        addresses.bankContract,
        Bank.abi,
        signer
      );

      const tokenContract = new ethers.Contract(
        addresses.tokenContract,
        Token.abi,
        signer
      );

      const address = await signer.getAddress();
      const amount = await bankContract.accounts(address);
      setUserTotalAssets(ethers.utils.formatEther(amount));

      const totalAssets = await bankContract.totalAssets();
      setTotalAssets(ethers.utils.formatEther(totalAssets));

      const balance = await tokenContract.balanceOf(address);
      setYieldTokens(ethers.utils.formatEther(balance));

      setSigner(signer);
      setBankContract(bankContract);
      setTokenContract(tokenContract);
    };

    init();
  }, []);

  const withdraw = async (val) => {
    try {
      const tx = await bankContract.withdraw(
        ethers.utils.parseEther(val.amountToWithdraw),
        addresses.tokenContract
      );
      await tx.wait();

      const address = await signer.getAddress();
      const amount = await bankContract.accounts(address);
      setUserTotalAssets(ethers.utils.formatEther(amount));

      const totalAssets = await bankContract.totalAssets();
      setTotalAssets(ethers.utils.formatEther(totalAssets));

      const balance = await tokenContract.balanceOf(address);
      setYieldTokens(ethers.utils.formatEther(balance));
    } catch (err) {
      alert(err.data.message.toString());
    }
  };

  const deposit = async (val) => {
    const tx = await bankContract.deposit({
      value: ethers.utils.parseEther(val.amountToDeposit),
    });
    await tx.wait();

    const address = await signer.getAddress();
    const amount = await bankContract.accounts(address);
    setUserTotalAssets(ethers.utils.formatEther(amount));

    const totalAssets = await bankContract.totalAssets();
    setTotalAssets(ethers.utils.formatEther(totalAssets));

    const balance = await tokenContract.balanceOf(address);
    setYieldTokens(ethers.utils.formatEther(balance));
  };

  return (
    <div className="App">
      <p>User Total Assets: {userTotalAssets}</p>
      <p>Total Assets: {totalAssets}</p>
      <p>Amount of Yield Tokens: {yieldTokens}</p>
      <p>Change: {JSON.stringify(change)}</p>
      <button onClick={() => deposit({ amountToDeposit: "1" })}>
        Deposit 1
      </button>
      <button onClick={() => withdraw({ amountToWithdraw: "1" })}>
        Withdraw 1
      </button>
    </div>
  );
}

export default App;
