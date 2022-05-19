import { ethers, upgrades } from "hardhat";

async function main() {
  const Whitelist = await ethers.getContractFactory("AddressRegistry");
  const whitelist = await upgrades.deployProxy(Whitelist, []);
  await whitelist.deployed();
  console.log("Whitelist deployed to:", whitelist.address);

  const Blacklist = await ethers.getContractFactory("AddressRegistry");
  const blacklist = await upgrades.deployProxy(Blacklist, []);
  await blacklist.deployed();
  console.log("Blacklist deployed to:", blacklist.address);

  const RJV = await ethers.getContractFactory("Rejuvenate");
  const rjv = await upgrades.deployProxy(RJV, [
    whitelist.address,
    blacklist.address,
  ]);
  await rjv.deployed();
  console.log("RJV deployed to:", rjv.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
