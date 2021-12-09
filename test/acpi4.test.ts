import { expect } from "chai";
import { ethers, name, symbol } from "hardhat";
import { RealT, ACPIFour } from "../typechain";

let realtToken: RealT;
let acpiFour: ACPIFour;

describe("ACPI Four", function () {
  beforeEach(async () => {
    const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

    const RealtFactory = await ethers.getContractFactory("RealT");
    realtToken = await RealtFactory.deploy(
      name,
      symbol,
      ACPI_MODERATOR.address
    );
    await realtToken.deployed();

    acpiFour = await ethers.getContractAt(
      "ACPIFour",
      await realtToken.acpiFour()
    );

    await realtToken.connect(TOKEN_ADMIN).setACPI(4);
  });

  it("Going at the end!", async function () {
    const [, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    let index = 0;
    for (index = 0; index < (await acpiFour.totalRound()); index++) {
      await acpiFour.connect(ACPI_MODERATOR).startRound();
    }

    expect(await acpiFour.totalRound()).to.equal(index);

    await expect(
      acpiFour.connect(addr1).buy({
        value: ethers.utils.parseUnits("3", "ether"),
      })
    ).to.be.revertedWith("BUY: All rounds have been done");
  });

  it("Already bet test", async function () {
    this.timeout(50 * 1000);

    const getSigners = await ethers.getSigners();

    await acpiFour.connect(getSigners[1]).setTotalRound(2);

    const totalRound = await acpiFour.totalRound();
    const rewardPerTurn = (await acpiFour.rewardPerTurn()).toNumber();
    let signerIndex = 0;
    let index = 0;
    for (index = 0; index < totalRound; index++) {
      for (let turnCount = 0; turnCount < 3; turnCount++) {
        const tokenPrice = await acpiFour.price();
        for (let bid = 0; bid < rewardPerTurn; bid++) {
          await acpiFour
            .connect(getSigners[signerIndex + 2])
            .buy({ value: tokenPrice });

          await expect(
            acpiFour
              .connect(getSigners[signerIndex + 2])
              .buy({ value: tokenPrice })
          ).to.revertedWith("You can only bet once per turn");

          signerIndex += 1;
        }

        expect(await acpiFour.rewardLeft()).to.equal(0);

        signerIndex = 0;
        await acpiFour.connect(getSigners[1]).startRound();
      }

      await acpiFour.connect(getSigners[1]).startRound();
    }

    expect(await acpiFour.totalRound()).to.equal(index);
  });

  it("Price doesn't match #1", async function () {
    const getSigners = await ethers.getSigners();

    await acpiFour.connect(getSigners[1]).setTotalRound(2);

    const tokenPrice = await acpiFour.price();

    await expect(
      acpiFour.connect(getSigners[2]).buy({ value: tokenPrice.add(10) })
    ).to.revertedWith("BUY: value must match price");
  });

  it("Price doesn't match #2", async function () {
    const getSigners = await ethers.getSigners();

    await acpiFour.connect(getSigners[1]).setTotalRound(2);

    const tokenPrice = await acpiFour.price();

    await expect(
      acpiFour.connect(getSigners[2]).buy({ value: tokenPrice.sub(3) })
    ).to.revertedWith("BUY: value must match price");
  });

  it("Test permission #1 - setDefaultPrice", async function () {
    const [, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    await expect(
      acpiFour
        .connect(addr1)
        .setDefaultPrice(ethers.utils.parseUnits("0.1", "ether"))
    ).to.revertedWith("Only ACPI Moderator Method");

    acpiFour
      .connect(ACPI_MODERATOR)
      .setDefaultPrice(ethers.utils.parseUnits("0.1", "ether"));

    expect(await acpiFour.defaultPrice()).to.equal(
      ethers.utils.parseUnits("0.1", "ether")
    );
  });

  it("Test permission #2 - setPriceIncrease", async function () {
    const [, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    await expect(acpiFour.connect(addr1).setPriceIncrease(30)).to.revertedWith(
      "Only ACPI Moderator Method"
    );

    await acpiFour.connect(ACPI_MODERATOR).setPriceIncrease(30);

    expect(await acpiFour.priceIncrease()).to.equal(30);
  });

  it("Test permission #3 - setReward", async function () {
    const [, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    await expect(acpiFour.connect(addr1).setReward(45)).to.revertedWith(
      "Only ACPI Moderator Method"
    );

    await acpiFour.connect(ACPI_MODERATOR).setReward(45);

    expect(await acpiFour.rewardPerTurn()).to.equal(45);

    expect(await acpiFour.rewardLeft()).to.equal(45);
  });

  it("OnlyCurrentACPI #1 - startRound", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    await expect(acpiFour.connect(ACPI_MODERATOR).startRound()).to.revertedWith(
      "Only Current ACPI Method"
    );

    await realtToken.connect(TOKEN_ADMIN).setACPI(4);

    await acpiFour.connect(ACPI_MODERATOR).startRound();
  });

  it("OnlyCurrentACPI #2 - buy", async function () {
    const [TOKEN_ADMIN, , addr1] = await ethers.getSigners();

    await realtToken.connect(TOKEN_ADMIN).setACPI(1);

    const tokenPrice = await acpiFour.price();

    await expect(
      acpiFour.connect(addr1).buy({ value: tokenPrice })
    ).to.revertedWith("Only Current ACPI Method");

    await realtToken.connect(TOKEN_ADMIN).setACPI(4);

    await acpiFour.connect(addr1).buy({ value: tokenPrice });
  });

  it("3 turn / 2 rounds / 100 token", async function () {
    this.timeout(0);

    const getSigners = await ethers.getSigners();

    await acpiFour.connect(getSigners[1]).setTotalRound(2);

    const totalRound = await acpiFour.totalRound();
    const rewardPerTurn = (await acpiFour.rewardPerTurn()).toNumber();
    let signerIndex = 0;
    let index = 0;
    for (index = 0; index < totalRound; index++) {
      for (let turnCount = 0; turnCount < 3; turnCount++) {
        const tokenPrice = await acpiFour.price();
        console.log(ethers.utils.formatEther(tokenPrice));
        for (let bid = 0; bid < rewardPerTurn; bid++) {
          await acpiFour
            .connect(getSigners[signerIndex + 2])
            .buy({ value: tokenPrice });

          signerIndex++;
        }
        signerIndex = 0;
        await acpiFour.connect(getSigners[1]).startRound();
      }
      await acpiFour
        .connect(getSigners[signerIndex + 2])
        .buy({ value: await acpiFour.price() });
      await acpiFour.connect(getSigners[1]).startRound();
    }

    expect(await acpiFour.totalRound()).to.equal(index);
  });
});