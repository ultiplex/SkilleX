pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./ERC721ComposableRegistry.sol";

contract TokeneX is ERC721Token("SkilleX", "SKLX") {

    ERC721ComposableRegistry internal composableRegistry;

    mapping(string => bool) private ipfsHashExists;
    mapping(uint => string) internal tokenIdToName;
    mapping(uint => string) internal tokenIdToIpfsHash;
    mapping(uint => uint) internal tokenIdToGeneration;
    mapping(string => uint[]) internal ipfsHashToTokenIds;

    constructor(ERC721ComposableRegistry cr) public {
        composableRegistry = cr;
    }

    function createSkill(string name, string ipfsHash, address toErc721, uint toTokenId) public {
        require(!ipfsHashExists[ipfsHash]);
        uint tokenId = allTokens.length + 1;
        _mint(composableRegistry, tokenId);
        ipfsHashExists[ipfsHash] = true;
        tokenIdToName[tokenId] = name;
        tokenIdToIpfsHash[tokenId] = ipfsHash;
        ipfsHashToTokenIds[ipfsHash].push(tokenId);
        composableRegistry.onERC721Received(this, tokenId, addressAndUintToBytes(toErc721, toTokenId));
    }

    function copySkill(uint originalId, address toErc721, uint toTokenId) internal {
        uint tokenId = allTokens.length + 1;
        _mint(composableRegistry, tokenId);
        tokenIdToName[tokenId] = tokenIdToName[originalId];
        tokenIdToIpfsHash[tokenId] = tokenIdToIpfsHash[originalId];
        tokenIdToGeneration[tokenId] = tokenIdToGeneration[originalId] + 1;
        ipfsHashToTokenIds[tokenIdToIpfsHash[tokenId]].push(tokenId);
        composableRegistry.onERC721Received(this, tokenId, addressAndUintToBytes(toErc721, toTokenId));
    }

    function addressAndUintToBytes(address erc721, uint tokenId) private pure returns (bytes) {
        bytes32 bytesErc721 = bytes32(erc721);
        bytes32 bytesTokenId = bytes32(tokenId);
        bytes memory ret = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            ret[i] = bytesErc721[i];
            ret[i + 32] = bytesTokenId[i];
        }
        return ret;
    }

    function getSkillName(uint tokenId) public view returns (string) {
        require(exists(tokenId));
        return tokenIdToName[tokenId];
    }

    function getIpfsHash(uint tokenId) public view returns (string) {
        require(exists(tokenId));
        return tokenIdToIpfsHash[tokenId];
    }

    modifier canTransfer(uint256 _tokenId) {
        require(false);
        _;
    }

    function getSkillOwners(string ipfsHash) public view returns (uint[]) {
        require(ipfsHashExists[ipfsHash]);
        return ipfsHashToTokenIds[ipfsHash];
    }
}

contract MarketeX is TokeneX {

    event OfferCreated(
        uint offerId,
        uint skillId,
        uint price,
        address teacherErc721,
        uint teacherTokenId,
        string skillName,
        uint generation
    );

    event OfferDeleted(
        uint offerId
    );

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
        uint offerIdPlusOne = offers.push(Offer(true, erc721, tokenId, skillId, price));
        emit OfferCreated(offerIdPlusOne - 1, skillId, price, erc721, tokenId, tokenIdToName[skillId], tokenIdToGeneration[skillId]);
    }

    function cancel(uint offerId) public {
        Offer memory offer = offers[offerId];
        require(offer.valid);
        require(composableRegistry.ownerOf(offer.teacherErc721, offer.teacherId) == msg.sender);
        delete offers[offerId];
        emit OfferDeleted(offerId);
    }

    function learn(uint offerId, ERC721 toErc721, uint toTokenId) public payable {
        Offer memory offer = offers[offerId];
        require(offer.valid);
        require(msg.value >= offer.price);
        require(!hasSkill(toErc721, toTokenId, getIpfsHash(offer.skillId)));
        copySkill(offers[offerId].skillId, toErc721, toTokenId);
        address teacherOwner = composableRegistry.ownerOf(offer.teacherErc721, offer.teacherId);
        teacherOwner.transfer(offer.price * 94 / 100);
        msg.sender.transfer(msg.value - offer.price);
    }

    function hasSkill(ERC721 erc721, uint tokenId, string ipfsHash) public view returns (bool) {
        bytes32 hash = keccak256(ipfsHash);
        ERC721[] memory erc721s;
        uint[] memory tokenIds;
        (erc721s, tokenIds) = composableRegistry.children(erc721, tokenId);
        for (uint i = 0; i < erc721s.length; i++) {
            if (erc721s[i] == this && keccak256(getIpfsHash(tokenIds[i])) == hash) {
                return true;
            }
        }
        return false;
    }
}

contract WithdraweX is Ownable {

    function withdrawEther() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
}

contract SkilleX is MarketeX, WithdraweX {

    constructor(ERC721ComposableRegistry cr) TokeneX(cr) public {
    }
}
