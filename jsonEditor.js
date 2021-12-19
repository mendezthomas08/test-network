var fs = require("fs");


let rawdata = fs.readFileSync('del_modified_config.json','utf8').toString();
//console.log(rawdata);
let del_modified_config_json = {};
 del_modified_config_json = JSON.parse(rawdata);
//console.log(JSON.stringify(del_modified_config_json)); 
var obj = {};
for(let i = 0; i<del_modified_config_json.length;i++){
 obj=del_modified_config_json[i];
}
//console.log(JSON.stringify(obj))
fs.writeFileSync('del_modified_config.json', JSON.stringify(obj));

