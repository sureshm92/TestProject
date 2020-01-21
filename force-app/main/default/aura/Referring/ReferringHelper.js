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
        component.set('v.countryInitialized', false);
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
        }
        component.set('v.participant', participant);
        component.set('v.countryInitialized', true);
    },

    setDelegate: function (component) {
        var delegateParticipant = {
            sobjectType: 'Participant__c',
        };
        component.set('v.delegateParticipant', delegateParticipant);
    },

    checkFields: function (component) {
        var participant = component.get('v.participant');
        var pEnrollment = component.get('v.pEnrollment');
        //var agreeShare = component.get('v.agreeShare');
        var agreePolicy = component.get('v.agreePolicy');
        var emailRepeat = component.get('v.emailRepeat');
        var emailCmp = component.find('emailField');
        var emailRepeatCmp = component.find('emailRepeatField');
        var emailVaild = emailCmp && emailCmp.get('v.validity') && emailCmp.get('v.validity').valid;
        var emailRepeatValid = emailRepeatCmp && emailRepeatCmp.get('v.validity') && emailRepeatCmp.get('v.validity').valid;
        var selectedCountry = participant.Mailing_Country_Code__c;
        var selectedState = participant.Mailing_State_Code__c;
        var states = component.get('v.states');

        //Guardian (Participant delegate)
        var needsDelegate = component.get('v.needsGuardian');
        var delegateParticipant = component.get('v.delegateParticipant');
        var emailDelegateRepeat = component.get('v.emailDelegateRepeat');
        var emailDelegateCmp = component.find('emailDelegateField');
        var emailDelegateRepeatCmp = component.find('emailDelegateRepeatField');
        var emailDelegateVaild = needsDelegate && emailDelegateCmp && emailDelegateCmp.get('v.validity') && emailDelegateCmp.get('v.validity').valid;
        var emailDelegateRepeatValid = needsDelegate && emailDelegateRepeatCmp && emailDelegateRepeatCmp.get('v.validity') && emailDelegateRepeatCmp.get('v.validity').valid;

        var result =
            participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Email__c &&
            participant.Mailing_Zip_Postal_Code__c &&
            (needsDelegate || emailVaild) &&
            (needsDelegate || emailRepeatValid) &&
            (needsDelegate || participant.Phone__c) &&
            //agreeShare &&
            selectedCountry &&
            (selectedState || states.length === 0) &&
            (!needsDelegate ||
                (needsDelegate &&
                    delegateParticipant.First_Name__c &&
                    delegateParticipant.Last_Name__c &&
                    delegateParticipant.Phone__c &&
                    delegateParticipant.Email__c &&
                    emailDelegateVaild &&
                    emailDelegateRepeatValid)) &&
            agreePolicy;
        component.set('v.allRequiredCompleted', result);
        component.set('v.emailsMatch',participant.Email__c && emailRepeat && participant.Email__c.toLowerCase() === emailRepeat.toLowerCase());

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
        if (needsDelegate && emailDelegateCmp && emailDelegateRepeatCmp) {
            if (delegateParticipant.Email__c && emailDelegateRepeat && delegateParticipant.Email__c.toLowerCase() !== emailDelegateRepeat.toLowerCase()) {
                emailCmp.setCustomValidity($A.get("$Label.c.PG_Ref_MSG_Email_s_not_equals"));//set('v.validity', {valid: false, badInput: true});
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