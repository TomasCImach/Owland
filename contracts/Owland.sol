// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { Base64 } from "./libraries/Base64.sol";

contract Owland is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256; //only for tokenURI override
    Counters.Counter public totalSupply;

    DarkOwls public darkowls;

    string public baseURI;
    string public baseExtension = ".json";

    uint256 public cost = 0.004 ether;
    uint256 public maxMint = 2500;
    bool public paused = false;
    bool public isFree = true;
    mapping(uint256 => bool) public typeAPlots;

    mapping(uint => bool) public hasMinted;

    //grid size of 50 by 50
    uint256 internal constant GRID_SIZE = 50;

    constructor() ERC721 ("OwLand", "OWLAND") {
        // Sepecial plots:
        uint16[38] memory aTypePlots = [51, 65, 75, 76, 85, 100, 510, 520, 530, 540, 751, 775, 776, 800, 1010, 1040, 1251, 1285, 1300, 1301, 1335, 1350, 1510, 1540, 1751, 1775, 1776, 1800, 510, 520, 530, 540, 2501, 2515, 2525, 2526, 2535, 2550];
        for (uint256 i = 0; i < 38; i++) {
            typeAPlots[aTypePlots[i]] = true;
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // Manages the id and retrieves the coordinates of the Land Plot (x,y)
    /// @notice total width of the map
    /// @return width
    function width() external pure returns(uint256) {
        return GRID_SIZE;
    }
    /// @notice total height of the map
    /// @return height
    function height() external pure returns(uint256) {
        return GRID_SIZE;
    }
    /// @notice x coordinate of Land token
    /// @param id tokenId
    /// @return the x coordinates
    function x(uint256 id) public pure returns(uint256) {
        //require(_ownerOf(id) != address(0), "token does not exist");
        return id % GRID_SIZE;
    }
    /// @notice y coordinate of Land token
    /// @param id tokenId
    /// @return the y coordinates
    function y(uint256 id) public pure returns(uint256) {
        //require(_ownerOf(id) != address(0), "token does not exist");
        return id / GRID_SIZE;
    }
    ///
    function getTokenIdByCoordinates(uint256 _x, uint256 _y) public pure returns(uint256) {
        require(_x <= GRID_SIZE && _y <= GRID_SIZE && _x > 0 && _y > 0, "Coordinates out of bounds");
        return _x + _y * GRID_SIZE;
    }

    //Returns true if DOWL had already minted a OWLAND
    function checkOwl(uint256 _owlId) public view returns (bool){
        return hasMinted[_owlId];
    }

    function mintByCoordinates(uint256 _x, uint256 _y, uint256 _owlId) external payable {
        require(!paused, "Contract Paused");
        require(totalSupply.current() + 1 <= maxMint, "Max NFTs minted."); //See if required
        if (!isFree) {
            require(msg.value >= cost, "Pay me!");
        }
        // Check if Owls Ids have minted a Land and is Owned by msg sender
        require(hasMinted[_owlId] == false, "Land already minted for this owl");
        require(darkowls.ownerOf(_owlId) == msg.sender, "Claimant is not the owner");
        hasMinted[_owlId] = true;
        // Check if coordinates are inside grid
        require(_x <= GRID_SIZE && _y <= GRID_SIZE && _x > 0 && _y > 0, "Coordinates out of bounds");

        _mintLand(_x + _y * GRID_SIZE);
    }

    function mintLands(uint256[] calldata _tokenIds, uint256[] calldata _owlIds) external payable {
        require(!paused, "Contract Paused");
        require(_tokenIds.length == _owlIds.length, "Put as many Lands as Owl Ids");
        require(totalSupply.current() + _owlIds.length <= maxMint, "Max NFTs minted."); //See if required
        require(_owlIds.length > 0, "mint more than 0 please"); // see if required
        if (!isFree) {
            require(msg.value >= cost * _owlIds.length, "Pay me!");
        }
        
        // Check if Owls Ids have minted a Land and is Owned by msg sender
        for (uint256 i = 0; i < _owlIds.length; i++) {
            require(hasMinted[_owlIds[i]] == false, "Land already minted for this owl");
            require(darkowls.ownerOf(_owlIds[i]) == msg.sender, "Claimant is not the owner");
            hasMinted[_owlIds[i]] = true;
        }

        // Check if coordinates are inside grid
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _tokenId = _tokenIds[i];
            require(x(_tokenId) <= GRID_SIZE && y(_tokenId) <= GRID_SIZE && x(_tokenId) > 0 && y(_tokenId) > 0, "Coordinates out of bounds");
        }
        
        _mintLand(_tokenIds);
    }

    function _mintLand(uint256 _tokenId) internal virtual {
        uint256[] memory _tokenIds = new uint256[](1);
        _tokenIds[0] = _tokenId;
        _mintLand(_tokenIds);
    }

    function _mintLand(uint256[] memory _tokenIds) internal virtual {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _tokenId = _tokenIds[i];
            require(!typeAPlots[_tokenId], "Cannot claim type A Plots");
            _safeMint(msg.sender, _tokenId);
            totalSupply.increment();
            console.log("An NFT w/ ID %s has been minted to %s", _tokenId, msg.sender);
        }
    }

    //UNTESTED - Returns array of ids owned by address
    function tokensOfOwner(address _address) public view returns(uint256[] memory) {
        require(balanceOf(_address) > 0, "Wallet has no tokens");
        uint256[] memory _tokensOfOwner = new uint256[](balanceOf(_address));
        uint256 j = 0;
        uint256 i = 0;
        while (i < balanceOf(_address)) {
            if (_exists(j)) {
                if (ownerOf(j) == _address) {
                    _tokensOfOwner[i] = j;
                    i++;
                }
            }
            j++;
        }
        return _tokensOfOwner;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), baseExtension)): "";
    }

    // onlyOwner functions
    function setMaxMint(uint256 _maxMint) external onlyOwner {
        maxMint = _maxMint;
    }
    function setCost(uint256 _cost) external onlyOwner {
        cost = _cost;
    }
    function setPause(bool _state) public onlyOwner {
        paused = _state;
    }
    function setIsFree(bool _state) public onlyOwner {
        isFree = _state;
    }
    function setDarkOwlsAddress(address _darkowlsAddress) public onlyOwner {
        darkowls = DarkOwls(_darkowlsAddress);
    }
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }
}

interface DarkOwls {
    
    function walletOfOwner(address _owner) external view returns (uint256[] memory);
    function ownerOf(uint256 tokenId) external view returns (address);
    
}