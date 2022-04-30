// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20TestToken is ERC20, Ownable {
    constructor() ERC20("ERC20TestToken", "ETT") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

//SciNET
//0x28fef184Fa745d82a923136b99EfC4678b261A31
