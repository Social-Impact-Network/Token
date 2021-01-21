module.exports = async function(callback) {
    try {
        SIPilotToken = artifacts.require("SIPilotToken");
        let accounts = await web3.eth.getAccounts();
        SIPilotToken = await SIPilotToken.deployed();
        
        //Transaction 1
        console.log(await SIPilotToken.withdrawAmount({from: accounts[0]}));

        //Transaction 2
        console.log(await SIPilotToken.withdrawAmount({from: accounts[1]}));
    
        //Transaction 3
        console.log(await SIPilotToken.withdrawAmount({from: accounts[2]}));

        //Transaction 4
        console.log(await SIPilotToken.withdrawAmount({from: accounts[3]}));

        callback();

} catch(e){
 console.log(e)
}
}
