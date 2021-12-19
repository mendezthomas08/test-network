/**
 * Copyright 2017 IBM All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
var util = require('util');
var helper = require('./helper.js');
var logger = helper.getLogger('Query');

var queryChaincode = async function(peer, channelName, chaincodeName, args, fcn, username, org_name) {
	let client = null;
	let channel = null;
	try {
		client = await helper.getClientForOrg(org_name, username);
		logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
		channel = client.getChannel(channelName);
		if(!channel) {
			let message = util.format('Channel %s was not defined in the connection profile', channelName);
			logger.error(message);
			throw new Error(message);
		}

		var request = {
			targets : [peer], 
			chaincodeId: chaincodeName,
			fcn: fcn,
			args: args
		};
		let response_payloads = await channel.queryByChaincode(request);
		if (response_payloads) {
			for (let i = 0; i < response_payloads.length; i++) {
				logger.info(response_payloads[i].toString('utf8'));
			}
			return response_payloads[0].toString('utf8');
		} else {
			logger.error('response_payloads is null');
			return 'response_payloads is null';
		}
	} catch(error) {
		logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
		return error.toString();
	} finally {
		if (channel) {
			channel.close();
		}
	}
};
var getBlockByNumber = async function(peer, channelName, blockNumber, username, org_name) {
	try {
		var client = await helper.getClientForOrg(org_name, username);
		logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
		var channel = client.getChannel(channelName);
		if(!channel) {
			let message = util.format('Channel %s was not defined in the connection profile', channelName);
			logger.error(message);
			throw new Error(message);
		}

		let response_payload = await channel.queryBlock(parseInt(blockNumber, peer));
		if (response_payload) {
			logger.debug(response_payload.data.data.length);
			return response_payload;
		} else {
			logger.error('response_payload is null');
			return 'response_payload is null';
		}
	} catch(error) {
		logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
		return error.toString();
	}
};
var getTransactionByID = async function(peer, channelName, trxnID, username, org_name) {
	try {
		var client = await helper.getClientForOrg(org_name, username);
		logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
		var channel = client.getChannel(channelName);
		if(!channel) {
			let message = util.format('Channel %s was not defined in the connection profile', channelName);
			logger.error(message);
			throw new Error(message);
		}

		let response_payload = await channel.queryTransaction(trxnID, peer);
		if (response_payload) {
			logger.debug(response_payload);
			return response_payload;
		} else {
			logger.error('response_payload is null');
			return 'response_payload is null';
		}
	} catch(error) {
		logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
		return error.toString();
	}
};
var getBlockByHash = async function(peer, channelName, hash, username, org_name) {
	try {
		var client = await helper.getClientForOrg(org_name, username);
		logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
		var channel = client.getChannel(channelName);
		if(!channel) {
			let message = util.format('Channel %s was not defined in the connection profile', channelName);
			logger.error(message);
			throw new Error(message);
		}

		let response_payload = await channel.queryBlockByHash(Buffer.from(hash,'hex'), peer);
		if (response_payload) {
			logger.debug(response_payload);
			return response_payload;
		} else {
			logger.error('response_payload is null');
			return 'response_payload is null';
		}
	} catch(error) {
		logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
		return error.toString();
	}
};
var getChainInfo = async function(peer, channelName, username, org_name) {
	try {
		var client = await helper.getClientForOrg(org_name, username);
		logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
		var channel = client.getChannel(channelName);
		if(!channel) {
			let message = util.format('Channel %s was not defined in the connection profile', channelName);
			logger.error(message);
			throw new Error(message);
		}

		let response_payload = await channel.queryInfo(peer);
		if (response_payload) {
			logger.debug(response_payload);
                        logger.debug(response_payload.height);
			return response_payload;
		} else {
			logger.error('response_payload is null');
			return 'response_payload is null';
		}
	} catch(error) {
		logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
		return error.toString();
	}
};

var getInstalledChaincodes = async function(peer, channelName, type, username, org_name) {
	try {
		var client = await helper.getClientForOrg(org_name, username);
		logger.debug('Successfully got the fabric client for the organization "%s"', org_name);

		let response = null
		if (type === 'installed') {
			response = await client.queryInstalledChaincodes(peer, true); 
		} else {
			var channel = client.getChannel(channelName);
			if(!channel) {
				let message = util.format('Channel %s was not defined in the connection profile', channelName);
				logger.error(message);
				throw new Error(message);
			}
			response = await channel.queryInstantiatedChaincodes(peer, true); 
		}
		if (response) {
			if (type === 'installed') {
				logger.debug('<<< Installed Chaincodes >>>');
			} else {
				logger.debug('<<< Instantiated Chaincodes >>>');
			}
			var details = [];
			for (let i = 0; i < response.chaincodes.length; i++) {
				logger.debug('name: ' + response.chaincodes[i].name + ', version: ' +
					response.chaincodes[i].version + ', path: ' + response.chaincodes[i].path
				);
				details.push('name: ' + response.chaincodes[i].name + ', version: ' +
					response.chaincodes[i].version + ', path: ' + response.chaincodes[i].path
				);
			}
			return details;
		} else {
			logger.error('response is null');
			return 'response is null';
		}
	} catch(error) {
		logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
		return error.toString();
	}
};
var getChannels = async function(peer, username, org_name) {
	try {
		var client = await helper.getClientForOrg(org_name, username);
		logger.debug('Successfully got the fabric client for the organization "%s"', org_name);

		let response = await client.queryChannels(peer);
		if (response) {
			logger.debug('<<< channels >>>');
			var channelNames = [];
			for (let i = 0; i < response.channels.length; i++) {
				channelNames.push('channel id: ' + response.channels[i].channel_id);
			}
			logger.debug(channelNames);
			return response;
		} else {
			logger.error('response_payloads is null');
			return 'response_payloads is null';
		}
	} catch(error) {
		logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
		return error.toString();
	}
};
var getOrgs = async function(channelName, username, org_name){
      try {
                var client = await helper.getClientForOrg(org_name, username);
                logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
                let channel = await client.getChannel(channelName);
                if(!channel) {
                                let message = util.format('Channel %s was not defined in the connection profile', channelName);
                                logger.error(message);
                                throw new Error(message);
                        }
               await channel.initialize();
                let channelPeers = await channel.getOrganizations();
                if (channelPeers) {
                        logger.debug('<<< Organizations >>>');
                        var organizations = [];
                    //    logger.debug(response.length);
                        for (let i = 0; i < channelPeers.length; i++) {
                               organizations.push(channelPeers[i]); 
                        }
                        logger.debug(organizations);
                        return organizations;
                        
                } else {
                        logger.error('response_payloads is null');
                        return 'response_payloads is null';
                }
        } catch(error) {
                logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
                return error.toString();
        }
};
var getLatestBlock = async function(peer,channelName, username, org_name){
          try {
                var client = await helper.getClientForOrg(org_name, username);
                logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
                let channel = await client.getChannel(channelName);
                if(!channel) {
                                let message = util.format('Channel %s was not defined in the connection profile', channelName);
                                logger.error(message);
                                throw new Error(message);
                        }
                 let response_payload = await channel.queryInfo(peer);
                if (response_payload) {
                       // logger.debug(response_payload);
                        logger.debug(response_payload.height.low);
                       // return response_payload;
                } else {
                        logger.error('response_payload is null');
                        return 'response_payload is null';
                }
                lastBlockNo = (response_payload.height.low)-1;
                logger.debug(lastBlockNo);
                
            let response_payload_1 = await channel.queryBlock(parseInt(lastBlockNo, peer));
                if (response_payload_1) {
                        logger.debug(response_payload_1);
                        return response_payload_1.header.number;
                } else {
                        logger.error('response_payload is null');
                        return 'response_payload is null';
                }

             }  catch(error) {
                logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
                return error.toString();
        }
};

var getPeers = async function(channelName, username, org_name){
          try {
                var client = await helper.getClientForOrg(org_name, username);
                logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
                let channel = await client.getChannel(channelName);
                if(!channel) {
                                let message = util.format('Channel %s was not defined in the connection profile', channelName);
                                logger.error(message);
                                throw new Error(message);
                        }
               
              //   await channel.initialize({discover:true,target:peer});
                 logger.debug('==============================');
                 let response = channel.getPeers();
                 if (response){
                   return response;
                 }else {
                        logger.error('response_payload is null');
                        return 'response_payload is null';
                }

             }  catch(error) {
                logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
                return error.toString();
        }
};

var getTotalTransactions = async function(peer,channelName, username, org_name){
          try {
                var client = await helper.getClientForOrg(org_name, username);
                logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
                let channel = await client.getChannel(channelName);
                if(!channel) {
                                let message = util.format('Channel %s was not defined in the connection profile', channelName);
                                logger.error(message);
                                throw new Error(message);
                        }
                 let response_payload = await channel.queryInfo(peer);
                if (response_payload) {
                       // logger.debug(response_payload);
                        logger.debug(response_payload.height.low);
                       // return response_payload;
                } else {
                        logger.error('response_payload is null');
                        return 'response_payload is null';
                }
                lastBlockNo = (response_payload.height.low)-1;
                logger.debug(lastBlockNo);
                var total=0;
         for(i=0;i<=lastBlockNo;i++){
            let response_payload_1 = await channel.queryBlock(parseInt(i, peer));
                if (response_payload_1) {
                       // logger.debug(response_payload_1.data.data.length);
                        total+=response_payload_1.data.data.length;
                   
                       // return response_payload_1.data.data.length;
                } else {
                        logger.error('response_payload is null');
                        return 'response_payload is null';
                }
                 //logger.debug(total);

            }
             logger.debug(total);
              const response = {
                
                total: total
        };
        return response;

             }  catch(error) {
                logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
                return error.toString();
        }
 };

var getAllBlocks = async function(peer,channelName, username, org_name){
          try {
                var client = await helper.getClientForOrg(org_name, username);
                logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
                let channel = await client.getChannel(channelName);
                if(!channel) {
                                let message = util.format('Channel %s was not defined in the connection profile', channelName);
                                logger.error(message);
                                throw new Error(message);
                        }
                 let response_payload = await channel.queryInfo(peer);
                if (response_payload) {
                       // logger.debug(response_payload);
                        logger.debug(response_payload.height.low);
                       // return response_payload;
                } else {
                        logger.error('response_payload is null');
                        return 'response_payload is null';
                }
                lastBlockNo = (response_payload.height.low)-1;
                logger.debug(lastBlockNo);
                var response = {};
                var array = [];
            for( i=0;i<=lastBlockNo;i++){
            let response_payload_1 = await channel.queryBlock(parseInt(i, peer));
                if (response_payload_1) {
                        logger.debug(response_payload_1);
                        blockId =  response_payload_1.header.number;
                        NoOfTransactions = response_payload_1.data.data.length;
                        dataHash = response_payload_1.header.data_hash;
                        prevHash = response_payload_1.header.previous_hash;
                        response = {
                        blockId : blockId,
                        channel : channelName,
                        NoOfTransactions : NoOfTransactions,
                        dataHash : dataHash,
                        prevHash: prevHash
                        };
                        array.push(response);
                                             
                   } else {
                        logger.error('response_payload is null');
                        return 'response_payload is null';
                }
              }
              const response1 = {
                 AllBlocks : array
             };
              return response1;
             }  catch(error) { 
                logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
                return error.toString();
        }
};

var getAllTransactions = async function(peer,channelName, username, org_name){
          try {
                var client = await helper.getClientForOrg(org_name, username);
                logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
                let channel = await client.getChannel(channelName);
                if(!channel) {
                                let message = util.format('Channel %s was not defined in the connection profile', channelName);
                                logger.error(message);
                                throw new Error(message);
                        }
                 let response_payload = await channel.queryInfo(peer);
                if (response_payload) {
                       // logger.debug(response_payload);
                        logger.debug(response_payload.height.low);
                       // return response_payload;
                } else {
                        logger.error('response_payload is null');
                        return 'response_payload is null';
                }
                lastBlockNo = (response_payload.height.low)-1;
                logger.debug(lastBlockNo);
                var response = {};
                var array = [];
            for( i=0;i<=lastBlockNo;i++){
            let response_payload_1 = await channel.queryBlock(parseInt(i, peer));
                if (response_payload_1) {
                        logger.debug(response_payload_1);
                        for(j=0;j<response_payload_1.data.data.length;j++){
                        transaction_id =  response_payload_1.data.data[j].payload.header.channel_header.tx_id;
                        channel_id = response_payload_1.data.data[j].payload.header.channel_header.channel_id;
                        timestamp = response_payload_1.data.data[j].payload.header.channel_header.timestamp;
                        creator = response_payload_1.data.data[j].payload.header.signature_header.creator.Mspid;
                        if(transaction_id){
                                               response = {
                        creator : creator,
                        tx_id : transaction_id,
                        channel : channel_id,
                        timestamp : timestamp
                        
                      
                        };
                       
                        array.push(response);
                      }
                      }

                   } else {
                        logger.error('response_payload is null');
                        return 'response_payload is null';
                }
              }
              const response1 = {
                 All_Transactions : array
             };
              return response1;
             }  catch(error) {
                logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
                return error.toString();
        }
};

var getPeer = async function(peer,channelName, username, org_name){
          try {
                var client = await helper.getClientForOrg(org_name, username);
                logger.debug('Successfully got the fabric client for the organization "%s"', org_name);
                let channel = await client.getChannel(channelName);
                if(!channel) {
                                let message = util.format('Channel %s was not defined in the connection profile', channelName);
                                logger.error(message);
                                throw new Error(message);
                        }

                 await channel.initialize();
                 logger.debug('==============================');
                 let response = channel.getPeer(peer);
                 if (response){
                   return response;
                 }else {
                        logger.error('response_payload is null');
                        return 'response_payload is null';
                }

             }  catch(error) {
                logger.error('Failed to query due to error: ' + error.stack ? error.stack : error);
                return error.toString();
        }
};

exports.getPeer = getPeer;
exports.getAllTransactions = getAllTransactions;
exports.getAllBlocks = getAllBlocks;
exports.getTotalTransactions = getTotalTransactions;
exports.getPeers = getPeers; 
exports.getLatestBlock = getLatestBlock;
exports.getOrgs = getOrgs;

exports.queryChaincode = queryChaincode;
exports.getBlockByNumber = getBlockByNumber;
exports.getTransactionByID = getTransactionByID;
exports.getBlockByHash = getBlockByHash;
exports.getChainInfo = getChainInfo;
exports.getInstalledChaincodes = getInstalledChaincodes;
exports.getChannels = getChannels;
