import { ethers } from "hardhat";

async function main() {
  const Registry = await ethers.getContractFactory("AddressRegistry");
  const reg = await Registry.deploy();
  await reg.deployed();
  console.log("registry deployed to:", reg.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
