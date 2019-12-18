/**
 * Created by Aleksey Moseev
 */
({

    uploadPaticipants: function(component, csvData, fileName, studySiteId, selectedStatus, helper) {
        component.find('upModalSpinner').show();
        communityService.executeAction(component, 'uploadParticipants', {
            csvFileLines: csvData,
            fileName: fileName,
            studySiteId: studySiteId,
            selectedStatus: selectedStatus
        }, function (returnValue) {
            component.find('upModalSpinner').hide();
            communityService.showSuccessToast('',  "Participant record import is processing. You will be notified via email when the process has complete");
            helper.clearFields(component, undefined, helper);

            component.find('uploadParticipantsDialog').hide();
        }, function (returnValue) {
            component.find('upModalSpinner').hide();
            communityService.showErrorToast('',  "Participant record import failed. Please use template for Participant uploading.");
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