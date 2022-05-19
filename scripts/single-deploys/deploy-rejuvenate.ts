import { ethers, upgrades } from "hardhat";

const whitelist = "";
const blacklist = "";

async function main() {
  const RJV = await ethers.getContractFactory("Rejuvenate");
  const rjv = await upgrades.deployProxy(RJV, [whitelist, blacklist]);
  await rjv.deployed();
  console.log("RJV deployed to:", rjv.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
