<div id="top"></div>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center" id="about-the-project">
  <a href="https://github.com/real-token/Realtoken-protocol-v1-contract-step0">
    <img src="images/logo.svg" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">Real Estate Governance</h3>

  <p align="center">
    ACPI project (self-construction of the initial price)

The ACPI project aims to identify the initial selling price of a token through various exercises of selling a very small portion of the available tokens.
As we have seen in the multiple projects that have launched a token, using various methods of selling and making available tokens (lock, non lock, pools, airdrop and other), a common point was the starting price, 2 ways are repeated for almost all projects, the first set an arbitrary price by a handful of people who estimate according to various criteria the value of the token, the second is to list with low liquidity and an extremely low price.

In the first case it is unlikely that people involved in the project can actually find the value of the token, this usually leads to a collapse of the price from the beginning
For the second case, because the price and low liquidity is very low, the price has a tendency to explode upwards violently to quickly collapse making the happiness of the boot who manages to buy very low and resell during the rise, this creates immediate losses for all those who enter, loss that can remain several months or year before regaining the highs of the launch

RealT Inc. is drawing conclusions from the experiments of other players, and as we do not want to offer this experience for the governance token that will be put on sale soon, we are going to experiment with a new approach, the ACPI.
RealT not being a seer we cannot give a price to the token, the market being irrational and parasitized by scavenger boots bringing nothing to the project (we do not speak about the arbitrator boots which is vital), we have worked on this solution which allows the market to determine the initial price with the sale of a small exchange of tokens with various mechanics giving all prices which will be consolidated to obtain an initial market price.

The objectives of the ACPIs are therefore to experiment with different prices through 4 sales methods, each of which will be reproduced several times to obtain a sample price which will then be consolidated between the 4 ACPIs to give the initial price.
Another important objective is to concretely involve the community from the beginning in the life and emotion of this token, being a DAO governance token, we are convinced that the initial price should not be established by a centralized entity, but by the people using it who have an interest.

<ins id="acpi1">ACPI 1</ins> - Similar to an auction, in each session a token is put up for bidding, interested parties will bid to win the token.
At the end of several bidding sessions, the contract will take the median value of all the bids to set the ACPI 1 exit price

<ins id="acpi2">ACPI 2</ins> - Participation method where the amount is determined by the user, with each session a token is put on sale, Every participant deposits an amount of their choice into the common pot, at the end of the session the total sum of the pot determines the value of the token and each participant receives a proportional share of the token compared to its deposit in the pot.
At the end of several sessions the contract will take the average value of all the ACPI 2 sessions to set the ACPI 2 exit price.

<ins id="acpi3">ACPI 3</ins> - Similar to ACPI 2, it differs by having a single participation with a fixed amount in the pot, at the end of each session the total sum of the pot determines the value of the token and each participant receives an identical share of the token.

<ins id="acpi4">ACPI 4</ins> - Selling with a tiered price aims to determine the ceiling price, it resembles a low price bid in a liquidity pool with little available liquidity, however in ACPI4 this is done in a controlled environment, each session starts with a low price and increases each round by 60%, each round has an identical number of tokens offered for sale at the prices set by the contract, an investor can only buy one token at a time, but can participate in multiple sessions and each round of the same session.
The round of a session ends when all the tokens of the round are sold or if at the end of the timer the tokens are not completely sold.
The final price of a session is determined by the contract by taking an average between the sale of the last round and the penultimate round.
At the end of several sessions the contract will take the median value of all the ACPI 4 sessions to set the exit price of the ACPI 4

The final consolidation allows the initial price to be determined by taking the outputs of all 4 ACPIs and applying a degree of impact in the value of the token for that initial sale, this further limits attempts at manipulation and would make it very expensive to manipulate the price.
Once all the ACPI's have been completed, the tokens are released and available for claim by the users, it is possible to delay this step to make the claim available at a later date.
    <br />
    <a href="https://realt.co/"><strong>Realt.co</strong></a>
    <br />
    <br />
    <a href="https://github.com/real-token/Realtoken-protocol-v1-contract-step0">Live website</a>
    ·
    <a href="https://github.com/real-token/Realtoken-protocol-v1-contract-step0/issues">Report Bug</a>
    ·
    <a href="https://github.com/real-token/Realtoken-protocol-v1-contract-step0/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#acpi1">ACPI 1</a></li>
        <li><a href="#acpi2">ACPI 2</a></li>
        <li><a href="#acpi3">ACPI 3</a></li>
        <li><a href="#acpi4">ACPI 4</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#built-with-hardhat">Built With Hardhat</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- GETTING STARTED -->
## Getting Started


### Prerequisites


