import { ethers, upgrades } from "hardhat";

async function main() {
  const Registry = await ethers.getContractFactory("AddressRegistry");
  const reg = await upgrades.deployProxy(Registry, []);
  await reg.deployed();
  console.log("reg deployed to:", reg.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
