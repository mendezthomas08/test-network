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
            let payload = await method(stub,ret.params, this);
            return shim.success(payload);
        } catch (err) {
            logger.error(err);
            return shim.error(err);
        }
    }

    async invokeAnotherChaincode(stub,args, thisClass) {
        logger.info('--- Invoke childcc from parentcc---');
        if (args.length != 3) {
            throw new Error('Incorrect number of arguments. Expecting 3.');
        }
          
        let chaincodeName = args[0];
        let channelName = args[1];
        let fcnAndParamOFOtherChaincode = args[2];
        let fcnAndParamOFOtherChaincodeJSON = JSON.parse(fcnAndParamOFOtherChaincode)

        if (!chaincodeName) {
            throw new Error('Argument chaincodeName must be a non-empty string');
        }
        if (!channelName) {
            throw new Error('Argument channelName must be a non-empty string');
        }
        if (!fcnAndParamOFOtherChaincode) {
            throw new Error('Argument fcnAndParamOFOtherChaincode  must be a non-empty string');
        }
        let chaincodeArgs = []
        chaincodeArgs.push(Buffer.from(fcnAndParamOFOtherChaincodeJSON.fcn))
        
        let length = fcnAndParamOFOtherChaincodeJSON.params.length;
        let paramArray = fcnAndParamOFOtherChaincodeJSON.params;
        console.log(chaincodeArgs)
        for(let i = 0;i<length;i++){
            chaincodeArgs.push(Buffer.from(paramArray[i]))

        }
        //Invoking childcc
        await stub.invokeChaincode(chaincodeName,chaincodeArgs,channelName);

    }
   
    



};
shim.start(new Chaincode());
