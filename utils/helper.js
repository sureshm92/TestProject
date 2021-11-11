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
    },
    ApexPage: {
        name: 'ApexPage',
        queryParams: 'Id,Name'
    },
    LightningComponentBundle: {
        name: 'LightningComponentBundle',
        queryParams: 'Id,DeveloperName'
    }
};

var metadataList = [];

async function createConnection() {
    conn = new jsforce.Connection({
        loginUrl: process.env.SALESFORCE_ENDPOINT
    });
    let userInfo = await conn.login(
        process.env.SALESFORCE_USERNAME,
        process.env.SALESFORCE_PASSWORD
    ); //, function (err, userInfo) {
    sfUserDetail = userInfo;
}
createConnection();

async function getMetadataByTypesImpl(type) {
    let baseURL = process.env.SALESFORCE_BASEURL + '/services/data/v52.0/tooling/query?q=';
    let qry =
        'SELECT ' + metadataOptionsMap[type].queryParams + ' FROM ' + metadataOptionsMap[type].name;
    console.log(qry);
    var _request = {
        url:
            '/services/data/v52.0/tooling/query?q=SELECT+' +
            metadataOptionsMap[type].queryParams +
            '+From+' +
            metadataOptionsMap[type].name,
        method: 'get',
        body: '',
        headers: {
            'Content-Type': 'application/json'
        }
    };
    await conn.request(_request, function (err, resp) {
        result = resp.records;
    });

    return result;
}

async function getMetadataByTypes(type) {
    let metadataRec = await getMetadataByTypesImpl(type);
    console.log(metadataRec);
    let metadataRecList = [];
    if (metadataRec) {
        metadataRecList = metadataRec.map((record) => record.Name || record.DeveloperName);
    }
    return metadataRecList;
}

module.exports = {
    getMetadata: getMetadataByTypes,
    metadataOptions: Object.keys(metadataOptionsMap),
    metadataList
};
