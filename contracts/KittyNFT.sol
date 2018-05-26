pragma solidity ^0.4.23;

import "openzeppelin-zos/contracts/token/ERC721/ERC721Token.sol";

contract KittyNFT is ERC721Token {

    constructor() public {
        ERC721Token.initialize("CryptoKitty", "CK");
    }

    function create() public {
        uint tokenId = allTokens.length + 1;
        _mint(msg.sender, tokenId);
    }
}
