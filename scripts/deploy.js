const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying ProductionMarket with:", deployer.address);
  console.log("Balance:", (await hre.ethers.provider.getBalance(deployer.address)).toString());

  const ProductionMarket = await hre.ethers.getContractFactory("ProductionMarket");
  
  // Platform fee receiver = deployer
  const contract = await ProductionMarket.deploy(deployer.address);
  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log("ProductionMarket deployed to:", address);
  console.log("Network:", hre.network.name);
  
  // Verify on BaseScan if not local
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("Waiting for block confirmations...");
    await new Promise(resolve => setTimeout(resolve, 30000));
    
    try {
      await hre.run("verify:verify", {
        address: address,
        constructorArguments: [deployer.address],
      });
      console.log("Contract verified on BaseScan!");
    } catch (e) {
      console.log("Verification failed (may need manual):", e.message);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
