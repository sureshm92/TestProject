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
        }
    };
    //creating package.xml in DeltaPackage
    componentMap = await createPackageXML(metadatRecMap,componentMap);
    //getting files and putting it in DeltaPackage
    getAllFiles(path.join(__dirname, '../', 'force-app'),componentMap);
}

function createPackageXML(metadatRecMap,componentMap) {
    const root = create({ version: '1.0', encoding: 'UTF-8' });
    let packageElement = root.ele('Package', { xmlns: 'http://soap.sforce.com/2006/04/metadata' });
    let MetadataKey = Object.keys(metadatRecMap)
    for (let key of MetadataKey) {
        componentMap[key].metaData = metadatRecMap[key];
        processComponentMap(path.join(__dirname, '../'), componentMap, packageElement, key);
    }
    packageElement.up();
    const xml = root.end({ prettyPrint: true });
    let fileName = path.join(__dirname, '../', 'DeltaPackage', '/', 'package.xml')
    fs.writeFile(fileName, xml.toString(), function (err) {
        if (err) throw err;
        console.log('Saved!');
    });
    return componentMap;
}

function processComponentMap(dirPath, componentMap, packageElement, key) {
    if (key == 'ApexClass') {
        addElementsToPackage(packageElement, componentMap.ApexClass.metaData, componentMap.ApexClass.name);
        let classArray = [];
        for (let className of componentMap.ApexClass.metaData) {
            className = className + '.cls';
            classMetaFileName = className + '-meta.xml';
            classArray.push(className);
            classArray.push(classMetaFileName);
        }
        componentMap.ApexClass.classArray = classArray;
        componentMap.ApexClass.classDestinationPath = path.join(dirPath, '/', 'DeltaPackage/classes');
    }
    if (key == 'Aura') {
        addElementsToPackage(packageElement, componentMap.Aura.metaData, componentMap.Aura.name);
        componentMap.Aura.auraDestinationPath = path.join(dirPath, '/', 'DeltaPackage/aura');
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

function getAllFiles(dirPath,componentMap) {
    files = fs.readdirSync(dirPath);
    let aura;
    let classes;

    if (componentMap.ApexClass.metaData!=undefined) {
        classes = componentMap['ApexClass'].classArray;
    }
    if (componentMap.Aura.metaData!=undefined) {
        aura = componentMap['Aura'].metaData;
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
            } else {
                getAllFiles(dirPath + '/' + file,componentMap);
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
