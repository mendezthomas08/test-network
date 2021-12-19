/**
 * Copyright 2017 IBM All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
'use strict';
var fs = require('fs');
var logger = require('./config/winston.js');
var express = require('express');
var bodyParser = require('body-parser');
var http = require('http');
var util = require('util');
var app = express();
var expressJWT = require('express-jwt');
var jwt = require('jsonwebtoken');
var bearerToken = require('express-bearer-token');
var cors = require('cors');
require('./config.js');
var hfc = require('fabric-client');
var helper = require('./app/helper.js');
var install = require('./app/install-chaincode.js');
var instantiate = require('./app/instantiate-chaincode.js');
var invoke = require('./app/invoke-transaction.js');
var query = require('./app/query.js');
var shell = require('shelljs');
var mkdirp = require('mkdirp');
var host = process.env.HOST || hfc.getConfigSetting('host');
var port = process.env.PORT || hfc.getConfigSetting('port');

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// SET CONFIGURATONS ////////////////////////////
///////////////////////////////////////////////////////////////////////////////
app.options('*', cors());
app.use(cors());
app.use(bodyParser.json());
app.set('secret', hfc.getConfigSetting('secret'));

app.get('/networkHealth', async function (req, res) {
        logger.info('<<<<<<<<<<<<<<<<< G E T  N E T W O R K  H E A L T H  W I T H  S C R I P T >>>>>>>>>>>>>>>>>');
        logger.debug('End point : /networkHealth');
        shell.exec('cd ../.. ; ./network_health.sh', function (code, stdout, stderr) {
                console.log('Exit code:', code);
                console.log('Program output:', stdout);
                console.log('Program stderr:', stderr);
                res.status(200).send(JSON.parse(stdout));
        });
});

app.use(expressJWT({
	secret: app.get('secret')
}).unless({
	path: ['/users/register']
}));

app.use(bearerToken());

app.use(function (req, res, next) {
	logger.debug(' ------>>>>>> new request for %s', req.originalUrl);

	if (req.originalUrl.indexOf('/users/register') >= 0) {
		return next();
	}

	if (req.name === 'UnauthorizedError') {
		res.status(error.status).send({ message: error.message });
		logger.error(error);
	}


	var token = req.token;
	jwt.verify(token, app.get('secret'), function (err, decoded) {
		if (err) {
			res.status(403).send({
				success: false,
				message: 'Failed to authenticate token.'
			});
			return;
		} else {
			req.username = decoded.username;
			req.orgname = decoded.orgName;
			logger.debug(util.format('Decoded from JWT token: username - %s, orgname - %s', decoded.username, decoded.orgName));
			return next();
		}
	});
});

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// START SERVER /////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var server = http.createServer(app).listen(port, function () { });
logger.info('****************** SERVER STARTED ************************');
logger.info('***************  http://%s:%s  ******************', host, port);
server.timeout = 240000;

function getErrorMessage(field) {
	var response = {
		success: false,
		message: field + ' field is missing or Invalid in the request'
	};
	return response;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////// REST ENDPOINTS START HERE ///////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Register and enrol user 
app.post('/users/register', async function (req, res) {
	var username = req.body.username;
	var orgName = req.body.orgName;
	var role = req.body.role;
	var attrs = req.body.attrs;
	var secret = req.body.secret;

	logger.debug('User name : ' + username);
	logger.debug('Org name  : ' + orgName);
	logger.debug('Role  : ' + role);
	logger.debug('Attrs  : ' + attrs);
	logger.debug('Secret  : ' + secret);

	if (!username) {
		res.status(400).json(getErrorMessage('\'username\''));
		return;
	}
	if (!orgName) {
		res.status(400).json(getErrorMessage('\'orgName\''));
		return;
	}
	if (!secret) {
		res.status(400).json(getErrorMessage('\'secret\''));
		return;
	}
	let secret2 = await helper.checkSecret(orgName, secret)
	if (secret === secret2) {
		var token = jwt.sign({
			exp: Math.floor(Date.now() / 1000) + parseInt(hfc.getConfigSetting('jwt_expiretime')),
			username: username,
			orgName: orgName,
		}, app.get('secret'));
		let response = await helper.registerUser(username, orgName, role, attrs);
		if (response && typeof response !== 'string') {
			response.token = token;
			res.status(200).send(response);
		} else {
			res.status(400).json({ success: false, message: response });
		}
	}
	else {
		res.status(400).json({ success: false, message: 'Invalid organization secret' });
	}

});


// Install chaincode on target peers
app.post('/chaincodes', async function (req, res) {
	logger.debug('==================== INSTALL CHAINCODE ==================');
	var peers = req.body.peers;
	var chaincodeName = req.body.chaincodeName;
	var chaincodePath = req.body.chaincodePath;
	var chaincodeVersion = req.body.chaincodeVersion;
	var chaincodeType = req.body.chaincodeType;
	logger.debug('peers : ' + peers); // target peers list
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('chaincodePath  : ' + chaincodePath);
	logger.debug('chaincodeVersion  : ' + chaincodeVersion);
	logger.debug('chaincodeType  : ' + chaincodeType);
	if (!peers || peers.length == 0) {
		res.status(400).json(getErrorMessage('\'peers\''));
		return;
	}
	if (!chaincodeName) {
		res.status(400).json(getErrorMessage('\'chaincodeName\''));
		return;
	}
	if (!chaincodePath) {
		res.status(400).json(getErrorMessage('\'chaincodePath\''));
		return;
	}
	if (!chaincodeVersion) {
		res.status(400).json(getErrorMessage('\'chaincodeVersion\''));
		return;
	}
	if (!chaincodeType) {
		res.status(400).json(getErrorMessage('\'chaincodeType\''));
		return;
	}
	let message = await install.installChaincode(peers, chaincodeName, chaincodePath, chaincodeVersion, chaincodeType, req.username, req.orgname)
	res.status(200).send(message);
});

// Instantiate chaincode on target peers
app.post('/channels/:channelName/chaincodes', async function (req, res) {
	logger.debug('==================== INSTANTIATE CHAINCODE ==================');
	var peers = req.body.peers;
	var chaincodeName = req.body.chaincodeName;
	var chaincodeVersion = req.body.chaincodeVersion;
	var channelName = req.params.channelName;
	var chaincodeType = req.body.chaincodeType;
	var fcn = req.body.fcn;
	var args = req.body.args;
	var policy = req.body.policy;

	logger.debug('peers  : ' + peers);
	logger.debug('channelName  : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('chaincodeVersion  : ' + chaincodeVersion);
	logger.debug('chaincodeType  : ' + chaincodeType);
	logger.debug('fcn  : ' + fcn);
	logger.debug('args  : ' + args);
	logger.debug('policy  : ' + policy);

	if (!chaincodeName) {
		res.status(400).json(getErrorMessage('\'chaincodeName\''));
		return;
	}
	if (!chaincodeVersion) {
		res.status(400).json(getErrorMessage('\'chaincodeVersion\''));
		return;
	}
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	if (!chaincodeType) {
		res.status(400).json(getErrorMessage('\'chaincodeType\''));
		return;
	}
	if (!args) {
		res.status(400).json(getErrorMessage('\'args\''));
		return;
	}
	if (!policy) {
		res.status(400).json(getErrorMessage('\'policy\''));
		return;
	}

	let message = await instantiate.instantiateChaincode(peers, channelName, chaincodeName, chaincodeVersion, chaincodeType, fcn, args, req.username, req.orgname, policy);
	res.status(200).send(message);
});


// Invoke transaction on chaincode on target peers
app.post('/channels/:channelName/chaincodes/:chaincodeName', async function (req, res) {
	logger.debug('==================== INVOKE ON CHAINCODE ==================');
	var peers = req.body.peers;
	var chaincodeName = req.params.chaincodeName;
	var channelName = req.params.channelName;
	var fcn = req.body.fcn;
	var args = req.body.args;
	logger.debug('channelName  : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('fcn  : ' + fcn);
	logger.debug('args  : ' + args);
	if (!chaincodeName) {
		res.status(400).json(getErrorMessage('\'chaincodeName\''));
		return;
	}
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	if (!fcn) {
		res.status(400).json(getErrorMessage('\'fcn\''));
		return;
	}
	if (!args) {
		res.status(400).json(getErrorMessage('\'args\''));
		return;
	}

	let message = await invoke.invokeChaincode(peers, channelName, chaincodeName, fcn, args, req.username, req.orgname);
	res.status(200).send(message);
});

// Query on chaincode on target peers
app.get('/channels/:channelName/chaincodes/:chaincodeName', async function (req, res) {
	logger.debug('==================== QUERY BY CHAINCODE ==================');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	let args = req.query.args;
	let fcn = req.query.fcn;
	let peer = req.query.peer;

	logger.debug('channelName : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('fcn : ' + fcn);
	logger.debug('args : ' + args);

	if (!chaincodeName) {
		res.status(400).json(getErrorMessage('\'chaincodeName\''));
		return;
	}
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	if (!fcn) {
		res.status(400).json(getErrorMessage('\'fcn\''));
		return;
	}
	if (!args) {
		res.status(400).json(getErrorMessage('\'args\''));
		return;
	}
	args = args.replace(/'/g, '"');
	args = JSON.parse(args);
	logger.debug(args);

	let message = await query.queryChaincode(peer, channelName, chaincodeName, args, fcn, req.username, req.orgname);
	res.status(200).send(message);
});

//  Query Get Block by BlockNumber
app.get('/channels/:channelName/blocks/:blockId', async function (req, res) {
	logger.debug('==================== GET BLOCK BY NUMBER ==================');
	let blockId = req.params.blockId;
	let peer = req.query.peer;
	logger.debug('channelName : ' + req.params.channelName);
	logger.debug('BlockID : ' + blockId);
	logger.debug('Peer : ' + peer);
	if (!blockId) {
		res.status(400).json(getErrorMessage('\'blockId\''));
		return;
	}

	let message = await query.getBlockByNumber(peer, req.params.channelName, blockId, req.username, req.orgname);
	res.status(200).send(message);
});

// Query Get Transaction by Transaction ID
app.get('/channels/:channelName/transactions/:trxnId', async function (req, res) {
	logger.debug('================ GET TRANSACTION BY TRANSACTION_ID ======================');
	logger.debug('channelName : ' + req.params.channelName);
	let trxnId = req.params.trxnId;
	let peer = req.query.peer;
	if (!trxnId) {
		res.status(400).json(getErrorMessage('\'trxnId\''));
		return;
	}

	let message = await query.getTransactionByID(peer, req.params.channelName, trxnId, req.username, req.orgname);
	res.status(200).send(message);
});

// Query Get Block by Hash
app.get('/channels/:channelName/blocks', async function (req, res) {
	logger.debug('================ GET BLOCK BY HASH ======================');
	logger.debug('channelName : ' + req.params.channelName);
	let hash = req.query.hash;
	let peer = req.query.peer;
	if (!hash) {
		res.status(400).json(getErrorMessage('\'hash\''));
		return;
	}

	let message = await query.getBlockByHash(peer, req.params.channelName, hash, req.username, req.orgname);
	res.status(200).send(message);
});

//Query for Channel Information
app.get('/channels/:channelName', async function (req, res) {
	logger.debug('================ GET CHANNEL INFORMATION ======================');
	logger.debug('channelName : ' + req.params.channelName);
	let peer = req.query.peer;

	let message = await query.getChainInfo(peer, req.params.channelName, req.username, req.orgname);
	res.status(200).send(message);
});

//Query for Channel instantiated chaincodes
app.get('/channels/:channelName/chaincodes', async function (req, res) {
	logger.debug('================ GET INSTANTIATED CHAINCODES ======================');
	logger.debug('channelName : ' + req.params.channelName);
	let peer = req.query.peer;

	let message = await query.getInstalledChaincodes(peer, req.params.channelName, 'instantiated', req.username, req.orgname);
	res.status(200).send(message);
});

// Query to fetch all Installed/instantiated chaincodes
app.get('/chaincodes', async function (req, res) {
	var peer = req.query.peer;
	var installType = req.query.type;
	logger.debug('================ GET INSTALLED CHAINCODES ======================');
	let message;
	if (installType === 'installed') {
		logger.debug('<< Installed Chaincodes >>');
		message = await query.getInstalledChaincodes(peer, null, 'installed', req.username, req.orgname)
	} else {
		logger.debug('<< Instantiated Chaincodes >>');
		message = await query.getInstalledChaincodes(peer, null, 'instantiated', req.username, req.orgname)
	}

	res.status(200).send(message);
});

// Query to fetch channels
app.get('/channels', async function (req, res) {
	logger.debug('================ GET CHANNELS ======================');
	logger.debug('peer: ' + req.query.peer);
	logger.debug('username: ' + req.username);
	logger.debug('orgname: ' + req.orgname);

	var peer = req.query.peer;
	if (!peer) {
		res.status(400).json(getErrorMessage('\'peer\''));
		return;
	}

	let message = await query.getChannels(peer, req.username, req.orgname);
	res.status(200).send(message);
});

//Query to get all Orgs in a channel
app.get('/orgs/:channelName/chaincode', async function (req, res) {
	logger.debug('================ GET ORGS IN A CHANNEL ======================');
	logger.debug('username: ' + req.username);
	logger.debug('orgname: ' + req.orgname);
	logger.debug('channelName: ' + req.params.channelName);
	//       logger.debug('peer: ' + req.query.peer);
	var channelName = req.params.channelName;
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	/* var peer = req.query.peer;
	 if (!peer) {
			  res.status(400).json(getErrorMessage('\'peer\''));
			  return;
	  }*/

	let message = await query.getOrgs(channelName, req.username, req.orgname);
	res.status(200).send(message);
});
//Query to get no of blocks in the channel
app.get('/transactions/:channelName', async function (req, res) {
	logger.debug('================ GET Maximum transactions in the latest block ======================');
	logger.debug('username: ' + req.username);
	logger.debug('orgname: ' + req.orgname);
	logger.debug('channelName: ' + req.params.channelName);
	var channelName = req.params.channelName;
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	var peer = req.query.peer;
	if (!peer) {
		res.status(400).json(getErrorMessage('\'peer\''));
		return;
	}

	let message = await query.getLatestBlock(peer, channelName, req.username, req.orgname);
	res.status(200).send(message);
});
//Query to Peers in a channel
app.get('/Peers/:channelName', async function (req, res) {
	logger.debug('================ GET Peers ======================');
	logger.debug('username: ' + req.username);
	logger.debug('orgname: ' + req.orgname);
	logger.debug('channelName: ' + req.params.channelName);
	var channelName = req.params.channelName;
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	/*         var peer = req.query.peer;
		  if (!peer) {
				   res.status(400).json(getErrorMessage('\'peer\''));
				   return;
		   }*/

	let message = await query.getPeers(channelName, req.username, req.orgname);
	res.status(200).send(message);
});

