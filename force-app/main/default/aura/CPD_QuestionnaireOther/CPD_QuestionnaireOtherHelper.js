({
    MAX_FILE_SIZE: 2000000, //Max file size 2 MB 2000000 
    CHUNK_SIZE: 2000000,      //Chunk Max size 750Kb 

    validateInput: function (component, event, formId) {
        var allValid = component.find(formId).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        return allValid;
    },

    inputValidationOnChange: function (component, event) {
        var field = event.getSource(),
            value = field.get('v.value');
        if (value) {
            field.set('v.validity', { valid: false, badInput: true });
            field.showHelpMessageIfInvalid();
        }
    },

    fileChange: function (component, event) {
        var data = event.getSource().get("v.files"),
            fileName, self = this, fileList;
        if (data.length > 0) {
            fileList = event.getSource().get("v.files")[0];
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set('v.attachmentErrorShow', false);
            component.set('v.isfileAttached', true);            
        }        
        component.set("v.fileList", fileList);
        component.set("v.fileLabel", fileName);
        self.inputValidationOnChange(component, event);
        self.fileLimititationException(component, event);
    },

    deleteFile : function(component, event){
        component.set('v.fileLabel', null);
        component.set('v.attachmentErrorShow', true);
               
        var fileInput = component.find('fileData');
        fileInput.forEach(function (attr) {
            if (attr.get('v.type') == 'file') {
                attr.set('v.value', '');
                component.set('v.fileData',{}); 
                component.set('v.isfileAttached', false);
                helper.validateInput(component, event, 'fileData');
            }
        });
    },

    changeDateLimitation: function (component, event) {
        var selectedDate = event.getSource().get('v.value');
        var changedDate = $A.localizationService.formatDate(selectedDate, "YYYY-MM-DD");
        component.set('v.endDate', changedDate);
    },

    fileLimititationException: function (component, event) {
        var fileInput = component.find("fileData"),
            file, self = this;
        fileInput.forEach(function (attr) {
            if (attr && attr.get('v.type') == 'file') {
                file = attr.get('v.files')[0];
            }
        });
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.isFileMaximum", true);
            component.set("v.fileLabel", '<span class="sld-custom-attachment-error">File size cannot exceed 2MB</span>');
            return;
        } else {
            component.set("v.isFileMaximum", false);
        }
    },


})