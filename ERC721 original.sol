// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721TestToken is ERC721, Ownable {
    constructor() ERC721("ERC721Original", "E7O") {}

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}

//SciNet
//0xa6CBef13fe344DF8B9bA39Bf88999Be7ba6ecDA1
