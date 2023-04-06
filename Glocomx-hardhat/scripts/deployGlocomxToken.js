const hre = require('hardhat');

async function main() { 
    const Glocomx = await hre.ethers.getContractFactory("Glocomx");
    const ERC20 = await Glocomx.deploy();
    await ERC20.deployed();
    console.log("Glocomx deployed to:", ERC20.address);
}




main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });