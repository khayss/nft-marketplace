import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OWNER_ADDRESS = "";

const NftMarketplaceModule = buildModule("NftMarketplaceModule", (m) => {
  const ownerArgs = m.getParameter("owner", OWNER_ADDRESS);

  const nftMarketplace = m.contract("NftMarketplace", [ownerArgs]);

  return {
    nftMarketplace,
  };
});

export default NftMarketplaceModule;