//Query to get maximum transaction count in the latest block
app.get('/Totaltransactions/:channelName', async function (req, res) {
	logger.debug('================ GET Maximum transactions in the latest block ======================');
	logger.debug('username: ' + req.username);
	logger.debug('orgname: ' + req.orgname);
	logger.debug('channelName: ' + req.params.channelName);
	var channelName = req.params.channelName;
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	var peer = req.query.peer;
	if (!peer) {
		res.status(400).json(getErrorMessage('\'peer\''));
		return;
	}

	let message = await query.getTotalTransactions(peer, channelName, req.username, req.orgname);
	res.status(200).send(message);
});

//Query to get all block info
app.get('/AllBlocks/:channelName', async function (req, res) {
	logger.debug('================ GET Maximum transactions in the latest block ======================');
	logger.debug('username: ' + req.username);
	logger.debug('orgname: ' + req.orgname);
	logger.debug('channelName: ' + req.params.channelName);
	var channelName = req.params.channelName;
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	var peer = req.query.peer;
	if (!peer) {
		res.status(400).json(getErrorMessage('\'peer\''));
		return;
	}

	let message = await query.getAllBlocks(peer, channelName, req.username, req.orgname);
	res.status(200).send(message);
});

//Query to get all transactions info
app.get('/AllTransactions/:channelName', async function (req, res) {
	logger.debug('================ GET Maximum transactions in the latest block ======================');
	logger.debug('username: ' + req.username);
	logger.debug('orgname: ' + req.orgname);
	logger.debug('channelName: ' + req.params.channelName);
	var channelName = req.params.channelName;
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	var peer = req.query.peer;
	if (!peer) {
		res.status(400).json(getErrorMessage('\'peer\''));
		return;
	}

	let message = await query.getAllTransactions(peer, channelName, req.username, req.orgname);
	res.status(200).send(message);
});

