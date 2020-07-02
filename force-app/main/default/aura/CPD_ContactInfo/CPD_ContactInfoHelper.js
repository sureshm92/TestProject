({
    getPicklistToValues: function (component, event) {
        var actionGetPicklistValues = component.get("c.getPickListValuesIntoList");
        actionGetPicklistValues.setCallback(this, function (response) {
            var state = response.getState(),
                data;
            if (state === 'SUCCESS') {
                data = response.getReturnValue();
                component.set("v.refsites", data);                
            } else {
                console.log(response.getError('Details'));
            }

        });
        $A.enqueueAction(actionGetPicklistValues);
    },

    getStateMapByCountry : function(component, event){
        var action = component.get('c.getStateMapByCountry');
        action.setCallback(this, function(response){
            var state = response.getState(),
            data;
            if(state === 'SUCCESS'){
                data = response.getReturnValue();
                var stateList = data['US'];
                component.set('v.stateList',stateList);
            }
        });
        $A.enqueueAction(action);

    },
    
    validateInput: function (component, event, formId) {
        var fieldValid = component.find(formId).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        return fieldValid;
    },

    validateInputOnChange: function (component, event) {
        var field = event.getSource(),
            value = field.get('v.value');
        if (value) {
            field.set('v.validity', { valid: false, badInput: true });
            field.showHelpMessageIfInvalid();
        }
    },

    changeReferringOrganization: function (component, event) {
        var selected = event.getSource().get("v.value"),
            required = false;
        component.set('v.formresult.Referral_Org__c', selected);
        if (selected && selected.toLowerCase().indexOf("other") > -1) {
            required = true;
        } else {
            required = false;
        }
        component.set('v.isOtherRequired', required);
        component.set('v.showOtherTextbox', required);
    },

    changePatSuffix: function (component, event, helper) {
        var val = event.getSource().get("v.value");
        component.set('v.intpatientreferral.Suffix__c', val);
    },

    changeDelSuffix: function (component, event, helper) {
        var val = event.getSource().get("v.value");
        component.set('v.intpatientreferral.Delegate_Suffix__c', val);
    },
})