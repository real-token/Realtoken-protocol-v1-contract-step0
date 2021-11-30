import { expect } from "chai";
import { ethers } from "hardhat";
import { RealT, ACPIThree } from "../typechain";

const name = "Governance Token RealT";
const symbol = "GTR";

let realtToken: RealT;
let acpiThree: ACPIThree;

describe("ACPI Three", function () {
  beforeEach(async () => {
    const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

    const RealtFactory = await ethers.getContractFactory("RealT");
    realtToken = await RealtFactory.deploy(
      name,
      symbol,
      ACPI_MODERATOR.address
    );
    await realtToken.deployed();

    acpiThree = await ethers.getContractAt(
      "ACPIThree",
      await realtToken.acpiThree()
    );

    await realtToken.connect(TOKEN_ADMIN).setACPI(3);
  });

  it("Going at the end!", async function () {
    const [, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    let index = 0;
    for (
      index = 0;
      index < (await acpiThree.totalRound()).toNumber();
      index++
    ) {
      await acpiThree.connect(ACPI_MODERATOR).startRound();
    }

    expect(await acpiThree.totalRound()).to.equal(index);

    await expect(
      acpiThree.connect(addr1).bid({
        value: ethers.utils.parseUnits("3", "ether"),
      })
    ).to.be.revertedWith("BID: All rounds have been done");
  });

  it("Get bid amount", async function () {
    expect(await acpiThree.bidAmount()).to.equal(
      ethers.utils.parseUnits("250", "gwei")
    );
  });

  it("set bid amount", async function () {
    const [, ACPI_MODERATOR] = await ethers.getSigners();

    expect(await acpiThree.bidAmount()).to.equal(
      ethers.utils.parseUnits("250", "gwei")
    );

    await acpiThree
      .connect(ACPI_MODERATOR)
      .setBidAmount(ethers.utils.parseUnits("1", "ether"));

    expect(await acpiThree.bidAmount()).to.equal(
      ethers.utils.parseUnits("1", "ether")
    );
  });

  it("set bid amount - permission #1", async function () {
    const [TOKEN_ADMIN] = await ethers.getSigners();

    await expect(
      acpiThree
        .connect(TOKEN_ADMIN)
        .setBidAmount(ethers.utils.parseUnits("1", "ether"))
    ).to.revertedWith("Only ACPI Moderator Method");
  });

  it("set bid amount - permission #2", async function () {
    const [, , user1] = await ethers.getSigners();

    await expect(
      acpiThree
        .connect(user1)
        .setBidAmount(ethers.utils.parseUnits("1", "ether"))
    ).to.revertedWith("Only ACPI Moderator Method");
  });

  it("set bid amount - permission #3", async function () {
    const [, , , user2] = await ethers.getSigners();

    await expect(
      acpiThree
        .connect(user2)
        .setBidAmount(ethers.utils.parseUnits("1", "ether"))
    ).to.revertedWith("Only ACPI Moderator Method");
  });

  it("startRound - permission #1", async function () {
    const [TOKEN_ADMIN] = await ethers.getSigners();

    await expect(acpiThree.connect(TOKEN_ADMIN).startRound()).to.revertedWith(
      "Only ACPI Moderator Method"
    );
  });

  it("startRound - permission #2", async function () {
    const [, , user1] = await ethers.getSigners();

    await expect(acpiThree.connect(user1).startRound()).to.revertedWith(
      "Only ACPI Moderator Method"
    );
  });

  it("startRound - permission #3", async function () {
    const [, , , user2] = await ethers.getSigners();

    await expect(acpiThree.connect(user2).startRound()).to.revertedWith(
      "Only ACPI Moderator Method"
    );
  });

  it("bid add 1", async function () {
    const [, , user1] = await ethers.getSigners();

    let _bidAmount = await acpiThree.bidAmount();

    _bidAmount = _bidAmount.add(1);

    await expect(
      acpiThree.connect(user1).bid({ value: _bidAmount })
    ).to.revertedWith("Bid value should match exactly bid amount");
  });

  it("bid sub 1", async function () {
    const [, , user1] = await ethers.getSigners();

    let _bidAmount = await acpiThree.bidAmount();

    _bidAmount = _bidAmount.sub(1);

    await expect(
      acpiThree.connect(user1).bid({ value: _bidAmount })
    ).to.revertedWith("Bid value should match exactly bid amount");
  });

  it("bid - Already bet this round #1", async function () {
    const [, , user1] = await ethers.getSigners();

    const _bidAmount = await acpiThree.bidAmount();

    await acpiThree.connect(user1).bid({ value: _bidAmount });

    await expect(
      acpiThree.connect(user1).bid({ value: _bidAmount })
    ).to.revertedWith("You already bet this round");
  });

  it("bid - Already bet this round #2", async function () {
    const [, , user1] = await ethers.getSigners();

    const _bidAmount = await acpiThree.bidAmount();

    acpiThree.connect(user1).bid({ value: _bidAmount });

    await expect(
      acpiThree.connect(user1).bid({ value: _bidAmount })
    ).to.revertedWith("You already bet this round");

    await expect(
      acpiThree.connect(user1).bid({ value: _bidAmount })
    ).to.revertedWith("You already bet this round");

    await expect(
      acpiThree.connect(user1).bid({ value: _bidAmount })
    ).to.revertedWith("You already bet this round");

    await expect(
      acpiThree.connect(user1).bid({ value: _bidAmount })
    ).to.revertedWith("You already bet this round");
  });

  it("bid wars #1", async function () {
    const [, ACPI_MODERATOR, user1, user2, user3, user4, user5] =
      await ethers.getSigners();

    const _bidAmount = await acpiThree.bidAmount();

    await acpiThree.connect(user1).bid({ value: _bidAmount });

    await acpiThree.connect(user2).bid({ value: _bidAmount });

    await acpiThree.connect(user3).bid({ value: _bidAmount });

    await acpiThree.connect(user4).bid({ value: _bidAmount });

    await acpiThree.connect(user5).bid({ value: _bidAmount });

    await acpiThree.connect(ACPI_MODERATOR).startRound();

    expect(await acpiThree.pendingWins(user1.address)).to.equal(
      ethers.utils.parseUnits("0.2", "ether")
    );

    expect(await acpiThree.pendingWins(user2.address)).to.equal(
      ethers.utils.parseUnits("0.2", "ether")
    );

    expect(await acpiThree.pendingWins(user3.address)).to.equal(
      ethers.utils.parseUnits("0.2", "ether")
    );

    expect(await acpiThree.pendingWins(user4.address)).to.equal(
      ethers.utils.parseUnits("0.2", "ether")
    );

    expect(await acpiThree.pendingWins(user5.address)).to.equal(
      ethers.utils.parseUnits("0.2", "ether")
    );
  });

  it("bid wars #2", async function () {
    const [, ACPI_MODERATOR, user1, user2, user3] = await ethers.getSigners();

    const _bidAmount = await acpiThree.bidAmount();

    await acpiThree.connect(user1).bid({ value: _bidAmount });

    await acpiThree.connect(user2).bid({ value: _bidAmount });

    await acpiThree.connect(user3).bid({ value: _bidAmount });

    await acpiThree.connect(ACPI_MODERATOR).startRound();

    expect(await acpiThree.pendingWins(user1.address)).to.equal(
      "333333333333333333"
    );

    expect(await acpiThree.pendingWins(user2.address)).to.equal(
      "333333333333333333"
    );

    expect(await acpiThree.pendingWins(user3.address)).to.equal(
      "333333333333333333"
    );

    await acpiThree.connect(user1).bid({ value: _bidAmount });

    await acpiThree.connect(user2).bid({ value: _bidAmount });

    await acpiThree.connect(ACPI_MODERATOR).startRound();

    expect(await acpiThree.pendingWins(user1.address)).to.equal(
      "833333333333333333"
    );

    expect(await acpiThree.pendingWins(user2.address)).to.equal(
      "833333333333333333"
    );
  });

  it("ACPI Price", async function () {
    const [TOKEN_ADMIN, ACPI_MODERATOR, user1, user2, user3, user4] =
      await ethers.getSigners();

    const _bidAmount = await acpiThree.bidAmount();

    await acpiThree.connect(user1).bid({ value: _bidAmount });

    await acpiThree.connect(user2).bid({ value: _bidAmount });

    await acpiThree.connect(user3).bid({ value: _bidAmount });

    await acpiThree.connect(user4).bid({ value: _bidAmount });

    await acpiThree.connect(ACPI_MODERATOR).startRound();

    await acpiThree.connect(user1).bid({ value: _bidAmount });

    await acpiThree.connect(user2).bid({ value: _bidAmount });

    await acpiThree.connect(ACPI_MODERATOR).startRound();

    let index = (await acpiThree.currentRound()).toNumber();
    for (index; index < (await acpiThree.totalRound()).toNumber(); index++) {
      await acpiThree.connect(ACPI_MODERATOR).startRound();
    }

    expect(await acpiThree.totalRound()).to.equal(index);

    await realtToken.connect(TOKEN_ADMIN).setACPI(5);

    expect(await realtToken.initialTokenPrice()).to.equal(
      _bidAmount.mul(3).div(100).mul(35)
    );
  });
});
