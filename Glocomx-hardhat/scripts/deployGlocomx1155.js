    const hre = require('hardhat');

    async function main() { 
        const ownerAddress = '0xeA29891b492Bd2bb13ab2a57C35650762D2d38e4';
        const Glocomx1155 = await hre.ethers.getContractFactory("Glocomx1155");
        const ERC1155 = await Glocomx1155.deploy(ownerAddress, [10000, 20000], [10, 20]);
        await ERC1155.deployed();
        console.log("Glocomx1155 deployed to:", ERC1155.address);
    }
    
    
    
    
    main()
      .then(() => process.exit(0))
      .catch((error) => {
        console.error(error);
        process.exit(1);
      });