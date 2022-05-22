import { ethers } from "hardhat";

const soldOnStart = BigInt("71513155628900000000000");
const tokenCap = BigInt("300000000000000000000000");

async function main() {
  const Presale = await ethers.getContractFactory("Presale");
  const presale = await Presale.deploy(soldOnStart, tokenCap);
  await presale.deployed();
  console.log("Presale deployed to:", presale.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
