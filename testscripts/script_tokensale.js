module.exports = async function(callback) {
    try {
        SIPilotToken = artifacts.require("SIPilotToken");
        let accounts = await web3.eth.getAccounts();
        SIPilotToken = await SIPilotToken.deployed();
        
        //check if tokensale is open 
        console.log(await SIPilotToken.tokensale_open()); 
    
        //Transaction 1  - Investing 1 USD   
        console.log(await SIPilotToken.buyTokens(web3.utils.toBN(web3.utils.toWei(String(1), 'ether')), {from: accounts[0], value: web3.utils.toBN(web3.utils.toWei(String(0.05), 'ether'))}));

        //Transaction 2 - Investing 2 USD
        console.log(await SIPilotToken.buyTokens(web3.utils.toBN(web3.utils.toWei(String(2), 'ether')), {from: accounts[1], value: web3.utils.toBN(web3.utils.toWei(String(0.05), 'ether'))}));

        //Transaction 3 - Investing 3 USD
        console.log(await SIPilotToken.buyTokens(web3.utils.toBN(web3.utils.toWei(String(3), 'ether')), {from: accounts[2], value: web3.utils.toBN(web3.utils.toWei(String(0.05), 'ether'))}));
    
        //Transaction 4 - Investing 4 USD
        console.log(await SIPilotToken.buyTokens(web3.utils.toBN(web3.utils.toWei(String(4), 'ether')), {from: accounts[3], value: web3.utils.toBN(web3.utils.toWei(String(0.05), 'ether'))}));
        
        //Transaction 5 - should revert, because funds are raised already raised
        console.log(await SIPilotToken.buyTokens(web3.utils.toBN(web3.utils.toWei(String(1), 'ether')), {from: accounts[3], value: web3.utils.toBN(web3.utils.toWei(String(0.05), 'ether'))}));
  
        
        //check if tokensale still open 
        console.log(await SIPilotToken.tokensale_open()); 

        callback();

} catch(e){
 console.log(e)
}
}
