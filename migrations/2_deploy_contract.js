var HumanToken = artifacts.require("HumanToken.sol");
var config = require("./config.json");

module.exports = function(deployer, network, accounts) {
	deployer.deploy(
    	HumanToken,
    	accounts[0]
    	//config.Owner
    );
};