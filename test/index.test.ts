import { expect } from "chai";
import { ethers, name, symbol } from "hardhat";
import { RealT } from "../typechain";

let realtToken: RealT;

describe("Realt Factory", function () {
  beforeEach(async () => {
    const [, ACPI_MODERATOR] = await ethers.getSigners();

    const RealtFactory = await ethers.getContractFactory("RealT");
    realtToken = await RealtFactory.deploy(
      name,
      symbol,
      ACPI_MODERATOR.address
    );
    await realtToken.deployed();
  });

  it("Should be ACPI 0", async function () {
    expect(await realtToken.getACPI()).to.equal(0);
  });

  it("Should set ACPI to 1", async function () {
    await realtToken.setACPI(1);

    expect(await realtToken.getACPI()).to.equal(1);
  });

  it("Should set ACPI to 2", async function () {
    await realtToken.setACPI(2);

    expect(await realtToken.getACPI()).to.equal(2);
  });

  it("Should set ACPI to 3", async function () {
    await realtToken.setACPI(3);

    expect(await realtToken.getACPI()).to.equal(3);
  });

  it("Should set ACPI to 4", async function () {
    await realtToken.setACPI(4);

    expect(await realtToken.getACPI()).to.equal(4);
  });

  it("Should set ACPI to 5", async function () {
    await realtToken.setACPI(5);

    expect(await realtToken.getACPI()).to.equal(5);
  });

  it("Should set ACPI to 6", async function () {
    await expect(realtToken.setACPI(6)).revertedWith("Allowed value is 0-5");
  });

  it("Test permission", async function () {
    const [, , addr1, addr2] = await ethers.getSigners();

    await expect(realtToken.connect(addr1).setACPI(4)).to.be.reverted;

    await expect(realtToken.connect(addr1).burn(addr1.address, 10)).to.be
      .reverted;

    await expect(realtToken.connect(addr1).mint(addr1.address, 10)).to.be
      .reverted;

    await expect(
      realtToken
        .connect(addr1)
        .batchMint([addr1.address, addr2.address], [10, 10])
    ).to.be.reverted;

    await expect(
      realtToken
        .connect(addr1)
        .batchBurn([addr1.address, addr2.address], [10, 10])
    ).to.be.reverted;
  });

  it("Should transfer tokens", async function () {
    const [TOKEN_ADMIN, , addr1, addr2] = await ethers.getSigners();

    expect(await realtToken.balanceOf(addr1.address)).to.equal(0);

    await realtToken.connect(TOKEN_ADMIN).mint(addr1.address, 100);

    expect(await realtToken.balanceOf(addr1.address)).to.equal(100);

    await realtToken.connect(addr1).transfer(addr2.address, 100);

    expect(await realtToken.balanceOf(addr1.address)).to.equal(0);

    expect(await realtToken.balanceOf(addr2.address)).to.equal(100);
  });

  it("Should not transfer tokens", async function () {
    const [TOKEN_ADMIN, , addr1, addr2] = await ethers.getSigners();

    expect(await realtToken.balanceOf(addr1.address)).to.equal(0);

    await realtToken.connect(TOKEN_ADMIN).mint(addr1.address, 100);

    expect(await realtToken.balanceOf(addr1.address)).to.equal(100);

    await expect(
      realtToken.connect(addr1).transfer(addr2.address, 101)
    ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
  });

  it("Batch Minting", async function () {
    const [TOKEN_ADMIN, , addr1, addr2] = await ethers.getSigners();

    expect(await realtToken.balanceOf(addr1.address)).to.equal(0);

    await realtToken.connect(TOKEN_ADMIN).mint(addr1.address, 100);

    expect(await realtToken.balanceOf(addr1.address)).to.equal(100);

    await realtToken
      .connect(TOKEN_ADMIN)
      .batchMint([addr1.address, addr2.address], [100, 100]);

    expect(await realtToken.balanceOf(addr1.address)).to.equal(200);

    expect(await realtToken.balanceOf(addr2.address)).to.equal(100);
  });

  it("Batch Minting Fail - Different Size", async function () {
    const [TOKEN_ADMIN, , addr1, addr2] = await ethers.getSigners();

    await expect(
      realtToken
        .connect(TOKEN_ADMIN)
        .batchMint([addr1.address, addr2.address], [100, 100, 100])
    ).to.revertedWith("Account & amount length mismatch");
  });

  it("Batch Minting Fail - Empty array", async function () {
    const [TOKEN_ADMIN] = await ethers.getSigners();

    await expect(
      realtToken.connect(TOKEN_ADMIN).batchMint([], [])
    ).to.revertedWith("can't process empty array");
  });

  it("Burning", async function () {
    const [TOKEN_ADMIN, , addr1] = await ethers.getSigners();

    expect(await realtToken.balanceOf(addr1.address)).to.equal(0);

    await realtToken.connect(TOKEN_ADMIN).mint(addr1.address, 100);

    expect(await realtToken.balanceOf(addr1.address)).to.equal(100);

    await realtToken.connect(TOKEN_ADMIN).burn(addr1.address, 100);

    expect(await realtToken.balanceOf(addr1.address)).to.equal(0);
  });

  it("Batch Burning", async function () {
    const [TOKEN_ADMIN, , addr1, addr2] = await ethers.getSigners();

    expect(await realtToken.balanceOf(addr1.address)).to.equal(0);

    await realtToken.connect(TOKEN_ADMIN).mint(addr1.address, 100);

    await realtToken.connect(TOKEN_ADMIN).mint(addr2.address, 150);

    expect(await realtToken.balanceOf(addr1.address)).to.equal(100);

    expect(await realtToken.balanceOf(addr2.address)).to.equal(150);

    await realtToken
      .connect(TOKEN_ADMIN)
      .batchBurn([addr1.address, addr2.address], [50, 75]);

    expect(await realtToken.balanceOf(addr1.address)).to.equal(50);

    expect(await realtToken.balanceOf(addr2.address)).to.equal(75);
  });
  it("Batch Burning Fail - Different Size", async function () {
    const [TOKEN_ADMIN, , addr1, addr2] = await ethers.getSigners();

    await expect(
      realtToken
        .connect(TOKEN_ADMIN)
        .batchBurn([addr1.address, addr2.address], [100, 100, 100])
    ).to.revertedWith("Account & amount length mismatch");
  });

  it("Batch Burning Fail - Empty array", async function () {
    const [TOKEN_ADMIN] = await ethers.getSigners();

    await expect(
      realtToken.connect(TOKEN_ADMIN).batchBurn([], [])
    ).to.revertedWith("can't process empty array");
  });

  it("Can't claim token", async function () {
    const [TOKEN_ADMIN, , addr1] = await ethers.getSigners();

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    expect(realtToken.connect(addr1).claimTokens()).to.revertedWith(
      "ACPI event need to be over to claim your tokens"
    );
  });
});

// TODO Test claimToken RealT.sol
