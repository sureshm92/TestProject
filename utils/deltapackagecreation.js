const path = require('path');
const fs = require('fs');
const { create } = require('xmlbuilder2');

async function createDeltaPackage(metadatRecMap) {
    let componentMap = {
        ApexClass: {
            name: 'ApexClass'
        },
        Aura: {
            name: 'AuraDefinitionBundle'
        },
        ApexPage: {
            name: 'ApexPage'
        },
        LightningComponentBundle: {
            name: 'LightningComponentBundle'
        }
    };
    //creating package.xml in DeltaPackage
    componentMap = await createPackageXML(metadatRecMap, componentMap);
    //getting files and putting it in DeltaPackage
    getAllFiles(path.join(__dirname, '../', 'force-app'), componentMap);
}

function createPackageXML(metadatRecMap, componentMap) {
    const root = create({ version: '1.0', encoding: 'UTF-8' });
    let packageElement = root.ele('Package', { xmlns: 'http://soap.sforce.com/2006/04/metadata' });
    packageElement.ele('version').txt(process.env.XML_VERSION).up();
    let MetadataKey = Object.keys(metadatRecMap);
    for (let key of MetadataKey) {
        componentMap[key].metaData = metadatRecMap[key];
        processComponentMap(path.join(__dirname, '../'), componentMap, packageElement, key);
    }
    packageElement.up();
    const xml = root.end({ prettyPrint: true });
    let fileName = path.join(__dirname, '../', 'DeltaPackage', '/', 'package.xml');
    fs.writeFile(fileName, xml.toString(), function (err) {
        if (err) throw err;
        console.log('Saved!');
    });
    return componentMap;
}

function processComponentMap(dirPath, componentMap, packageElement, key) {
    if (key == 'ApexClass') {
        addElementsToPackage(
            packageElement,
            componentMap.ApexClass.metaData,
            componentMap.ApexClass.name
        );
        let classArray = [];
        for (let className of componentMap.ApexClass.metaData) {
            className = className + '.cls';
            classMetaFileName = className + '-meta.xml';
            classArray.push(className);
            classArray.push(classMetaFileName);
        }
        componentMap.ApexClass.classArray = classArray;
        componentMap.ApexClass.classDestinationPath = path.join(
            dirPath,
            '/',
            'DeltaPackage/classes'
        );
    }
    if (key == 'ApexPage') {
        addElementsToPackage(
            packageElement,
            componentMap.ApexPage.metaData,
            componentMap.ApexPage.name
        );
        let pageArray = [];
        for (let pageName of componentMap.ApexPage.metaData) {
            pageName = pageName + '.page';
            pageMetaFileName = pageName + '-meta.xml';
            pageArray.push(pageName);
            pageArray.push(pageMetaFileName);
        }
        componentMap.ApexPage.pageArray = pageArray;
        componentMap.ApexPage.pageDestinationPath = path.join(dirPath, '/', 'DeltaPackage/pages');
    }
    if (key == 'Aura') {
        addElementsToPackage(packageElement, componentMap.Aura.metaData, componentMap.Aura.name);
        componentMap.Aura.auraDestinationPath = path.join(dirPath, '/', 'DeltaPackage/aura');
    }
    if (key == 'LightningComponentBundle') {
        addElementsToPackage(
            packageElement,
            componentMap.LightningComponentBundle.metaData,
            componentMap.LightningComponentBundle.name
        );
        componentMap.LightningComponentBundle.lwcDestinationPath = path.join(
            dirPath,
            '/',
            'DeltaPackage/lwc'
        );
    }
}

function addElementsToPackage(packageElement, elements, elementType) {
    typesElements = packageElement.ele('types');
    for (var i = 0; i < elements.length; i++) {
        const item = typesElements.ele('members');
        item.txt(elements[i]).up();
    }
    typesElements.ele('name').txt(elementType).up();
    typesElements.up();
}

function getAllFiles(dirPath, componentMap) {
    files = fs.readdirSync(dirPath);
    let aura;
    let classes;
    let pages;
    let lwcs;
    if (componentMap.ApexClass.metaData != undefined) {
        classes = componentMap['ApexClass'].classArray;
    }
    if (componentMap.ApexPage.metaData != undefined) {
        pages = componentMap['ApexPage'].pageArray;
    }
    if (componentMap.Aura.metaData != undefined) {
        aura = componentMap['Aura'].metaData;
    }
    if (componentMap.LightningComponentBundle.metaData != undefined) {
        lwcs = componentMap['LightningComponentBundle'].metaData;
    }
    files.forEach(function (file) {
        if (fs.statSync(dirPath + '/' + file).isDirectory()) {
            if (aura && aura.includes(file)) {
                checkAndCreateDirecotry(componentMap.Aura.auraDestinationPath);
                console.log('auraPath');
                console.log(path.join(dirPath + '/' + file));
                copyFileOrDirectory(
                    path.join(dirPath + '/' + file),
                    path.join(componentMap.Aura.auraDestinationPath + '/' + file),
                    true
                );
            }
            if (lwcs && lwcs.includes(file)) {
                checkAndCreateDirecotry(componentMap.LightningComponentBundle.lwcDestinationPath);
                console.log(path.join(dirPath + '/' + file));
                copyFileOrDirectory(
                    path.join(dirPath + '/' + file),
                    path.join(
                        componentMap.LightningComponentBundle.lwcDestinationPath + '/' + file
                    ),
                    true
                );
            } else {
                getAllFiles(dirPath + '/' + file, componentMap);
            }
        } else {
            if (classes && classes.includes(file)) {
                checkAndCreateDirecotry(componentMap.ApexClass.classDestinationPath);
                //console.log(path.join(dirPath, '/', file));
                copyFileOrDirectory(
                    path.join(dirPath + '/' + file),
                    path.join(componentMap.ApexClass.classDestinationPath + '/' + file),
                    false
                );
            }
            if (pages && pages.includes(file)) {
                checkAndCreateDirecotry(componentMap.ApexPage.pageDestinationPath);
                //console.log(path.join(dirPath, '/', file));
                copyFileOrDirectory(
                    path.join(dirPath + '/' + file),
                    path.join(componentMap.ApexPage.pageDestinationPath + '/' + file),
                    false
                );
            }
        }
    });
}

function checkAndCreateDirecotry(directoryPath) {
    console.log(directoryPath);
    console.log(fs.existsSync(directoryPath));
    if (!fs.existsSync(directoryPath)) {
        console.log('directoryPath');
        console.log(directoryPath);
        fs.mkdirSync(directoryPath);
    }
}
function copyFileOrDirectory(sourcePath, destinationPath, isDirectory) {
    if (isDirectory) {
        copyFolderSync(sourcePath, destinationPath);
    } else {
        fs.copyFile(sourcePath, destinationPath, (err) => {
            if (err) {
                console.log('Error Found:', err);
            } else {
                console.log('file copied successfully');
            }
        });
    }
}
function copyFolderSync(from, to) {
    fs.mkdirSync(to);
    fs.readdirSync(from).forEach((element) => {
        if (fs.lstatSync(path.join(from, element)).isFile()) {
            fs.copyFileSync(path.join(from, element), path.join(to, element));
        } else {
            copyFolderSync(path.join(from, element), path.join(to, element));
        }
    });
}

module.exports = {
    init: createDeltaPackage
};
