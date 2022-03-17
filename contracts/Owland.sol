// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Owland is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public totalSupply;

    DarkOwls public darkowls;

    string public baseURI;

    uint256 public cost = 0.004 ether;
    uint256 public costRare = 0.01 ether;
    //uint256 public maxMint = 2500;
    uint256 public maxPublicMint = 4;
    bool public paused = false;
    bool public publicMinting = false;
    bool public rareByAllowance = false;
    bool public rareByPublic = false;
    bool public isFree = true;
    mapping(uint256 => bool) public typeAPlots;
    mapping(uint256 => bool) public typeBPlots;
    mapping(address => uint256) public rareAllowance;
    mapping(uint => bool) public hasMinted;
    address public stakingAddress;

    uint256 internal constant GRID_SIZE = 50;

    constructor() ERC721 ("OwLand", "OWLAND") {
        uint16[36] memory aTypePlots = [0, 14, 24, 25, 34, 49, 459, 469, 479, 489, 700, 749, 959, 989, 1200, 1224, 1225, 1249, 1250, 1274, 1275, 1299, 1459, 1489, 1700, 1749, 1959, 1969, 1979, 1989, 2450, 2464, 2474, 2475, 2484, 2499];
        for (uint256 i = 0; i < aTypePlots.length; i++) {
            typeAPlots[aTypePlots[i]] = true;
        }
        uint16[242] memory bTypePlots = [1, 2, 23, 26, 47, 48, 50, 51, 64, 74, 75, 84, 98, 99, 100, 149, 408, 409, 410, 418, 419, 420, 428, 429, 430, 438, 439, 440, 458, 460, 468, 470, 478, 480, 488, 490, 508, 509, 510, 518, 519, 520, 528, 529, 530, 538, 539, 540, 701, 748, 908, 909, 910, 938, 939, 940, 958, 960, 974, 975, 988, 990, 1008, 1009, 1010, 1020, 1021, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1038, 1039, 1040, 1070, 1071, 1072, 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1120, 1121, 1122, 1123, 1124, 1125, 1126, 1127, 1128, 1129, 1150, 1170, 1171, 1172, 1173, 1174, 1175, 1176, 1177, 1178, 1179, 1199, 1201, 1219, 1220, 1221, 1222, 1223, 1226, 1227, 1228, 1229, 1230, 1248, 1251, 1269, 1270, 1271, 1272, 1273, 1276, 1277, 1278, 1279, 1280, 1298, 1300, 1320, 1321, 1322, 1323, 1324, 1325, 1326, 1327, 1328, 1329, 1349, 1370, 1371, 1372, 1373, 1374, 1375, 1376, 1377, 1378, 1379, 1408, 1409, 1410, 1420, 1421, 1422, 1423, 1424, 1425, 1426, 1427, 1428, 1429, 1438, 1439, 1440, 1458, 1460, 1470, 1471, 1472, 1473, 1474, 1475, 1476, 1477, 1478, 1479, 1488, 1490, 1508, 1509, 1510, 1538, 1539, 1540, 1701, 1748, 1908, 1909, 1910, 1918, 1919, 1920, 1928, 1929, 1930, 1938, 1939, 1940, 1958, 1960, 1968, 1970, 1978, 1980, 1988, 1990, 2008, 2009, 2010, 2018, 2019, 2020, 2028, 2029, 2030, 2038, 2039, 2040, 2350, 2399, 2400, 2401, 2414, 2424, 2425, 2434, 2448, 2449, 2451, 2452, 2473, 2476, 2497, 2498];
        for (uint256 i = 0; i < bTypePlots.length; i++) {
            typeBPlots[bTypePlots[i]] = true;
        }

        baseURI = "ipfs://QmULxBcpD1faHAR8Xxa9ombntY2REvrKmQZ6LCKPcgbwrf/"; //for tests only
        darkowls = DarkOwls(0x2849D61bB776A45B862f23C72Fa544Db9Fb3E2d4); //for tests only
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
        return id % GRID_SIZE;
    }
    /// @notice y coordinate of Land token
    /// @param id tokenId
    /// @return the y coordinates
    function y(uint256 id) public pure returns(uint256) {
        return id / GRID_SIZE;
    }
    ///
    function getTokenIdByCoordinates(uint256 _x, uint256 _y) public pure returns(uint256) {
        require(_x < GRID_SIZE && _y < GRID_SIZE);
        return _x + _y * GRID_SIZE;
    }

    //Returns true if DOWL had already minted a OWLAND
    function checkOwl(uint256 _owlId) public view returns (bool){
        return hasMinted[_owlId];
    }

    function mintByCoordinates(uint256 _x, uint256 _y, uint256 _owlId, bool _stake) external payable {
        require(!paused, "Pause");
        //require(totalSupply.current() + 1 <= maxMint, "Max NFTs minted."); //See if required
        if (!isFree) {
            require(msg.value >= cost);
        }
        // Check if Owls Ids have minted a Land and is Owned by msg sender
        require(hasMinted[_owlId] == false, "Invalid Owl");
        require(darkowls.ownerOf(_owlId) == msg.sender, "Not owner");
        hasMinted[_owlId] = true;
        // Check if coordinates are inside grid
        require(_x < GRID_SIZE && _y < GRID_SIZE, "out of bounds");

        _mintLand(_x + _y * GRID_SIZE, _stake);
    }

    function mintLands(uint256[] calldata _tokenIds, uint256[] calldata _owlIds, bool _stake) external payable {
        require(!paused, "Pause");
        require(_tokenIds.length == _owlIds.length, "#lands = #owls");
        require(_owlIds.length > 0, ">0"); // see if required
        if (!isFree) {
            require(msg.value >= cost * _owlIds.length, "Pay me!");
        }
        
        // Check if Owls Ids have minted a Land and is Owned by msg sender
        for (uint256 i = 0; i < _owlIds.length; i++) {
            require(hasMinted[_owlIds[i]] == false, "Invalid Owl");
            require(darkowls.ownerOf(_owlIds[i]) == msg.sender, "Not owner");
            hasMinted[_owlIds[i]] = true;
        }

        // Check if coordinates are inside grid
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _tokenId = _tokenIds[i];
            require(x(_tokenId) < GRID_SIZE && y(_tokenId) < GRID_SIZE, "out of bounds");
        }
        
        _mintLand(_tokenIds, _stake);
    }

    function mintEpicPlotsOwner(address _to, uint256[] calldata _tokenIds) external onlyOwner {
        require(_tokenIds.length > 0, ">0"); // see if required

        // Requires is reserved plot and mints to _to
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _tokenId = _tokenIds[i];
            require(typeAPlots[_tokenId], "Epic");
            _safeMint(_to, _tokenId);
            totalSupply.increment();
        }
    }

    function mintRarePlotsOwner(address _to, uint256[] calldata _tokenIds) external onlyOwner {
        require(_tokenIds.length > 0, ">0"); // see if required

        // Requires is reserved plot and mints to _to
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _tokenId = _tokenIds[i];
            require(typeBPlots[_tokenId], "Rare");
            _safeMint(_to, _tokenId);
            totalSupply.increment();
        }
    }

    function mintRarePlots(uint256[] calldata _tokenIds, bool _stake) external payable {
        address sender = _msgSender();
        require(!paused, "Pause");
        require((rareByAllowance && !rareByPublic) || (!rareByAllowance && rareByPublic), "R");
        require(_tokenIds.length > 0, ">0");
        require(msg.value >= costRare * _tokenIds.length);

        if (rareByPublic) {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                uint256 _tokenId = _tokenIds[i];
                require(typeBPlots[_tokenId], "Rare");

                if (!_stake) {
                    _safeMint(msg.sender, _tokenId); // Don't stake, mint to the sender address
                } else {
                    require(stakingAddress != address(0), "no staking");
                    _safeMint(stakingAddress, _tokenId); // Mint to the staking address
                }
                totalSupply.increment();
            }
        }
        
        if (rareByAllowance) {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                require(rareAllowance[sender] > 0, "maxed allowed amount");
                uint256 _tokenId = _tokenIds[i];
                require(typeBPlots[_tokenId], "Rare");

                if (!_stake) {
                    _safeMint(msg.sender, _tokenId); // Don't stake, mint to the sender address
                } else {
                    require(stakingAddress != address(0), "no staking");
                    _safeMint(stakingAddress, _tokenId); // Mint to the staking address
                }
                rareAllowance[sender]--;
                totalSupply.increment();
            }
        }
    }

    function mintByCoordinatesPublic(uint256 _x, uint256 _y, bool _stake) external payable {
        require(!paused, "Pause");
        require(publicMinting, "Public minting disabled");
        //require(totalSupply.current() + 1 <= maxMint, "Max NFTs minted."); //See if required
        require(msg.value >= cost);
        
        // Check if coordinates are inside grid
        require(_x < GRID_SIZE && _y < GRID_SIZE);

        _mintLand(_x + _y * GRID_SIZE, _stake);
    }

    function mintLandsPublic(uint256[] calldata _tokenIds, bool _stake) external payable {
        require(!paused, "Pause");
        require(publicMinting, "Public minting disabled");
        //require(totalSupply.current() + _tokenIds.length <= maxMint, "Max NFTs minted."); //See if required
        require(_tokenIds.length > 0, ">0"); // see if required
        require(_tokenIds.length < maxPublicMint + 1, "Exceded the maximum minting amount by one Tx");
        require(msg.value >= cost * _tokenIds.length);

        // Check if coordinates are inside grid
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _tokenId = _tokenIds[i];
            require(x(_tokenId) < GRID_SIZE && y(_tokenId) < GRID_SIZE, "Coordinates out of bounds");
        }
        
        _mintLand(_tokenIds, _stake);
    }

    function _mintLand(uint256 _tokenId, bool _stake) internal virtual {
        uint256[] memory _tokenIds = new uint256[](1);
        _tokenIds[0] = _tokenId;
        _mintLand(_tokenIds, _stake);
    }

    function _mintLand(uint256[] memory _tokenIds, bool _stake) internal virtual {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _tokenId = _tokenIds[i];
            require(!typeAPlots[_tokenId], "Common");
            require(!typeBPlots[_tokenId], "Common");
            if (!_stake) {
                _safeMint(msg.sender, _tokenId); // Don't stake, mint to the sender address
            } else {
                require(stakingAddress != address(0), "no staking");
                _safeMint(stakingAddress, _tokenId); // Mint to the staking address
            }
            
            totalSupply.increment();
        }
    }

    function tokensOfOwner(address _address) public view returns(uint256[] memory) {
        require(balanceOf(_address) > 0, "no tks");
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

    // onlyOwner functions
    //function setMaxMint(uint256 _maxMint) external onlyOwner {
    //    maxMint = _maxMint;
    //}
    function setCost(uint256 _cost) external onlyOwner {
        cost = _cost;
    }
    function setCostRare(uint256 _cost) external onlyOwner {
        costRare = _cost;
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
    function setStakingAddress(address _stakingAddress) external onlyOwner {
        stakingAddress = _stakingAddress;
    }
    function setPublicMinting(bool _publicMinting) public onlyOwner {
        publicMinting = _publicMinting;
    }
    function setRareByAllowance(bool _rareByAllowance) public onlyOwner {
        rareByAllowance = _rareByAllowance;
        require(!(rareByAllowance && rareByPublic), "rare by allowance and public true");
    }
    function setRareByPublic(bool _rareByPublic) public onlyOwner {
        rareByPublic = _rareByPublic;
        require(!(rareByAllowance && rareByPublic), "rare by allowance and public true");
    }
    function setMaxPublicMint(uint256 _maxPublicMint) external onlyOwner {
        maxPublicMint = _maxPublicMint;
    }
    function addRareAllowanceToAddress(address _to, uint256 _allowance) external onlyOwner {
        uint256 currentAllowance = rareAllowance[_to];
        rareAllowance[_to] = currentAllowance + _allowance;
    }
    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    // Allows staking contract to make transfer on behalf of owner
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        address sender = _msgSender();
        require(_isApprovedOrOwner(sender, tokenId) || sender == stakingAddress, "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }
}

interface DarkOwls {
    
    function walletOfOwner(address _owner) external view returns (uint256[] memory);
    function ownerOf(uint256 tokenId) external view returns (address);
    
}