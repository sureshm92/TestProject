/**
 * Created by Aleksey Moseev
 */
({
    uploadPaticipants: function (
        component,
        csvData,
        fileName,
        studySiteId,
        selectedStatus,
        createUsers,
        doContact,
        isEmail,
        isPhone,
        isSMS,
        iqviaOutreachEmail,
        iqviaOutreachPhone,
        iqviaOutreachSMS,
        iqviaOutreachDirectMail,
        visitPlanId,
        helper
    ) {
        component.find('upModalSpinner').show();
        communityService.executeAction(
            component,
            'uploadParticipants',
            {
                csvFileLines: csvData,
                fileName: fileName,
                studySiteId: studySiteId,
                selectedStatus: selectedStatus,
                createUsers: createUsers,
                doContact: doContact,
                allowEmail: isEmail,
                allowPhone: isPhone,
                allowSMS: isSMS,
                outreachEmail : iqviaOutreachEmail,
                outreachPhone : iqviaOutreachPhone,
                outreachSMS : iqviaOutreachSMS,
                outreachDirectMail : iqviaOutreachDirectMail,
                visitPlanId: visitPlanId==''?undefined:visitPlanId
            },
            function (returnValue) {
                component.find('upModalSpinner').hide();
                communityService.showSuccessToast(
                    '',
                    $A.get('$Label.c.PG_EMN_MSG_Participant_record_import_is_processing')
                );
                helper.clearFields(component, undefined, helper);

                component.find('uploadParticipantsDialog').hide();
            },
            function (returnValue) {
                component.find('upModalSpinner').hide();
                communityService.showErrorToast(
                    '',
                    $A.get('$Label.c.PG_EMN_MSG_Participant_record_import_failed')
                );
            }
        );
    },

    clearFields: function (component, event, helper) {
        component.set('v.FileList', []);
        component.set('v.fullFileName', '');
        component.set('v.fileName', '');
        component.set('v.fileType', '');
        component.set('v.fileBody', '');
        component.set('v.selectedStatus', '');
    },

    checkCommunity: function (component, event, helper) {
        component.set(
            'v.communityWithPPInv',
            communityService.getCurrentCommunityTemplateName() !=
                $A.get('$Label.c.Janssen_Community_Template_Name')
        );
    },

    convertArrayOfObjectsToCSV : function(component, event, helper,objectRecords) {
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        columnDivider = ',';
        lineDivider =  '\n';
        //keys = ['Language','Language ISO Code'];
        keys = ['Language','LanguageISOcode'];

        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ; 
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
                if(objectRecords[i][skey] != undefined){
                    csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                }else{
                    csvStringResult += '"'+ '' +'"';
                }               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
        return csvStringResult;        
    },

});