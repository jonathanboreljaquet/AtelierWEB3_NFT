// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts@5.3.0/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts@5.3.0/token/ERC721/extensions/ERC721URIStorage.sol";

contract Mattejon is ERC721URIStorage {
    mapping(address => bool) public isOwner;

    constructor(address secondOwner)
        ERC721("Mattejon", "MJTK") 
    {
        isOwner[msg.sender] = true;   // Moi le créateur J.BJ
        isOwner[secondOwner] = true;  // Je définis le deuxième propriétaire, M.S
    }

    //Fonction pour vérifier si l'utilisateur est un Owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not authorized");
        _;
    }

    // Fonction pour mint un NFT
    //https://emn178.github.io/online-tools/keccak_256_checksum.html site pour hash une image avec fonction de hachage Keccak-256
    function safeMint(address to, uint256 tokenId, string memory uri) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

}
