 /*eslint-disable no-console*/
var fs = require("fs");
var path = require("path");
var util = require("util");
var yaml = require("js-yaml");

try {
    var networkYaml= yaml.load(fs.readFileSync( path.join(__dirname, "network-config.yaml"), "utf8"));
    var channelYaml = yaml.load(fs.readFileSync( path.join(__dirname, "channel-config.yaml"), "utf8"));
    var  ordererYaml = yaml.load(fs.readFileSync( path.join(__dirname, "orderer-config.yaml"), "utf8"));
   
    var networkChannel = networkYaml.channels;
    var newChannel = channelYaml.channels;
    var networkOrderer = networkYaml.orderers;
    var newOrderer = ordererYaml.orderers;
    
    networkChannel[Object.keys(newChannel)[0]] = newChannel[Object.keys(newChannel)[0]];
    networkOrderer[Object.keys(newOrderer)[0]] = newOrderer[Object.keys(newOrderer)[0]];
    networkOrderer[Object.keys(newOrderer)[1]] = newOrderer[Object.keys(newOrderer)[1]];
    networkOrderer[Object.keys(newOrderer)[2]] = newOrderer[Object.keys(newOrderer)[2]];

   // console.log(util.inspect(networkYaml, false, 10, true));
    fs.writeFile("network-config.yaml", yaml.dump(networkYaml), "utf8", err => {
    if (err) console.log(err);
  });
} catch (err) {
  console.log(err.stack || String(err));
}
