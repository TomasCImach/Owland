// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { Base64 } from "./libraries/Base64.sol";

contract Owland is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    DarkOwls public darkowls;

    uint256 public cost = 0.004 ether;
    uint256 public maxMint = 2500;
    bool public paused = false;
    bool public isFree = true;
    event NewOwlandMinted(address sender, uint256 tokenId);

    mapping(uint => bool) public hasMinted;

    //grid size of 50 by 50
    uint256 internal constant GRID_SIZE = 50;

    // SVG creation
    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    string[] firstWords = ["land", "toke", "tierra"];
    //string[] secondWords = ["1", "2", "3", "4", "5", "6"];
    string[] thirdWords = ["owl", "sova", "ugle", "pollo", "buho"];
    string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green"];


    constructor() ERC721 ("OwLand", "OWLAND") {}

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

    // randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        rand = rand % firstWords.length;
        return firstWords[rand];
    }
    /*function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }*/
    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }
    function pickRandomColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
        rand = rand % colors.length;
        return colors[rand];
    }
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function checkOwl(uint256 _owlId) public view returns (bool){
        return hasMinted[_owlId];
    }

    function mint(uint256[] memory _owlIds) public payable {
        require(!paused);
        require(_tokenIds.current() + _owlIds.length <= maxMint, "Max NFTs minted.");
        require(_owlIds.length > 0, "mint more than 0 please");
        if (!isFree) {
            require(msg.value >= cost * _owlIds.length, "Pay me!");
        }
        
        for (uint256 i = 0; i < _owlIds.length; i++) {
            require(hasMinted[_owlIds[i]] == false, "Land already minted for this owl");
            require(darkowls.ownerOf(_owlIds[i]) == msg.sender, "Claimant is not the owner");

            hasMinted[_owlIds[i]] = true;
            makeAnEpicNFT();
        }
    }

    function makeAnEpicNFT() internal virtual {
        require(_tokenIds.current() <= maxMint - 1, "Max NFTs minted. Again");
        uint256 newItemId = _tokenIds.current();

        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = Strings.toString(newItemId); //pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // Add the random color in.
        string memory randomColor = pickRandomColor(newItemId);
        string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of lands.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(
            string(
            abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);
    
        // Update your URI!!!
        _setTokenURI(newItemId, finalTokenUri);
    
        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        emit NewOwlandMinted(msg.sender, newItemId);
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
}

interface DarkOwls {
    
    function walletOfOwner(address _owner) external view returns (uint256[] memory);
    function ownerOf(uint256 tokenId) external view returns (address);
    
}