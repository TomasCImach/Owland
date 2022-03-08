# Test on 0x54A186829F19078110D7D760B3D3aE4187fc842D

Changed DOWL address -- success

*** totalSupply changed to public *** success on V2

constructor chaged typeAPlots success

baseURI empty. Changed success
*** URI not showing .json baseExtension *** success on V2 - Showing metadata on Opensea

Width and high success at 50.

x and y responds success

*** getTokenIdByCoordinates(0,26) return 1300 -- Implemented FIX *** Success V2

checkOwl all false

mintByCoordinates
    (2,2,2) - testing wallet no owl's owner - Fail with error 'Claimant is not the owner'
    *** changed grid size verification *** Tested on getTokenIdByCoordinates
    (2,51,0) - testing out of bound - Fail with error 'Coordinates out of bounds'
    (2,2,0) - success Id 102 (gas 135k)

mintLands
    ([103,104,105],[2,3]) - testing not equal minting and owls - Fail with error 'Put as many Lands as Owl Ids'
    ([103,104],[0,3]) - testing land minted for this role - Fail with error 'Land already minted for this owl'
    ([103,104],[1,3]) - testing not owl owner - Fail with error 'Claimant is not the owner'
    ([103,104],[2,3]) - success (gas 176k - 88/u)
    ([105],[1]) - success (gas 102k) -- 30% less gas than mintByCoordinates
    *** test outbound coordinates *** success V2

tokensOfOwner
    tested with random address -- success "wallet has no tokens"
    *** for valid address - uint256[] :  Error: Returned error: execution reverted: ERC721: owner query for nonexistent token - Implemented FIX with if _exists *** success V2