import { ethers, upgrades } from "hardhat";

const wlm = "0xAE7c5644A5f7be2E57bD4095F57ecD4110465332";
const rjv = "0xAE7c5644A5f7be2E57bD4095F57ecD4110465332";

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
