import { ethers } from "ethers";
import abi from "../constants/ABI.json";

export const getWeb3State = async () => {
  let [contractInstance, selectedAccount, chainId] = [null, null, null, null];

  try {
    if (!window.ethereum) {
      throw new Error("Metamask is not installed");
    }

    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });

    const chainIdHex = await window.ethereum.request({
      method: "eth_chainId",
    });

    chainId = parseInt(chainIdHex, 16);
    selectedAccount = accounts[0];
    // read operation
    const provider = new ethers.BrowserProvider(window.ethereum);
    // write operation
    const signer = await provider.getSigner();

    // Once you deploy the Ticket.sol in remix.. Paste the contract Address over here
    const contractAddress = "0x7a365aa65b7e971629c6d8B56ae2649d12F01f93";
    contractInstance = new ethers.Contract(contractAddress, abi, signer);
    return {
      contractInstance,
      chainId,
      selectedAccount,
    };
  } catch (error) {
    console.error("Not able to get the web3 state", error.message);
    throw error;
  }
};
