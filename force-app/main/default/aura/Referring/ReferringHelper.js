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
        component.set('v.participant', {
            sobjectType: 'Participant__c',
            First_Name__c: pe.Participant_Name__c,
            Last_Name__c: pe.Participant_Surname__c,
            Mailing_Country_Code__c: pe.HCP__r.HCP_Contact__r.Account.BillingCountryCode,
            Mailing_State_Code__c: pe.HCP__r.HCP_Contact__r.Account.BillingStateCode
        });
        component.set('v.countryInitialized', true);
    },

    checkFields: function (component) {
        var participant = component.get('v.participant');
        var pEnrollment = component.get('v.pEnrollment');
        //var agreeShare = component.get('v.agreeShare');
        var agreePolicy = component.get('v.agreePolicy');
        var emailRepeat = component.get('v.emailRepeat');
        var emailCmp = component.find('emailField');
        var emailRepeatCmp = component.find('emailRepeatField');
        //var emailVaild = emailCmp.get('v.validity').valid;
        //var emailRepeatValid = emailRepeatCmp.get('v.validity').valid;
        var selectedCountry = participant.Mailing_Country_Code__c;
        var selectedState = participant.Mailing_State_Code__c;
        var states = component.get('v.states');

        var result =
            participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Email__c &&
            participant.Email__c === emailRepeat &&
            participant.Mailing_Zip_Postal_Code__c &&
            //emailVaild &&
            //emailRepeatValid &&
            participant.Phone__c &&
            //agreeShare &&
            selectedCountry &&
            (selectedState || states.length === 0) &&
            agreePolicy;
        component.set('v.allRequiredCompleted', result);

        if(participant.Email__c !== emailRepeat && emailRepeat){
            emailCmp.set('v.validity', {valid: false, badInput: true});
            emailRepeatCmp.set('v.validity', {valid: false, badInput: true});
        }
    }



})