//Query to Peers in a channel
app.get('/ChannelPeer/:channelName', async function (req, res) {
	logger.debug('================ GET Peers ======================');
	logger.debug('username: ' + req.username);
	logger.debug('orgname: ' + req.orgname);
	logger.debug('channelName: ' + req.params.channelName);
	var channelName = req.params.channelName;
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	var peer = req.query.peer;
	if (!peer) {
		res.status(400).json(getErrorMessage('\'peer\''));
		return;
	}

	let message = await query.getPeer(peer, channelName, req.username, req.orgname);
	res.status(200).send(message);
});

// Create Channel with script
app.post('/channel-create-script', async function (req, res) {
	logger.info('<<<<<<<<<<<<<<<<< C R E A T E  C H A N N E L  w i t h  s c r i p t>>>>>>>>>>>>>>>>>');
	logger.debug('End point : /channel-create-script');

	var orgName = req.body.orgName;
	var domainName = req.body.domainName;
	var channelName = req.body.channelName;
	logger.debug('orgName : ' + orgName);
	logger.debug('domainName : ' + domainName);
	logger.debug('channelName : ' + channelName);

	if (!orgName) {
		res.status(400).json(getErrorMessage('\'orgName\''));
		return;
	}
	if (!domainName) {
		res.status(400).json(getErrorMessage('\'domainName\''));
		return;
	}
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}

	// let message = await createChannel.createChannel(channelName, channelConfigPath, req.username, req.orgname);
	// shell.exec('../../myscript.sh');
	//shell.exec('cd $HOME/dlt-network-base; pwd; ./createChannelFabric.sh ' + orgName + ' ' + domainName + ' ' + channelName);
	//res.status(200).send('success');
	shell.exec('cd ../.. ; ./createChannelFabric.sh ' + orgName + ' ' + domainName + ' ' + channelName, function (code, stdout, stderr) {
		console.log('Exit code:', code);
		console.log('Program output:', stdout);
		console.log('Program stderr:', stderr);
		if (code != 0) {
			res.status(400).send({ "stdout": stdout, "stderr": stderr, "code": code });
		} else {
			res.status(200).send({ "stdout": stdout, "stderr": stderr, "code": code });
		}
	});
});

