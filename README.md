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
      invoke chaincode in parentcc that will internally invoke action name createBP in childcc.
STOP THE NETWORK
    
    step 1: ./stop,sh         
        