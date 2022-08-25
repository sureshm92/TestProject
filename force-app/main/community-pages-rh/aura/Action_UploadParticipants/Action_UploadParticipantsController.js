/**
 * Created by Aleksey Moseev
 */
({
    doExecute: function (component, event, helper) {
        component.set('v.reload',true);
        component.find('upModalSpinner').show();
        component.set('v.createUsers', false);
        component.set('v.isEmail', false);
        component.set('v.isPhone', false);
        component.set('v.isSMS', false);
        component.set('v.doContact', false);
        component.set('v.visitPlanAvailable', false);
        component.set('v.visitPlanRequired', false);
        component.set('v.visitPlanDisabled', false);
        component.set('v.visitPlanId', undefined);
        component.find('consent-Manager').resetConsents();
        var params = event.getParam('arguments');
        component.find('uploadParticipantsDialog').show();
        var studySiteId = params['studySiteId'];
        component.set('v.studySiteId', studySiteId);
        var studySiteType = params['studySiteType'];
        var isSuppressed = params['isSuppressed'];
        var trial = params['trial'];
        component.set('v.studySiteType', studySiteType);
        component.set('v.isSuppressed', isSuppressed);
        component.set('v.patientPortalEnabled',trial.Patient_Portal_Enabled__c);        
        if (params.callback) component.set('v.callback', $A.getCallback(params.callback));
        helper.clearFields(component, event, helper);
        helper.checkCommunity(component, event, helper);

        communityService.executeAction(
            component,
            'getParticipantsStatusesAndVisitPlans',
            {
                studySiteId: studySiteId
            },
            function (returnValue) {
                component.find('upModalSpinner').hide();
                component.set('v.participantStatuses', returnValue.participantStatuses);
                if(returnValue.visitPlansLVList!=undefined && returnValue.visitPlansLVList.length >0){
                    component.set('v.visitPlanAvailable', true);
                    if(returnValue.visitPlansLVList.length!=1){
                        returnValue.visitPlansLVList.push({label:$A.get('$Label.c.None'),value:''});
                    }else{
                        component.set('v.visitPlanDisabled', true);
                        component.set('v.visitPlanId',returnValue.visitPlansLVList[0].value);
                    }
                }
                component.set('v.visitPlansLVList', returnValue.visitPlansLVList);                             
            }
        );
    },

    doCancel: function (component, event, helper) {
        component.set('v.reload',false);
        component.set('v.isEmail', false);
        component.set('v.isPhone', false);
        component.set('v.isSMS', false);
        component.set('v.doContact', false);
        helper.clearFields(component, event, helper);
        component.find('uploadParticipantsDialog').cancel();
    },
    
    setVisitPlanRequiredOrNot: function (component, event, helper){
        if((component.get('v.selectedStatus') =='Enrollment Success' || 
           component.get('v.selectedStatus') =='Randomization Success') && 
          component.get('v.visitPlanDisabled') == true){
            component.set('v.visitPlanRequired', true);
        }else{
            component.set('v.visitPlanRequired', false);
        }
    },
    
    doClearFile: function (component, event, helper) {
        component.set('v.FileList', []);
        component.set('v.fullFileName', '');
        component.set('v.fileName', '');
        component.set('v.fileType', '');
        component.set('v.fileBody', '');
    },

    doImport: function (component, event, helper) {
        helper.uploadPaticipants(
            component,
            component.get('v.fileBody'),
            component.get('v.fileName'),
            component.get('v.studySiteId'),
            component.get('v.selectedStatus'),
            component.get('v.createUsers') && component.get('v.communityWithPPInv'),
            component.get('v.doContact'),
            component.get('v.isEmail'),
            component.get('v.isPhone'),
            component.get('v.isSMS'),
            component.get('v.iqviaOutreachEmail'),
            component.get('v.iqviaOutreachPhone'),
            component.get('v.iqviaOutreachSMS'),
            component.get('v.iqviaOutreachDirectMail'),
            component.get('v.visitPlanId'),
            helper
        );
    },

    upload: function (component, event, helper) {
        component.find('upModalSpinner').show();
        var fileTypes = ['csv', 'xls', 'xlsx'];

        var file = component.get('v.FileList')[0];
        var extension = file.name.split('.').pop().toLowerCase();
        var fileName = file.name.split('.')[0];

        if (fileTypes.indexOf(extension) == -1) {
            communityService.showToast(
                'error',
                'error',
                'ERROR: File format not correct. Please use the provided template.'
            );
            component.find('upModalSpinner').hide();

            return;
        }

        var reader = new FileReader();
        reader.onload = function (e) {
            var binary = '';
            var bytes = new Uint8Array(e.target.result);
            var length = bytes.byteLength;

            for (var i = 0; i < length; i++) {
                binary += String.fromCharCode(bytes[i]);
            }

            var workbook = XLSX.read(binary, { type: 'binary', raw: true });
            var sheet_name_list = workbook.SheetNames;
            var csvData = XLSX.utils.sheet_to_csv(workbook.Sheets[sheet_name_list[0]]);
            var stringArray = csvData.split('\n');

            if (stringArray.length > 45005 || length > 4100226) {
                communityService.showToast(
                    'error',
                    'error',
                    'ERROR: file contains more than 45,000 records; you may split the file. Please correct the problem and try again.'
                );
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
    doContactParticipant: function (component) {
        if (!component.get('v.doContact')) {
            component.set('v.createUsers', false);
        }
    },
    doContactEmail: function (component) {
        component.set('v.isEmail', !component.get('v.isEmail'));
    },

    doContactPhone: function (component) {
        component.set('v.isPhone', !component.get('v.isPhone'));
    },

    doContactSMS: function (component) {
        component.set('v.isSMS', !component.get('v.isSMS'));
    },
    //changes related to RH-6742
    handleConsentChange: function (component,event){
            component.set('v.isEmail', event.getParam('consentMap').pe.Permit_Mail_Email_contact_for_this_study__c);
            component.set('v.doContact', event.getParam('consentMap').pe.Permit_Mail_Email_contact_for_this_study__c);
            component.set('v.isPhone', event.getParam('consentMap').pe.Permit_Voice_Text_contact_for_this_study__c);
            component.set('v.isSMS', event.getParam('consentMap').pe.Permit_SMS_Text_for_this_study__c);
            if (!component.get('v.doContact')) {
                component.set('v.createUsers', false);
            }    
            component.set('v.iqviaOutreachEmail',event.getParam('consentMap').contact.Participant_Opt_In_Status_Emails__c);
            component.set('v.iqviaOutreachSMS',event.getParam('consentMap').contact.Participant_Opt_In_Status_SMS__c);
            component.set('v.iqviaOutreachPhone',event.getParam('consentMap').contact.Participant_Phone_Opt_In_Permit_Phone__c);
            component.set('v.iqviaOutreachDirectMail',event.getParam('consentMap').contact.IQVIA_Direct_Mail_Consent__c);
    
    },
    
    generateISOLanguage: function (component, event, helper) {
        var action = component.get('c.getISOLanguage');
        action.setCallback(this, function(response){
           var state = response.getState();
           if (state === "SUCCESS") {
                var csv = helper.convertArrayOfObjectsToCSV(component, event, helper,response.getReturnValue());   
                if (csv == null){return;} 
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
                hiddenElement.target = '_self'; // 
                hiddenElement.download = 'ISO_Language_Guide.csv';  // CSV file Name* you can change it.[only name not .csv] 
                document.body.appendChild(hiddenElement); // Required for FireFox browser
                hiddenElement.click(); // using click() js function to download csv file
           }

        });
        $A.enqueueAction(action);
      },


});