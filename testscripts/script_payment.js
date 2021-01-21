module.exports = async function(callback) {
    try {
        ERC20 = artifacts.require("ERC20");
        const daiContract = new web3.eth.Contract(ERC20.abi, "0xaD6D458402F60fD3Bd25163575031ACDce07538D");

        SIPilotToken = artifacts.require("SIPilotToken");
        let accounts = await web3.eth.getAccounts();
        SIPilotToken = await SIPilotToken.deployed();
        
        //amount of the lease payment
        var daiAmount = 1;
        var daiTokens = web3.utils.toWei(daiAmount.toString(), 'ether');
        var bnAmount = web3.utils.toBN(daiTokens);
        
        
        //get stable coin DAI balance of the user account 
        console.log(await daiContract.methods.balanceOf(accounts[0]).call({from: accounts[0]}));
        
        //approve the Token Smart Contract to send amount of stable coin DAI from user account
        console.log(await daiContract.methods.approve(SIPilotToken.address, bnAmount).send({from: accounts[0]}));

        //get the Token Smart Contract is allowed to send amount of stable coin DAI from user account
        console.log(await daiContract.methods.allowance(accounts[0], SIPilotToken.address).call({from: accounts[0]}));

        //send stable coin DAI from user account to the contract 
        console.log(await SIPilotToken.receivePayment(bnAmount, {from: accounts[0]}));

        callback();

    } catch(e){
        console.log(e)
    }
}
