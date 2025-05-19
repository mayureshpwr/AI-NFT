
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying DecentrawoodAI_NFTs with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const DEOD_TOKEN_ADDRESS = ""; 

  const NFTContractFactory = await hre.ethers.getContractFactory("DecentrawoodAI_NFTs");
  const nftContract = await NFTContractFactory.deploy(DEOD_TOKEN_ADDRESS);

  await nftContract.deployed();

  console.log("DecentrawoodAI_NFTs deployed to:", nftContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
