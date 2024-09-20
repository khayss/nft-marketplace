// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Nft is ERC721, ERC721URIStorage, Ownable {
    uint256 private s_nextTokenId;
    uint256 private s_maxSupply;
    bool private s_isFixedSupply;
    string private s_baseUri;
    uint256 private s_mintPrice;

    constructor(
        address _owner,
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        bool _isfixedSupply,
        uint256 _maxSupply,
        uint256 _price
    ) ERC721(_name, _symbol) Ownable(_owner) {
        s_nextTokenId = 1;
        s_baseUri = _baseUri;
        s_isFixedSupply = _isfixedSupply;
        if (_isfixedSupply) {
            s_maxSupply = _maxSupply;
        }
        s_mintPrice = _price;
    }

    error Nft__AddressZeroNotAllowed();
    error Nft__MaxSupplyReached();
    error Nft__NotEnoughFunds();
    error Nft__FixedSupply();
    error Nft__CannotBeLessThanCurrentSupply();
    error Nft__CannotBeZero();
    error Nft__TransferFailed();

    function _baseURI() internal view override returns (string memory) {
        return s_baseUri;
    }

    function safeMint(address to) public payable returns (uint256 tokenId) {
        if (to == address(0)) revert Nft__AddressZeroNotAllowed();
        if (msg.value < s_mintPrice) revert Nft__NotEnoughFunds();
        if (s_isFixedSupply && s_nextTokenId > s_maxSupply)
            revert Nft__MaxSupplyReached();

        tokenId = s_nextTokenId;

        _safeMint(to, s_nextTokenId);
        _setTokenURI(s_nextTokenId, tokenURI(s_nextTokenId));

        s_nextTokenId++;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(_tokenId);
    }

    function supportsInterface(
        bytes4 _interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    function setTokenURI(
        uint256 _tokenId,
        string memory _tokenURI
    ) public onlyOwner {
        _setTokenURI(_tokenId, _tokenURI);
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        s_mintPrice = _mintPrice;
    }

    function setBaseUri(string memory _baseUri) public onlyOwner {
        s_baseUri = _baseUri;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        if (s_isFixedSupply) revert Nft__FixedSupply();
        if (_maxSupply < s_nextTokenId - 1)
            revert Nft__CannotBeLessThanCurrentSupply();
        s_maxSupply = _maxSupply;
    }

    function setIsFixedSupply(bool _isFixedSupply) public onlyOwner {
        s_isFixedSupply = _isFixedSupply;
    }

    function withdraw() public onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        if (!success) revert Nft__TransferFailed();
    }

    function getMintPrice() public view returns (uint256) {
        return s_mintPrice;
    }

    function getMaxSupply() public view returns (uint256) {
        return s_maxSupply;
    }

    function getIsFixedSupply() public view returns (bool) {
        return s_isFixedSupply;
    }
}
