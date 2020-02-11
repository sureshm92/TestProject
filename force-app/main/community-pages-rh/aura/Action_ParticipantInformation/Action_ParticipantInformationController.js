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
            component.set('v.initialized', false);
            component.set('v.sendEmails', false);
            var params = event.getParam('arguments');
            var pe = JSON.parse(JSON.stringify(params.pe));
            console.log('pe>>>',pe);
            component.set('v.isInvited', params.isInvited);
            if(params.actions)
                component.set('v.actions', JSON.parse(JSON.stringify(params.actions)));
            component.set('v.popUpTitle', pe.Participant__r.Full_Name__c);
            if(params.pathItems)
                component.set('v.pathItems', JSON.parse(JSON.stringify(params.pathItems)));
            component.set('v.rootComponent', params.rootComponent);
            if (params.callback) component.set('v.callback', params.callback);
            communityService.executeAction(component, 'getSteps', {
                peId: pe.Id,
                userMode: communityService.getUserMode(),
                delegateId: communityService.getDelegateId(),
            }, function (returnValue) {
                returnValue = JSON.parse(returnValue);
                //component.set('v.statusSteps', returnValue.steps);
                component.set('v.formData.visitPlansLVList', returnValue.visitPlanLVList);
                component.set('v.participantPath',returnValue.steps);
                component.set('v.isFinalUpdate', false);
                component.set('v.initialized', true);
                setTimeout($A.getCallback(function () {
                    var formComponent = component.find('editForm');
                    if (returnValue.isEnrolled) formComponent.set('v.isFinalUpdate', true);
                    component.find('spinner').hide();
                    component.set('v.anchor', params.anchorScroll);
                    component.set('v.pe', returnValue.enrollment);
                    console.log('pe', JSON.parse(JSON.stringify(component.get('v.pe'))));
                    component.set('v.participant', pe.Participant__r);
                    console.log('parti11', component.get('v.participant'));
                    formComponent.createDataStamp();
                    formComponent.checkFields();
                   /* setTimeout(function () {
                        document.getElementById('anchor').scrollIntoView({
                            behavior: 'smooth',
                            block: 'start',
                            inline: 'nearest'
                        });
                    }), 200*/
                }), 15);
            });
            console.log('parti', component.get('v.participant'));
            component.find('dialog').show();
        } catch (e) {
            console.error(e);
        }
    },

    prepareEditableSteps: function (component, event, helper) {
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
        pe.Participant__r = participant;
        component.find('spinner').show();
        communityService.executeAction(component, 'updatePatientInfo', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe)
        }, function () {
            if (component.get('v.saveAndChangeStep')) {
                component.set('v.saveAndChangeStep', false);
                var steps = component.find('stepControls');
                steps[steps.length - 1].statusSave();
            }
            component.get('v.callback')(pe);
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    doCallback: function (component, event, helper) {
        var pe = component.get('v.pe');
        component.get('v.callback')(pe);
    },
    doPrint: function (component, event, helper) {
        var pe = component.get('v.pe');
        window.open('patient-info-pv?id=' + pe.Id, '_blank');
    },
    doCancel: function (component, event, helper) {
        var comp = component.find('dialog');
        comp.hide();
    },
    checkTabs: function (component, event,helper) {
        var checking = event.getSource();
        console.log('checking', checking.getLocalId());
        if(checking.getLocalId() === 'participantDetails') {
            component.set('v.checkTabs', 'participantDetails');
        } else {
            component.set('v.checkTabs', 'otherTabs') ;
        }
    },
    doUpdateCancel: function (component, event, helper) {
        var action = component.get('c.doUpdate');
        $A.enqueueAction(action);
        var comp = component.find('dialog');
        comp.hide();
    },

    createUserForPatient: function(component, event, helper){
    	var sendEmails = component.get('v.sendEmails');
    	var pe = component.get('v.pe');
        component.find('spinner').show();
        communityService.executeAction(component, 'createUserForPatientProtal', {
            peJSON: JSON.stringify(pe),
            sendEmails: sendEmails
        }, function () {
            var action = component.get('c.doUpdate');
            $A.enqueueAction(action);
            component.set('v.isInvited', true);
            communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    doUpdatePatientStatus: function (component, event, helper) {
        var stepWrapper = component.get('v.participantPath.currentStep');
        var pe = component.get('v.pe');
        component.find('spinner').show();
        communityService.executeAction(component, 'updatePatientStatus', {
            stepWrapperJSON: JSON.stringify(stepWrapper),
            peId: pe.Id
        }, function (returnValueJSON) {
            var returnValue = JSON.parse(returnValueJSON);
            //component.set('v.statusSteps', returnValue.steps);
            component.set('v.participantPath',returnValue);
            component.get('v.callback')(pe);
        }, null, function () {
            component.find('spinner').hide();
        });

    },
});
