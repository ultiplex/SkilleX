import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

contract KittyNFT is ERC721Token("CryptoKitty", "CK") {


    function create(){
        uint tokenId = allTokens.length + 1;
        _mint(msg.sender, tokenId);
    }
}