// Join Channel with script
app.post('/channel-join-script', async function (req, res) {
	logger.info('<<<<<<<<<<<<<<<<< J O I N  C H A N N E L  W I T H  S C R I P T >>>>>>>>>>>>>>>>>');
	logger.debug('End point : /channel-join-script');

	var orgName = req.body.orgName;
	var orgUserId = req.body.orgUserId;
	var orgServerIp = req.body.orgServerIp;
	var channelName = req.body.channelName;
	var domainName = req.body.domainName;
	var baseOrgName = req.body.baseOrgName;
	var signingOrgs = req.body.signingOrgs;
	var orgArray = '';
	for (let i = 0; i < signingOrgs.length; i++) {
		orgArray = orgArray + signingOrgs[i].orgName + ' ' + signingOrgs[i].userId + ' ' + signingOrgs[i].serverIp + ' ';
	}

	logger.debug('orgName : ' + orgName);
	logger.debug('orgUserId : ' + orgUserId);
	logger.debug('orgServerIp : ' + orgServerIp);
	logger.debug('channelName : ' + channelName);
	logger.debug('domainName : ' + domainName);
	logger.debug('baseOrgName : ' + baseOrgName);
	logger.debug('orgArray : ' + orgArray);

	if (!orgName) {
		res.status(400).json(getErrorMessage('\'orgName\''));
		return;
	}
	if (!orgUserId) {
		res.status(400).json(getErrorMessage('\'orgUserId\''));
		return;
	}
	if (!orgServerIp) {
		res.status(400).json(getErrorMessage('\'orgServerIp\''));
		return;
	}
	if (!domainName) {
		res.status(400).json(getErrorMessage('\'domainName\''));
		return;
	}
	if (!channelName) {
		res.status(400).json(getErrorMessage('\'channelName\''));
		return;
	}
	if (!baseOrgName) {
		res.status(400).json(getErrorMessage('\'baseOrgName\''));
		return;
	}

	shell.exec('cd ../.. ; ./channeljoin_ss_fabric.sh ' + orgName + ' ' + orgUserId + ' ' + orgServerIp + ' ' + channelName + ' ' + domainName + ' ' + baseOrgName + ' ' + orgArray, function (code, stdout, stderr) {
		console.log('Exit code:', code);
		console.log('Program output:', stdout);
		console.log('Program stderr:', stderr);
		if (code != 0) {
			res.status(400).send({ "stdout": stdout, "stderr": stderr, "code": code });
		} else {
			res.status(200).send({ "stdout": stdout, "stderr": stderr, "code": code });
		}
	});
});

