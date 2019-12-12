/**
 * Created by Aleksey Moseev
 */
({

    doExecute: function (component, event, helper) {
        var params = event.getParam('arguments');
        component.find('uploadParticipantsDialog').show();
        component.set('v.studySiteId', params.studySiteId);
        if (params.callback) component.set('v.callback', $A.getCallback(params.callback));
    },

    doCancel: function (component, event, helper) {
        component.find('uploadParticipantsDialog').cancel();
    },

    upload: function(component, event, helper) {
        component.find('modalSpinner').show();
        var toastEvent = $A.get("e.force:showToast");

        var fileTypes = ['csv', 'xls', 'xlsx'];

        var file = component.get("v.FileList")[0];
        var extension = file.name.split('.').pop().toLowerCase();
        var fileName = file.name.split('.')[0];

        if (fileTypes.indexOf(extension) == -1) {
            communityService.showToast('error', 'error', "ERROR: file format must be .CSV, .XLS or .XLSX; also, the field names must match the ones provided in the Sample Template. Please correct the problem and try again.");
            component.find('modalSpinner').hide();

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
                component.find('modalSpinner').hide();

                return;
            }

            helper.uploadPaticipants(component, stringArray, fileName, component.get('v.studySiteId'));
        };

        reader.readAsArrayBuffer(file);
    }

})