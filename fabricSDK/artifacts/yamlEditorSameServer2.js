 /*eslint-disable no-console*/
var fs = require("fs");
var path = require("path");
var util = require("util");
var yaml = require("js-yaml");

const args = process.argv;
var channelName = args[2];
try {
    var networkYaml= yaml.load(fs.readFileSync( path.join(__dirname, "network-config.yaml"), "utf8"));
    var peerYaml = yaml.load(fs.readFileSync( path.join(__dirname, "channelpeer-config.yaml"), "utf8"));
   
    var networkPeers = networkYaml.channels[channelName].peers;
    var newPeers = peerYaml.peers;

    
    networkPeers[Object.keys(newPeers)[0]] = newPeers[Object.keys(newPeers)[0]];
    networkPeers[Object.keys(newPeers)[1]] = newPeers[Object.keys(newPeers)[1]];

    fs.writeFile("network-config.yaml", yaml.dump(networkYaml), "utf8", err => {
    if (err) console.log(err);
  });
} catch (err) {
  console.log(err.stack || String(err));
}
