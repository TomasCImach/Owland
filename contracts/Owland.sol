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
    Counters.Counter private _tokenIds;

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
    function x(uint256 id) external pure returns(uint256) {
        //require(_ownerOf(id) != address(0), "token does not exist");
        return id % GRID_SIZE;
    }
    /// @notice y coordinate of Land token
    /// @param id tokenId
    /// @return the y coordinates
    function y(uint256 id) external pure returns(uint256) {
        //require(_ownerOf(id) != address(0), "token does not exist");
        return id / GRID_SIZE;
    }

    //Returns true if DOWL had already minted a OWLAND
    function checkOwl(uint256 _owlId) public view returns (bool){
        return hasMinted[_owlId];
    }

    function mint(uint256[] memory _owlIds) public payable {
        require(!paused, "Contract Paused");
        require(_tokenIds.current() + _owlIds.length <= maxMint, "Max NFTs minted.");
        require(_owlIds.length > 0, "mint more than 0 please");
        if (!isFree) {
            require(msg.value >= cost * _owlIds.length, "Pay me!");
        }
        
        for (uint256 i = 0; i < _owlIds.length; i++) {
            require(hasMinted[_owlIds[i]] == false, "Land already minted for this owl");
            require(darkowls.ownerOf(_owlIds[i]) == msg.sender, "Claimant is not the owner");

            hasMinted[_owlIds[i]] = true;
            mintLand();
        }
    }

    function mintLand() internal virtual {
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
    
        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    }

    //UNTESTED - Returns array of ids owned by address
    function tokensOfOwner(address _address) public view returns(uint256[] memory) {
        require(balanceOf(_address) > 0, "Wallet has no tokens");
        uint256[] memory _tokensOfOwner = new uint256[](balanceOf(_address));
        uint256 j = 0;
        uint256 i = 0;
        while (i < balanceOf(_address)) {
            if (ownerOf(j) == _address) {
                _tokensOfOwner[i] = j;
                i++;
            }
            j++;
        }
        return _tokensOfOwner;
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