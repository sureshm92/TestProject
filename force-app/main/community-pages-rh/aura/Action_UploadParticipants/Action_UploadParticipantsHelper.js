/**
 * Created by Aleksey Moseev
 */
({

    uploadPaticipants: function(component, csvData, fileName, studySiteId, selectedStatus, createUsers, helper) {
        component.find('upModalSpinner').show();
        communityService.executeAction(component, 'uploadParticipants', {
            csvFileLines: csvData,
            fileName: fileName,
            studySiteId: studySiteId,
            selectedStatus: selectedStatus,
            createUsers: createUsers
        }, function (returnValue) {
            component.find('upModalSpinner').hide();
            communityService.showSuccessToast('',  $A.get("$Label.c.PG_EMN_MSG_Participant_record_import_is_processing"));
            helper.clearFields(component, undefined, helper);

            component.find('uploadParticipantsDialog').hide();
        }, function (returnValue) {
            component.find('upModalSpinner').hide();
            communityService.showErrorToast('',  $A.get("$Label.c.PG_EMN_MSG_Participant_record_import_failed"));
        });
    },

    clearFields: function (component, event, helper) {
        component.set("v.FileList", []);
        component.set("v.fullFileName", '');
        component.set("v.fileName", '');
        component.set("v.fileType", '');
        component.set("v.fileBody", '');
        component.set("v.selectedStatus", '');
    }

})