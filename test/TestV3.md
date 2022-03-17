

mintReservedPlots - SUCCESS
    by owner (0xe2960F53Fd160Ce71195Bd6201B87493719cB0eD (DOWL), [700]) - Success - ERC721: transfer to non ERC721Receiver implementer
    by owner (0xC64F9a145E00172E13EeddC097A096bd806ab464, [700]) - success gas 100k
    *** ERASED PAYABLE ***

transferFrom - Staking ennable - SUCCESSS
    by owner - success - 'ERC721: transfer caller is not owner nor approved'
    by stakeAddress - success gas 47k

_mintLand stake if - SUCCESS
    mint with stake=true and stakeAddress=0 - success - Fail with error 'Staking not available'
    mint with stake=false and stakeAddress=0 - success gas 114k
    mint with stake=true and stakeAddress=0xC64F9a145E00172E13EeddC097A096bd806ab464 - success gas 102k

verify out of bounds - SUCCESS

try mint negatives 

public minting - SUCCESS
    when paused - success - Fail with error 'Public minting disabled'
    when public=true but no ether - success Fail with error 'Pay me!'
    when public=true value=.004 - success 85k