* npm
  ```sh
  npm install npm@latest -g
  ```

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/real-token/Realtoken-protocol-v1-contract-step0.git
   ```
2. Install NPM packages
   ```sh
   npm install
   ```
3. Setup a `.env` file, with the following config

   >  CoinMarketCap API Key [here](https://coinmarketcap.com/api/pricing/)

   >  Infura API Key [here](https://infura.io/pricing)

   >  Etherscan API Key [here](https://etherscan.io/apis)

   ```sh
    ETHERSCAN_API_KEY=API-KEY
    REPORT_GAS=CoinMarketCap-API-Key

    XDAI_URL=https://rpc.xdaichain.com/realt
    BSC_URL=https://bsc-dataseed.binance.org/
    POLYGON_URL=https://polygon-rpc.com/

    RINKEBY_URL=https://rinkeby.infura.io/v3/API-KEY
    GOERLI_URL=https://goerli.infura.io/v3/API-KEY

    TOKEN_ADMIN_PK=Token_Contract_Creator_Private_Key
    ACPI_MODERATOR=ACPI_Moderator_Private_Key
   ```

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

The Real Estate Governance Smart Contract suite is now ready for testing, compiling, auditing, and deploying.

+ Run tests
```sh
npx hardhat test
```
+ Check coverage
```sh
npx hardhat coverage
```
+ Verify deployed smart contract on Etherscan
```sh
npx hardhat verify CONTRACT_ADDRESS --network NETWORK_ID
```
+ Deploy and verify on network
```sh
npx hardhat run scripts/deployEther.ts --network NETWORK_ID
```
+ Deploy on network
```sh
npx hardhat run scripts/deploy.ts --network NETWORK_ID
```
> NETWORK_ID is specified inside [config](hardhat.config.ts)
<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MASS TESTING -->
# End2End Testing

> In order to ensure the reliability of our contract, we designed an end-to-end test that features 100 users across each of the 4 ACPIs. It verifies that the price for all ACPIs matches and the rewards are all in line.

## The report is available [here](https://docs.google.com/spreadsheets/d/15VrGhLZ6GQ370HacbFeNl1vms_BwhxSOSbxK2alWs2E/edit?usp=sharing)

Use the following command to start the test

```
npx hardhat test test/end2end/index.test.ts
```

The following syntax will appear in the report:

```
102: 5.332486580477705241 - 0.262922728291408962 - 13.15
```

+ **102** is the index of the user you can referer to the report [result tab](https://docs.google.com/spreadsheets/d/15VrGhLZ6GQ370HacbFeNl1vms_BwhxSOSbxK2alWs2E/edit#gid=1071362346)

+ **The first value 5.3324...** : `tokenToClaim` value, what the user will be able to withdraw at the end of the ACPI event, you can check that value in the report

+ **The second value 0.2629...** is the amount of tokens rewarded by the bids that were not the top bidder during **ACPI #1** you can check that value in the report as `PendingReturns`

+ **The third value 13.15** : The total of bids that were not the top bidder during ACPI #1 **ACPI #1**

## Following the ACPI event, user #102 will be able to collect the sum of his winnings, for example: <ins>~5.33249 REG</ins>
<p align="right">(<a href="#top">back to top</a>)</p>

<!-- AUDIT -->
## Audit

Auditing the solidity code in an important aspect of this language, we need to be confident with the code we ship to the customer to avoid malicious attacks

A lot of the auditing have been done during the contract construction using the `Solidity static analysis framework` [**Slither**](https://github.com/crytic/slither)

You can download Slither and use the following command to _audit_ the code

```sh
slither .
```
<p align="right">(<a href="#top">back to top</a>)</p>


<!-- ROADMAP -->
## Roadmap

- Main contract ✅
- ACPI 1 ✅
- ACPI 2 ✅
- ACPI 3 ✅
- ACPI 4 ✅
- Testing ✅

See the [open issues](https://github.com/real-token/Realtoken-protocol-v1-contract-step0/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- COVERAGE -->
## Coverage

<img src="images/coverage.png" alt="Coverage">

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- GAS FEES -->
## Gas fees

<img src="images/gas.png" alt="Coverage">

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing


If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Support - [@RealTPlatform](https://twitter.com/RealTPlatform) - support@realt.co

Project Link: [https://github.com/real-token/Realtoken-protocol-v1-contract-step0](https://github.com/real-token/Realtoken-protocol-v1-contract-step0)

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- BUILD WITH HARDHAT -->

## Built With Hardhat

* [Eslint](https://eslint.org/)
* [Chai](https://www.chaijs.com/guide/)
* [Solhint](https://github.com/protofire/solhint)
* [Prettier](https://github.com/prettier/prettier)
* [solidity-coverage](https://github.com/sc-forks/solidity-coverage)
* [dotenv](https://www.npmjs.com/package/dotenv)
* [Waffle](https://getwaffle.io/)
* [Typescript](https://www.typescriptlang.org/)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Hardhat Team](https://hardhat.org/)
* [Haytham Allos - CTO # Off Chain Oracle](https://www.linkedin.com/in/haythamallos/)
* [Michael Courvoisier - COO # Guidelines](https://github.com/Michael-RealT)
* [Bastien Silhol - Solidity code](https://github.com/chichke)
* [Nathan Quesseveur - Front end](https://www.linkedin.com/in/nathan-quesseveur-221a12145)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/real-token/Realtoken-protocol-v1-contract-step0.svg?style=for-the-badge
[contributors-url]: https://github.com/real-token/Realtoken-protocol-v1-contract-step0/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/real-token/Realtoken-protocol-v1-contract-step0.svg?style=for-the-badge
[forks-url]: https://github.com/real-token/Realtoken-protocol-v1-contract-step0/network/members
[stars-shield]: https://img.shields.io/github/stars/real-token/Realtoken-protocol-v1-contract-step0.svg?style=for-the-badge
[stars-url]: https://github.com/real-token/Realtoken-protocol-v1-contract-step0/stargazers
[issues-shield]: https://img.shields.io/github/issues/real-token/Realtoken-protocol-v1-contract-step0.svg?style=for-the-badge
[issues-url]: https://github.com/real-token/Realtoken-protocol-v1-contract-step0/issues
[license-shield]: https://img.shields.io/github/license/real-token/Realtoken-protocol-v1-contract-step0.svg?style=for-the-badge
[license-url]: https://github.com/real-token/Realtoken-protocol-v1-contract-step0/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/realtplatform/
[product-screenshot]: images/screenshot.png