// sshAuthenticationKeyUpdate
app.post('/sshAuthenticationKeyUpdate', async function (req, res) {
	logger.info('<<<<<<<<<<<<<<<<< SSH AUTHENTICATION KEY UPDATE t>>>>>>>>>>>>>>>>>');
	logger.debug('End point : /sshAuthenticationKeyUpdate');

	var sshPublicKey = req.body.sshPublicKey;

	logger.debug('sshPublicKey : ' + sshPublicKey);

	if (!sshPublicKey) {
		res.status(400).json(getErrorMessage('\'sshPublicKey\''));
		return;
	}
	try {
		var key = fs.readFileSync("./../../../.ssh/authorized_keys", "utf8");
		if (key.includes(sshPublicKey)) {
			console.log('key already existing')
			res.status(200).send('key already existing');
		} else {
			console.log('key not available.adding the key: ==> ' + sshPublicKey)

			fs.appendFile('./../../../.ssh/authorized_keys', sshPublicKey + "\n", 'utf8',
				// callback function
				function (err) {
					if (err) throw err;
					// if no error
					console.log("Data is appended to file successfully.")
					res.status(200).send("PublicKey has appended to file successfully");
				});
		}
	} catch (err) {
		console.log(err.stack || String(err));
	}
});

/*app.get('/networkHealth', async function (req, res) {
	logger.info('<<<<<<<<<<<<<<<<< G E T  N E T W O R K  H E A L T H  W I T H  S C R I P T >>>>>>>>>>>>>>>>>');
	logger.debug('End point : /networkHealth');
	shell.exec('cd ../.. ; ./network_health.sh', function (code, stdout, stderr) {
		console.log('Exit code:', code);
		console.log('Program output:', stdout);
		console.log('Program stderr:', stderr);
		res.status(200).send(stdout);
	});
});*/

