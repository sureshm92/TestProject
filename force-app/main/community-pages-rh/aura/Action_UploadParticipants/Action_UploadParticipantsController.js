/**
 * Created by Aleksey Moseev
 */
({
    
    doExecute: function (component, event, helper) {
        component.find('upModalSpinner').show();
        component.set('v.createUsers', false);
        component.set('v.isEmail',false);
        component.set('v.isPhone',false);
        component.set('v.isSMS',false);
        component.set('v.doContact',false);
        var params = event.getParam('arguments');
        component.find('uploadParticipantsDialog').show();
        var studySiteId = params["studySiteId"];
        component.set('v.studySiteId', studySiteId);
        if (params.callback) component.set('v.callback', $A.getCallback(params.callback));
        helper.clearFields(component, event, helper);
        helper.checkCommunity(component, event, helper);

        communityService.executeAction(component, 'getParticipantsStatuses', {
            studySiteId : studySiteId
        }, function (returnValue) {
            component.find('upModalSpinner').hide();
            component.set('v.participantStatuses', returnValue);
        });
    },
    
    doCancel: function (component, event, helper) {

        component.set('v.isEmail',false);
        component.set('v.isPhone',false);
        component.set('v.isSMS',false);
        component.set('v.doContact',false);
        helper.clearFields(component, event, helper);
        component.find('uploadParticipantsDialog').cancel();
    },

    doClearFile: function (component, event, helper) {
        component.set("v.FileList", []);
        component.set("v.fullFileName", '');
        component.set("v.fileName", '');
        component.set("v.fileType", '');
        component.set("v.fileBody", '');
    },
    
    doImport: function (component, event, helper) {
        helper.uploadPaticipants(component,
                                 component.get('v.fileBody'),
                                 component.get('v.fileName'),
                                 component.get('v.studySiteId'),
                                 component.get('v.selectedStatus'),
                                 component.get('v.createUsers') && component.get('v.communityWithPPInv'),
                                 component.get('v.doContact'),
                                 component.get('v.isEmail'),
                                 component.get('v.isPhone'),
                                 component.get('v.isSMS'),
                                 helper);
    },
    
    upload: function(component, event, helper) {
        component.find('upModalSpinner').show();
        var fileTypes = ['csv', 'xls', 'xlsx'];
        
        var file = component.get("v.FileList")[0];
        var extension = file.name.split('.').pop().toLowerCase();
        var fileName = file.name.split('.')[0];
        
        if (fileTypes.indexOf(extension) == -1) {
            communityService.showToast('error', 'error', "ERROR: File format not correct. Please use the provided template.");
            component.find('upModalSpinner').hide();
            
            return;
        }
        
        var reader = new FileReader();
        reader.onload = function (e) {
            var binary = "";
            var bytes = new Uint8Array(e.target.result);
            var length = bytes.byteLength;
            
            for (var i = 0; i < length; i++) {
                binary += String.fromCharCode(bytes[i]);
            }
            
            var workbook = XLSX.read(binary, { type: 'binary', raw: true });
            var sheet_name_list = workbook.SheetNames;
            var csvData = XLSX.utils.sheet_to_csv(workbook.Sheets[sheet_name_list[0]]);
            var stringArray = csvData.split("\n");
            
            if (stringArray.length > 45005 || length > 4100226) {
                communityService.showToast('error', 'error', "ERROR: file contains more than 45,000 records; you may split the file. Please correct the problem and try again.");
                component.find('upModalSpinner').hide();
                
                return;
            }
            
            component.set('v.fileBody', stringArray);
            component.set('v.fileName', fileName);
            component.set('v.fileType', extension);
            component.set('v.fullFileName', fileName + '.' + extension);
            
            component.find('upModalSpinner').hide();
        };
        
        reader.readAsArrayBuffer(file);
    },
    doContactParticipant : function (component){
        if(!component.get('v.doContact')){
            component.set('v.createUsers',false);
        }
    },
    doContactEmail : function (component){
        component.set('v.isEmail', !component.get('v.isEmail'));
    },
    
    doContactPhone : function (component){
        component.set('v.isPhone', !component.get('v.isPhone'));
    },
    
    doContactSMS : function(component){
        component.set('v.isSMS',!component.get('v.isSMS'));
    }
    
})