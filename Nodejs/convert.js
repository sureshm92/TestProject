const profileFolders = ['../force-app/main/default/profiles'];
const labelFolders = ['../force-app/main/default/labels'];
const translationFolder = '../force-app/main/default/translations';
const objectsFolder = '../force-app/main/default/objects/Contact/recordTypes/MASTER.recordType-meta.xml';
const communityFile1 = '../force-app/main/default/siteDotComSites/IQVIA_Referral_Hub_C.site';
const communityFile2 = '../force-app/main/default/siteDotComSites/IQVIA_Referral_Hub_C.site-meta.xml';
const fs = require("fs");
const fileReader = require("./fileReader");
let xpath = require('xpath');
let dom = require('xmldom').DOMParser;

fs.exists(objectsFolder, function (exists) {
    if (exists) {
        //Show in green
        console.log(objectsFolder, ('File exists. Deleting now ...'));
        fs.unlink(objectsFolder, function (err) {
            if (err) return console.log(err);
            console.log(objectsFolder, 'file deleted successfully');
        });
    } else {
        console.log(objectsFolder, 'File not found, so not deleting.');
    }
});
fs.exists(communityFile1, function (exists) {
    if (exists) {
        //Show in green
        console.log(communityFile1, ('File exists. Deleting now ...'));
        fs.unlink(communityFile1, function (err) {
            if (err) return console.log(err);
            console.log(communityFile1, 'file deleted successfully');
        });
    } else {
        console.log(communityFile1, 'File not found, so not deleting.');
    }
});
fs.exists(communityFile2, function (exists) {
    if (exists) {
        //Show in green
        console.log(communityFile2, ('File exists. Deleting now ...'));
        fs.unlink(communityFile2, function (err) {
            if (err) return console.log(err);
            console.log(communityFile2, 'file deleted successfully');
        });
    } else {
        console.log(communityFile2, 'File not found, so not deleting.');
    }
});
fs.exists(translationFolder, function (exists) {
   if (exists) {
       fileReader.readFiles(translationFolder, (content, filename) => {
           let todesTodelete = [];
           content = content.replace('xmlns="http://soap.sforce.com/2006/04/metadata"', 'attrStub="stub"');
           var doc = new dom().parseFromString(content);
           let node1 = xpath.select("//Translations//customApplications", doc);
           let node2 = xpath.select("//Translations//customTabs", doc);
           let node3 = xpath.select("//Translations//quickActions", doc);
           let node4 = xpath.select("//Translations//flowDefinitions", doc);
           todesTodelete.push(node1);
           todesTodelete.push(node2);
           todesTodelete.push(node3);
           todesTodelete.push(node4);
           todesTodelete.forEach(item => {
               if (item && item.length > 0) {
                   item.forEach(i => {
                       i.normalize();
                       doc.documentElement.removeChild(i);
                   });
               }
           });
           let xml = doc.toString();
           xml = xml.replace('attrStub="stub"', 'xmlns="http://soap.sforce.com/2006/04/metadata"');
           fs.writeFile(translationFolder + '/' + filename, xml, function (err, data) {
               if (err) console.log(err);
               console.log(filename, "successfully updated");
           });
       });
   } else {
       console.log(translationFolder, 'Folder not found, so not deleting.');
   }
});



profileFolders.forEach(profileFolder => {
    fileReader.readFiles(profileFolder, (content, filename) => {
        let todesTodelete = [];
        content = content.replace('xmlns="http://soap.sforce.com/2006/04/metadata"', 'attrStub="stub"');
        var doc = new dom().parseFromString(content);
        let node1 = xpath.select("//Profile//userPermissions//name[text()='EnableCommunityAppLauncher']", doc);
        let node2 = xpath.select("//Profile//userPermissions//name[text()='FieldServiceAccess']", doc);
        let node3 = xpath.select("//Profile//userPermissions//name[text()='SendExternalEmailAvailable']", doc);
        let node4 = xpath.select("//Profile//applicationVisibilities//application[text()='Developer']", doc);
        todesTodelete.push(node1);
        todesTodelete.push(node2);
        todesTodelete.push(node3);
        todesTodelete.push(node4);

        todesTodelete.forEach(item => {
            if (item && item[0] && item[0].parentNode) {
                doc.documentElement.removeChild(item[0].parentNode);
            }
        });
    /*    let spaces = xpath.select("//text()[normalize-space(.)='']", doc);
        spaces.forEach(item => {
            item.parentNode.removeChild(item);
        });*/
        let xml = doc.toString();
        xml = xml.replace('attrStub="stub"', 'xmlns="http://soap.sforce.com/2006/04/metadata"');
        fs.writeFile(profileFolder + '/' + filename, xml, function (err, data) {
            if (err) console.log(err);
            console.log(filename, "successfully updated");
        });
    });
});

labelFolders.forEach(labelFolder => {
    fileReader.readFiles(labelFolder, (content, filename) => {
        let todesTodelete = [];
        content = content.replace('xmlns="http://soap.sforce.com/2006/04/metadata"', 'attrStub="stub"');
        var doc = new dom().parseFromString(content);
        let node1 = xpath.select("//CustomLabels//labels//fullName[text()='CommunityURL']", doc);
        todesTodelete.push(node1);
        todesTodelete.forEach(item => {
            if (item && item[0] && item[0].parentNode) {
                doc.documentElement.removeChild(item[0].parentNode);
            }
        });
        /*    let spaces = xpath.select("//text()[normalize-space(.)='']", doc);
            spaces.forEach(item => {
                item.parentNode.removeChild(item);
            });*/
        let xml = doc.toString();
        xml = xml.replace('attrStub="stub"', 'xmlns="http://soap.sforce.com/2006/04/metadata"');
        fs.writeFile(labelFolder + '/' + filename, xml, function (err, data) {
            if (err) console.log(err);
            console.log(filename, "successfully updated");
        });
    });
});




/*return permissionsToRemove.includes(item.XmlElement)
console.log('Include?', permissionsToRemove.includes(item.name[0]));
});
xmlParser.parseString(content, (err, result) => {
    let userPermissions = result.Profile.userPermissions;
    let filteredItems = userPermissions.filter(item => {
        console.log('item', item.name[0]);
        return !permissionsToRemove.includes(item.name[0])
        // console.log('Include?', permissionsToRemove.includes(item.name[0]));
    });
    result.Profile.userPermissions = filteredItems;
    console.log('filteredItems', filteredItems);
    console.log('result.userPermissions', result.Profile.userPermissions);
    let builder = new xmlParser.Builder();
    let xml = builder.buildObject(result);
    const xmlbeautify = xmlBeautifier(xml);
    fs.writeFile(profielsFolder + '/' + filename, xmlbeautify, function (err, data) {
        if (err) console.log(err);
        console.log("successfully written our update xml to file");
    });
});*/


/*
fs.readdir(profielsFolder, (err, files) => {
    if (err) {
        console.log('filed read error', err);
    }
    files.forEach(filename => {
        fs.readFile(profielsFolder + '/' + filename, 'utf-8', function (err, content) {
            if (err) {
                onError(err);
                return;
            }
            xmlParser.parseString(content, (err, result) => {
                /!* console.log('filename', filename);
                 console.log('result.Content', result);*!/
                console.log('result.userPermissions', result.Profile.userPermissions);
            });
            //onFileContent(filename, content);
        });

    });
});
*/
