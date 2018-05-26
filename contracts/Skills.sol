pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./ERC721ComposableRegistry.sol";

contract Skills is ERC721Token("Skillex", "SKLX") {

    ERC721ComposableRegistry internal composableRegistry;

    mapping(string => bool) private ipfsHashExists;
    mapping(string => string) private nameToIpfsHash;
    mapping(uint => string) public tokenIdToName;
    mapping(uint => uint) public generation;

    constructor(ERC721ComposableRegistry cr) public {
        composableRegistry = cr;
    }

    function createSkill(string name, string ipfsHash, address toErc721, uint toTokenId) public {
        require(!ipfsHashExists[ipfsHash]);
        uint tokenId = allTokens.length + 1;
        _mint(composableRegistry, tokenId);
        ipfsHashExists[ipfsHash] = true;
        nameToIpfsHash[name] = ipfsHash;
        tokenIdToName[tokenId] = name;
        composableRegistry.onERC721Received(this, tokenId, addressAndUintToBytes(toErc721, toTokenId));
    }

    function copySkill(uint originalId, address toErc721, uint toTokenId) internal {
        uint tokenId = allTokens.length + 1;
        _mint(composableRegistry, tokenId);
        tokenIdToName[tokenId] = tokenIdToName[originalId];
        generation[tokenId] = generation[originalId] + 1;
        composableRegistry.onERC721Received(this, tokenId, addressAndUintToBytes(toErc721, toTokenId));
    }

    function addressAndUintToBytes(address erc721, uint tokenId) constant returns (bytes) {
        bytes32 bytesErc721 = bytes32(erc721);
        bytes32 bytesTokenId = bytes32(tokenId);
        bytes memory ret = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            ret[i] = bytesErc721[i];
            ret[i + 32] = bytesTokenId[i];
        }
        return ret;
    }

    function getIpfsHash(uint tokenId) public view returns (string) {
        require(exists(tokenId));
        return nameToIpfsHash[tokenIdToName[tokenId]];
    }

    modifier canTransfer(uint256 _tokenId) {
        require(false);
        _;
    }
}

contract MarketeX is Skills {

    struct Offer {
        bool valid;
        ERC721 teacherErc721;
        uint teacherId;
        uint skillId;
        uint price;
    }

    Offer[] offers;

    function offerTeach(uint skillId, uint price) public {
        address owner = composableRegistry.ownerOf(this, skillId);
        require(owner == msg.sender);
        ERC721 erc721;
        uint tokenId;
        (erc721, tokenId) = composableRegistry.parentOf(this, skillId);
        offers.push(Offer(true, erc721, tokenId, skillId, price));
    }

    function cancel(uint offerId) public {
        Offer memory offer = offers[offerId];
        require(offer.valid);
        require(composableRegistry.ownerOf(offer.teacherErc721, offer.teacherId) == msg.sender);
        delete offers[offerId];
    }

    function learn(uint offerId, ERC721 toErc721, uint toTokenId) public payable {
        Offer memory offer = offers[offerId];
        require(offer.valid);
        require(msg.value >= offer.price);
        require(!hasSkill(toErc721, toTokenId, offer.skillId));
        copySkill(offers[offerId].skillId, toErc721, toTokenId);
        address teacherOwner = composableRegistry.ownerOf(offer.teacherErc721, offer.teacherId);
        teacherOwner.transfer(offer.price * 94 / 100);
        msg.sender.transfer(msg.value - offer.price);
    }

    function hasSkill(ERC721 erc721, uint tokenId, uint skillId) private returns (bool) {
        return false;
    }
}

contract WithdraweX is MarketeX, Ownable {

    constructor(ERC721ComposableRegistry cr) Skills(cr) public {
    }

    function withdrawEther() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
}
