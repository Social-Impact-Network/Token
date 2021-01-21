module.exports = async function(callback) {
    try {
        SIPilotToken = artifacts.require("SIPilotToken");
        SIPilotToken = await SIPilotToken.deployed();
        
        //Release the funds to the registered beneficiary address
        console.log(await SIPilotToken.releaseFunds());

        callback();

} catch(e){
 console.log(e)
}
}
