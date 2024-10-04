import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OWNER_ADDRESS = "0xDaB8892C07FB4C362Dd99D9a2fBFf8B555D39Cb5";

const NftMarketplaceModule = buildModule("NftMarketplaceModule", (m) => {
  const ownerArgs = m.getParameter("owner", OWNER_ADDRESS);

  const nftMarketplace = m.contract("NftMarketplace", [ownerArgs]);

  return {
    nftMarketplace,
  };
});

export default NftMarketplaceModule;
