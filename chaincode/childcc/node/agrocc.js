'use strict';
const shim = require('fabric-shim');
const util = require('util');
var log4js = require('log4js');
var logger = log4js.getLogger('ChaincodeLogger');

// ===============================================
// Chaincode name:[agrocc.js]
// ===============================================
let Chaincode = class {
    async Init(stub) {
        let ret = stub.getFunctionAndParameters();
        logger.info(ret);
        logger.info('=========== Instantiated Chaincode ===========');
        return shim.success();
    }

    async Invoke(stub) {
        logger.info('Transaction ID: ' + stub.getTxID());
        logger.info(util.format('Args: %j', stub.getArgs()));

        let ret = stub.getFunctionAndParameters();
        logger.info(ret);

        let method = this[ret.fcn];
        if (!method) {
            logger.error('no function of name:' + ret.fcn + ' found');
            throw new Error('Received unknown function ' + ret.fcn + ' invocation');
        }
        try {
            let payload = await method(stub, ret.params, this);
            return shim.success(payload);
        } catch (err) {
            logger.error(err);
            return shim.error(err);
        }
    }

    // ===============================================
    // createBP - create a BP in chaincode state
    // Args - bpId, bpName, bpDescription
    // ===============================================
    async createBP(stub, args, thisClass) {
        logger.info('--- start createBP ---');
        if (args.length != 3) {
            throw new Error('Incorrect number of arguments. Expecting 3.');
        }

        let bpId = args[0];
        let bpName = args[1];
        let bpDescription = args[2];

        if (!bpId) {
            throw new Error('Argument bpId must be a non-empty string');
        }
        if (!bpName) {
            throw new Error('Argument bpName must be a non-empty string');
        }

        let bpState = await stub.getState('bp_' + bpId);
        if (bpState && bpState.toString()) {
            throw new Error('This business partner already exists: ' + bpId);
        }

        let businesspartner = {};
        businesspartner.docType = "bp";
        businesspartner.bpId = bpId;
        businesspartner.bpName = bpName;
        businesspartner.bpDescription = bpDescription;
        await stub.putState('bp_' + bpId, Buffer.from(JSON.stringify(businesspartner)));

    }

    async updateBPDescription(stub, args, thisClass) {
        logger.info('--- start createBP ---');
        if (args.length != 3) {
            throw new Error('Incorrect number of arguments. Expecting 3.');
        }

        let bpId = args[0];
        
        let bpDescription = args[1];

        if (!bpId) {
            throw new Error('Argument bpId must be a non-empty string');
        }
       

        let bpState = await stub.getState('bp_' + bpId);
        if (!bpState && bpState.toString()) {
            throw new Error('This business partner does not exist: ' + bpId);
        }
        let businessPartner = {}
        try {
            businessPartner = JSON.parse(bpState.toString())
        } catch (err) {
            let jsonResp = {}
            jsonResp.errorMsg = 'Failed to decode JSON of BP: ' + bpId
            throw new Error(JSON.stringify(jsonResp));
        }
        
        businesspartner.bpDescription = bpDescription;
        await stub.putState('bp_' + bpId, Buffer.from(JSON.stringify(businesspartner)));

    }
 
    async queryBP(stub, args, thisClass) {
        if (args.length != 1) {
            throw new Error('Incorrect number of arguments. Expecting key of the business partner to query');
        }

        let key = args[0]
        if (!key) {
            throw new Error(' Business partner key must not be empty');
        }

        let bpAsBytes = await stub.getState("bp_" + key);
        if (!bpAsBytes || !bpAsBytes.toString()) {
            let jsonResp = {}
            jsonResp.errorMsg = 'Business partner does not exist: ' + key;
            throw new Error(JSON.stringify(jsonResp));
        }

        logger.info('=======================================')
        logger.log(bpAsBytes.toString())
        logger.info('=======================================')
            logger.info(bpAsBytes)
        return bpAsBytes;
    }




};
shim.start(new Chaincode());
