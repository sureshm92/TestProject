/**
 * Created by Nikita Abrazhevitch on 05-Sep-19.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', null, function (formData) {
            var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
            component.set('v.formData', formData);
            component.set('v.initialized', true);
        });
    },

    doExecute: function (component, event, helper) {
        try {
            component.find('spinner').show();
            var params = event.getParam('arguments');
            var pe = JSON.parse(JSON.stringify(params.pe));
            component.set('v.pe', pe);
            component.set('v.participant', pe.Participant__r);
            component.set('v.popUpTitle', pe.Participant__r.Full_Name__c + ' ' + $A.get('$Label.c.PE_Info_PopUp_Title') + ' ' + pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c);
            component.set('v.pathItems', JSON.parse(JSON.stringify(params.pathItems)));
            component.set('v.rootComponent', params.rootComponent);
            component.set('v.peStatusesPathList', params.peStatusesPathList);
            component.set('v.peStatusStateMap', params.peStatusStateMap);
            if (params.callback) component.set('v.callback', params.callback);
            communityService.executeAction(component, 'getSteps', {
                peId: pe.Id,
                userMode: communityService.getUserMode(),
                delegateId: communityService.getDelegateId(),
            }, function (returnValue) {
                returnValue = JSON.parse(returnValue);
                component.set('v.statusSteps', returnValue.steps);
                component.set('v.isFinalUpdate', false);
                var formComponent = component.find('editForm');
                formComponent.set('v.handleChangesEnabled', false);
                formComponent.createDataStamp();
                formComponent.set('v.handleChangesEnabled', true);
                component.find('spinner').hide();
                component.set('v.anchor', params.anchorScroll);
                setTimeout($A.getCallback(function () {
                    document.getElementById(params.anchorScroll).scrollIntoView({
                        behavior: "smooth",
                        block: "start",
                        inline: "nearest"
                    });
                }), 5);
            });
            var dialog = component.find('dialog')
            dialog.show();
            dialog.set('v.closeCallback', $A.getCallback(function () {
                var formComponent = component.find('editForm');
                formComponent.set('v.handleChangesEnabled', false);
                component.get('v.rootComponent').refresh();
            }));
        } catch (e) {
            console.error(e);
        }
    },

    prepareEditableSteps: function(component, event, helper){
        var pathItems = event.getParam('value');
        var showButtonsForSteps = [];
        for (let i = 0; i < pathItems.length; i++) {
            if (pathItems[i].isCurrent) {
                showButtonsForSteps.push(pathItems[i].name);
                if (i + 1 != pathItems.length) {
                    showButtonsForSteps.push(pathItems[i + 1].name);
                } else {
                    showButtonsForSteps.push('');
                }
                component.set('v.modifiedSteps', showButtonsForSteps);
                break;
            }
        }
    },

    doUpdate: function (component, event, helper) {
        var participant = component.get('v.participant');
        var pe = component.get('v.pe');
        component.find('spinner').show();
        communityService.executeAction(component, 'updatePatientInfo', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe)
        }, function () {
            if (component.get('v.saveAndChangeStep')) {
                var steps = component.find('stepControls');
                steps[steps.length - 1].statusSave();
            }
            component.get('v.callback')(pe);
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    doCancel: function (component, event, helper) {
        component.find('dialog').cancel();
    },

    doCallback: function (component, event, helper) {
        var formComponent = component.find('editForm');
        formComponent.set('v.handleChangesEnabled', false);
        var pe = component.get('v.pe');
        component.get('v.callback')(pe);
    },
});