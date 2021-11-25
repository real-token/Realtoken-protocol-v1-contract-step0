import { expect } from "chai";
import { ethers } from "hardhat";
import { RealT, ACPIOne } from "../typechain";

const name = "Governance Token RealT";
const symbol = "GTR";

let realtToken: RealT;
let acpiOne: ACPIOne;

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

    acpiOne = await ethers.getContractAt("ACPIOne", await realtToken.acpiOne());
  });

  it("Starting a bid war", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1, addr2] =
      await ethers.getSigners();

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await acpiOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await acpiOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("2.5", "ether"),
    });

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("3", "ether"),
    });

    await acpiOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("3.5", "ether"),
    });

    expect(await acpiOne.highestBid()).to.equal(
      ethers.utils.parseUnits("7.5", "ether")
    );

    expect(await acpiOne.highestBidder()).to.equal(addr2.address);

    expect(await acpiOne.pendingReturns(addr1.address)).to.equal(
      ethers.utils.parseUnits("6", "ether")
    );
  });

  it("User bid multiples times while being the top bidder", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1, addr2] =
      await ethers.getSigners();

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await acpiOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("3", "ether"),
    });

    expect(await acpiOne.highestBid()).to.equal(
      ethers.utils.parseUnits("6", "ether")
    );

    expect(await acpiOne.highestBidder()).to.equal(addr1.address);

    expect(await acpiOne.pendingReturns(addr2.address)).to.equal(
      ethers.utils.parseUnits("1.5", "ether")
    );

    expect(await acpiOne.pendingReturns(addr1.address)).to.equal(
      ethers.utils.parseUnits("0", "ether")
    );
  });

  it("Testing multiple rounds", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1, addr2, addr3] =
      await ethers.getSigners();

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await acpiOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await acpiOne.connect(addr3).bid({
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1.8", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await acpiOne.connect(addr2).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await acpiOne.connect(addr3).bid({
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1.8", "ether"),
    });

    expect(await acpiOne.highestBid()).to.equal(
      ethers.utils.parseUnits("2.8", "ether")
    );

    expect(await acpiOne.highestBidder()).to.equal(addr1.address);

    expect(await acpiOne.pendingReturns(addr1.address)).to.equal(
      ethers.utils.parseUnits("0", "ether")
    );

    expect(await acpiOne.pendingReturns(addr2.address)).to.equal(
      ethers.utils.parseUnits("3", "ether")
    );

    expect(await acpiOne.pendingReturns(addr3.address)).to.equal(
      ethers.utils.parseUnits("4", "ether")
    );
  });

  it("Going at the end!", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    let index = 0;
    for (index = 0; index < (await acpiOne.totalRound()).toNumber(); index++) {
      await acpiOne.connect(ACPI_MODERATOR).startRound();
    }

    expect(await acpiOne.totalRound()).to.equal(index);

    await expect(
      acpiOne.connect(addr1).bid({
        value: ethers.utils.parseUnits("3", "ether"),
      })
    ).to.be.revertedWith("BID: All rounds have been done");
  });

  it("Set roundtime set totalround set bidincrement", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).setRoundTime(1);

    expect(await acpiOne.roundTime()).to.equal(1);

    await acpiOne.connect(ACPI_MODERATOR).setTotalRound(6);

    expect(
      await acpiOne.connect(ACPI_MODERATOR).callStatic.setTotalRound(12)
    ).to.equal(12);

    await acpiOne
      .connect(ACPI_MODERATOR)
      .setBidIncrement(ethers.utils.parseUnits("3", "gwei"));

    expect(await acpiOne.bidIncrement()).to.equal(
      ethers.utils.parseUnits("3", "gwei")
    );
  });

  it("Testing bid increment", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1, addr2] =
      await ethers.getSigners();

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne
      .connect(ACPI_MODERATOR)
      .setBidIncrement(ethers.utils.parseUnits("1", "ether"));

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await expect(
      acpiOne.connect(addr2).bid({
        value: ethers.utils.parseUnits("2", "ether"),
      })
    ).to.revertedWith("BID: value is to low");

    expect(await acpiOne.highestBid()).to.equal(
      ethers.utils.parseUnits("1.5", "ether")
    );

    expect(await acpiOne.highestBidder()).to.equal(addr1.address);

    expect(await acpiOne.pendingReturns(addr1.address)).to.equal(
      ethers.utils.parseUnits("0", "ether")
    );

    expect(await acpiOne.pendingReturns(addr2.address)).to.equal(
      ethers.utils.parseUnits("0", "ether")
    );
  });

  it("Testing get balance", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid({
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    expect(await acpiOne.connect(addr1).getBet(addr1.address)).to.equal(
      ethers.utils.parseUnits("1.5", "ether")
    );
  });
});
