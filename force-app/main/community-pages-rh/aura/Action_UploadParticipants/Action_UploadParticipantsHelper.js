/**
 * Created by Aleksey Moseev
 */
({

    uploadPaticipants: function(cmp, csvData, fileName, studySiteId, selectedStatus) {
        communityService.executeAction(component, 'uploadParticipants', {
            csvFileLines: csvData,
            fileName: fileName,
            studySiteId: studySiteId,
            selectedStatus: selectedStatus
        }, function (returnValue) {
            component.find('modalSpinner').hide();
            component.find('uploadParticipantsDialog').hide();
            communityService.showSuccessToast('',  "Participant record import is processing. You will be notified via email when the process has complete");
        });
    },

    clearFields: function (component, event, helper) {
        component.set("v.FileList", []);
        component.set("v.fileName", '');
        component.set("v.fileType", '');
        component.set("v.fileBody", '');
        component.set("v.selectedStatus", '');
    }

})