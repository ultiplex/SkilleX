'use strict';

require('dotenv').config({path: '.env.local'});
const Web3 = require("web3");
const web3 = new Web3();
const WalletProvider = require("truffle-wallet-provider");
const Wallet = require('ethereumjs-wallet');

module.exports = {
	networks: {
		kovan: {
		    provider: function(){
		    	var kovanPrivateKey = new Buffer(process.env["PRIVATE_KEY"], "hex")
				var kovanWallet = Wallet.fromPrivateKey(kovanPrivateKey);
		    	return new WalletProvider(kovanWallet, "https://kovan.infura.io/");
		    },
		    gas: 4600000,
	      	gasPrice: web3.toWei("20", "gwei"),
		    network_id: '42',
		},
		local: {
          host: 'localhost',
          port: 8545,
          gas: 5000000,
          network_id: '*'
        }
	}
};