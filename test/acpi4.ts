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
    for (index = 0; index < (await acpiFour.totalRound()).toNumber(); index++) {
      await acpiFour.connect(ACPI_MODERATOR).startRound();
    }

    expect(await acpiFour.totalRound()).to.equal(index);

    await expect(
      acpiFour.connect(addr1).buy({
        value: ethers.utils.parseUnits("3", "ether"),
      })
    ).to.be.revertedWith("BUY: All rounds have been done");
  });
});
