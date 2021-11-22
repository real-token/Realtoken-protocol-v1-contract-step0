import { expect } from "chai";
import { ethers } from "hardhat";
import { RealT } from "../typechain";

const name = "Governance Token RealT";
const symbol = "GTR";

let realtToken: RealT;

describe("ACPI One", function () {
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

  it("Starting a bid war", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1, addr2] =
      await ethers.getSigners();

    const ACPIOne = await ethers.getContractAt(
      "ACPIOne",
      await realtToken.acpiOne()
    );

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await ACPIOne.connect(ACPI_MODERATOR).startRound();

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await ACPIOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await ACPIOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("2.5", "ether"),
    });

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("3", "ether"),
    });

    await ACPIOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("3.5", "ether"),
    });

    expect(await ACPIOne.highestBid()).to.equal(
      ethers.utils.parseUnits("7.5", "ether")
    );

    expect(await ACPIOne.highestBidder()).to.equal(addr2.address);

    expect(await ACPIOne.pendingReturns(addr1.address)).to.equal(
      ethers.utils.parseUnits("6", "ether")
    );
  });

  it("User bid multiples times while being the top bidder", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1, addr2] =
      await ethers.getSigners();

    const ACPIOne = await ethers.getContractAt(
      "ACPIOne",
      await realtToken.acpiOne()
    );

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await ACPIOne.connect(ACPI_MODERATOR).startRound();

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await ACPIOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("3", "ether"),
    });

    expect(await ACPIOne.highestBid()).to.equal(
      ethers.utils.parseUnits("6", "ether")
    );

    expect(await ACPIOne.highestBidder()).to.equal(addr1.address);

    expect(await ACPIOne.pendingReturns(addr2.address)).to.equal(
      ethers.utils.parseUnits("1.5", "ether")
    );

    expect(await ACPIOne.pendingReturns(addr1.address)).to.equal(
      ethers.utils.parseUnits("0", "ether")
    );
  });

  it("Testing multiple rounds", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1, addr2, addr3] =
      await ethers.getSigners();

    const ACPIOne = await ethers.getContractAt(
      "ACPIOne",
      await realtToken.acpiOne()
    );

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await ACPIOne.connect(ACPI_MODERATOR).startRound();

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await ACPIOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await ACPIOne.connect(addr3).bid({
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1.8", "ether"),
    });

    await ACPIOne.connect(ACPI_MODERATOR).startRound();

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await ACPIOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await ACPIOne.connect(addr3).bid({
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1.8", "ether"),
    });

    expect(await ACPIOne.highestBid()).to.equal(
      ethers.utils.parseUnits("2.8", "ether")
    );

    expect(await ACPIOne.highestBidder()).to.equal(addr1.address);

    expect(await ACPIOne.pendingReturns(addr1.address)).to.equal(
      ethers.utils.parseUnits("0", "ether")
    );

    expect(await ACPIOne.pendingReturns(addr2.address)).to.equal(
      ethers.utils.parseUnits("3", "ether")
    );

    expect(await ACPIOne.pendingReturns(addr3.address)).to.equal(
      ethers.utils.parseUnits("4", "ether")
    );
  });

  it("Going at the end!", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    const ACPIOne = await ethers.getContractAt(
      "ACPIOne",
      await realtToken.acpiOne()
    );

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    let index = 0;
    for (index = 0; index < (await ACPIOne.totalRound()).toNumber(); index++) {
      await ACPIOne.connect(ACPI_MODERATOR).startRound();
    }

    expect(await ACPIOne.totalRound()).to.equal(index);

    await expect(
      ACPIOne.connect(addr1).bid({
        value: ethers.utils.parseUnits("3", "ether"),
      })
    ).to.be.revertedWith("BID: All rounds have been done");
  });

  it("Set roundtime set totalround set bidincrement", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

    const ACPIOne = await ethers.getContractAt(
      "ACPIOne",
      await realtToken.acpiOne()
    );

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await ACPIOne.connect(ACPI_MODERATOR).setRoundTime(1);

    expect(await ACPIOne.roundTime()).to.equal(1);

    await ACPIOne.connect(ACPI_MODERATOR).setTotalRound(12);

    expect(await ACPIOne.totalRound()).to.equal(12);

    await ACPIOne.connect(ACPI_MODERATOR).setBidIncrement(
      ethers.utils.parseUnits("3", "gwei")
    );

    expect(await ACPIOne.bidIncrement()).to.equal(
      ethers.utils.parseUnits("3", "gwei")
    );
  });

  it("Testing bid increment", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1, addr2] =
      await ethers.getSigners();

    const ACPIOne = await ethers.getContractAt(
      "ACPIOne",
      await realtToken.acpiOne()
    );

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await ACPIOne.connect(ACPI_MODERATOR).startRound();

    await ACPIOne.connect(ACPI_MODERATOR).setBidIncrement(
      ethers.utils.parseUnits("1", "ether")
    );

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await expect(
      ACPIOne.connect(addr2).bid({
        value: ethers.utils.parseUnits("2", "ether"),
      })
    ).to.revertedWith("BID: value is to low");

    expect(await ACPIOne.highestBid()).to.equal(
      ethers.utils.parseUnits("1.5", "ether")
    );

    expect(await ACPIOne.highestBidder()).to.equal(addr1.address);

    expect(await ACPIOne.pendingReturns(addr1.address)).to.equal(
      ethers.utils.parseUnits("0", "ether")
    );

    expect(await ACPIOne.pendingReturns(addr2.address)).to.equal(
      ethers.utils.parseUnits("0", "ether")
    );
  });

  it("Testing get balance", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    const ACPIOne = await ethers.getContractAt(
      "ACPIOne",
      await realtToken.acpiOne()
    );

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await ACPIOne.connect(ACPI_MODERATOR).startRound();

    await ACPIOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    expect(await ACPIOne.connect(addr1).getBet(addr1.address)).to.equal(
      ethers.utils.parseUnits("1.5", "ether")
    );
  });
});
