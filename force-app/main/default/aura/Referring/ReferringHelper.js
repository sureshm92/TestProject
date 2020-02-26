/**
 * Created by Leonid Bartenev
 */
({
    addEventListener: function (component, helper) {
        if(!component.serveyGizmoResultHandler){
            component.serveyGizmoResultHandler = $A.getCallback(function(e) {
                if(e.data.messageType === 'SurveyGizmoResult'){
                    if(e.data.success){
                        component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Contact_Info'));
                        window.scrollTo(0, 0);
                    }else{
                        helper.doFailedReferral(component, 'Failed Pre-Eligibility Screening', function () {
                            component.set('v.currentState', 'Questionare Failed');
                            window.scrollTo(0, 0);
                        });
                    }
                    console.log('Gizmo prescreeinig result' + e.data.pdfContent);
                } else if(e.data.messageType === 'SurveyGizmoHeight'){
                    component.set('v.frameHeight', e.data.value + 10);
                    window.scrollTo(0, 0);
                }
            });
            window.addEventListener('message', component.serveyGizmoResultHandler);
        }

    },

    doFailedReferral: function (component, reason, successCallBack) {
        var pEnrollment = component.get('v.pEnrollment');
        var spinner = component.find('mainSpinner');
        spinner.show();
        communityService.executeAction(component, 'setfailedReferral', {
            peJSON: JSON.stringify(pEnrollment),
            reason: reason
        }, function (returnValue) {
            successCallBack();
        }, null, function () {
            spinner.hide();
        });
    },

    setParticipant: function (component, pe) {
        var participant = {
            sobjectType: 'Participant__c',
            First_Name__c: pe.Participant_Name__c,
            Last_Name__c: pe.Participant_Surname__c,
            // Mailing_Country_Code__c: pe.HCP__r.HCP_Contact__r.Account.BillingCountryCode,
            // Mailing_State_Code__c: pe.HCP__r.HCP_Contact__r.Account.BillingStateCode
        };
        if(pe.HCP__r){
            participant.Mailing_Country_Code__c= pe.HCP__r.HCP_Contact__r.Account.BillingCountryCode;
            participant.Mailing_State_Code__c= pe.HCP__r.HCP_Contact__r.Account.BillingStateCode;
            component.set('v.selectedCountry', participant.Mailing_Country_Code__c);
        }
        component.set('v.participant', participant);
    },

    setDelegate: function (component) {
        var delegateParticipant = {
            sobjectType: 'Participant__c',
        };
        component.set('v.delegateParticipant', delegateParticipant);
    },

    checkFields: function (component) {
        let agreePolicy = component.get('v.agreePolicy');
        let states = component.get('v.states');
        let needsDelegate = component.get('v.needsGuardian');

        //Participant
        let participant = component.get('v.participant');
        let emailRepeat = component.get('v.emailRepeat');
        let emailCmp = component.find('emailField');
        let emailRepeatCmp = component.find('emailRepeatField');
        let emailVaild = emailCmp && emailCmp.get('v.validity') && emailCmp.get('v.validity').valid;
        let emailRepeatValid = emailRepeatCmp && emailRepeatCmp.get('v.validity') && emailRepeatCmp.get('v.validity').valid;
        let selectedCountry = participant.Mailing_Country_Code__c;
        let selectedState = participant.Mailing_State_Code__c;

        //Guardian (Participant delegate)
        let delegateParticipant = component.get('v.delegateParticipant');
        let emailDelegateRepeat = component.get('v.emailDelegateRepeat');
        let emailDelegateCmp = component.find('emailDelegateField');
        let emailDelegateRepeatCmp = component.find('emailDelegateRepeatField');
        let emailDelegateVaild = needsDelegate && emailDelegateCmp && emailDelegateCmp.get('v.validity') && emailDelegateCmp.get('v.validity').valid;
        let emailDelegateRepeatValid = needsDelegate && emailDelegateRepeatCmp && emailDelegateRepeatCmp.get('v.validity') && emailDelegateRepeatCmp.get('v.validity').valid;

        let isValid = false;
        isValid = isValid ||
            (participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Date_of_Birth__c &&
            (needsDelegate || participant.Email__c) &&
            (needsDelegate || emailVaild) &&
            (needsDelegate || emailRepeatValid) &&
            (needsDelegate || participant.Phone__c) &&
            participant.Mailing_Zip_Postal_Code__c &&
            selectedCountry &&
            (selectedState || states.length === 0) &&
            (!needsDelegate ||
                (needsDelegate && delegateParticipant &&
                    participant.Health_care_proxy_is_needed__c &&
                    delegateParticipant.First_Name__c &&
                    delegateParticipant.Last_Name__c &&
                    delegateParticipant.Phone__c &&
                    delegateParticipant.Email__c &&
                    emailDelegateVaild &&
                    emailDelegateRepeatValid)) &&
            agreePolicy);
        component.set('v.allRequiredCompleted', isValid);

        if (!needsDelegate && emailCmp && emailRepeatCmp) {
            if (participant.Email__c && emailRepeat && participant.Email__c.toLowerCase() !== emailRepeat.toLowerCase()) {
                emailCmp.setCustomValidity($A.get("$Label.c.PG_Ref_MSG_Email_s_not_equals"));//set('v.validity', {valid: false, badInput: true});
                emailRepeatCmp.setCustomValidity($A.get("$Label.c.PG_Ref_MSG_Email_s_not_equals"));//.set('v.validity', {valid: false, badInput: true});
            } else {
                emailCmp.setCustomValidity("");
                emailRepeatCmp.setCustomValidity("");
            }
            if (participant.Email__c && participant.Email__c !== '' && emailRepeat && emailRepeat !== '') {
                emailCmp.reportValidity();
                emailRepeatCmp.reportValidity();
            }
        }
        if (needsDelegate && delegateParticipant && emailDelegateCmp && emailDelegateRepeatCmp) {
            if (delegateParticipant.Email__c && emailDelegateRepeat && delegateParticipant.Email__c.toLowerCase() !== emailDelegateRepeat.toLowerCase()) {
                emailDelegateCmp.setCustomValidity($A.get("$Label.c.PG_Ref_MSG_Email_s_not_equals"));//set('v.validity', {valid: false, badInput: true});
                emailDelegateRepeatCmp.setCustomValidity($A.get("$Label.c.PG_Ref_MSG_Email_s_not_equals"));//.set('v.validity', {valid: false, badInput: true});
            } else {
                emailDelegateCmp.setCustomValidity("");
                emailDelegateRepeatCmp.setCustomValidity("");
            }
            if (delegateParticipant.Email__c && delegateParticipant.Email__c !== '' && emailDelegateRepeat && emailDelegateRepeat !== '') {
                emailDelegateCmp.reportValidity();
                emailDelegateRepeatCmp.reportValidity();
            }
        }

        console.log('VALIDATION isValid RESULT2: ' + isValid);
    },

    checkParticipantNeedsGuardian: function (component, helper) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        var participant = component.get('v.participant');
        console.log('checkParticipantNeedsGuardian');
        console.log(JSON.stringify(participant));
        communityService.executeAction(component, 'checkNeedsGuardian', {
            participantJSON: JSON.stringify(participant)
        }, function (returnValue) {
            console.log('isNeedGuardian: ' + returnValue);
            var isNeedGuardian = (returnValue == 'true');
            console.log('checkNeedsGuardian - SUCCESS: ' + isNeedGuardian);
            component.set('v.needsGuardian', isNeedGuardian);
            component.set('v.participant.Health_care_proxy_is_needed__c', isNeedGuardian);
            component.set('v.participant.Adult__c', !isNeedGuardian);

            if (isNeedGuardian) {
                helper.setDelegate(component);
            }
        }, null, function () {
            spinner.hide();
        });
    },

    checkSites: function(component){
        var studySites = component.get("v.studySites");
        if(studySites.length>0){
            component.set('v.currentState', 'Screening');
        }
        else{
            component.set('v.currentState', 'No Active Sites');
        }
    },

    fillMarkers: function (component) {
        var markers = [];
        var descriptionLink = '';
        var studySiteMarkers = component.get('v.studySiteMarkers');
        for(var i = 0, j = studySiteMarkers.length; i < j; i++){
            var mark = studySiteMarkers[i];
            if(!mark.ssAccount.BillingCity || !mark.ssAccount.BillingStreet || mark.siteType == 'Virtual') {
                continue;
            }
            markers.push({
                location: {
                    Street: mark.ssAccount.BillingStreet,
                    City: mark.ssAccount.BillingCity,
                    PostalCode: mark.ssAccount.BillingPostalCode,
                    State: mark.ssAccount.BillingState,
                    Country: mark.ssAccount.BillingCountry
                },
                icon: 'custom:custom86',
                title: i+1 + '. ' + mark.name,
                description: descriptionLink
            });
        }
        return markers;
    }



})