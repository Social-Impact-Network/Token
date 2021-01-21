const SIPilotToken = artifacts.require("SIPilotToken");

module.exports = function(deployer, network, accounts) {
  
  //Token name
  var tokenName = "Social Impact Prototype Token";
  //Token label
  var tokenLabel = "SIP";
  //Funding size
  var fundingAmount = 100;
  var fundingAmountInWei = web3.utils.toWei(fundingAmount.toString(), 'ether');
  var BNfundingAmountInWei = web3.utils.toBN(fundingAmountInWei);
  
  //Conversion rate USD to Social Impact Token - 1 means 1 USD is equal 1 SIP
  var conversionRateTokenUSD = 1;

  //Beneficiary address
  var beneficiary = accounts[3];

  //Deploy Smart Contract
  deployer.deploy(SIPilotToken, tokenName, tokenLabel, decimals, BNfundingAmountInWei, conversionRateTokenUSD, beneficiary);
  //constructor (string memory name_, string memory symbol_, uint8 decimals_, uint256 cap_, uint256 rate_, address beneficiary_) {
};
