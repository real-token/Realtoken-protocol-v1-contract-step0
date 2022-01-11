import { expect } from "chai";
import { ethers, name, symbol, upgrades } from "hardhat";
import { REG, ACPIThree, ACPIMaster } from "../typechain-types";

let regToken: REG;
let acpiThree: ACPIThree;
let acpiMaster: ACPIMaster;

describe("ACPI Three", function () {
  beforeEach(async () => {
    const [TOKEN_ADMIN, ACPI_MODERATOR] = await ethers.getSigners();

    const regFactory = await ethers.getContractFactory("REG");
    regToken = (await upgrades.deployProxy(
      regFactory,
      [name, symbol, TOKEN_ADMIN.address],
      { kind: "uups" }
    )) as REG;
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

    const acpiOneFactory = await ethers.getContractFactory("ACPIOne");
    const acpiOne = await acpiOneFactory.deploy(acpiMaster.address);

    await acpiOne.deployed();

    await acpiMaster.setACPIOne(acpiOne.address);

    const acpiTwoFactory = await ethers.getContractFactory("ACPITwo");
    const acpiTwo = await acpiTwoFactory.deploy(acpiMaster.address);

    await acpiTwo.deployed();

    await acpiMaster.setACPITwo(acpiTwo.address);

    const acpiThreeFactory = await ethers.getContractFactory("ACPIThree");
    acpiThree = await acpiThreeFactory.deploy(acpiMaster.address);

    await acpiThree.deployed();

    await acpiMaster.setACPIThree(acpiThree.address);

    const acpiFourFactory = await ethers.getContractFactory("ACPIFour");
    const acpiFour = await acpiFourFactory.deploy(acpiMaster.address);

    await acpiFour.deployed();

    await acpiMaster.setACPIFour(acpiFour.address);
    await acpiMaster.connect(TOKEN_ADMIN).setACPI(3);
  });

  it("Going at the end!", async function () {
    const [, ACPI_MODERATOR, addr1] = await ethers.getSigners();

    let index = 0;
    for (index = 0; index < (await acpiThree.totalRound()); index++) {
      await acpiThree.connect(ACPI_MODERATOR).startRound();
    }

    expect(await acpiThree.totalRound()).to.equal(index);

    await expect(
      acpiThree.connect(addr1).bid(index, {
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
      acpiThree.connect(user1).bid(0, { value: _bidAmount })
    ).to.revertedWith("BID: Amount sent doesn't match expected value");
  });

  it("bid sub 1", async function () {
    const [, , user1] = await ethers.getSigners();

    let _bidAmount = await acpiThree.bidAmount();

    _bidAmount = _bidAmount.sub(1);

    await expect(
      acpiThree.connect(user1).bid(0, { value: _bidAmount })
    ).to.revertedWith("BID: Amount sent doesn't match expected value");
  });

  it("bid - Already bet this turn #1", async function () {
    const [, , user1] = await ethers.getSigners();

    const _bidAmount = await acpiThree.bidAmount();

    await acpiThree.connect(user1).bid(0, { value: _bidAmount });

    await expect(
      acpiThree.connect(user1).bid(0, { value: _bidAmount })
    ).to.revertedWith("BID: You can only bet once per round");
  });

  it("bid - Already bet this turn #2", async function () {
    const [, , user1] = await ethers.getSigners();

    const _bidAmount = await acpiThree.bidAmount();

    await acpiThree.connect(user1).bid(0, { value: _bidAmount });

    await expect(
      acpiThree.connect(user1).bid(0, { value: _bidAmount })
    ).to.revertedWith("BID: You can only bet once per round");

    await expect(
      acpiThree.connect(user1).bid(0, { value: _bidAmount })
    ).to.revertedWith("BID: You can only bet once per round");

    await expect(
      acpiThree.connect(user1).bid(0, { value: _bidAmount })
    ).to.revertedWith("BID: You can only bet once per round");

    await expect(
      acpiThree.connect(user1).bid(0, { value: _bidAmount })
    ).to.revertedWith("BID: You can only bet once per round");
  });

  it("bid wars #1", async function () {
    const [, ACPI_MODERATOR, user1, user2, user3, user4, user5] =
      await ethers.getSigners();

    const _bidAmount = await acpiThree.bidAmount();

    await acpiThree.connect(user1).bid(0, { value: _bidAmount });

    await acpiThree.connect(user2).bid(0, { value: _bidAmount });

    await acpiThree.connect(user3).bid(0, { value: _bidAmount });

    await acpiThree.connect(user4).bid(0, { value: _bidAmount });

    await acpiThree.connect(user5).bid(0, { value: _bidAmount });

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

    await acpiThree.connect(user1).bid(0, { value: _bidAmount });

    await acpiThree.connect(user2).bid(0, { value: _bidAmount });

    await acpiThree.connect(user3).bid(0, { value: _bidAmount });

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

    await acpiThree.connect(user1).bid(1, { value: _bidAmount });

    await acpiThree.connect(user2).bid(1, { value: _bidAmount });

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

    await acpiThree.connect(user1).bid(0, { value: _bidAmount });

    await acpiThree.connect(user2).bid(0, { value: _bidAmount });

    await acpiThree.connect(user3).bid(0, { value: _bidAmount });

    await acpiThree.connect(user4).bid(0, { value: _bidAmount });

    await acpiThree.connect(ACPI_MODERATOR).startRound();

    await acpiThree.connect(user1).bid(1, { value: _bidAmount });

    await acpiThree.connect(user2).bid(1, { value: _bidAmount });

    await acpiThree.connect(ACPI_MODERATOR).startRound();

    let index = await acpiThree.currentRound();
    for (index; index < (await acpiThree.totalRound()); index++) {
      await acpiThree.connect(ACPI_MODERATOR).startRound();
    }

    expect(await acpiThree.totalRound()).to.equal(index);

    await acpiMaster.connect(TOKEN_ADMIN).setACPI(5);

    expect(await acpiMaster.initialTokenPrice()).to.equal(
      _bidAmount.mul(3).div(100).mul(35)
    );
  });
});
