Here is a **proper, structured, and complete `README.md`** for your smart contract system:

---

````markdown
# 🪵 DecentrawoodAI NFT Minting System

A decentralized AI-powered NFT minting and marketplace system built on the Polygon network. The system uses a dual-contract setup:

- **Depositor**: Handles MATIC payments, authorization, and NFT minting.
- **DecentrawoodAI_NFTs**: An ERC721-compliant NFT contract integrated with a DEOD token-based marketplace.

---

## 📂 Project Structure

- `contracts/Depositor.sol` – MATIC payment contract and minting gateway.
- `contracts/DecentrawoodAI_NFTs.sol` – ERC721 NFT contract with integrated resale marketplace.
- `scripts/deploy.js` – Deployment script for both contracts.
- `README.md` – This file.

---

## 🧩 Contract Overview

### ✅ Depositor Contract

A secure gateway for users to mint NFTs by sending MATIC.

#### Functions:
- `depositAndMint(string memory tokenURI)`  
  Users call this with MATIC and a tokenURI to mint an NFT.
  
- `setRequiredMaticAmount(uint256 amount)`  
  Developer or creator sets the required MATIC amount to mint.

- `withdrawFunds()`  
  Creator or developer can withdraw all collected MATIC.

- `updateNFTContract(address newAddress)`  
  Developer can update the NFT contract address.

- `setCreator(address creator)`  
  Developer assigns the creator role.

- `updateDeveloper(address developer)`  
  Developer can transfer their own role.

#### Roles:
- **Developer**: Admin role to manage contracts and ownership.
- **Creator**: Authorized to withdraw funds.
- **User**: Mints NFTs by sending MATIC.

#### Events:
- `DepositReceived(user, amount, tokenURI)`
- `CreatorWithdrawn(creator, amount)`

---

### 🖼️ DecentrawoodAI_NFTs Contract

An ERC721 NFT contract supporting:
- Minting restricted to the `Depositor` contract.
- Resale marketplace using the DEOD token.
- 5% royalty to the original creator.
- Burning of owned NFTs.
- ERC-2981 royalty support.

#### Key Functions:
- `mintNFT(address to, string memory tokenURI)`  
  Can only be called by the Depositor contract.

- `listNFT(uint256 tokenId, uint256 price)`  
  List an NFT for sale using DEOD tokens.

- `buyNFT(uint256 tokenId)`  
  Buy a listed NFT. 5% goes to original creator, 95% to seller.

- `burn(uint256 tokenId)`  
  Burn an NFT you own.

#### Events:
- `NFTMinted(to, tokenId, tokenURI)`
- `NFTListed(tokenId, price)`
- `NFTSold(tokenId, buyer)`
- `NFTBurned(tokenId)`
- `RoyaltyPaid(creator, amount)`

---

## ⚙️ How It Works

1. User connects their wallet and prepares a tokenURI.
2. User sends the required MATIC to the `depositAndMint()` function on `Depositor`.
3. `Depositor` checks MATIC amount and calls `mintNFT()` on the NFT contract.
4. NFT is minted and assigned to the user.
5. User can later list/sell/burn their NFTs via the NFT contract.

---

## 🛡️ Security Features

- Uses `ReentrancyGuard` to protect against reentrancy attacks.
- Role-based access for sensitive functions (developer & creator).
- NFT minting is strictly restricted to the `Depositor` contract.
- ERC-2981 support ensures standardized royalty tracking.

---

## 🧪 Deployment

Update the deploy script (`scripts/deploy.js`) with your wallet and network info. Then run:

```bash
npx hardhat run scripts/deploy.js --network polygon
````

---

## 🔐 Access Control Summary

| Role      | Capabilities                                     |
| --------- | ------------------------------------------------ |
| Developer | Set NFT contract, assign creator, withdraw funds |
| Creator   | Withdraw funds                                   |
| User      | Mint NFTs with MATIC                             |

---

## 📢 Authors

* **Mayuresh Pawar**
* **Monish Nagre**

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

```