// Get block file of Channel 
app.post('/getChannelBlockFile', async function (req, res) {
	logger.info('<<<<<<<<<<<<<<<<< G E T  C H A N N E L  B L O C K >>>>>>>>>>>>>>>>>');
	logger.debug('End point : /getChannelBlockFile');

	var channelName = req.body.channelName;
	logger.info(channelName);
	var blockFilePath = "./../channels/" + channelName + "/" + channelName + ".block";
	console.log(blockFilePath);
	//	var key = fs.readFileSync(blockFilePath, "utf8");

	let buff = fs.readFileSync(blockFilePath);
	let base64data = buff.toString('base64');

	// let buff = new Buffer(key);
	// let base64data = buff.toString('base64');
	logger.debug(base64data);
	res.status(200).send({ "stdout": '', "stderr": '', "code": '', "data": base64data });
});

// Create File from Block data
app.post('/createFileFromBlock', async function (req, res) {
	logger.info('<<<<<<<<<<<<<<<<< G E T  C H A N N E L  B L O C K >>>>>>>>>>>>>>>>>');
	logger.debug('End point : /getChannelBlockFile');

	var channelName = req.body.channelName;
	var data = req.body.data;
	logger.info(channelName);
	var fileName = channelName + ".block";

	//fs.writeFile(fileName, data, (err) => {
	//	if (err) throw err;
	//	console.log('The file has been saved!');
	// });

	let buff = new Buffer(data, 'base64');
	fs.writeFileSync(fileName, buff);

	res.status(200).send({ "stdout": '', "stderr": '', "code": '', "data": "file created" });
});

// Copy msp folder
app.post('/copyMspFolder', async function (req, res) {
	logger.info('<<<<<<<<<<<<<<<< COPY MSP FOLDER  >>>>>>>>>>>>>>>>>');
	logger.debug('End point : /copyMspFolder');

	var orgName = req.body.orgName;
	logger.info(orgName);
	var tlsPath = "./../crypto-config/peerOrganizations/" + orgName + ".dlt-domain.com/msp/tlscacerts/tlsca." + orgName + ".dlt-domain.com-cert.pem";
	var caPath = "./../crypto-config/peerOrganizations/" + orgName + ".dlt-domain.com/msp/cacerts/ca." + orgName + ".dlt-domain.com-cert.pem";
	var adminPath = "./../crypto-config/peerOrganizations/" + orgName + ".dlt-domain.com/msp/admincerts/Admin@" + orgName + ".dlt-domain.com-cert.pem";
	var ordererCaPath = "./..//crypto-config/ordererOrganizations/dlt-domain.com/msp/tlscacerts/tlsca.dlt-domain.com-cert.pem";
	logger.info("tlscert path : " + tlsPath);
	logger.info("cacert path : " + caPath);
	logger.info("admincert path : " + adminPath);
	logger.info("ordererCacert path : " + ordererCaPath);
	try {
		var tlscert = fs.readFileSync(tlsPath);
		var base64tlscert = tlscert.toString('base64');
		var cacert = fs.readFileSync(caPath);
		var base64cacert = cacert.toString('base64');
		var admincert = fs.readFileSync(adminPath);
		var base64admincert = admincert.toString('base64');
		var ordererCacert = fs.readFileSync(ordererCaPath);
		var base64ordererCacert = ordererCacert.toString('base64');
		res.status(200).send({ "tlscert": base64tlscert, "cacert": base64cacert, "admincert": base64admincert, "base64ordererCacert": base64ordererCacert });
	} catch (e) {
		logger.info(e);
		res.status(400).send(e);
	}
});

