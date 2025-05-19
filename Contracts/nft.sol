/**
______ _____ _____  _____ _   _ ___________  ___  _    _  _____  ___________ 
|  _  \  ___/  __ \|  ___| \ | |_   _| ___ \/ _ \| |  | ||  _  ||  _  |  _  \
| | | | |__ | /  \/| |__ |  \| | | | | |_/ / /_\ \ |  | || | | || | | | | | |
| | | |  __|| |    |  __|| . ` | | | |    /|  _  | |/\| || | | || | | | | | |
| |/ /| |___| \__/\| |___| |\  | | | | |\ \| | | \  /\  /\ \_/ /\ \_/ / |/ / 
|___/ \____/ \____/\____/\_| \_/ \_/ \_| \_\_| |_/\/  \/  \___/  \___/|___/  
                                                                                                                                                        
  ___  _____   _   _ ______ _____                                            
 / _ \|_   _| | \ | ||  ___|_   _|                                           
/ /_\ \ | |   |  \| || |_    | |                                             
|  _  | | |   | . ` ||  _|   | |                                             
| | | |_| |_  | |\  || |     | |                                             
\_| |_/\___/  \_| \_/\_|     \_/                                             
                                                                                                                                                                                                                                                                  
**/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract DecentrawoodAI_NFTs is ERC721URIStorage, ERC2981, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _burnedCounter;
    mapping(uint256 => bool) private _burnedTokens;
    mapping(uint256 => Order) private orderByAssetId;

    IERC20 public immutable deodToken;

    struct Order {
        bytes32 id;
        address seller;
        uint256 price;
        uint256 expiresAt;
    }

    event Minted(address indexed user, uint256 tokenId, string tokenURI);
    event Burned(uint256 tokenId, address indexed owner);
    event CreatedOrder(
        bytes32 indexed orderId,
        uint256 indexed assetId,
        address indexed seller,
        uint256 price,
        uint256 expiresAt
    );
    event OrderCancelled(bytes32 indexed orderId, uint256 indexed assetId, address indexed seller);
    event OrderSuccessful(
        bytes32 indexed orderId,
        uint256 indexed assetId,
        address indexed seller,
        uint256 price,
        address buyer
    );

    address private _deployer;
    uint96 public constant ROYALTY_FEE = 500; // 5% royalty fee (500 basis points)

    modifier onlyDeployer() {
        require(msg.sender == _deployer, "Caller is not the deployer");
        _;
    }

    constructor(address _deodToken) ERC721("DecentrawoodAI_NFTs", "DWNFT") Ownable(_msgSender()) {
        require(_deodToken != address(0), "Invalid DEOD token address");
        deodToken = IERC20(_deodToken);
    }

    function setDeployer(address deployer) external onlyOwner {
        require(deployer != address(0), "Invalid admin address");
        _deployer = deployer;
    }

    function mintNFT(address user, string memory tokenURI) external onlyDeployer {
        require(user != address(0), "Invalid user address");
        uint256 newTokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(user, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        // Set a static 5% royalty for the user (creator)
        _setTokenRoyalty(newTokenId, user, ROYALTY_FEE);

        emit Minted(user, newTokenId, tokenURI);
    }

    function sellNFT(uint256 assetId, uint256 priceInDeodToken, uint256 expiresAt) external {
    address sender = _msgSender();
    require(sender == ownerOf(assetId), "Only the owner can create orders");
    require(priceInDeodToken > 0, "Price must be greater than 0");
    require(expiresAt > block.timestamp, "Expiration must be in the future");

    // Automatically handle expired orders
    Order memory existingOrder = orderByAssetId[assetId];
    if (existingOrder.id != 0) {
        require(block.timestamp > existingOrder.expiresAt, "Asset is already on sale");
        delete orderByAssetId[assetId]; // Clean up expired order
        emit OrderCancelled(existingOrder.id, assetId, existingOrder.seller);
    }

    bytes32 orderId = keccak256(
        abi.encodePacked(block.timestamp, sender, assetId, priceInDeodToken)
    );

    orderByAssetId[assetId] = Order({
        id: orderId,
        seller: sender,
        price: priceInDeodToken,
        expiresAt: expiresAt
    });

    emit CreatedOrder(orderId, assetId, sender, priceInDeodToken, expiresAt);
}

    function buyNFT(uint256 assetId) external nonReentrant {
    Order memory order = orderByAssetId[assetId];
    require(order.id != 0, "Order does not exist");

    if (block.timestamp >= order.expiresAt) {
        // Handle expired order
        delete orderByAssetId[assetId];
        emit OrderCancelled(order.id, assetId, order.seller);
        revert("Order expired and has been canceled");
    }

    address buyer = _msgSender();
    address seller = order.seller;
    uint256 price = order.price;

    require(buyer != seller, "Buyer cannot be the seller");
    require(deodToken.balanceOf(buyer) >= price, "Insufficient DEOD balance");
    require(deodToken.allowance(buyer, address(this)) >= price, "Allowance not sufficient");

    // Get royalty information
    (address royaltyReceiver, uint256 royaltyAmount) = royaltyInfo(assetId, price);

    // Transfer royalties to creator
    if (royaltyAmount > 0) {
        require(deodToken.transferFrom(buyer, royaltyReceiver, royaltyAmount), "Royalty transfer failed");
    }

    // Transfer remaining amount to seller
    uint256 sellerAmount = price - royaltyAmount;
    require(deodToken.transferFrom(buyer, seller, sellerAmount), "Seller transfer failed");

    // Transfer NFT to buyer
    _transfer(seller, buyer, assetId);

    // Finalize order
    delete orderByAssetId[assetId];
    emit OrderSuccessful(order.id, assetId, seller, price, buyer);
}

    function cancelOrder(uint256 assetId) external returns (Order memory) {
        address sender = _msgSender();
        Order memory order = orderByAssetId[assetId];

        require(order.id != 0, "Order does not exist");
        require(order.seller == sender || sender == owner(), "Unauthorized user");

        bytes32 orderId = order.id;

        // Delete the order
        delete orderByAssetId[assetId];

        emit OrderCancelled(orderId, assetId, order.seller);

        return order;
    }

    function burnNFT(uint256 tokenId) external nonReentrant {
        require(msg.sender == ownerOf(tokenId), "Caller is not the owner");
        require(!_burnedTokens[tokenId], "Already burned");
        Order memory order = orderByAssetId[tokenId];
        require(order.id == 0, "Cannot burn while asset is on sale");
        address tokenOwner = ownerOf(tokenId);
        _burnedTokens[tokenId] = true;
        _burnedCounter.increment();
        _burn(tokenId);
        emit Burned(tokenId, tokenOwner);
    }

    // Override `supportsInterface` to include ERC2981
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721URIStorage, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    // Created by Dev — https://github.com/mayureshpwr & https://github.com/monish-nagre
}
