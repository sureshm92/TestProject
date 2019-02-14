/**
 * Created by Leonid Bartenev
 */
({
    doInit: function(component, event, heper){
        component.find('spinner').hide();
    },

    doExport: function (component, event, hepler) {
        var spinner = component.find('spinner');
        spinner.show();
        communityService.executeAction(component, 'export', {
            studyId: component.get('v.studySite.Clinical_Trial_Profile__c'),
            languageCode: component.get('v.translateItem.Language__c'),
            exportType: component.get('v.exportType')
        }, function (generatedFile) {
            var blob = new Blob([generatedFile], {
                type : 'text/plain'
            });
            var filename = 'Export_' + component.get('v.exportType') + '_' + component.get('v.translateItem.Language__c') + '__' + component.get('v.studySite.Clinical_Trial_Profile__r.Name') + '.xlf';
            saveAs(blob, filename);
        }, null, function () {
            spinner.hide();
        });
    },

     doImport: function (component, event, helper) {
         var spinner = component.find('spinner');
         spinner.show();
         var fileSelector = component.find('fileSelector');
         component.set('v.fileName', fileSelector.get('v.placeholder'));
         var fileContent = component.get('v.fileContent');
         fileSelector.reset();
         communityService.executeAction(component, 'importTranslation',{
             base64File: fileContent
         }, function (returnValue) {
             var importResult = JSON.parse(returnValue);
             component.set('v.importResult', importResult);
         }, null, function () {
             spinner.hide();
         })

     },

    doResetImportResult: function (component, event, hepler) {
        component.set('v.importResult', null);
    },

    doSaveUnimportedItems: function (component, event, handler) {
        var blob = new Blob([component.get('v.importResult.unimportedData')], {
            type : 'text/plain'
        });
        var filename = 'ErrorItems_' + component.get('v.fileName');
        saveAs(blob, filename);
    }
})