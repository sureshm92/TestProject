({
    doInit: function (component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.todayDate", today);
    },
    handleValidateInput: function (component, event, helper) {
        return helper.validateInput(component, event, 'fileData');
    },
    handleValidateInputOnChange: function (component, event, helper) {
        helper.inputValidationOnChange(component, event);
    },
    handleFilesChange: function (component, event, helper) {
        helper.fileChange(component, event);
    },
    handleChangeDateLimitation: function (component, event, helper) {       
        helper.changeDateLimitation(component, event);
    },

    handledeleteFiles: function (component, event, helper) {       
        helper.deleteFile(component, event);
    }

})