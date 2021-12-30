import { expect } from "chai";
import { ethers, name, symbol } from "hardhat";
import { REG, ACPIOne, ACPIMaster } from "../typechain";

let regToken: REG;
let acpiOne: ACPIOne;
let acpiMaster: ACPIMaster;
describe("ACPI One", function () {
  beforeEach(async () => {
    const [, ACPI_MODERATOR] = await ethers.getSigners();

    const regFactory = await ethers.getContractFactory("REG");

    regToken = await regFactory.deploy(name, symbol);
    await regToken.deployed();

    const acpiMasterFactory = await ethers.getContractFactory("ACPIMaster");
    acpiMaster = await acpiMasterFactory.deploy(
      regToken.address,
      ACPI_MODERATOR.address
    );

    await acpiMaster.deployed();

    await regToken.contractTransfer(
      acpiMaster.address,
      ethers.utils.parseUnits("1000", "ether")
    );

    acpiOne = await ethers.getContractAt(
      "ACPIOne",
      await acpiMaster.acpiOneContract()
    );
  });

  it("Starting a bid war", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1, addr2] =
      await ethers.getSigners();

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(1, {
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await acpiOne.connect(addr2).bid(1, {
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await acpiOne.connect(addr1).bid(1, {
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await acpiOne.connect(addr2).bid(1, {
      value: ethers.utils.parseUnits("2.5", "ether"),
    });

    await acpiOne.connect(addr1).bid(1, {
      value: ethers.utils.parseUnits("3", "ether"),
    });

    await acpiOne.connect(addr2).bid(1, {
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

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(1, {
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await acpiOne.connect(addr2).bid(1, {
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await acpiOne.connect(addr1).bid(1, {
      value: ethers.utils.parseUnits("1", "ether"),
    });

    expect(await acpiOne.highestBid()).to.equal(
      ethers.utils.parseUnits("2", "ether")
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

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(1, {
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await acpiOne.connect(addr2).bid(1, {
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await acpiOne.connect(addr3).bid(1, {
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await acpiOne.connect(addr1).bid(1, {
      value: ethers.utils.parseUnits("1.8", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(2, {
      value: ethers.utils.parseUnits("1", "ether"),
    });

    await acpiOne.connect(addr2).bid(2, {
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await acpiOne.connect(addr3).bid(2, {
      value: ethers.utils.parseUnits("2", "ether"),
    });

    await acpiOne.connect(addr1).bid(2, {
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

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(1);

    let index = 0;
    for (index = 0; index < (await acpiOne.totalRound()); index++) {
      await acpiOne.connect(ACPI_MODERATOR).startRound();
    }

    expect(await acpiOne.totalRound()).to.equal(index);

    await expect(
      acpiOne.connect(addr1).bid(index, {
        value: ethers.utils.parseUnits("3", "ether"),
      })
    ).to.be.revertedWith("BID: All rounds have been done");
  });

  it("Set roundtime set totalround set bidincrement", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).setRoundTime(1);

    expect(await acpiOne.roundTime()).to.equal(1);

    await acpiOne.connect(ACPI_MODERATOR).setTotalRound(6);

    await acpiOne.connect(ACPI_MODERATOR).setTotalRound(12);

    expect(await acpiOne.totalRound()).to.equal(12);

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

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne
      .connect(ACPI_MODERATOR)
      .setBidIncrement(ethers.utils.parseUnits("1", "ether"));

    await acpiOne.connect(addr1).bid(1, {
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    await expect(
      acpiOne.connect(addr2).bid(1, {
        value: ethers.utils.parseUnits("2", "ether"),
      })
    ).to.revertedWith("BID: value is too low");

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

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(1, {
      value: ethers.utils.parseUnits("1.5", "ether"),
    });

    expect(await acpiOne.connect(addr1).getBid()).to.equal(
      ethers.utils.parseUnits("1.5", "ether")
    );
  });

  it("Test final price median", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(1);

    await acpiOne.connect(ACPI_MODERATOR).setTotalRound(100);

    await acpiOne.connect(addr1).bid(0, {
      value: ethers.utils.parseUnits("9", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(1, {
      value: ethers.utils.parseUnits("10", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(2, {
      value: ethers.utils.parseUnits("12", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(3, {
      value: ethers.utils.parseUnits("13", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(4, {
      value: ethers.utils.parseUnits("14", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(5, {
      value: ethers.utils.parseUnits("15", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(6, {
      value: ethers.utils.parseUnits("16", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(7, {
      value: ethers.utils.parseUnits("17", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(8, {
      value: ethers.utils.parseUnits("18", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(9, {
      value: ethers.utils.parseUnits("22", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(10, {
      value: ethers.utils.parseUnits("23", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(11, {
      value: ethers.utils.parseUnits("24", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(12, {
      value: ethers.utils.parseUnits("24", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(13, {
      value: ethers.utils.parseUnits("25", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    await acpiOne.connect(addr1).bid(14, {
      value: ethers.utils.parseUnits("30", "ether"),
    });

    await acpiOne.connect(ACPI_MODERATOR).startRound();

    let index = await acpiOne.currentRound();

    for (; index < (await acpiOne.totalRound()); index++) {
      await acpiOne.connect(ACPI_MODERATOR).startRound();
    }

    expect(await acpiOne.totalRound()).to.equal(index);

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(5);

    expect(await acpiMaster.initialTokenPrice()).to.equal(
      ethers.utils.parseUnits("17", "ether").div(100).mul(15)
    );
  });
});
