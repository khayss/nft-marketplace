import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("NftMarketplace", () => {
  async function deployNftMarketplace() {
    const [account1, account2, otherAccounts] = await ethers.getSigners();
    const NftMarketplace = await ethers.getContractFactory("NftMarketplace");
    const nftMarketplace = await NftMarketplace.deploy(account1.address);

    return { nftMarketplace, account1, account2, otherAccounts };
  }

  describe("deployment", () => {
    it("should set the owner to the deployer", async () => {
      const { nftMarketplace, account1 } = await loadFixture(
        deployNftMarketplace
      );
      expect(await nftMarketplace.owner()).to.equal(account1.address);
    });
  });
});
