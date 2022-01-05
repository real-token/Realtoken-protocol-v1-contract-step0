import { BigNumber } from "@ethersproject/bignumber";
import { expect } from "chai";
import { ethers, name, symbol } from "hardhat";
import {
  ACPIFour,
  ACPIMaster,
  ACPIOne,
  ACPIThree,
  ACPITwo,
  REG,
} from "../../typechain";
import { acpiData1, pendingReturns } from "./acpi1data";
import { acpiData2 } from "./acpi2data";
import { acpiData3 } from "./acpi3data";
import { acpiData4 } from "./acpi4data";

let acpiMaster: ACPIMaster;

let regToken: REG;
let acpiOne: ACPIOne;
let acpiTwo: ACPITwo;
let acpiThree: ACPIThree;
let acpiFour: ACPIFour;

const signersOffset = 2;
const testUserNumber = 100;

describe("END 2 END Testing", function () {
  it("End 2 End - Deployment", async function () {
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

    await regToken.contractTransfer(
      acpiMaster.address,
      ethers.utils.parseUnits("10000", "ether")
    );

    acpiOne = await ethers.getContractAt(
      "ACPIOne",
      await acpiMaster.acpiOneContract()
    );
    acpiTwo = await ethers.getContractAt(
      "ACPITwo",
      await acpiMaster.acpiTwoContract()
    );
    acpiThree = await ethers.getContractAt(
      "ACPIThree",
      await acpiMaster.acpiThreeContract()
    );
    acpiFour = await ethers.getContractAt(
      "ACPIFour",
      await acpiMaster.acpiFourContract()
    );
  });

  it("ACPI 1", async function () {
    const getSigners = await ethers.getSigners();

    await acpiMaster.connect(getSigners[0]).setACPI(1);

    await acpiOne.connect(getSigners[1]).setTotalRound(4);

    for (let i = 0; i < acpiData1.length; i++) {
      let counter = 0;
      let index = acpiData1[i].i;
      let increment = acpiData1[i].in;
      const direction = acpiData1[i].d;
      while (counter < testUserNumber) {
        await acpiOne.connect(getSigners[index + signersOffset]).bid(i, {
          value: increment,
        });

        increment = increment.add(acpiData1[i].in);

        if (direction > 0) index++;
        else index--;

        if (index === 100) index = 0;

        counter++;
      }
      await acpiOne.connect(getSigners[1]).startRound();
    }

    for (let j = 0; j < 100; j++) {
      let expectedValue = BigNumber.from(0);
      if (j === 0 || j === 10 || j === 58 || j === 99)
        expectedValue = ethers.utils.parseUnits("1", "ether");

      expect(
        await acpiOne.pendingReturns(getSigners[j + signersOffset].address)
      ).to.equal(
        ethers.utils.parseUnits(pendingReturns[j].toString(), "ether")
      );

      expect(
        await acpiOne.pendingWins(getSigners[j + signersOffset].address)
      ).to.equal(expectedValue);
    }
  });

  it("ACPI 2", async function () {
    const getSigners = await ethers.getSigners();

    const rounds = 4;
    await acpiMaster.connect(getSigners[0]).setACPI(2);
    await acpiTwo.connect(getSigners[1]).setTotalRound(rounds);

    const getEtherValue = (i: number, j: number) => {
      const getData = () => {
        if (i === 0) return acpiData2[j][1];
        if (i === 1) return acpiData2[j][2];
        if (i === 2) return acpiData2[j][3];
        if (i === 3) return acpiData2[j][4];

        return acpiData2[j][1];
      };

      let ethValue = getData();
      ethValue = ethValue.replace(",", ".");

      return ethers.utils.parseUnits(ethValue, "ether");
    };

    for (let i = 0; i < rounds; i++) {
      for (let j = 0; j < testUserNumber; j++) {
        const amount = getEtherValue(i, j);
        await acpiTwo.connect(getSigners[j + signersOffset]).bid(i, {
          value: amount,
        });
      }
      await acpiTwo.connect(getSigners[1]).startRound();
    }
    let total = BigNumber.from(0);

    for (let j = 0; j < testUserNumber; j++) {
      const pendingWins = await acpiTwo.pendingWins(
        getSigners[j + signersOffset].address
      );

      // TODO Find a way to test the actual pendingWins
      expect(pendingWins).to.not.be.equal(BigNumber.from(0));

      total = total.add(pendingWins);
    }

    console.log(
      "\nTotal redistributed: " + ethers.utils.formatEther(total) + "\n"
    );
    expect(await acpiMaster.getACPI()).to.equal(2);
  });

  it("ACPI 3", async function () {
    const { bidAmount, expected } = acpiData3;
    const getSigners = await ethers.getSigners();
    const rounds = 4;

    await acpiMaster.connect(getSigners[0]).setACPI(3);

    await acpiThree.connect(getSigners[1]).setBidAmount(bidAmount);

    await acpiThree.connect(getSigners[1]).setTotalRound(rounds);

    for (let i = 0; i < rounds; i++) {
      for (let j = 0; j < testUserNumber; j++) {
        await acpiThree.connect(getSigners[j + signersOffset]).bid(i, {
          value: bidAmount,
        });
      }
      await acpiThree.connect(getSigners[1]).startRound();
    }

    for (let i = 0; i < testUserNumber; i++) {
      expect(
        await acpiThree.pendingWins(getSigners[i + signersOffset].address)
      ).to.equal(expected);
    }
    expect(await acpiMaster.getACPI()).to.equal(3);
  });

  it("ACPI 4", async function () {
    type ACPI4key =
      | "Turn 1"
      | "Turn 2"
      | "Turn 3"
      | "Turn 1__1"
      | "Turn 2__1"
      | "Turn 3__1";

    type small = 1 | 2 | 3;
    const getSigners = await ethers.getSigners();

    const rounds = 2;
    const getEtherValue = (round: number, userIndex: number, turn: small) => {
      const getData = () => {
        let key: ACPI4key = `Turn ${turn}`;
        if (round > 0) key += "__1";

        return acpiData4[userIndex][key as ACPI4key];
      };

      let ethValue = getData();
      ethValue = ethValue.replace(",", ".");

      return ethers.utils.parseUnits(ethValue, "ether");
    };

    await acpiMaster.connect(getSigners[0]).setACPI(4);
    await acpiFour.connect(getSigners[1]).setTotalRound(rounds);
    await acpiFour.connect(getSigners[1]).setReward(100);

    for (let i = 0; i < rounds; i++) {
      let turnCount = 1 as small;
      while (true) {
        for (let j = 0; j < testUserNumber; j++) {
          const getValue = getEtherValue(i, j, turnCount);

          if (getValue.gt(0))
            await acpiFour
              .connect(getSigners[j + signersOffset])
              .bid(turnCount - 1, {
                value: getValue,
              });
        }
        turnCount++;
        const rewardLeft = await acpiFour.rewardLeft();
        if (rewardLeft.gt(0)) break;
        else await acpiFour.connect(getSigners[1]).startRound();
      }
      await acpiFour.connect(getSigners[1]).startRound();
    }

    for (let i = 0; i < testUserNumber; i++) {
      expect(
        await acpiFour.pendingWins(getSigners[i + signersOffset].address)
      ).to.equal(acpiData4[i].pendingWins);
    }

    expect(await acpiMaster.getACPI()).to.equal(4);
  });

  it("ACPI - Result", async function () {
    const getSigners = await ethers.getSigners();

    await acpiMaster.connect(getSigners[0]).setACPI(5);
    const initialTokenPrice = await acpiMaster.initialTokenPrice();

    await acpiMaster
      .connect(getSigners[0])
      .generateCrossChainPrice(initialTokenPrice);

    await acpiMaster.connect(getSigners[0]).setACPI(6);

    console.log("\nTOKEN TO CLAIM\n");
    let total = BigNumber.from(0);
    for (let i = 0; i < testUserNumber; i++) {
      const tokenToClaim = await acpiMaster
        .connect(getSigners[i + signersOffset])
        .tokenToClaim();

      const wins = await acpiMaster
        .connect(getSigners[i + signersOffset])
        .getACPIWins();

      const returns = await acpiMaster
        .connect(getSigners[i + signersOffset])
        .getACPIReturns();

      total = total.add(tokenToClaim);
      console.log(
        `${i + 3}: ` +
          ethers.utils.formatEther(tokenToClaim) +
          " - " +
          ethers.utils.formatEther(tokenToClaim.sub(wins)) +
          " - " +
          ethers.utils.formatEther(returns)
      );

      await acpiMaster.connect(getSigners[i + signersOffset]).claimTokens();
    }

    const totalReturns = await acpiMaster.totalReturns();
    const totalWins = await acpiMaster.totalWins();

    console.log("");
    const bal1 = await acpiOne.provider.getBalance(acpiOne.address);
    const bal2 = await acpiTwo.provider.getBalance(acpiTwo.address);
    const bal3 = await acpiThree.provider.getBalance(acpiThree.address);
    const bal4 = await acpiFour.provider.getBalance(acpiFour.address);

    const deposit = bal1.add(bal2).add(bal3).add(bal4);

    const price1 = await acpiOne.acpiPrice();
    const price2 = await acpiTwo.acpiPrice();
    const price3 = await acpiThree.acpiPrice();
    const price4 = await acpiFour.acpiPrice();

    console.log("TOTAL TOKEN GIVEN:\t" + ethers.utils.formatEther(total));
    console.log("TOTAL ETH DEPOSIT:\t" + ethers.utils.formatEther(deposit));

    console.log(
      "TOKEN PRICE GENERATED:\t" + ethers.utils.formatEther(initialTokenPrice)
    );

    console.log("TOTAL RETURNS:\t" + ethers.utils.formatEther(totalReturns));
    console.log("TOTAL WINS:\t" + ethers.utils.formatEther(totalWins));

    console.log("ACPI 1 PRICE:\t" + ethers.utils.formatEther(price1));
    console.log("ACPI 2 PRICE:\t" + ethers.utils.formatEther(price2));
    console.log("ACPI 3 PRICE:\t" + ethers.utils.formatEther(price3));
    console.log("ACPI 4 PRICE:\t" + ethers.utils.formatEther(price4));

    console.log(
      "TOKEN PRICE = 15%(ACPI1) + 25%(ACPI2) + 35%(ACPI3) + 25%(ACPI4)"
    );
    expect(await acpiMaster.getACPI()).to.equal(6);
  });
});
