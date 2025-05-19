Here's your updated `README.md` file — **only the README content, nothing else**:

---

```markdown
# 🪵 DecentrawoodAI NFT System

DecentrawoodAI is a decentralized platform for AI-generated NFTs on the Polygon blockchain. It consists of two main smart contracts:

- `DecentrawoodAI_NFTs`: An ERC721 NFT contract
- `Depositor`: A MATIC payment contract that acts as the exclusive minter

---

## 📜 Contracts Overview

### 🔹 `Depositor.sol`

Handles MATIC-based NFT minting and manages roles and fund withdrawals.

- Users mint NFTs by sending MATIC and a `tokenURI`
- Calls the `mintNFT` function on the NFT contract
- Roles:
  - `developer`: Can update NFT contract, set creator, withdraw funds
  - `creator`: Can withdraw funds
- Emits:
  - `DepositReceived`: On mint + deposit
  - `CreatorWithdrawn`: On fund withdrawal

### 🔹 `DecentrawoodAI_NFTs.sol`

ERC721 contract with:

- Minting restricted to `Depositor` contract
- DEOD-token-based marketplace
- 5% royalty to original minter on resale
- ERC-2981 royalty standard support
- Burn functionality
- Events for minting, burning, and marketplace activity

---

## ⚙️ Usage Flow

1. User calls `depositAndMint(tokenURI)` on `Depositor` with required MATIC.
2. `Depositor` calls `mintNFT(user, tokenURI)` on NFT contract.
3. NFT is minted to the user’s wallet.
4. Funds can be withdrawn by `developer` or `creator`.

---

## 💡 Key Features

- Mint NFTs with MATIC payments
- Role-based access control (developer & creator)
- Withdraw MATIC from contract
- NFT trading with DEOD token
- On-chain royalty enforcement (5%)

---

## 🔐 Security

- ✅ Minting limited to Depositor contract
- ✅ ReentrancyGuard to protect fund-handling
- ✅ Developer-controlled contract linking and upgrades
- ✅ Creator/developer-only fund withdrawals

---

## 🧑‍💻 Authors

- Mayuresh Pawar
- Monish Nagre
```

Let me know if you'd like this exported to a `.md` file or included with deployment/usage examples.
