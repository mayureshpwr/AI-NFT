/**
______           _                         _____             _                  _   
|  _  \         | |                       /  __ \           | |                | |  
| | | |___ _ __ | | ___  _   _  ___ _ __  | /  \/ ___  _ __ | |_ _ __ __ _  ___| |_ 
| | | / _ \ '_ \| |/ _ \| | | |/ _ \ '__| | |    / _ \| '_ \| __| '__/ _` |/ __| __|
| |/ /  __/ |_) | | (_) | |_| |  __/ |    | \__/\ (_) | | | | |_| | | (_| | (__| |_ 
|___/ \___| .__/|_|\___/ \__, |\___|_|     \____/\___/|_| |_|\__|_|  \__,_|\___|\__|
          | |             __/ |                                                     
          |_|            |___/                                                      
**/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface INFT {
    function mintNFT(address user, string memory tokenURI) external;
}

contract Depositor is ReentrancyGuard {
    address public developer;
    address public creator;
    address public nftContract;

    uint256 public MaticAmount;  

    event DepositReceived(address indexed user, uint256 amount, string tokenURI);
    event CreatorWithdrawn(address indexed creator, uint256 amount);

    modifier onlyDeveloper() {
        require(msg.sender == developer, "Only developer can call this function");
        _;
    }

    modifier onlyCreator() {
        require(msg.sender == creator, "Only creator can call this function");
        _;
    }

    modifier onlyAuthorized() {
    require(msg.sender == developer || msg.sender == creator, "Not authorized");
    _;
    }

    constructor(address _developer, address _nftContract) {
        require(_developer != address(0), "Invalid developer address");
        require(_nftContract != address(0), "Invalid NFT contract address");

        developer = _developer;
        nftContract = _nftContract;
    }

    function depositAndMint(string memory tokenURI) external payable nonReentrant {
        uint256 totalAmount = MaticAmount + msg.value;

        // Ensure the user sends at least the required amount of MATIC
        require(msg.value >= MaticAmount, "MATIC amount must be greater than required");

        // Call the mintNFT function on the NFT contract
        INFT(nftContract).mintNFT(msg.sender, tokenURI);

        // Emit the DepositReceived event
        emit DepositReceived(msg.sender, totalAmount, tokenURI);
    }

    function setRequiredMaticAmount(uint256 _newRequiredMaticAmount) external onlyAuthorized{
        require(_newRequiredMaticAmount > 0, "Required MATIC amount must be greater than 0");
        MaticAmount = _newRequiredMaticAmount;

        // Emit event to signal the update
    }

    function withdrawFunds() external onlyAuthorized nonReentrant {
    uint256 balance = address(this).balance;
    require(balance > 0, "No funds to withdraw");
    payable(msg.sender).transfer(balance);
    emit CreatorWithdrawn (msg.sender,balance);
    }

    function updateNFTContract(address _nftContract) external onlyDeveloper {
        require(_nftContract != address(0), "Invalid NFT contract address");
        nftContract = _nftContract;
    }

    function updateDeveloper(address _developer) external onlyDeveloper {
        require(_developer != address(0), "Invalid developer address");
        developer = _developer;
    }
    function setCreator (address _creator) external onlyDeveloper{
        require(_creator != address(0), "Invalid creator address");
        creator = _creator;
    }
}
