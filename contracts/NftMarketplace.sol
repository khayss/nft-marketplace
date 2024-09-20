// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Nft} from "./Nft.sol";

contract NftMarketplace is Ownable {
    // TYPES
    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 price;
        bool isListed;
    }

    // STATE VARIABLES
    mapping(address => mapping(uint256 => Listing)) private s_listings;
    mapping(uint256 => address) s_mints;
    uint256 totalMints;

    // ERRORS
    error NftMarketplace__AddressZeroNotAllowed();
    error NftMarketplace__NotOwner();
    error NftMarketplace__NotListed();
    error NftMarketplace__NotEnoughFunds();
    error NftMarketplace__TransferFailed();
    error NftMarketplace__AlreadyListed();

    // EVENTS
    event NftListing(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed owner
    );
    event NftDelisting(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed owner
    );
    event NftPurchase(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed owner,
        address buyer,
        uint256 price
    );
    event NftCreate(address indexed nft, uint256 indexed mintId);
    event NftMint(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed minter
    );

    // CONSTRUCTOR
    constructor(address _owner) Ownable(_owner) {}

    // PRIVATE FUNCTIONS
    function _checkAddressZero(address _address) private pure {
        if (_address == address(0))
            revert NftMarketplace__AddressZeroNotAllowed();
    }

    // EXTERNAL FUNCTIONS
    function listToken(
        address _nft,
        uint256 _tokenId,
        uint256 _price
    ) external {
        _checkAddressZero(msg.sender);
        _checkAddressZero(_nft);

        Listing storage listing = s_listings[_nft][_tokenId];
        if (listing.isListed) revert NftMarketplace__AlreadyListed();

        IERC721(_nft).transferFrom(msg.sender, address(this), _tokenId);

        listing.seller = msg.sender;
        listing.price = _price;
        listing.isListed = true;

        emit NftListing(_nft, _tokenId, msg.sender);
    }

    function delistNft(address _nft, uint256 _tokenId) external {
        Listing storage listing = s_listings[_nft][_tokenId];
        if (listing.seller != msg.sender) revert NftMarketplace__NotOwner();

        delete s_listings[_nft][_tokenId];

        emit NftDelisting(_nft, _tokenId, msg.sender);
    }

    function buyNft(address _nft, uint256 _tokenId) external payable {
        _checkAddressZero(msg.sender);

        Listing storage listing = s_listings[_nft][_tokenId];

        if (listing.isListed == false) revert NftMarketplace__NotListed();
        if (msg.value < listing.price) revert NftMarketplace__NotEnoughFunds();

        address seller = listing.seller;
        uint256 price = listing.price;

        delete s_listings[_nft][_tokenId];

        (bool success, ) = payable(seller).call{value: price}("");
        if (!success) revert NftMarketplace__TransferFailed();

        IERC721(_nft).transferFrom(address(this), msg.sender, _tokenId);
    }

    function createNft(
        address _owner,
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI,
        bool _isfixedSupply,
        uint256 _maxSupply,
        uint256 _price
    ) external returns (address nftAddress, uint256 mintId) {
        _checkAddressZero(_owner);

        Nft nft = new Nft(
            _owner,
            _name,
            _symbol,
            _baseTokenURI,
            _isfixedSupply,
            _maxSupply,
            _price
        );

        mintId = totalMints;
        nftAddress = address(nft);

        s_mints[totalMints] = address(nft);
        totalMints++;

        emit NftCreate(nftAddress, mintId);
    }

    function mintNft(uint256 _mintId) external payable {
        _checkAddressZero(msg.sender);

        Nft nft = Nft(s_mints[_mintId]);
        uint256 mintPrice = nft.getMintPrice();

        if (msg.value < mintPrice) revert NftMarketplace__NotEnoughFunds();

        uint256 tokenId = nft.safeMint{value: mintPrice}(msg.sender);

        emit NftMint(address(nft), tokenId, msg.sender);
    }

    // GETTERS
    function getListing(
        address _nft,
        uint256 _tokenId
    ) external view returns (Listing memory) {
        return s_listings[_nft][_tokenId];
    }

    function getMint(uint256 _mintId) external view returns (address) {
        return s_mints[_mintId];
    }
}
