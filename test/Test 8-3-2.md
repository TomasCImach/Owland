# Test on 0xBAbe99fe1A9Aa7DA8653bC040a8E1d7A3Ad9409B

totalSupply is readable

mintLands x 2 gas 194k
    totalSupply = 2
    tokenURI ok
    ([2551],[2]) - testing out of bounds y=51 - Fail with error 'Coordinates out of bounds'
    [50] - x=0 - Fail with error 'Coordinates out of bounds'
    [2] - y=0 - Fail with error 'Coordinates out of bounds'
    ([201,202,203,204],[2,3,4,5]) - success (gas 293k - 73/u)

tokensOfOwner
    success!!!

typeAPlot minting - mintLands ([51],[6]) - success Fail with error 'Cannot claim type A Plots'
