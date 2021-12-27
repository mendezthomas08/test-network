# test-network

INSTALL PREREQUISITES 

    step 1: cd test-network
    step 2 : ./prereq_beforeRestart.sh
    step 3 : logout
    step 4 : ./prereq_afterRestart.sh


 BRING UP THE NETWORK

     step 1: ./magic_start_here.sh up myOrg example myNetwork mychannel
   Description:
      The above script will create a single org with single channel.
      Install and instantiate both the chaincode parentcc and childcc.
      Invoke chaincode in parentcc that will internally invoke action name createBP in childcc.


PARENT CHAINCODE

   

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
        logger.info('--- Invoke Childcc from parentcc ---');
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
   
    
CHAINCODE CHILDCC


    
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

 The childcc contains 3 operations

 1)CreateBP

 2)queryBP

 3)updateBpDescription

 TESTING

   To invoke CreateBp action of childcc ,run the below command

   docker exec climyOrg peer chaincode invoke -o orderer0.myOrg.example.com:7050 -C mychannel -n parentcc --peerAddresses peer0.org1.example.com:7051  -c '{"Args":["invokeAnotherChaincode","childcc","mychannel","{\"fcn\": \"createBP\",\"params\": [\"bp02\",\"bpName02\",\"bpDescriptio02\"]}]}'

   To invoke updateBpDescription run the below command

   docker exec climyOrg peer chaincode invoke -o orderer0.myOrg.example.com:7050 -C mychannel -n parentcc --peerAddresses peer0.org1.example.com:7051  -c '{"Args":["invokeAnotherChaincode","childcc","mychannel","{\"fcn\": \"updateBpDescription\",\"params\": [\"bp02\",\"newBpDescription\"]}]}'

   To queryBp

   docker exec climyOrg peer chaincode query -C mychannel -n childcc -c '{"Args":["queryBP","bp02"]}'



STOP THE NETWORK
    
    step 1: ./stop,sh         
        