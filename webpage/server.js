var express = require('express');
var server = express();
// host webpage on localhost
server.use(express.static(__dirname + '/public'));

var bodyParser = require('body-parser');
server.use(bodyParser.urlencoded({extended: true}));

var eth_address = "";
var eth_donate = 0;
var total_money = 0;

// handles post request from donor html form 
server.post('/donor', (request, response) => {
	// post request from donor.html --> {ethereum address of donor, money amount of donation}
	console.log("post request received from /donor\n");
	console.log(request.body + "\n");
	// save data from post request
	eth_address = request.body.Address;
	eth_donate = parseInt(request.body.Donation);
	total_money += eth_donate;
	console.log("address: " + eth_address + " type: " + typeof(eth_address));
	console.log("donation: " + eth_donate + " type: " + typeof(eth_address));
	console.log("total_money_donated: " + total_money + " type: " + typeof(eth_address) + "\n\n");
	
	response.status(200).send("Thank you for your kind donation. It has been well received.");
});

server.listen(3000, function () {
	console.log("Server is listening on port 3000");
});

// run in terminal: node server.js