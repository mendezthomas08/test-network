 /*eslint-disable no-console*/
var fs = require("fs");
var path = require("path");
var util = require("util");
var yaml = require("js-yaml");
//Attention. this script requires 2 args as input==> orgname and domain name
const args = process.argv;
var orgName = args[2];
var domainName = args[3];
var channelName = args[4];
try {
    var networkYaml= yaml.load(fs.readFileSync( path.join(__dirname, "./../channels/" + channelName + "/configtx.yaml"), "utf8"));
    var orgJson= { Name: ''+ orgName + 'MSP',ID: ''+ orgName + 'MSP',MSPDir: '../../partnerOrgs/'+ orgName + '-config/msp',AnchorPeers: [{Host: 'peer0.'+ orgName +'.'+ domainName  +'.com',Port: '7051'}] }

    networkYaml.Organizations.push(orgJson);
    networkYaml.Profiles.TwoOrgsOrdererGenesis.Consortiums.SampleConsortium.Organizations.push(orgJson);
    networkYaml.Profiles.TwoOrgsChannel.Application.Organizations.push(orgJson);

    fs.writeFile("./../channels/" + channelName + "/configtx.yaml", yaml.dump(networkYaml), "utf8", err => {
    if (err) console.log(err);
  });
} catch (err) {
  console.log(err.stack || String(err));
}
