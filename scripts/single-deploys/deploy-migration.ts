import { ethers, upgrades } from "hardhat";

const wlm = "0x1Cf87CF9e01b4497674570BAA037844A3816B7A9";
const rjv = "0x2B60Bd0D80495DD27CE3F8610B4980E94056b30c";

async function main() {
  const Migration = await ethers.getContractFactory("WLMMigration");
  const migration = await Migration.deploy(wlm, rjv);
  await migration.deployed();
  console.log("Migration deployed to:", migration.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
