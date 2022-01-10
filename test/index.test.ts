import { expect } from "chai";
import { ethers, name, symbol } from "hardhat";
import { ACPIMaster, REG } from "../typechain-types";

let regToken: REG;
let acpiMaster: ACPIMaster;

describe("REG Factory", function () {
  beforeEach(async () => {
    const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

    const regFactory = await ethers.getContractFactory("REG");
    regToken = await regFactory.deploy(name, symbol, TOKEN_ADMIN.address);
    await regToken.deployed();

    const acpiMasterFactory = await ethers.getContractFactory("ACPIMaster");
    acpiMaster = await acpiMasterFactory.deploy(
      regToken.address,
      TOKEN_ADMIN.address,
      ACPI_MODERATOR.address
    );

    await acpiMaster.deployed();

    await regToken.mint(
      acpiMaster.address,
      ethers.utils.parseUnits("1000", "ether")
    );
  });

  it("Should be ACPI 0", async function () {
    expect(await acpiMaster.getACPI()).to.equal(0);
  });

  it("Should set ACPI to 1", async function () {
    await acpiMaster.setACPI(1);

    expect(await acpiMaster.getACPI()).to.equal(1);
  });

  it("Should set ACPI to 2", async function () {
    await acpiMaster.setACPI(2);

    expect(await acpiMaster.getACPI()).to.equal(2);
  });

  it("Should set ACPI to 3", async function () {
    await acpiMaster.setACPI(3);

    expect(await acpiMaster.getACPI()).to.equal(3);
  });

  it("Should set ACPI to 4", async function () {
    await acpiMaster.setACPI(4);

    expect(await acpiMaster.getACPI()).to.equal(4);
  });

  it("Should set ACPI to 5", async function () {
    await acpiMaster.setACPI(5);

    expect(await acpiMaster.getACPI()).to.equal(5);
  });

  it("Should set ACPI to 6", async function () {
    await acpiMaster.setACPI(6);

    expect(await acpiMaster.getACPI()).to.equal(6);
  });

  it("Should set ACPI to 6", async function () {
    await expect(acpiMaster.setACPI(7)).revertedWith("Allowed value is 0-6");
  });

  it("Test permission", async function () {
    const [, , addr1, addr2] = await ethers.getSigners();

    await expect(acpiMaster.connect(addr1).setACPI(4)).to.be.reverted;

    await expect(regToken.connect(addr1).contractBurn(10)).to.be.reverted;

    await expect(regToken.connect(addr1).mint(addr1.address, 10)).to.be
      .reverted;

    await expect(
      regToken
        .connect(addr1)
        .batchMint([addr1.address, addr2.address], [10, 10])
    ).to.be.reverted;
  });

  it("Should transfer tokens", async function () {
    const [TOKEN_ADMIN, , addr1, addr2] = await ethers.getSigners();

    expect(await regToken.balanceOf(addr1.address)).to.equal(0);

    await regToken.connect(TOKEN_ADMIN).mint(addr1.address, 100);

    expect(await regToken.balanceOf(addr1.address)).to.equal(100);

    await regToken.connect(addr1).transfer(addr2.address, 100);

    expect(await regToken.balanceOf(addr1.address)).to.equal(0);

    expect(await regToken.balanceOf(addr2.address)).to.equal(100);
  });

  it("Should not transfer tokens", async function () {
    const [TOKEN_ADMIN, , addr1, addr2] = await ethers.getSigners();

    expect(await regToken.balanceOf(addr1.address)).to.equal(0);

    await regToken.connect(TOKEN_ADMIN).mint(addr1.address, 100);

    expect(await regToken.balanceOf(addr1.address)).to.equal(100);

    await expect(
      regToken.connect(addr1).transfer(addr2.address, 101)
    ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
  });

  it("Batch Minting", async function () {
    const [TOKEN_ADMIN, , addr1, addr2] = await ethers.getSigners();

    expect(await regToken.balanceOf(addr1.address)).to.equal(0);

    await regToken.connect(TOKEN_ADMIN).mint(addr1.address, 100);

    expect(await regToken.balanceOf(addr1.address)).to.equal(100);

    await regToken
      .connect(TOKEN_ADMIN)
      .batchMint([addr1.address, addr2.address], [100, 100]);

    expect(await regToken.balanceOf(addr1.address)).to.equal(200);

    expect(await regToken.balanceOf(addr2.address)).to.equal(100);
  });

  it("Batch Minting Fail - Different Size", async function () {
    const [TOKEN_ADMIN, , addr1, addr2] = await ethers.getSigners();

    await expect(
      regToken
        .connect(TOKEN_ADMIN)
        .batchMint([addr1.address, addr2.address], [100, 100, 100])
    ).to.revertedWith("Account & amount length mismatch");
  });

  it("Batch Minting Fail - Empty array", async function () {
    const [TOKEN_ADMIN] = await ethers.getSigners();

    await expect(
      regToken.connect(TOKEN_ADMIN).batchMint([], [])
    ).to.revertedWith("can't process empty array");
  });

  it("Can't claim token", async function () {
    const [TOKEN_ADMIN, , addr1] = await ethers.getSigners();

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(1);

    expect(acpiMaster.connect(addr1).claimTokens()).to.revertedWith(
      "ACPI event need to be over to claim your tokens"
    );
  });
});

// TODO Test claimToken REG.sol
