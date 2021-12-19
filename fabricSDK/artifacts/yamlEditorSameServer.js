 /*eslint-disable no-console*/
var fs = require("fs");
var path = require("path");
var util = require("util");
var yaml = require("js-yaml");

try {
    var networkYaml= yaml.load(fs.readFileSync( path.join(__dirname, "network-config.yaml"), "utf8"));
    var orgYaml = yaml.load(fs.readFileSync( path.join(__dirname, "org-config.yaml"), "utf8"));
    var peerYaml = yaml.load(fs.readFileSync( path.join(__dirname, "peer-config.yaml"), "utf8"));
    var caYaml = yaml.load(fs.readFileSync( path.join(__dirname, "ca-config.yaml"), "utf8"));
   
    var networkOrg = networkYaml.organizations;
    var networkPeers = networkYaml.peers;
    var networkCa = networkYaml.certificateAuthorities;
    var newOrg = orgYaml.organizations;
    var newPeers = peerYaml.peers;
    var newCa = caYaml.certificateAuthorities;

    
    networkOrg[Object.keys(newOrg)[0]] = newOrg[Object.keys(newOrg)[0]];
    networkPeers[Object.keys(newPeers)[0]] = newPeers[Object.keys(newPeers)[0]];
    networkPeers[Object.keys(newPeers)[1]] = newPeers[Object.keys(newPeers)[1]];
    networkCa[Object.keys(newCa)[0]] = newCa[Object.keys(newCa)[0]];

   // console.log(util.inspect(networkYaml, false, 10, true));
    fs.writeFile("network-config.yaml", yaml.dump(networkYaml), "utf8", err => {
    if (err) console.log(err);
  });
} catch (err) {
  console.log(err.stack || String(err));
}
