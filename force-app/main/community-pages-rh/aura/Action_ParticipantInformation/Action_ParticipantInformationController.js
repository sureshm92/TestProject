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
            component.set('v.isStatusChanged', false);
            var params = event.getParam('arguments');
            var pe = JSON.parse(JSON.stringify(params.pe));
            var contId = pe.Participant__r.Contact__c;
            component.set('v.isInvited', params.isInvited);
            if(params.actions) component.set('v.actions', JSON.parse(JSON.stringify(params.actions)));
            component.set('v.popUpTitle', pe.Participant__r.Full_Name__c);
            component.set('v.rootComponent', params.rootComponent);
            if (params.callback) component.set('v.callback', params.callback);
            // if (component.get('v.isInvited')) {
            //     communityService.executeAction(component, 'getUserLanguage', {
            //         contId: contId
            //     }, function (returnValue) {
            //         component.set('v.userInfo', returnValue);
            //         console.log('USERINFO', JSON.stringify(returnValue));
            //     });
            // }
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
                    component.set('v.participantDelegate', returnValue.participantDelegate);
                    component.set('v.participant', pe.Participant__r);
                    component.set('v.userInfo', returnValue.userInfo);
                    formComponent.createDataStamp();
                    formComponent.checkFields();
                }), 15);
            });
            component.find('dialog').show();
            component.find('dialog').scrollTop();
        } catch (e) {
            console.error(e);
        }
    },

    checkParticipant: function (component, event, helper) {
        let newPhone = component.get('v.pe.Participant__r.Phone__c');
        let oldPhone = component.get('v.participant.Phone__c');
        if (!component.get('v.participant.Adult__c') && !newPhone && newPhone != oldPhone) {
            component.set('v.participant.Phone__c', newPhone);
        }
    },    


    doUpdate: function (component, event, helper) {
        var participant = component.get('v.participant');
        var pe = component.get('v.pe');
        var userInfo = component.get('v.userInfo');
        pe.Participant__r = participant;
        if (!pe.sObjectType) {
            pe.sObjectType = 'Participant_Enrollment__c';
        }        
        component.find('spinner').show();
        // if(component.get('v.isInvited')){
        //     communityService.executeAction(component, 'updateUserLanguage', {userJSON: JSON.stringify(userInfo)})
        // }
        communityService.executeAction(component, 'updatePatientInfoWithDelegate', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe),
            delegateJSON: JSON.stringify(component.get('v.participantDelegate')),
            userInfoJSON: JSON.stringify(userInfo)
        }, function () {
            if (component.get('v.saveAndChangeStep')) {
                component.set('v.saveAndChangeStep', false);

            }
            var callback = component.get('v.callback');
            if(callback){
                callback(pe);
            }
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    doCallback: function (component, event, helper) {
        var pe = component.get('v.pe');
        var callback = component.get('v.callback');
        if(callback){
            callback(pe);
        }
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
        component.set('v.checkTabs', checking.getLocalId());
    },
    doUpdateCancel: function (component, event, helper) {
        var userInfo = component.get('v.userInfo');
        var participant = component.get('v.participant');
        var pe = component.get('v.pe');
        var pathWrapper = component.get('v.participantPath');
        var statusDetailValid = component.get('v.statusDetailValid');
        var isStatusChanged = component.get('v.isStatusChanged');
        console.log('#isStatusChanged: '+ isStatusChanged);
        console.log('##statusDetailValid: '+statusDetailValid);
        pe.Participant__r = participant;
        if (!pe.sObjectType) {
            pe.sObjectType = 'Participant_Enrollment__c';
        }        
        component.find('spinner').show();
        var actionName = 'updatePatientInfoWithDelegate';
        var actionParams = {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe),
            delegateJSON: JSON.stringify(component.get('v.participantDelegate')),
            userInfoJSON: JSON.stringify(userInfo)
        };
        if(statusDetailValid){
            actionName = 'updatePatientInfoAndStatusWithDelegate';
            actionParams = {
                participantJSON: JSON.stringify(participant),
                peJSON: JSON.stringify(pe),
                pathWrapperJSON: JSON.stringify(pathWrapper),
                peId: pe.Id,
                delegateJSON: JSON.stringify(component.get('v.participantDelegate')),
                userInfoJSON: JSON.stringify(userInfo),
                historyToUpdate : isStatusChanged 
            };
        }
        // if(component.get('v.isInvited')){
        //     communityService.executeAction(component, 'updateUserLanguage', {userJSON: JSON.stringify(userInfo)})
        // }
        communityService.executeAction(component, actionName, actionParams , function () {
            var callback = component.get('v.callback');
            if(callback){
                callback(pe);
            }
            component.find('spinner').hide();
            var comp = component.find('dialog');
            comp.hide();
        }, null, function () {
            component.set('v.isStatusChanged', false);
            component.find('spinner').hide();
        });
    },

    createUserForPatient: function(component, event, helper){
    	var sendEmails = component.get('v.sendEmails');
    	var pe = component.get('v.pe');
        component.find('spinner').show();
        communityService.executeAction(component, 'createUserForPatientProtal', {
            peJSON: JSON.stringify(pe),
            sendEmails: sendEmails
        }, function (returnvalue) {
            returnvalue = JSON.parse(JSON.stringify(returnvalue[0]));
            component.set('v.isInvited', true);
            component.set('v.userInfo', returnvalue);
            communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
            var callback = component.get('v.callback');
            if(callback){
                callback(pe);
            }
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    doUpdatePatientStatus: function (component, event, helper) {
        let pathWrapper = component.get('v.participantPath');
        let pe = component.get('v.pe');
        let statusDetailValid = component.get('v.statusDetailValid');
        var isStatusChanged = component.get('v.isStatusChanged');
        console.log('#isStatusChanged: '+ isStatusChanged);
        if(statusDetailValid){
            component.find('spinner').show();
            console.log(JSON.stringify(pathWrapper));
            communityService.executeAction(component, 'updatePatientStatus', {
                pathWrapperJSON: JSON.stringify(pathWrapper),
                peId: pe.Id,
                historyToUpdate: isStatusChanged
            }, function (returnValueJSON) {
                var returnValue = JSON.parse(returnValueJSON);
                component.set('v.updateInProgress', true);
                component.set('v.participantPath',returnValue.participantPath);

                component.set('v.pe', returnValue.pe);
                var callback = component.get('v.callback');
                if(callback){
                    callback(pe);
                }
            }, null, function () {
                component.set('v.updateInProgress', false);                
                component.set('v.isStatusChanged', false);
                component.find('spinner').hide();
            });
        }

    },
    doCheckStatusDetailValidity : function (component, event, helper) {
        let steps = component.get('v.participantPath.steps');
        let isValid = true;
        for (let ind = 0; ind < steps.length; ind++) {
            if (!steps[ind].isCurrentStepValid) {
                isValid = false;
                break;
            }
        }
        component.set('v.statusDetailValid', isValid);
    },

    checkChildChanges: function(component, event, helper){
        var isChangedPatientInfo = event.getParam("isChangedPatientInfo");
        var isChangedStatus = event.getParam("isChangedStatus");
        var source = event.getParam("source");
        
        if(isChangedStatus && source === 'STATUS'){
            component.set('v.isStatusChanged', true);
        }
        
    }
});