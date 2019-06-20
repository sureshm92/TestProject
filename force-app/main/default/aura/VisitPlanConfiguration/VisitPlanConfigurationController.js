/**
 * Created by AlexKetch on 6/18/2019.
 */
({

    doInit: function (component, event, helper) {
        helper.getRelatedVisitPlans(component, event, helper);
    },
    addVisit: function (component, event, helper) {
        component.find('customModal').show();
    },
    preload: function (component, event, helper) {
        const recId = component.get('v.recordId');
        component.find('visitPlan').set('v.value', recId);
    },
    scriptload: function (component, event, helper) {
        const recId = component.get('v.recordId');
        component.find('visitPlan').set('v.value', recId);
    },
    closeModal: function (component, event, helper) {
        const recId = component.get('v.recordId');
        component.find('customModal').hide();
    },

    submitForm: function (component, event, helper) {
        let icons = component.get('v.selectedIcons');
        let strCoins = icons.join(';');
        component.find('splittedIcons').set('v.value', strCoins);
        component.find('editForm').submit();
    },
    shiftRight: function (component, event, helper) {
        debugger;
        const elements = component.find('leftIcons');
        let selectedNames = [];
        let newLeft = [];
        for (let i = 0; i < elements.length; i++) {
            if (elements[i].get('v.selected')) {
                selectedNames.push(elements[i].get('v.name'));
            }else{
                newLeft.push(elements[i].get('v.name'));
            }
        }
        let selectedIcons = component.get('v.selectedIcons');
        for (let i = 0; i < selectedNames.length; i++) {
            selectedIcons.push(selectedNames[i]);
        }
        component.set('v.selectedIcons',selectedIcons);
        component.set('v.availableIcons',newLeft);
    },
    shiftLeft: function (component, event, helper) {
        const elements = component.find('rightIcons');
        let selectedNames = [];
        let newRigt = [];
        for (let i = 0; i < elements.length; i++) {
            if (elements[i].get('v.selected')) {
                selectedNames.push(elements[i].get('v.name'));
            }else{
                newRigt.push(elements[i].get('v.name'));
            }
        }
        let availableIcons = component.get('v.availableIcons');
        for (let i = 0; i < selectedNames.length; i++) {
            availableIcons.push(selectedNames[i]);
        }
        component.set('v.selectedIcons',newRigt);
        component.set('v.availableIcons',availableIcons);

    },
    handleSuccess: function (component, event, helper) {
        debugger;
        component.find('customModal').hide();
        helper.getRelatedVisitPlans(component, event, helper);
        helper.notify({
            "title": "Success!",
            "message": "The record has been created successfully.",
            "type": 'success'
        });
    }

})