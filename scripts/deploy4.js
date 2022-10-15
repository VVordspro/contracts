/* global describe it before ethers */

const {
    getSelectors,
    FacetCutAction
  } = require('./libraries/diamond.js')
      
  const { assert } = require('chai')
  
  async function deployVRF () { 
  
    const diamondAddress = "0x92Ef5499cE50B6fA356843C842643F2Ab65D8e30" //deploy3 diamond on polygon
    let  diamondCut = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
  
    let tx
  
  
    // deploy facet
    console.log('')
    console.log('Deploying VRF')
    const FacetName = "VRF"
    const cut = []
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy()
    await facet.deployed()
    console.log(`${FacetName} deployed: ${facet.address}`)
    cut.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet).remove(['init()'])
    })
  
    // upgrade diamond with facet
    console.log('')
    console.log('Diamond Cut:', cut)
    let functionCall = facet.interface.encodeFunctionData('init')
    tx = await diamondCut.diamondCut(cut, facet.address, functionCall)
    console.log('Diamond cut tx: ', tx.hash)
    console.log('Completed diamond cut')
    return facet.address
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  if (require.main === module) {
    deployVRF()
      .then(() => process.exit(0))
      .catch(error => {
        console.error(error)
        process.exit(1)
      })
  }
  
  exports.deployVRF = deployVRF