/* global describe it before ethers */

const {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets
} = require('../scripts/libraries/diamond.js')

const { deployDiamond } = require('../scripts/deploy.js')

const { assert } = require('chai')

describe('DiamondTest', async function () {
  let diamondAddress
  let diamondCutFacet
  let diamondLoupeFacet
  let ownershipFacet
  let tx
  let receipt
  let result    
  let zero_address
  let deployer, user1, user2
  const addresses = []

  before(async function () {
    diamondAddress = await deployDiamond()
    diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
    diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)
    ownershipFacet = await ethers.getContractAt('OwnershipFacet', diamondAddress)

    zero_address = "0x0000000000000000000000000000000000000000"
    const accounts = await ethers.getSigners();
    [deployer, user1, user2] = accounts
  })

  it('should have three facets -- call to facetAddresses function', async () => {
    for (const address of await diamondLoupeFacet.facetAddresses()) {
      addresses.push(address)
    }

    assert.equal(addresses.length, 3)
  })

  it('facets should have the right function selectors -- call to facetFunctionSelectors function', async () => {
    let selectors = getSelectors(diamondCutFacet)
    result = await diamondLoupeFacet.facetFunctionSelectors(addresses[0])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(diamondLoupeFacet)
    result = await diamondLoupeFacet.facetFunctionSelectors(addresses[1])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(ownershipFacet)
    result = await diamondLoupeFacet.facetFunctionSelectors(addresses[2])
    assert.sameMembers(result, selectors)
  })

  it('selectors should be associated to facets correctly -- multiple calls to facetAddress function', async () => {
    assert.equal(
      addresses[0],
      await diamondLoupeFacet.facetAddress('0x1f931c1c')
    )
    assert.equal(
      addresses[1],
      await diamondLoupeFacet.facetAddress('0xcdffacc6')
    )
    assert.equal(
      addresses[1],
      await diamondLoupeFacet.facetAddress('0x01ffc9a7')
    )
    assert.equal(
      addresses[2],
      await diamondLoupeFacet.facetAddress('0xf2fde38b')
    )
  })

  it('should add ERC1155 functions', async () => {
    const ERC1155SolidState = await ethers.getContractFactory('ERC1155SolidState', diamondAddress)
    const ERC1155 = await ERC1155SolidState.deploy()
    await ERC1155.deployed()
    addresses.push(ERC1155.address)
    const selectors = getSelectors(ERC1155).remove([
      'init()', 'uri(uint256)', 'supportsInterface(bytes4)'
    ])
    tx = await diamondCutFacet.diamondCut(
      [{
        facetAddress: ERC1155.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
      }],
      ERC1155.address, 
      ERC1155.interface.encodeFunctionData('init')
    )
    receipt = await tx.wait()
    if (!receipt.status) {
      throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(ERC1155.address)
    assert.sameMembers(result, selectors)
  })

  it('should test ERC1155 function call', async () => {
    const ERC1155 = await ethers.getContractAt('ERC1155SolidState', diamondAddress)
    await ERC1155.paused()
  })

  it('should add words functions', async () => {
    const Words = await ethers.getContractFactory('Words', diamondAddress)
    const words = await Words.deploy()
    await words.deployed()
    addresses.push(words.address)
    const selectors = getSelectors(words).remove([
      'init()'
    ])
    tx = await diamondCutFacet.diamondCut(
      [{
        facetAddress: words.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
      }],
      words.address, 
      words.interface.encodeFunctionData('init')
    )
    receipt = await tx.wait()
    if (!receipt.status) {
      throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(words.address)
    assert.sameMembers(result, selectors)
  })

  it('should test words function call', async () => {
    const words = await ethers.getContractAt('Words', diamondAddress)
    await words.nextTokenId()
  })

  it('should add power functions', async () => {
    const Power = await ethers.getContractFactory('Power', diamondAddress)
    const power = await Power.deploy()
    await power.deployed()
    addresses.push(power.address)
    const selectors = getSelectors(power).remove([
      'init()'
    ])
    tx = await diamondCutFacet.diamondCut(
      [{
        facetAddress: power.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
      }],
      power.address, 
      power.interface.encodeFunctionData('init')
    )
    receipt = await tx.wait()
    if (!receipt.status) {
      throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(power.address)
    assert.sameMembers(result, selectors)
  })

  it('should test power function call', async () => {
    const power = await ethers.getContractAt('Power', diamondAddress)
    assert.equal(
      await power.totalPower(),
      0
    )
  })

  it('should add OnchainMetadata functions', async () => {
    const OnchainMetadata = await ethers.getContractFactory('OnchainMetadata', diamondAddress)
    const metadata = await OnchainMetadata.deploy()
    await metadata.deployed()
    addresses.push(metadata.address)
    const selectors = getSelectors(metadata).remove([
      'init()'
    ])
    tx = await diamondCutFacet.diamondCut(
      [{
        facetAddress: metadata.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
      }],
      metadata.address, 
      metadata.interface.encodeFunctionData('init')
    )
    receipt = await tx.wait()
    if (!receipt.status) {
      throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(metadata.address)
    assert.sameMembers(result, selectors)
  })

  it('should mint a new vvord', async () => {
    const words = await ethers.getContractAt('Words', diamondAddress)
    await words.mintVVord(
      ["first line", "second line", "third line"],
      "test tags",
      "test url",
      0,
      deployer.address
    )
  })

  it('should return token 0 template address', async () => {
    const metadata = await ethers.getContractAt('OnchainMetadata', diamondAddress)
    console.log(await metadata.tokenTemplateAddress(0))
  })

  it('should return uri of token number 0', async () => {
    const metadata = await ethers.getContractAt('OnchainMetadata', diamondAddress)
    console.log(await metadata.uri(0))
  })

})