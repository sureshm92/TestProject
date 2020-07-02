({
    doInit: function (component, event, helper) {
        helper.getStateMapByCountry(component, event);
        helper.getPicklistToValues(component, event);
    },

    validateContactInfo: function (component, event, helper) {
        var showParent = component.get('v.showParent'), valid;
        let sectionIds = (showParent) ? ['contactInfo', 'legalguardian'] : ['contactInfo'];
        for (let id in sectionIds) {
            valid = helper.validateInput(component, event, sectionIds[id]);
            if (!valid) { break; }
        }
        return valid;
    },

    handleInputValidation: function (component, event, helper) {
        helper.validateInputOnChange(component, event );
    },

    handleInputValidationDelegate: function (component, event, helper) {
        helper.validateInputOnChange(component, event);
    },

    changeReferringOrganization: function (component, event, helper) {
        helper.changeReferringOrganization(component, event);
    },

    changePatSuffix: function (component, event, helper) {
        helper.changePatSuffix(component, event, helper);
    },
    
    changeDelSuffix: function (component, event, helper) {
      helper.changeDelSuffix(component, event, helper);
      
    },   
})