import { ethers } from "hardhat";

const forSaleCur = "0x2B60Bd0D80495DD27CE3F8610B4980E94056b30c";
const paymentCur = "";
const pricePerToken = BigInt(100000000000000000000000000000000);
const reasury = "";
const dev = "";
const tokenCap = BigInt(100000000000000000000000000000000);

async function main() {
  const Presale = await ethers.getContractFactory("Presale");
  const presale = await Presale.deploy(
    forSaleCur,
    paymentCur,
    pricePerToken,
    reasury,
    dev,
    tokenCap
  );
  await presale.deployed();
  console.log("Presale deployed to:", presale.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