var createFilesAndFolder = function (cert, path, certPath) {
    return new Promise((resolve, reject) => {
        mkdirp(path, function (err) {
            if (err) {
                logger.error("Error creating directory" + path, err);
                reject(err);
                // return res.status(400).send(err);
            } else {
                logger.info('sucessfully created #' + path + '#');
                let tlsbuff = new Buffer(cert, 'base64');
                fs.writeFile(certPath, tlsbuff, (err) => {
                    if (err) {
                        logger.error("Error creating file" + certPath, err);
                        reject(err);
                    } else {
                        logger.info("Successfully created the msp file: " + certPath);
                        resolve(certPath + 'created successfully.');
                    }
                });
            }
        });
    });
    
}
// staticChannelCreation script
app.post('/fabricChannelCreate', async function (req, res) {
	logger.info('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
	logger.info('<<<<<<<<<<<<<<<<< Static channel creation script >>>>>>>>>>>>>>>>>');
	logger.info('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
	logger.debug('End point : /fabricChannelCreate');
	try {
		var baseOrgName = req.body.baseOrgName;
		var domainName = req.body.domainName;
		var channelName = req.body.channelName;
		var orgArray = req.body.orgArray;
		var scriptOrgArray = '';
		logger.debug('baseOrgName : ' + baseOrgName);
		logger.debug('domainName : ' + domainName);
		logger.debug('channelName : ' + channelName);
        logger.debug('orgArray : ' + orgArray);
        

        let promises = [];
		for (let i = 0; i < orgArray.length; i++) {
			scriptOrgArray = scriptOrgArray + orgArray[i].newOrg + ' ';
			var newOrg = orgArray[i].newOrg;
			var tlscert = orgArray[i].tlscert;
			var cacert = orgArray[i].cacert;
			var admincert = orgArray[i].admincert;
			logger.info(newOrg);
			logger.info(tlscert);
			logger.info(cacert);
			logger.info(admincert);
			var tlsPath = "./../partnerOrgs/" + newOrg + "-config/msp/tlscacerts";
			var caPath = "./../partnerOrgs/" + newOrg + "-config/msp/cacerts";
			var adminPath = "./../partnerOrgs/" + newOrg + "-config/msp/admincerts";
			var tlsCertPath = "./../partnerOrgs/" + newOrg + "-config/msp/tlscacerts/tlsca." + newOrg + ".dlt-domain.com-cert.pem";
			var caCertPath = "./../partnerOrgs/" + newOrg + "-config/msp/cacerts/ca." + newOrg + ".dlt-domain.com-cert.pem";
			var adminCertPath = "./../partnerOrgs/" + newOrg + "-config/msp/admincerts/Admin@" + newOrg + ".dlt-domain.com-cert.pem";

            promises.push(createFilesAndFolder(tlscert, tlsPath, tlsCertPath));
            promises.push(createFilesAndFolder(cacert, caPath, caCertPath));
            promises.push(createFilesAndFolder(admincert, adminPath, adminCertPath));
		}

        Promise.all(promises).then(function(data) {
            logger.info("All promises returned..");
            shell.exec('cd ../.. ; ./fabric_channel_create.sh ' + baseOrgName + ' ' + domainName + ' ' + channelName + ' ' + scriptOrgArray, function (code, stdout, stderr) {
                logger.info('Exit code:', code);
                logger.info('Program output:', stdout);
                logger.info('Program stderr:', stderr);
                if (code != 0) {
                return res.status(400).send({ "success": false,"stdout": stdout, "stderr": stderr, "code": code });
                }
    
                var blockFilePath = "./../channels/" + channelName + "/" + channelName + ".block";
                logger.info("BlockFilePath: " + blockFilePath);
                let buff = fs.readFileSync(blockFilePath);
                let base64data = buff.toString('base64');
                logger.debug(base64data);
                return res.status(200).send({ "success": true, "message": "api exicuted sucessfully", "block": base64data });
            });
        }, function(err) {
            logger.error('Error creating certificate FileList. Cannot proceed with blockfile creation.')
            return res.status(400).send(err);
        });

		
	} catch (e) {
		logger.info(e);
		return res.status(400).send({ "success": false,"stdout": stdout, "stderr": stderr, "code": code });
	}
	
});

// newPeerJoinScript.sh
app.post('/fabricChannelJoin', async function (req, res) {
	logger.info('<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
	logger.info('<<<<<<<<<<<<<<<<< NEW PEER JOIN SCRIPT >>>>>>>>>>>>>>>>>');
	logger.info('<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
	logger.debug('End point : /fabricChannelJoin');

	var orgName = req.body.orgName;
	var domainName = req.body.domainName;
	var channelName = req.body.channelName;
	var baseOrg = req.body.baseOrg;
	var baseServerIp = req.body.baseServerIp;
	var baseOrdererCaCert = req.body.baseOrdererCaCert;
	var block = req.body.block;
	logger.info(orgName);
	logger.info(domainName);
	logger.info(channelName);
	logger.info(baseOrg);
	logger.info(baseServerIp);
	logger.info(baseOrdererCaCert);

	try {
		var caPath0 = "./artifacts/channel/crypto-config/ordererOrganizations/dlt-domain.com/orderers/orderer0." + baseOrg + ".dlt-domain.com/tls/";
		var caPath1 = "./artifacts/channel/crypto-config/ordererOrganizations/dlt-domain.com/orderers/orderer1." + baseOrg + ".dlt-domain.com/tls/";
		var caPath2 = "./artifacts/channel/crypto-config/ordererOrganizations/dlt-domain.com/orderers/orderer2." + baseOrg + ".dlt-domain.com/tls/";

		var caCertPath0 = "./artifacts/channel/crypto-config/ordererOrganizations/dlt-domain.com/orderers/orderer0." + baseOrg + ".dlt-domain.com/tls/ca.crt";
		var caCertPath1 = "./artifacts/channel/crypto-config/ordererOrganizations/dlt-domain.com/orderers/orderer1." + baseOrg + ".dlt-domain.com/tls/ca.crt";
		var caCertPath2 = "./artifacts/channel/crypto-config/ordererOrganizations/dlt-domain.com/orderers/orderer2." + baseOrg + ".dlt-domain.com/tls/ca.crt";

		var channelPath = "./../channels/" + channelName + "/";
		var blockPath = "./../channels/" + channelName + "/" + channelName + ".block";
		mkdirp(caPath0, function (err) {
			if (err) {
				console.error(err);
				res.status(400).send(err);
			} else {
				console.log('sucessfully created #' + caPath0 + '#');
				let cabuff0 = new Buffer(baseOrdererCaCert, 'base64');
				fs.writeFile(caCertPath0, cabuff0, (err) => {
					if (err) {
						console.error(err);
						res.status(400).send(err);
					} else {
						console.log(caCertPath0 + 'created');
					}
				});
			}
		});
		mkdirp(caPath1, function (err) {
			if (err) {
				console.error(err);
				res.status(400).send(err);
			} else {
				console.log('sucessfully created #' + caPath1 + '#');
				let cabuff1 = new Buffer(baseOrdererCaCert, 'base64');
				fs.writeFile(caCertPath1, cabuff1, (err) => {
					if (err) {
						console.error(err);
						res.status(400).send(err);
					} else {
						console.log(caCertPath1 + 'created');
					}
				});
			}
		});
		mkdirp(caPath2, function (err) {
			if (err) {
				console.error(err);
				res.status(400).send(err);
			} else {
				console.log('sucessfully created #' + caPath2 + '#');
				let cabuff2 = new Buffer(baseOrdererCaCert, 'base64');
				fs.writeFile(caCertPath2, cabuff2, (err) => {
					if (err) {
						console.error(err);
						res.status(400).send(err);
					} else {
						console.log(caCertPath2 + 'created');
					}
				});
			}
		});
		mkdirp(channelPath, function (err) {
			if (err) {
				console.error(err);
				res.status(400).send(err);
			} else {
				console.log('sucessfully created #' + channelPath + '#');
				let channelbuff = new Buffer(block, 'base64');
				fs.writeFile(blockPath, channelbuff, (err) => {
					if (err) {
						console.error(err);
						res.status(400).send(err);
					} else {
						console.log(blockPath + 'created');
					}
				});
			}
		});
		shell.exec('cd ../.. ; ./fabric_channel_join.sh ' + orgName + ' ' + domainName + ' ' + channelName + ' ' + baseOrg + ' ' + baseServerIp, function (code, stdout, stderr) {
			console.log('Exit code:', code);
			console.log('Program output:', stdout);
			console.log('Program stderr:', stderr);
			if (code != 0) {
				res.status(400).send({ "success": false,"stdout": stdout, "stderr": stderr, "code": code });
			} else {
				res.status(200).send({ "success": true,"stdout": stdout, "stderr": stderr, "code": code });
			}
		});
	} catch (e) {
		logger.info(e);
		res.status(400).send(e);
	}

});


