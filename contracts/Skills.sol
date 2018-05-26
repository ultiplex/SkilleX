pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "./ERC721ComposableRegistry.sol";


contract Skills is ERC721Token("Skill", "SKL") {

    ERC721ComposableRegistry internal globalRegistry;

    mapping(string => bool) ipfsHashIsTaken;
    mapping(string => string) nameToIpfsHash;

    constructor(ERC721ComposableRegistry _globalRegistry){
        globalRegistry = _globalRegistry;
    }

    function createSkill(string name, string ipfsHash, bytes to) public {
        require(!ipfsHashIsTaken[ipfsHash]);
        uint256 tokenId = allTokens.length + 1;
        _mint(globalRegistry, tokenId);
        ipfsHashIsTaken[ipfsHash] = true;
        nameToIpfsHash[name] = ipfsHash;
        globalRegistry.onERC721Received(this, tokenId, to);
    }

    modifier canTransfer(uint256 _tokenId) {
        require(false);
        _;
    }
}
