[![License](https://img.shields.io/github/license/Social-Impact-Network/Token?style=plastic)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/Social-Impact-Network/Token?style=plastic)](https://github.com/Social-Impact-Network/Token/issues)
[![GitHub package version](https://img.shields.io/github/v/release/Social-Impact-Network/Token?include_prereleases&style=plastic)](https://github.com/Social-Impact-Network/Token/blob/master/package.json)
[![Twitter](https://img.shields.io/twitter/follow/SINetwork1.svg?style=social&label=@SINetwork1)](https://twitter.com/SINetwork1)

## Social Impact  Token (Smart Contract)

The Social Impact Token (SI Token) is used for payment flows (including investment, allocation, interest and payouts). SI Token is an ERC20 token on the Ethereum Blockchain, programmed in Solidity. All interactions with SI Token can be done through SI platform (frontend). Since the token was implemented according to the ERC20 standard, the basic functions (e.g. sending and receiving) can also be performed via any ERC20-enabled wallet.

## Vulnerabilites, Bugs & Feature Request

If you find any vulnerability, bug, or you want a feature added, feel free to submit an issue at [Github Issues](https://github.com/Social-Impact-Network/Token/issues)

## Getting started in Dev Mode

1. Make sure you have NPM version 6 or later and NodeJS v8.9.4 or later installed.
2. Open terminal
3. Clone the repo: `git clone https://github.com/Social-Impact-Network/Token.git`.
4. Move to the dictory by running `cd Token`
5. Run `npm install -g truffle` to install Truffle Suite.
6. Run `npm install` to install node packages.
7. Set up your own personal Ethereum-Virtual-Machine based Blockchain. Check out this [Quickstart](https://www.trufflesuite.com/docs/ganache/quickstart)
8. Run `truffle migrate --network development` to deploy the Smart Contract in you personal Blockchain.
9. You can interact with the Smart Contract by setting up the [Frontend](https://github.com/Social-Impact-Network/Frontend) or directly via Web3 client (e.g. [ethers.js](https://github.com/ethers-io/ethers.js/) or [web3.js](https://github.com/ChainSafe/web3.js).

## Getting started in Production Mode

1. Make sure you have NPM version 6 or later and NodeJS v8.9.4 or later installed.
2. Open terminal
3. Clone the repo: `git clone https://github.com/Social-Impact-Network/Token.git`.
4. Move to the dictory by running `cd Token`
5. Run `npm install -g truffle` to install Truffle Suite.
6. Run `npm install` to install node packages.
7. Edit the values `MNENOMIC` (wallet seed phrase) and `INFURA_API_KEY` (check this [Infura - Getting Started](https://blog.infura.io/getting-started-with-infura-28e41844cc89/)) in the file .env.example and rename it to .env.
8. Edit the file `/migrations/2_migration_token.js` to customize the parameter of the Token deployment. 
9. Run `truffle migrate --network mainnet` to deploy the Smart Contract to the Ethereum mainnet network.
10. You can interact with the Smart Contract by setting up the [Frontend](https://github.com/Social-Impact-Network/Frontend) or directly via Web3 client (e.g. [ethers.js](https://github.com/ethers-io/ethers.js/) or [web3.js](https://github.com/ChainSafe/web3.js) the.

## Simulation of user interactions

`truffle exec ./testscripts/script_tokensale.js --network development`  
This script initiates 4 transaction from investors to buy Token.


`truffle exec ./testscripts/script_release_funds.js --network development`  
This script initiates the transaction to release the raised funds to the benficiary.

`truffle exec ./testscripts/script_payment.js –network development`  
This script initiates a loan payment transaction from beneficiary to Smart Contract.

`truffle exec ./testscripts/script_claim_dividends.js --network development`  
This script initiates 4 transactions from investors to claim the payment.

