import { ethers, upgrades } from "hardhat";

const wlm = "0x1Cf87CF9e01b4497674570BAA037844A3816B7A9";
const rjv = "0xA5e1033117D08B4E3dd48aeE89412495E217C0D4";

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
