import { expect } from "chai";
import { ethers, name, symbol } from "hardhat";
import { RealT, ACPITwo, ACPIMaster } from "../typechain";

let realToken: RealT;
let acpiTwo: ACPITwo;
let acpiMaster: ACPIMaster;

describe("ACPI Two", function () {
  beforeEach(async () => {
    const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

    const RealtFactory = await ethers.getContractFactory("RealT");
    realToken = await RealtFactory.deploy(name, symbol);
    await realToken.deployed();

    const ACPIMasterFactory = await ethers.getContractFactory("ACPIMaster");
    acpiMaster = await ACPIMasterFactory.deploy(
      realToken.address,
      ACPI_MODERATOR.address
    );

    await acpiMaster.deployed();

    await realToken.contractTransfer(
      acpiMaster.address,
      ethers.utils.parseUnits("1000", "ether")
    );

    acpiTwo = await ethers.getContractAt("ACPITwo", await acpiMaster.acpiTwo());

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(2);
  });

  it("Going at the end!", async function () {
    const [, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    let index = 0;
    for (index; index < (await acpiTwo.totalRound()); index++) {
      await acpiTwo.connect(ACPI_MODERATOR).startRound();
    }

    expect(await acpiTwo.totalRound()).to.equal(index);

    await expect(
      acpiTwo.connect(addr1).bid({
        value: ethers.utils.parseUnits("3", "ether"),
      })
    ).to.be.revertedWith("BID: All rounds have been done");
  });

  it("Building the pot", async function () {
    const [, ACPI_MODERATOR, addr1, addr2, addr3, addr4] =
      await ethers.getSigners();

    await acpiTwo.connect(ACPI_MODERATOR).startRound();

    await acpiTwo
      .connect(addr1)
      .bid({ value: ethers.utils.parseUnits("1", "ether") });

    await acpiTwo
      .connect(addr2)
      .bid({ value: ethers.utils.parseUnits("1.5", "ether") });

    await acpiTwo
      .connect(addr3)
      .bid({ value: ethers.utils.parseUnits("0.5", "ether") });

    await acpiTwo
      .connect(addr4)
      .bid({ value: ethers.utils.parseUnits("0.3", "ether") });

    await acpiTwo
      .connect(addr1)
      .bid({ value: ethers.utils.parseUnits("0.2", "ether") });

    await acpiTwo
      .connect(addr2)
      .bid({ value: ethers.utils.parseUnits("0.3", "ether") });

    await acpiTwo
      .connect(addr3)
      .bid({ value: ethers.utils.parseUnits("0.4", "ether") });

    await acpiTwo
      .connect(addr4)
      .bid({ value: ethers.utils.parseUnits("0.5", "ether") });

    expect(await acpiTwo.roundPot()).to.be.equal(
      ethers.utils.parseUnits("4.7", "ether")
    );

    await acpiTwo.connect(ACPI_MODERATOR).startRound();

    expect(await acpiTwo.roundPot()).to.be.equal(
      ethers.utils.parseUnits("0", "ether")
    );
  });

  it("Check for reward overflow", async function () {
    const [, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    let reward = ethers.utils.parseUnits("1", "ether");

    await acpiTwo.connect(ACPI_MODERATOR).setTotalRound(200);

    await acpiTwo.connect(ACPI_MODERATOR).setRewardMultiplicator(1);

    const totalRound = await acpiTwo.totalRound();
    let index = 0;
    for (index; index < totalRound - 1; index++) {
      await acpiTwo.connect(ACPI_MODERATOR).startRound();
      await acpiTwo
        .connect(addr1)
        .bid({ value: ethers.utils.parseUnits("1", "ether") });

      expect(await acpiTwo.reward()).to.equal(reward);

      reward = reward.add(reward.div(100));
    }

    await acpiTwo.connect(ACPI_MODERATOR).startRound();
  });

  it("Bid wars #1", async function () {
    const [, ACPI_MODERATOR, addr1, addr2, addr3, addr4, addr5, addr6] =
      await ethers.getSigners();

    await acpiTwo
      .connect(addr1)
      .bid({ value: ethers.utils.parseUnits("2", "ether") });

    await acpiTwo
      .connect(addr1)
      .bid({ value: ethers.utils.parseUnits("3", "ether") });

    await acpiTwo
      .connect(addr2)
      .bid({ value: ethers.utils.parseUnits("1", "ether") });

    await acpiTwo
      .connect(addr3)
      .bid({ value: ethers.utils.parseUnits("4", "ether") });

    await acpiTwo
      .connect(addr4)
      .bid({ value: ethers.utils.parseUnits("7", "ether") });

    await acpiTwo
      .connect(addr5)
      .bid({ value: ethers.utils.parseUnits("3", "ether") });

    await acpiTwo
      .connect(addr6)
      .bid({ value: ethers.utils.parseUnits("20", "ether") });

    await acpiTwo.connect(ACPI_MODERATOR).startRound();

    expect(await acpiTwo.pendingWins(addr1.address)).to.equal(
      ethers.utils.parseUnits("0.125", "ether")
    );

    expect(await acpiTwo.pendingWins(addr2.address)).to.equal(
      ethers.utils.parseUnits("0.025", "ether")
    );

    expect(await acpiTwo.pendingWins(addr3.address)).to.equal(
      ethers.utils.parseUnits("0.1", "ether")
    );

    expect(await acpiTwo.pendingWins(addr4.address)).to.equal(
      ethers.utils.parseUnits("0.175", "ether")
    );

    expect(await acpiTwo.pendingWins(addr5.address)).to.equal(
      ethers.utils.parseUnits("0.075", "ether")
    );

    expect(await acpiTwo.pendingWins(addr6.address)).to.equal(
      ethers.utils.parseUnits("0.5", "ether")
    );
  });
});
