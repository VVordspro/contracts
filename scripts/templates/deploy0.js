const hre = require("hardhat");
const { verify } = require("../utils/verifier.js")

async function main() {

  const Template0 = await hre.ethers.getContractFactory("Template0");
  const t0 = await Template0.deploy();

  await t0.deployed();

  console.log(
    `Template0 deployed to ${t0.address}`
  );

  await verify(t0.address)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
