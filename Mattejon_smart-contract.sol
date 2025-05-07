// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts@5.3.0/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts@5.3.0/token/ERC721/extensions/ERC721URIStorage.sol";

contract Mattejon is ERC721URIStorage {
    mapping(address => bool) private  _isOwner;

    mapping(uint256 => uint256) private _mintedAt;  
    mapping(uint256 => uint256) private _lastTransferredAt;

    uint256 public constant DELAY_AFTER_MINT = 3 days;
    uint256 public constant DELAY_AFTER_TRANSFER = 1 days;

    constructor(address secondOwner)
        ERC721("Mattejon", "MJTK") 
    {
        _isOwner[msg.sender] = true;   // Moi le créateur J.BJ
        _isOwner[secondOwner] = true;  // Je définis le deuxième propriétaire, M.S
    }

    //Fonction pour vérifier si l'utilisateur est un Owner
    modifier onlyOwner() {
        require(_isOwner[msg.sender], "Not authorized");
        _;
    }

    // Fonction pour mint un NFT
    //https://emn178.github.io/online-tools/keccak_256_checksum.html site pour hash un fichier avec fonction de hachage Keccak-256
    function safeMint(address to, uint256 tokenId, string memory uri) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _mintedAt[tokenId] = block.timestamp;
    }
    
    // Fonction appelée lors d'un transfert
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) 
    {
        uint256 currentTime = block.timestamp;

        uint256 mintedAt = _mintedAt[tokenId];
        require(currentTime >= mintedAt + DELAY_AFTER_MINT, "Transfer blocked: 3 days lock after minting");

        uint256 lastTransferTime = _lastTransferredAt[tokenId];
        require(currentTime >= lastTransferTime + DELAY_AFTER_TRANSFER, "Transfer blocked: 1 day lock after transfer");

        _lastTransferredAt[tokenId] = block.timestamp;

        return super._update(to, tokenId, auth);
    }

    // Fonction pour connaitre le temps restant en secondes avant que le token puisse être transféré
    function timeUntilTransferable(uint256 tokenId) public view returns (uint256) 
    {
        require (ownerOf(tokenId) != address(0), "Token does not exist");
        uint256 currentTime = block.timestamp;

        
        uint256 mintedAt = _mintedAt[tokenId];
        uint256 remainingTimeAfterMint = (mintedAt + DELAY_AFTER_MINT > currentTime) ? mintedAt + DELAY_AFTER_MINT - currentTime : 0;

        uint256 lastTransferredAt = _lastTransferredAt[tokenId];
        uint256 remainingTimeAfterTransfer = (lastTransferredAt + DELAY_AFTER_TRANSFER > currentTime) ? lastTransferredAt + DELAY_AFTER_TRANSFER - currentTime : 0;

        return (remainingTimeAfterMint > remainingTimeAfterTransfer) ? remainingTimeAfterMint : remainingTimeAfterTransfer;
    }
}


