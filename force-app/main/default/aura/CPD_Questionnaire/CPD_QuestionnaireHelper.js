({
    calculateDOB: function (component, event) {
        var selectedDate = event.getSource().get('v.value'),
            age = this.calculateAge(selectedDate);
        if (age < 16) { 
            component.set('v.isPatientRequired', false); 
            component.set('v.isParentRequired', false);            
            component.set('v.showParent', false);                      
        }
        else if (age >= 16 && age <= 18) {
            component.set('v.isPatientRequired', false); 
            component.set('v.isParentRequired', true);            
            component.set('v.showParent', true);   
        }
        else if (age > 18) {
            component.set('v.isPatientRequired', true); 
            component.set('v.isParentRequired', false);            
            component.set('v.showParent', false);   
        }
    },

    calculateAge: function (dateString) {
        var birthday = +new Date(dateString);
        return ((Date.now() - birthday) / (31557600000));
    },

    radioInputChange : function (component, event) {
        var questionEvt = component.getEvent("questionnaireEvent"),
            checked = event.getSource().get('v.value'),
            checkedValue = event.getSource().get('v.value'),
            DOB = component.get('v.dob');

        component.set('v.showNext', !checked);
        component.set('v.radioCheck', checkedValue);
        component.set('v.formresult.Positive_for_COVID_19__c', checkedValue);

        questionEvt.setParams({ positive : checkedValue, dateOfBirth : DOB});
        questionEvt.fire(); 
    },

    radioGroupValues: function (component) {
        const options = [{ 'label': $A.get("$Label.c.CP_Symptoms_Yes"), 'value': 'true' }, { 'label': $A.get("$Label.c.CP_Symptoms_No"), 'value': 'false' }];
        component.set('v.options', options);
        component.set('v.radioOptions', options);
    },

    validateField: function (component, event, formId) {
        var field = component.find(formId);
        field.showHelpMessageIfInvalid();
        return field.get('v.validity').valid;
    },

    isPositiveCovid: function (ccomponent, id) {
        var validateFields = ccomponent.find(id || 'positive'),
            isValid;
        if (validateFields) {
            isValid = [].concat(validateFields).reduce(function (validSoFar, input) {
                input.showHelpMessageIfInvalid();
                return validSoFar && input.get('v.validity').valid;
            }, true);
        }
        return isValid;
    },

    validateInputOnChange: function (component, event, helper) {
        var field = event.getSource(),
            value = field.get('v.value');
        if (value) {
            field.set('v.validity', { valid: false, badInput: true });
            field.showHelpMessageIfInvalid();
        }
    },

})