/**
 * Created by Nikita Abrazhevitch on 20-Aug-19.
 */

({
    doExecute: function (component, event, helper) {
        var params = event.getParam('arguments');
        var ssWrapper = JSON.parse(JSON.stringify(params.studySiteWrapper));
        component.set('v.studySite', ssWrapper.studySite);
        component.set('v.studySiteAccounts', ssWrapper.accounts);
        if (params.callback) component.set('v.callback', $A.getCallback(params.callback));
        component.find('manageLocation').show();
        setTimeout($A.getCallback(function () {
            /*var instructions = document.getElementsByClassName("driving-instructions");
            for (var i = 0; i < instructions.length; i++) {
                var instruction = instructions.item(i);
                if (instruction != null) {
                    helper.clampLine(instruction, 3);
                }
            }*/
        }), 5);
    },

    changeRadioMarker: function (component, event, helper) {
        var radioBtns = component.find('radioBtn');
        for (let i = 0; i < radioBtns.length; i++) {
            radioBtns[i].set('v.checked', false);
        }
        event.getSource().set('v.checked', true);
        component.set('v.checkedAccount', event.getSource().get('v.value'));
        component.set('v.locationWasChanged', true);
    },

    changeStudySiteAddress: function (component, event, helper) {
        component.find('modalSpinner').show();
        var studySite = component.get('v.studySite');
        studySite.Site__r = component.get('v.checkedAccount');
        studySite.Site__c = component.get('v.checkedAccount').Id;
        communityService.executeAction(component, 'saveSSChanges', {studySiteInfo: JSON.stringify(studySite)}, function (returnValue) {
            communityService.showToast('success', 'success', $A.get('$Label.c.SS_Success_Save_Message'));
            component.set('v.locationWasChanged', false);
            component.find('modalSpinner').hide();
            component.find('manageLocation').hide();
            component.get('v.callback')(studySite); 
        });
    },

    closeModal: function (component, event, helper) {
        component.find('manageLocation').hide();
    },
});