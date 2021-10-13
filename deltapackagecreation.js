const fs = require('fs');
const path = require('path');
const { create } = require('xmlbuilder2');
var packageEle;
var componentMap = {};

function createPackage(metadatRecMap) {
    const root = create({ version: '1.0', encoding: 'UTF-8' });
    packageEle = root.ele('Package', { xmlns: 'http://soap.sforce.com/2006/04/metadata' });
    componentMap = metadatRecMap;
    processComponentMap(__dirname);
    packageEle.up();
    const xml = root.end({ prettyPrint: true });
    createPackageXML(xml.toString(), path.join(__dirname, 'DeltaPackage', '/', 'package.xml'));
    getAllFiles(path.join(__dirname, 'force-app'));
}

function processComponentMap(dirPath) {
    if ('ApexClass' in componentMap) {
        addElementsToPackage(packageEle, componentMap['ApexClass'], 'ApexClass');
        let classArray = [];
        for (let className of componentMap['ApexClass']) {
            className = className + '.cls';
            classMetaFileName = className + '-meta.xml';
            classArray.push(className);
            classArray.push(classMetaFileName);
        }
        componentMap['ApexClass'] = classArray;
        componentMap['classDestinationPath'] = path.join(dirPath, '/', 'DeltaPackage/classes');
    }
    if ('Aura' in componentMap) {
        addElementsToPackage(packageEle, componentMap['Aura'], 'AuraDefinitionBundle');
        componentMap['auraDestinationPath'] = path.join(dirPath, '/', 'DeltaPackage/aura');
    }
}

function getAllFiles(dirPath) {
    files = fs.readdirSync(dirPath);
    let aura;
    let classes;

    if ('ApexClass' in componentMap) {
        classes = componentMap['ApexClass'];
    }
    if ('Aura' in componentMap) {
        aura = componentMap['Aura'];
    }
    files.forEach(function (file) {
        if (fs.statSync(dirPath + '/' + file).isDirectory()) {
            if (aura && aura.includes(file)) {
                checkAndCreateDirecotry(componentMap['auraDestinationPath']);
                console.log('auraPath');
                console.log(path.join(dirPath + '/' + file));
                copyFileOrDirectory(
                    path.join(dirPath + '/' + file),
                    path.join(componentMap['auraDestinationPath'] + '/' + file),
                    true
                );
            } else {
                getAllFiles(dirPath + '/' + file);
            }
        } else {
            if (classes && classes.includes(file)) {
                checkAndCreateDirecotry(componentMap['classDestinationPath']);
                //console.log(path.join(dirPath, '/', file));
                copyFileOrDirectory(
                    path.join(dirPath + '/' + file),
                    path.join(componentMap['classDestinationPath'] + '/' + file),
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
function addElementsToPackage(packageElement, elements, elementType) {
    typesElements = packageElement.ele('types');
    for (var i = 0; i < elements.length; i++) {
        const item = typesElements.ele('members');
        item.txt(elements[i]).up();
    }
    typesElements.ele('name').txt(elementType).up();
    typesElements.up();
}
function createPackageXML(content, file) {
    fs.writeFile(file, content, function (err) {
        if (err) throw err;
        console.log('Saved!');
    });
}
module.exports = {
    init: createPackage
};
