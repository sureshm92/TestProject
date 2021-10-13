const { response } = require('express');
const jsforce = require('jsforce');
var conn;
var sfUserDetail;
var metadataOptionsMap = {
    ApexClass: 'ApexClass',
    Aura: 'AuraDefinitionBundle'
};
var metadataLst = [];
async function createConnection() {
    conn = new jsforce.Connection({
        // you can change loginUrl to connect to sandbox or prerelease env.
        loginUrl: 'https://test.salesforce.com'
    });
    var username = 'sravani.dasari@iqvia.com.rhformal';
    var password = 'Iqvia@123456';
    let userInfo = await conn.login(username, password); //, function (err, userInfo) {
    sfUserDetail = userInfo;
    console.log(sfUserDetail);
}
async function getMetadataByTypesImpl(type) {
    let typeDeveloperName = '';
    console.log(typeDeveloperName);
    var records = [];
    var qry = 'SELECT Id,';
    if (type === 'ApexClass') {
        qry = qry + 'Name ';
        typeDeveloperName = metadataOptionsMap[type];
    } else if (type === 'Aura') {
        qry = qry + 'DeveloperName ';
        typeDeveloperName = metadataOptionsMap[type];
    }
    console.log(typeDeveloperName);
    qry = qry + 'FROM ' + typeDeveloperName;
    console.log(qry);
    result = await conn.query(qry); //, function (err, result) {
    console.log(result.records);
    console.log('total : ' + result.totalSize);
    console.log('fetched : ' + result.records.length);
    console.log('done ? : ' + result.done);
    if (!result.done) {
        // you can use the locator to fetch next records set.
        // Connection#queryMore()
        console.log('next records URL : ' + result.nextRecordsUrl);
    }
    return result.records;
    // });
}
async function getMetadataByTypes(type) {
    var metadataRec;
    var metadataRecList = [];
    if (sfUserDetail == null) {
        await createConnection();
        metadataRec = await getMetadataByTypesImpl(type);
    } else {
        metadataRec = await getMetadataByTypesImpl(type);
    }
    for (let i = 0; i < metadataRec.length; i++) {
        if (type === 'Aura') {
            metadataRecList.push(metadataRec[i].DeveloperName);
        }
        if (type === 'ApexClass') {
            metadataRecList.push(metadataRec[i].Name);
        }
    }
    return metadataRecList;
}
module.exports = {
    getMetadata: getMetadataByTypes,
    metadataOptions: Object.keys(metadataOptionsMap),
    metadataList: metadataLst
};
