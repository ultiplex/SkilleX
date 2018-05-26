pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

contract KittyNFT is ERC721Token("CryptoKitty", "CK") {

    function create() public {
        uint tokenId = allTokens.length + 1;
        _mint(msg.sender, tokenId);
    }
}
