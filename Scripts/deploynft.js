const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  // Deploy NFT contract
  const DEOD_ADDRESS = "0x..."; // Set token address
  const NFT = await hre.ethers.getContractFactory("DecentrawoodAI_NFTs");
  const nft = await NFT.deploy(DEOD_ADDRESS);
  await nft.deployed();
  console.log("NFT Contract deployed to:", nft.address);

  // Deploy Depositor contract
  const Depositor = await hre.ethers.getContractFactory("Depositor");
  const depositor = await Depositor.deploy(deployer.address, nft.address);
  await depositor.deployed();
  console.log("Depositor Contract deployed to:", depositor.address);

  // Set Depositor as deployer in NFT contract
  const tx = await nft.setDeployer(depositor.address);
  await tx.wait();
  console.log("Depositor set as deployer in NFT contract");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
