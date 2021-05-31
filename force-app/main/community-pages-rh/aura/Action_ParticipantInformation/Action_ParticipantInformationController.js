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
        var statusList = $A.get("$Label.c.Promote_to_SH_Statuses").split(",");
        
        try {
            component.set(
                'v.isIQVIA',
                communityService.getCurrentCommunityTemplateName() !==
                $A.get('$Label.c.Janssen_Community_Template_Name')
            );
            component.set('v.init', false);
            component.find('spinner').show();
            component.set('v.initialized', false);
            component.set('v.sendEmails', false);
            component.set('v.isStatusChanged', false);
            var params = event.getParam('arguments');
            var pe = JSON.parse(JSON.stringify(params.pe));
            var contId = pe.Participant__r.Contact__c;
            var status = pe.Participant_Status__c;
            component.set('v.peInvitedtoPP', (pe.Invited_To_PP_Date__c!=undefined && pe.Invited_To_PP_Date__c!=null)?true:false);
           	helper.getPESH(component,event,statusList,helper) ;
            component.set('v.isInvited', params.isInvited);
            if(component.get('v.isInvited')){
                helper.getInvitedDate(component,event,helper);
            }
            if (params.actions)
                component.set('v.actions', JSON.parse(JSON.stringify(params.actions)));
			
			helper.setPopUpName(component, pe);	
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
            communityService.executeAction(
                component,
                'getSteps',
                {
                    peId: pe.Id,
                    userMode: communityService.getUserMode(),
                    delegateId: communityService.getDelegateId()
                },
                function (returnValue) {
                    returnValue = JSON.parse(returnValue);
                    //component.set('v.statusSteps', returnValue.steps);
                    component.set('v.formData.visitPlansLVList', returnValue.visitPlanLVList);
                    // component.set('v.participantPath', returnValue.steps);
                    component.set('v.isFinalUpdate', false);
                    component.set('v.initialized', true);
                    if(returnValue.steps != null && returnValue.steps != undefined){
                        component.set('v.promoteToSHStatus',(returnValue.sendToSH==true)?true:false);
                        component.set('v.dateofSH',returnValue.sendToSHDate); 
                    }
                    setTimeout(
                        $A.getCallback(function () {
                            var formComponent = component.find('editForm');
                            if (returnValue.isEnrolled) formComponent.set('v.isFinalUpdate', true);
                            component.find('spinner').hide();
                            component.set('v.anchor', params.anchorScroll);
                            if (returnValue.enrollment.HCP__r) {
                                component.set(
                                    'v.refProvider',
                                    returnValue.enrollment.HCP__r.HCP_Contact__r
                                );
                                returnValue.enrollment.HCP__r.HCP_Contact__r = undefined;
                            }
                            component.set('v.pe', returnValue.enrollment);
                            component.set('v.containsFile', returnValue.containsFile);//REF-2654
                            component.set('v.init', true);
                            component.set(
                                'v.isEmail',
                                returnValue.enrollment.Permit_Mail_Email_contact_for_this_study__c
                            );
                            component.set(
                                'v.isPhone',
                                returnValue.enrollment.Permit_Voice_Text_contact_for_this_study__c
                            );
                            component.set(
                                'v.isSMS',
                                returnValue.enrollment.Permit_SMS_Text_for_this_study__c
                            );
                            
                            component.set(
                                'v.doContact',
                                !pe.Permit_IQVIA_to_contact_about_study__c
                            );
                            component.set('v.participantDelegate', returnValue.participantDelegate);
                            component.set('v.participant', pe.Participant__r);
                            component.set('v.userInfo', returnValue.userInfo);
                            component.set('v.contactInfo', returnValue.contactInfo);
							component.set('v.yob',returnValue.yearOfBirth);
                            component.set('v.isBulkImport',returnValue.isBulkImport);
                            formComponent.createDataStamp();
                            formComponent.checkFields();
                        }),
                        15
                    );
                }
            );
            component.find('dialog').show();
            //component.find('dialog').scrollTop();
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
    
	doCheckDateOfBith: function (component, event, helper) {
        helper.checkParticipantNeedsGuardian(component, helper, event);
    },
     
    doUpdate: function (component, event, helper) {
        var participant = component.get('v.participant');
        var pe = component.get('v.pe');
        var usermode = communityService.getUserMode();
        //pe.Permit_IQVIA_to_contact_about_study__c = !component.get('v.doNotContact');
        pe.Permit_Mail_Email_contact_for_this_study__c = component.get('v.isEmail');
        pe.Permit_Voice_Text_contact_for_this_study__c = component.get('v.isPhone');
        pe.Permit_SMS_Text_for_this_study__c = component.get('v.isSMS');
        /*if(component.get('v.sendEmails')&& component.get('v.doContact')){
            helper.createUserForPatient(component,event,helper);
        }*/
        var userInfo = component.get('v.userInfo');
        var contactInfo  = component.get('v.contactInfo');
        var userInfoJSON=null;
        var contactInfoJSON=null;
        //if user is available, update user language else update contact language. 
        if(userInfo!=null && userInfo!== undefined){
            userInfo.LanguageLocaleKey=contactInfo.Language__c;
            userInfoJSON = JSON.stringify(userInfo);
        }else{
            contactInfoJSON = JSON.stringify(contactInfo);
        }
        pe.Participant__r = participant;
        if (!pe.sObjectType) {
            pe.sObjectType = 'Participant_Enrollment__c';
        }
        component.find('spinner').show();
        // if(component.get('v.isInvited')){
        //     communityService.executeAction(component, 'updateUserLanguage', {userJSON: JSON.stringify(userInfo)})
        // }
        var participantDelegateUseExisiting = component.get('v.participantDelegateUseExisiting');
       if(!$A.util.isEmpty(component.get('v.BtnClicked')))
       {
            if(component.get('v.BtnClicked') == 'newRecord'){
                component.set('v.participantDelegate.Id',null);
            }
           else if( component.get('v.BtnClicked') == 'useExistingRecord'){
               component.set('v.participantDelegate.Id',participantDelegateUseExisiting.Id);
               component.set('v.participantDelegate.Contact__c',participantDelegateUseExisiting.Contact__c);
           }  
           
       }
        
        if(!component.get('v.participant.Adult__c')){
             component.set('v.participant.Email__c', '');
             component.set('v.participant.Phone__c', '');
             component.set('v.participant.Phone_Type__c', '');
        }
        communityService.executeAction(
            component,
            'updatePatientInfoWithDelegate',
            {
                participantJSON: JSON.stringify(participant),
                peJSON: JSON.stringify(pe),
                delegateJSON: JSON.stringify(component.get('v.participantDelegate')),
                userInfoJSON: userInfoJSON,
                contactInfoJSON: contactInfoJSON 
            },
            function (returnvalue) {
                if (component.get('v.saveAndChangeStep')) {
                    component.set('v.saveAndChangeStep', false);
                }
                var callback = component.get('v.callback');
                if (callback) {
                    //callback(pe);
                    var compEvent = component.getEvent("FilterKeep");
                    compEvent.fire();

                }
                component.set('v.pe', returnvalue.particpantEnrollment);
				helper.setPopUpName(component, returnvalue.particpantEnrollment);				
                component.set('v.participant', returnvalue.particpantEnrollment.Participant__r);
                if(!$A.util.isEmpty(returnvalue.DelegateParticipant))
                 component.set('v.participantDelegate', returnvalue.DelegateParticipant);
                component.set('v.BtnClicked','');
				component.set('v.isFirstPrimaryDelegate',false);
                 component.set('v.attestAge',false);
                 component.set('v.isBulkImport',false);
                if (usermode === 'CC') {
                    var cmpEvent = component.getEvent('callcenter');
                    cmpEvent.setParams({ searchKey: component.get('v.searchKey') });
                    cmpEvent.fire();
                }
                if (component.get('v.isListView') == true) {
                    var p = component.get('v.parent');
                    p.refreshTable();
                }
            },
            null,
            function () {
                component.find('spinner').hide();
            }
        );
    },
    
    doCallback: function (component, event, helper) {
        var pe = component.get('v.pe');
        var callback = component.get('v.callback');
        if (callback) {
            callback(pe);
        }
    },
    doPrint: function (component, event, helper) {
        if (communityService.isMobileSDK()) {
            communityService.showWarningToast(
                'Warning!',
                $A.get('$Label.c.Pdf_Not_Available'),
                100
            );
            return;
        }
        var pe = component.get('v.pe');
        window.open('patient-info-pv?id=' + pe.Id, '_blank', 'noopener');
    },
    doCancel: function (component, event, helper) {
        var comp = component.find('dialog');
        if (component.get('v.isListView') == true) {
            var p = component.get('v.parent');
            if(p !=undefined){
                p.refreshTable();
            }
        }
        comp.hide();
    },
    checkTabs: function (component, event, helper) {
        var checking = event.getSource();
        component.set('v.checkTabs', checking.getLocalId());
    },
    doUpdateCancel: function (component, event, helper) {
        var userInfo = component.get('v.userInfo');
        var contactInfo  = component.get('v.contactInfo');
        var userInfoJSON;
        var contactInfoJSON;
        //if user is available, update user language else update contact language. REF-2930
        if(userInfo!=null && userInfo!== undefined){
            userInfo.LanguageLocaleKey=contactInfo.Language__c;
            userInfoJSON = JSON.stringify(userInfo);
        }else{
            userInfoJSON = null; 
            contactInfoJSON = JSON.stringify(contactInfo);
        }
        var usermode = communityService.getUserMode();
        var participant = component.get('v.participant');
        var pe = component.get('v.pe');
        //pe.Permit_IQVIA_to_contact_about_study__c = !component.get('v.doNotContact');
        pe.Permit_Mail_Email_contact_for_this_study__c = component.get('v.isEmail');
        pe.Permit_Voice_Text_contact_for_this_study__c = component.get('v.isPhone');
        pe.Permit_SMS_Text_for_this_study__c = component.get('v.isSMS');
        /*if(component.get('v.sendEmails')&& component.get('v.doContact')){
            helper.createUserForPatient(component,event,helper);
        }*/
        var pathWrapper = component.get('v.participantPath');
        var statusDetailValid = component.get('v.statusDetailValid');
        var isStatusChanged = component.get('v.isStatusChanged');
        let steps = component.get('v.participantPath.steps');
        var notesToBeAdded = false;
        var outcome = null;
        var isIniVisCurrentStep = false;
        var nextStepNeutral = false;
        var nextOutcome = null;
        if(steps != null){
            for (let ind = 0; ind < steps.length; ind++) {
                if (steps[ind].isCurrentStepValid && steps[ind].isCurrentStep) {
                    if (steps[ind].notes != '' && steps[ind].notes != null) {
                        notesToBeAdded = true;
                    }
                    if (ind > 0 && (steps[ind].outcome == undefined || steps[ind].outcome == null)) {
                        outcome = steps[ind - 1].outcome;
                    } else {
                        outcome = steps[ind].outcome;
                    }
                }
                if (
                    steps[ind].title == $A.get('$Label.c.PWS_Initial_Visit_Name') &&
                    steps[ind].isCurrentStepValid &&
                    steps[ind].isCurrentStep
                ) {
                    isStatusChanged = true;
                    isIniVisCurrentStep = true;
                    if (ind + 1 < steps.length && steps[ind + 1].state == 'neutral') {
                        nextStepNeutral = true;
                    } else if (ind + 1 < steps.length && steps[ind + 1].state != 'neutral') {
                        nextOutcome = steps[ind + 1].outcome;
                    }
                    break;
                }
            }
        }
        if (isStatusChanged && !isIniVisCurrentStep) {
            notesToBeAdded = false;
        }
        if (isIniVisCurrentStep && !nextStepNeutral) {
            if (nextOutcome != null) {
                outcome = nextOutcome;
            } else {
                outcome = null;
            }
        }
        pe.Participant__r = participant;
        if (!pe.sObjectType) {
            pe.sObjectType = 'Participant_Enrollment__c';
        }
        var participantDelegateUseExisiting = component.get('v.participantDelegateUseExisiting');
       if(!$A.util.isEmpty(component.get('v.BtnClicked')))
       {
            if(component.get('v.BtnClicked') == 'newRecord'){
                component.set('v.participantDelegate.Id',null);
            }
           else if( component.get('v.BtnClicked') == 'useExistingRecord'){
               component.set('v.participantDelegate.Id',participantDelegateUseExisiting.Id);
               component.set('v.participantDelegate.Contact__c',participantDelegateUseExisiting.Contact__c);
           }  
       }
        component.find('spinner').show();
        var actionName;
        if (usermode == 'CC') {
            actionName = 'updatePatientInfoWithDelegateCC';
        } else {
            actionName = 'updatePatientInfoWithDelegate';
        }
        
        var actionParams = {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe),
            delegateJSON: JSON.stringify(component.get('v.participantDelegate')),
            userInfoJSON: userInfoJSON, 
            contactInfoJSON: contactInfoJSON 
        };
        if (statusDetailValid) {
            if (usermode == 'CC') {
                actionName = 'updatePatientInfoAndStatusWithDelegateCC';
            } else {
                actionName = 'updatePatientInfoAndStatusWithDelegate';
            }
            actionParams = {
                participantJSON: JSON.stringify(participant),
                peJSON: JSON.stringify(pe),
                pathWrapperJSON: JSON.stringify(pathWrapper),
                peId: pe.Id,
                delegateJSON: JSON.stringify(component.get('v.participantDelegate')),
                userInfoJSON: userInfoJSON, 
                contactInfoJSON: contactInfoJSON, 
                historyToUpdate: isStatusChanged,
                notesToBeAdded: notesToBeAdded,
                outcome: outcome
            };

        }
        
        communityService.executeAction(
            component,
            actionName,
            actionParams,
            function () {
                var actionName1;
                if (usermode == 'CC') {
                    actionName1 = component.get("c.updatePatientStatusCCHelper");
                } else {
                    actionName1 = component.get("c.updatePatientStatusHelper");
                }
                actionName1.setParams({
                    peJSON: JSON.stringify(pe),
                    pathWrapperJSON: JSON.stringify(pathWrapper),
                    historyToUpdate: isStatusChanged,
                    notesToBeAdded: notesToBeAdded,
                    outcome: outcome
                });
                component.find('spinner').show();
                actionName1.setCallback(this, $A.getCallback(function(response) {
                    var response = response.getReturnValue();
                    var callback = component.get('v.callback');
                    if (callback) {
                        //callback(pe);
                        var compEvent = component.getEvent("FilterKeep");
                        compEvent.fire();
    
                    }
                    component.set('v.BtnClicked','');
					component.set('v.isFirstPrimaryDelegate',false);
                    component.set('v.attestAge',false);
                    component.set('v.isBulkImport',false);
                    var comp = component.find('dialog');
                    if (usermode === 'CC') {
                        var cmpEvent = component.getEvent('callcenter');
                        cmpEvent.setParams({ searchKey: component.get('v.searchKey') });
                        cmpEvent.fire();
                    }
                    if (component.get('v.isListView') == true) {
                        var p = component.get('v.parent');
                        p.refreshTable();
                    }
                    comp.hide();
                    
                component.find('spinner').hide();
                }));
                $A.enqueueAction(actionName1);
            },
            null,
            function () {
                component.set('v.participantPath', null);
                component.set('v.isStatusChanged', false);
            }
        );
    },
    
    doUpdatePatientStatus: function (component, event, helper) {
        let pathWrapper = component.get('v.participantPath');
        var usermode = communityService.getUserMode();
        let pe = component.get('v.pe');
        //pe.Permit_IQVIA_to_contact_about_study__c = !component.get('v.doNotContact');
        pe.Permit_Mail_Email_contact_for_this_study__c = component.get('v.isEmail');
        pe.Permit_Voice_Text_contact_for_this_study__c = component.get('v.isPhone');
        pe.Permit_SMS_Text_for_this_study__c = component.get('v.isSMS');
        /*if(component.get('v.sendEmails')&& component.get('v.doContact')){
            helper.createUserForPatient(component,event,helper);
        }*/
        let statusDetailValid = component.get('v.statusDetailValid');
        var isStatusChanged = component.get('v.isStatusChanged');
        let steps = component.get('v.participantPath.steps');
        var notesToBeAdded = false;
        var outcome = null;
        var isIniVisCurrentStep = false;
        var nextStepNeutral = false;
        var nextOutcome = null;
        for (let ind = 0; ind < steps.length; ind++) {
            if (steps[ind].isCurrentStepValid && steps[ind].isCurrentStep) {
                if (steps[ind].notes != '' && steps[ind].notes != null) {
                    notesToBeAdded = true;
                }
                if (ind > 0 && (steps[ind].outcome == undefined || steps[ind].outcome == null)) {
                    outcome = steps[ind - 1].outcome;
                } else {
                    outcome = steps[ind].outcome;
                }
            }
            if (
                steps[ind].title == $A.get('$Label.c.PWS_Initial_Visit_Name') &&
                steps[ind].isCurrentStepValid &&
                steps[ind].isCurrentStep
            ) {
                isStatusChanged = true;
                isIniVisCurrentStep = true;
                if (ind + 1 < steps.length && steps[ind + 1].state == 'neutral') {
                    nextStepNeutral = true;
                } else if (ind + 1 < steps.length && steps[ind + 1].state != 'neutral') {
                    nextOutcome = steps[ind + 1].outcome;
                }
                break;
            }
        }
        if (isStatusChanged && !isIniVisCurrentStep) {
            notesToBeAdded = false;
        }
        if (isIniVisCurrentStep && !nextStepNeutral) {
            if (nextOutcome != null) {
                outcome = nextOutcome;
            } else {
                outcome = null;
            }
        }
        if (statusDetailValid) {
            component.find('spinner').show();
            var actionName;
            if (usermode == 'CC') {
                actionName = 'updatePatientStatusCC';
            } else {
                actionName = 'updatePatientStatus';
            }
            communityService.executeAction(
                component,
                actionName,
                {
                    pathWrapperJSON: JSON.stringify(pathWrapper),
                    peId: pe.Id,
                    historyToUpdate: isStatusChanged,
                    notesToBeAdded: notesToBeAdded,
                    outcome: outcome
                },
                function (returnValueJSON) {
                    var returnValue = JSON.parse(returnValueJSON);
                    component.set('v.updateInProgress', true);
                    component.set('v.participantPath', returnValue.participantPath);

                    component.set('v.pe', returnValue.pe);
                    component.set('v.promoteToSHStatus',(returnValue.participantPath.sendToSH==true)?true:false);
                    component.set('v.dateofSH',returnValue.participantPath.sendToSHDate);
                    var callback = component.get('v.callback');
                    if (callback) {
                        //callback(pe);
                        var compEvent = component.getEvent("FilterKeep");
                        compEvent.fire();
    
                    }
                    if (usermode === 'CC') {
                        var cmpEvent = component.getEvent('callcenter');
                        cmpEvent.setParams({ searchKey: component.get('v.searchKey') });
                        cmpEvent.fire();
                    }
                    if (component.get('v.isListView') == true) {
                        var p = component.get('v.parent');
                        p.refreshTable();
                    }
                },
                null,
                function () {
                    var childComponent = component.find("childCmp");
        			childComponent.refreshChildTable();
                    component.set('v.updateInProgress', false);
                    component.set('v.isStatusChanged', false);
                    component.find('spinner').hide();
                }
            );
        }
    },
    createUserForPatient: function (component, event, helper) {
        var sendEmails = component.get('v.sendEmails');
        var pe = component.get('v.pe');
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'createUserForPatientProtal',
            {
                peJSON: JSON.stringify(pe),
                sendEmails: sendEmails
            },
            function (returnvalue) {
                if(returnvalue ==undefined || returnvalue.length>0){
                    returnvalue = JSON.parse(JSON.stringify(returnvalue[0]));
                    component.set('v.isInvited', true);
                    component.set('v.userInfo', returnvalue);
                    component.set('v.invitedon',Date.now());
                }else{
                    component.set('v.peInvitedtoPP',true);
                }
                communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
                var callback = component.get('v.callback');
                if (callback) {
                    callback(pe);
                }
                if (component.get('v.isListView') == true) {
                    var p = component.get('v.parent');
                    p.refreshTable();
                }
            },
            null,
            function () {
                component.find('spinner').hide();
            }
        );
    },
    doCheckStatusDetailValidity: function (component, event, helper) {
        var params = event.getParam('arguments');
        // let steps = component.get('v.participantPath.steps');
        component.set('v.participantPath', params.participantWorkflowWrapper);
        let steps = params.participantWorkflowWrapper.steps;
        let isValid = true;
        for (let ind = 0; ind < steps.length; ind++) {
            if (!steps[ind].isCurrentStepValid) {
                isValid = false;
                break;
            }
        }
        component.set('v.statusDetailValid', isValid);
    },
    
    checkChildChanges: function (component, event, helper) {
        var isChangedPatientInfo = event.getParam('isChangedPatientInfo');
        var isChangedStatus = event.getParam('isChangedStatus');
        var source = event.getParam('source');
        
        if (isChangedStatus && source === 'STATUS') {
            component.set('v.isStatusChanged', true);
        }
    },
    doContact: function (component) {
        component.set('v.doContact', !component.get('v.doContact'));
        if (!component.get('v.doContact')) {
            component.set('v.sendEmails', false);
        }
    },
    doContactEmail: function (component) {
        component.set('v.isEmail', !component.get('v.isEmail'));
    },
    
    doContactPhone: function (component) {
        component.set('v.isPhone', !component.get('v.isPhone'));
    },
    
    doContactSMS: function (component) {
        component.set('v.isSMS', !component.get('v.isSMS'));
    },
    
    sendToStudyHub : function(component,event,helper){
        
        var pe = component.get('v.pe');
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'updateParticipantData',
            {
                peId : pe.Id
            }, function(returnValueJSON){
                var returnValue = JSON.parse(returnValueJSON);
                component.set('v.updateInProgress', true);
                component.set('v.participantPath', returnValue.participantPath);
                component.set('v.pe', returnValue.pe);
                component.find('spinner').hide();
            },
                null,
                function () {
                    var childComponent = component.find("childCmp");
                    if(childComponent!=undefined){
                        childComponent.refreshChildTable();
                        component.set('v.isStatusChanged', false);
                    }
                     var callback = component.get('v.callback');
                    if (callback) {
                        //callback(pe);
                        var compEvent = component.getEvent("FilterKeep");
                        compEvent.fire();
                    }
                    component.set('v.updateInProgress', false);
                    component.find('spinner').hide();
                });
        helper.getpeshdate(component,event,helper);
        helper.showToast();
    },
});