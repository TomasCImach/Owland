# Dark Owls Land NFTs

There will be a total of 2500 Land parcels, all of them make the Owl Estate. From (0,0) to (49,49)

The Estate will be divided by 50 x 50, each Land parcel can be positioned by its coorinates (15, 25).
The id of the NFT is such that x=id%50 and y=id/50. id=x+y*50.

278 plots will be a community area, owned by the project. WHICH WALLET WILL OWN THESE?
Each of the 2222 plots correspond to a Dark Owl NFT and can be claimed by its owner.

Set Base URI to: ipfs://QmefNJkJPsvqyHTBUZF3ACGwXnhmgEoUWJXRLzwYQJQyNN/
Set darkowls to: 0x2849D61bB776A45B862f23C72Fa544Db9Fb3E2d4

The following states can be modified by the owner of the contract:
    maxMint - maximum quantity of lands
    isFree - if the plots can be minted for free or for a price
    cost - the price op each NFT if isFree is FALSE
    costRare - cost for type B plots
    paused - pauses minting if TRUE
    rareByAllowance - 
    rareByPublic - 
    darkowls - Dark Owls NFT SC Address
    baseURI - 
    baseExtension - 
    stakingAddress - sets address of the staking smart contract
    publicMinting - change to true for allowing public to mint common lands for a price
    maxPublicMint - sets the maximum amount of public minting in one transaction

Contructor:
    - sepecifies special plots
    - Specify types a and b plots

TODO:    
