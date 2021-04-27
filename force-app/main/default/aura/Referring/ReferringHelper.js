/**
 * Created by Leonid Bartenev
 */
 ({
    addEventListener: function (component, helper) {
        if (!component.serveyGizmoResultHandler) {
            component.serveyGizmoResultHandler = $A.getCallback(function (e) {
                if (e.data.messageType === 'SurveyGizmoResult') {
                    if (e.data.success) {
                        component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Contact_Info'));
                        window.scrollTo(0, 0);
                    } else {
                        helper.doFailedReferral(
                            component,
                            'Failed Pre-Eligibility Screening',
                            function () {
                                component.set('v.currentState', 'Questionare Failed');
                                window.scrollTo(0, 0);
                            }
                        );
                    }
                    console.log('Gizmo prescreeinig result' + e.data.pdfContent);
                } else if (e.data.messageType === 'SurveyGizmoHeight') {
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
        communityService.executeAction(
            component,
            'setfailedReferral',
            {
                peJSON: JSON.stringify(pEnrollment),
                reason: reason
            },
            function (returnValue) {
                successCallBack();
            },
            null,
            function () {
                spinner.hide();
            }
        );
    },

   
    setParticipant: function (component, pe, markers) {
        var participant = {
            sobjectType: 'Participant__c',
            First_Name__c: pe.Participant_Name__c,
            Last_Name__c: pe.Participant_Surname__c
            // Mailing_Country_Code__c: pe.HCP__r.HCP_Contact__r.Account.BillingCountryCode,
            // Mailing_State_Code__c: pe.HCP__r.HCP_Contact__r.Account.BillingStateCode
        };
        if (pe.HCP__r) {
            participant.Mailing_Country_Code__c =
                pe.HCP__r.HCP_Contact__r.Account.BillingCountryCode;
            participant.Mailing_State_Code__c = pe.HCP__r.HCP_Contact__r.Account.BillingStateCode;
            component.set('v.selectedCountry', participant.Mailing_Country_Code__c);
        }
        component.set('v.participant', participant);
    },

    setDelegate: function (component, participant) {
        var delegateParticipant = {
            sobjectType: 'Participant__c'
        };
        component.set('v.delegateParticipant', delegateParticipant);
        component.set('v.emailDelegateRepeat', '');
    },

    checkFields: function (component, event, helper, doNotCheckFields) {
        let agreePolicy = component.get('v.agreePolicy');
        let isAdultDel = component.get('v.isAdultDel');
        let attestAge = component.get('v.attestAge');
        let states = component.get('v.states');
        let needsDelegate = component.get('v.needsGuardian');
        let isNewPrimaryDelegate =  component.get('v.isNewPrimaryDelegate');

        //Participant
        let participant = component.get('v.participant');
        let emailRepeat = component.get('v.emailRepeat');
        let emailCmp = component.find('emailField');
        let emailRepeatCmp = component.find('emailRepeatField');
        let emailVaild = emailCmp && communityService.isValidEmail(participant.Email__c);
        let emailRepeatValid = emailRepeatCmp && communityService.isValidEmail(emailRepeat);
        let selectedCountry = participant.Mailing_Country_Code__c;
        let selectedState = participant.Mailing_State_Code__c;

        //Guardian (Participant delegate)
        let delegateParticipant = component.get('v.delegateParticipant');
        let emailDelegateRepeat = component.get('v.emailDelegateRepeat');
        //REF-3070
        let delegateParticipantemail = component.get('v.delegateParticipant.Email__c')!== undefined ? true : false;
        let emailDelegateCmp = component.find('emailDelegateField');
        let emailDelegateRepeatCmp = component.find('emailDelegateRepeatField');
        //REF-3070
        let emailDelegateVaild = false;        
        if(delegateParticipantemail){
            emailDelegateVaild = needsDelegate &&
                    emailDelegateCmp &&
                    helper.checkValidEmail(emailCmp, delegateParticipant.Email__c);
        }else{
            emailDelegateVaild = false;
        }    

        let emailDelegateRepeatValid = false;        
        if(emailDelegateRepeat && emailDelegateRepeat !== undefined){ 
            emailDelegateRepeatValid = 
                needsDelegate &&
                emailDelegateRepeatCmp &&
            	helper.checkValidEmail(emailDelegateRepeatCmp, emailDelegateRepeat);
        }else {
            emailDelegateRepeatValid = false;
        }
        //let emailDelegateVaild = needsDelegate && emailDelegateCmp && emailDelegateCmp.get('v.validity') && emailDelegateCmp.get('v.validity').valid;
        //let emailDelegateRepeatValid = needsDelegate && emailDelegateRepeatCmp && emailDelegateRepeatCmp.get('v.validity') && emailDelegateRepeatCmp.get('v.validity').valid;

        if (
            emailDelegateVaild &&
            emailDelegateRepeatValid &&
            delegateParticipant.First_Name__c &&
            delegateParticipant.Last_Name__c &&
            delegateParticipant.Email__c.toLowerCase() == emailDelegateRepeat.toLowerCase() &&
            !doNotCheckFields &&
            delegateParticipant.Email__c.toLowerCase() != component.get('v.emailInstance')
        ) {
            helper.checkDelegateDuplicate(
                component,
                event,
                helper,
                delegateParticipant.Email__c,
                delegateParticipant.First_Name__c,
                delegateParticipant.Last_Name__c
            );
        }
        
        let isValid = false;
        isValid =
            isValid ||
            (participant.First_Name__c &&
                participant.Last_Name__c &&
                participant.Date_of_Birth__c &&
                participant.Date_of_Birth__c <= component.get('v.todayDate') &&
                (needsDelegate || participant.Email__c) &&
                (needsDelegate || emailVaild) &&
                (needsDelegate || emailRepeatValid) &&
                participant.Email__c == emailRepeat &&
                (needsDelegate || participant.Phone__c) &&
                participant.Mailing_Zip_Postal_Code__c &&
                selectedCountry &&
                (selectedState || states.length === 0) &&
                (!needsDelegate ||
                    (needsDelegate &&
                        delegateParticipant &&
                        participant.Health_care_proxy_is_needed__c &&
                        delegateParticipant.First_Name__c &&
                        delegateParticipant.Last_Name__c &&
                        delegateParticipant.Phone__c &&
                        delegateParticipant.Email__c &&

                        emailDelegateVaild &&
                        emailDelegateRepeatValid &&
                        delegateParticipant.Email__c == emailDelegateRepeat)) &&
                agreePolicy);
        if(isNewPrimaryDelegate)
        {
            if(!(isAdultDel && attestAge))
            	isValid = false;
        }
		if(isValid == undefined){
            component.set('v.allRequiredCompleted', false);
        }else{
			component.set('v.allRequiredCompleted', isValid);
		}

        if (!needsDelegate && emailCmp && emailRepeatCmp) {
            if (
                participant.Email__c &&
                emailRepeat &&
                participant.Email__c.toLowerCase() !== emailRepeat.toLowerCase()
            ) {
                emailCmp.setCustomValidity($A.get('$Label.c.PG_Ref_MSG_Email_s_not_equals')); //set('v.validity', {valid: false, badInput: true});
                emailRepeatCmp.setCustomValidity($A.get('$Label.c.PG_Ref_MSG_Email_s_not_equals')); //.set('v.validity', {valid: false, badInput: true});
            } else {
                emailCmp.setCustomValidity('');
                emailRepeatCmp.setCustomValidity('');
            }
            if (
                participant.Email__c &&
                participant.Email__c !== '' &&
                emailRepeat &&
                emailRepeat !== ''
            ) {
                emailCmp.reportValidity();
                emailRepeatCmp.reportValidity();
            }
        }
        if (needsDelegate && delegateParticipant && emailDelegateCmp && emailDelegateRepeatCmp) {
            if (
                delegateParticipant.Email__c &&
                emailDelegateRepeat &&
                delegateParticipant.Email__c.toLowerCase() !== emailDelegateRepeat.toLowerCase()
            ) {
                emailDelegateCmp.setCustomValidity(
                    $A.get('$Label.c.PG_Ref_MSG_Email_s_not_equals')
                ); //set('v.validity', {valid: false, badInput: true});
                emailDelegateRepeatCmp.setCustomValidity(
                    $A.get('$Label.c.PG_Ref_MSG_Email_s_not_equals')
                ); //.set('v.validity', {valid: false, badInput: true});
            } else {
                emailDelegateCmp.setCustomValidity('');
                emailDelegateRepeatCmp.setCustomValidity('');
            }
            if (
                delegateParticipant.Email__c &&
                delegateParticipant.Email__c !== '' &&
                emailDelegateRepeat &&
                emailDelegateRepeat !== ''
            ) {
                emailDelegateCmp.reportValidity();
                emailDelegateRepeatCmp.reportValidity();
            }
        }

        console.log('VALIDATION isValid RESULT2: ' + isValid);
    },

    checkValidEmail: function (email, emailValue) {
        var isValid = false;
        var regexp = $A.get('$Label.c.RH_Email_Validation_Pattern');
        var regexpInvalid = new RegExp($A.get('$Label.c.RH_Email_Invalid_Characters'));
        var invalidCheck = regexpInvalid.test(emailValue);
        if (invalidCheck == false) {
            email.setCustomValidity('');
            if (emailValue.match(regexp)) {
                email.setCustomValidity('');
                isValid = true;
            } else {
                email.setCustomValidity('You have entered an invalid format');
                isValid = false;
            }
        } else {
            email.setCustomValidity('You have entered an invalid format');
            isValid = false;
        }
        email.reportValidity();
        return isValid;
    },
    checkDelegateDuplicate: function (component, event, helper, email, firstName, lastName) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        communityService.executeAction(
            component,
            'checkDuplicateDelegate',
            {
                email: email,
                firstName: firstName,
                lastName: lastName
            },
            function (returnValue) {
                component.set('v.delegateDuplicateInfo', returnValue);
                if (
                    returnValue.isDuplicateDelegate ||
                    returnValue.contactId ||
                    returnValue.participantId
                ) {
                    component.set('v.useThisDelegate', true);
                    component.set('v.useThisDelegate', false);
                     component.set('v.isNewPrimaryDelegate', false);
                } else {
                    component.set('v.useThisDelegate', true); 
                    if(!component.get('v.isNewPrimaryDelegate')){
                         component.set('v.isNewPrimaryDelegate', true);
                        component.set('v.delegateParticipant.Birth_Year__c','');
                    component.set('v.attestAge', false);
                    }
                }
                var participantDelegate = component.get('v.delegateParticipant');
                if (returnValue.email) {
                    participantDelegate.Email__c = returnValue.email;
                    component.set('v.emailInstance', returnValue.email.toLowerCase());
                } else component.set('v.emailInstance', null);
                if (returnValue.lastName) participantDelegate.Last_Name__c = returnValue.lastName;
                if (returnValue.firstName)
                    participantDelegate.First_Name__c = returnValue.firstName;
                helper.checkFields(component, event, helper, true);
                component.set('v.delegateParticipant', participantDelegate);
                spinner.hide();
            }
        );
    },

    checkParticipantNeedsGuardian: function (component, event, helper) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        var participant = component.get('v.participant');
        console.log('checkParticipantNeedsGuardian');
        console.log(JSON.stringify(participant));
        communityService.executeAction(
            component,
            'checkNeedsGuardian',
            {
                participantJSON: JSON.stringify(participant)
            },
            function (returnValue) {
                var isNeedGuardian = returnValue == 'true';

                if (isNeedGuardian != component.get('v.needsGuardian')) {
                    component.set('v.needsGuardian', isNeedGuardian);
                    component.set('v.participant.Health_care_proxy_is_needed__c', isNeedGuardian);
                    component.set('v.participant.Adult__c', !isNeedGuardian);
                }
                //REF-3070
                if (isNeedGuardian) {
                   		component.set('v.needsGuardian', true);
                        component.set('v.enableGuardian', true);
                    	component.set('v.participant.Email__c', ''); 
                    	component.set('v.emailRepeat', '');
                    	component.set('v.participant.Phone__c', '');
                    	component.set('v.participant.Phone_Type__c', '');
                        helper.setDelegate(component);
                }else{
                    component.set('v.enableGuardian', false);
                    component.set('v.needsGuardian', false);
                }     
                helper.checkFields(component, event, helper, true);
            } ,         
            null,
            function () {
                spinner.hide();
            }
        );
    },
	
    //added by sumit
    checkGuardianAge: function (component, event, helper) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        var participant = component.get('v.participant');
        var delegateParticipant = component.get('v.delegateParticipant');
        if(delegateParticipant.Birth_Year__c == ''){
        	component.set('v.yobBlankErrMsg', true);
            component.set('v.delNotAdultErrMsg', false);
            component.set('v.attestAge', false);
           component.set('v.isAdultDel', false);
            var attestCheckbox = component.find('checkBoxAttestation');
            attestCheckbox.setCustomValidity('');
            attestCheckbox.reportValidity('');
            spinner.hide();
        }else{
            component.set('v.yobBlankErrMsg', false);
            communityService.executeAction(
                component,
                'checkDelegateAge',
                {
                    participantJSON: JSON.stringify(participant),
                    delegateParticipantJSON: JSON.stringify(delegateParticipant)
                },
                function (returnValue) {
                    var isAdultDelegate = returnValue == 'true';
                    if(isAdultDelegate){
                        component.set('v.isAdultDel', true);
                        component.set('v.delNotAdultErrMsg', false);
                    }else{
                        component.set('v.isAdultDel', false);
                        component.set('v.attestAge', false);
                        component.set('v.delNotAdultErrMsg' , true);
                         var attestCheckbox = component.find('checkBoxAttestation');
                        attestCheckbox.setCustomValidity('');
                        attestCheckbox.reportValidity('');
                    }
                    
                    helper.checkFields(component, event, helper, true);
                } ,         
                null,
                function () {
                    spinner.hide();
                }
            );
        } 
        helper.checkFields(component, event, helper, true);
    },
    
    checkSites: function (component) {
        var studySites = component.get('v.studySites');
        if (studySites.length > 0) {
            component.set('v.currentState', 'Screening');
        } else {
            component.set('v.currentState', 'No Active Sites');
        }
    },

    fillMarkers: function (component) {
        var markers = [];
        var descriptionLink = '';
        var studySiteMarkers = component.get('v.studySiteMarkers');
        for (var i = 0, j = studySiteMarkers.length; i < j; i++) {
            var mark = studySiteMarkers[i];
            if (
                !mark.ssAccount.BillingCity ||
                !mark.ssAccount.BillingStreet ||
                mark.siteType == 'Virtual'
            ) {
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
                title: i + 1 + '. ' + mark.name,
                description: descriptionLink
            });
        }
        return markers;
    }
});