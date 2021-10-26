const jsforce = require('jsforce');
var conn;
var sfUserDetail;

var metadataOptionsMap = {
    ApexClass: {
        name: 'ApexClass',
        queryParams: 'Id,Name'
    },
    Aura: {
        name: 'AuraDefinitionBundle',
        queryParams: 'Id,DeveloperName'
    }
};

var metadataList = [];

async function createConnection() {
    conn = new jsforce.Connection({
        loginUrl: process.env.SALESFORCE_ENDPOINT
    });
    let userInfo = await conn.login(process.env.SALESFORCE_USERNAME, process.env.SALESFORCE_PASSWORD); //, function (err, userInfo) {
    sfUserDetail = userInfo;
}
createConnection();

async function getMetadataByTypesImpl(type) {
    let qry = 'SELECT ' + metadataOptionsMap[type].queryParams+ ' FROM ' + metadataOptionsMap[type].name;
    console.log(qry);
    result = await conn.query(qry);
    console.log(result.records[0]);
    console.log('total : ' + result.totalSize, '|| fetched : ' + result.records.length, '|| done  : ' + result.done);
    if (!result.done) {
        console.log('next records URL : ' + result.nextRecordsUrl);
    }
    return result.records;
}

async function getMetadataByTypes(type) {
    let metadataRec = await getMetadataByTypesImpl(type);
    let metadataRecList = []
    if (metadataRec.length != 0) {
        metadataRecList = metadataRec.map(record => record.Name || record.DeveloperName);
    }
    return metadataRecList;
}

module.exports = {
    getMetadata: getMetadataByTypes,
    metadataOptions: Object.keys(metadataOptionsMap),
    metadataList
};
