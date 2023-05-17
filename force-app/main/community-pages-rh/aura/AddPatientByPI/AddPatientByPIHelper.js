/**
 * Created by Leonid Bartenev
 */
 ({
    initData: function (component) {
        var ss = component.get('v.ss');
        component.set('v.participant', {
            sobjectType: 'Participant__c',
            Mailing_Country_Code__c: 'US',
            Mailing_State_Code__c: ss.Principal_Investigator__r.Account.BillingStateCode,
            Site__c: ss.Site__c
        });
        let formData = component.get('v.formData');
        let pe = {
            sobjectType: 'Participant_Enrollment__c',
            Study_Site__c: ss.Id
        };
        if (formData.visitPlansLVList && formData.visitPlansLVList.length === 1) {
            pe.Visit_Plan__c = formData.visitPlansLVList[0].value;
        }
        component.set('v.pe', pe);
        component.set('v.isValid', false);
        component.set('v.isDelegateValid', false);
        component.set('v.needsGuardian', false);         
        component.set('v.delNotAdultErrMsg',false);
        component.set('v.yobBlankErrMsg',false);
        component.set('v.emailInstance', '');
        if (component.find('checkbox-delegate')) {
            component.find('checkbox-delegate').getElement().checked = false;
        }
        if (component.find('checkbox-doContact')) {
            component.find('checkbox-doContact').getElement().checked = true;
        }
    },

    createParticipant: function (component, callback) {
        component.find('spinner').show();
        var pe = component.get('v.pe');
        var participant = component.get('v.participant');
        var userLanguage = component.get('v.userLanguage');
        console.log(
            "component.get('v.delegateDuplicateInfo')>>>>>>",
            component.get('v.delegateDuplicateInfo')
        );
        var ssId = communityService.getUrlParameter('ssId');
        var isDelegate = component.get('v.createUserForDelegate');
        if(!component.get('v.needsGuardian')) {
            component.set('v.participantDelegate',null);
            component.set('v.delegateDuplicateInfo',null);
        }
        communityService.executeAction(
            component,
            'saveParticipant',
            {
                participantJSON: JSON.stringify(participant),
                peJSON: JSON.stringify(pe),
                userLanguage: userLanguage,
                ssId: ssId ? ssId : component.get('v.ss').Id,
                createUser: component.get('v.createUsers') && component.get('v.communityWithPPInv'),
                participantDelegateJSON: JSON.stringify(component.get('v.participantDelegate')),
                delegateDuplicateInfo: JSON.stringify(component.get('v.delegateDuplicateInfo')),
                allowEmail: component.get('v.isEmail'),
                allowPhone: component.get('v.isPhone'),
                allowSMS: component.get('v.isSMS'),
                allowContact: component.get('v.doContact'),
                allowDelegateContact: isDelegate,
                contactConsentJSON: JSON.stringify(component.get('v.contactConsent')),
                iqviaOutreachEnabled: component.get('v.ctp').IQVIA_Outreach__c,
            },
            function (createdPE) {
                communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
                callback();
                component.set('v.doContact', false);
                if (!component.get('v.doContact')) {
                    component.set('v.createUsers', false);
                }
                component.find('consent-Manager').reInitialize();
                component.set('v.attestAge', false);
            },
            null,
            function () {
                component.find('spinner').hide();
            }
        );
    },
    createParticipants: function (component) {
        component.find('spinner').show();
        var pe = component.get('v.pe');
        var participant = component.get('v.participant');
        var userLanguage = component.get('v.userLanguage');
        console.log(
            "component.get('v.delegateDuplicateInfo')>>>>>>",
            component.get('v.delegateDuplicateInfo')
        );
        var ssId = communityService.getUrlParameter('ssId');
        var isDelegate = component.get('v.createUserForDelegate');
        if(!component.get('v.needsGuardian')) {
            component.set('v.participantDelegate',null);
            component.set('v.delegateDuplicateInfo',null);
        }
        var action1 = component.get("c.saveParticipants");
        action1.setParams({
                participantJSON: JSON.stringify(participant),
                peJSON: JSON.stringify(pe),
                userLanguage: userLanguage,
                ssId: ssId ? ssId : component.get('v.ss').Id,
                createUser: component.get('v.createUsers') && component.get('v.communityWithPPInv'),
                participantDelegateJSON: JSON.stringify(component.get('v.participantDelegate')),
                delegateDuplicateInfo: JSON.stringify(component.get('v.delegateDuplicateInfo')),
                allowEmail: component.get('v.isEmail'),
                allowPhone: component.get('v.isPhone'),
                allowSMS: component.get('v.isSMS'),
                allowContact: component.get('v.doContact'),
                allowDelegateContact: isDelegate,
                contactConsentJSON: JSON.stringify(component.get('v.contactConsent')),
                iqviaOutreachEnabled: component.get('v.ctp').IQVIA_Outreach__c
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") { 
                console.log('server 1 call end');console.log('response-->'+response.getReturnValue());  
                var partid = response.getReturnValue() ;
                component.set('v.partID',partid[0]);
                component.set('v.dupPart',partid[1]);
                this.createPER(component);
            }else{
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                // log the error passed in to AuraHandledException
                                console.log("Error message: " + 
                                            errors[0].message);
                               communityService.showErrorToast('', errors[0].message); 
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
        });
        $A.enqueueAction(action1);
       
    }, 
    createPER: function (component) { 
        var pe = component.get('v.pe');
        var dupPart = component.get('v.dupPart');
        var participant = component.get('v.participant');
        var userLanguage = component.get('v.userLanguage');
        console.log(
            "component.get('v.delegateDuplicateInfo')>>>>>>",
            component.get('v.delegateDuplicateInfo')
        );
        var ssId = communityService.getUrlParameter('ssId');
        var isDelegate = component.get('v.createUserForDelegate');
        if(!component.get('v.needsGuardian')) {
            component.set('v.participantDelegate',null);
            component.set('v.delegateDuplicateInfo',null);
        }
        var sendToSH = false;
        if(component.get('v.ctp').Promote_to_SH__c == true && 
            component.get('v.ctp').DCT_Platform__c == 'Study Hub' &&
            component.get('v.ctp').Initial_Visit_Required__c == false){
                sendToSH = true;
        }
                var action2 = component.get("c.savePER");
                action2.setParams({
                        participantJSON: JSON.stringify(participant),
                        peJSON: JSON.stringify(pe),
                        ssId: ssId ? ssId : component.get('v.ss').Id,
                        createUser: component.get('v.createUsers') && component.get('v.communityWithPPInv'),
                        participantDelegateJSON: JSON.stringify(component.get('v.participantDelegate')),
                        delegateDuplicateInfo: JSON.stringify(component.get('v.delegateDuplicateInfo')),
                        allowDelegateContact: isDelegate,
                        contactConsentJSON: JSON.stringify(component.get('v.contactConsent')),
                        iqviaOutreachEnabled: component.get('v.ctp').IQVIA_Outreach__c,
                        partId:component.get('v.partID'),
                        allowEmail: component.get('v.isEmail'),
                        allowPhone: component.get('v.isPhone'),
                        allowSMS: component.get('v.isSMS'), 
                        allowContact: component.get('v.doContact'),
                        sendToSH : sendToSH,
                        ssType : component.get('v.ss').Study_Site_Type__c
                        });
                action2.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") { 
                        if(dupPart!='no duplicate'){
                            var action3 = component.get("c.updateParticipant");
                            action3.setParams({
                                participantJSON : dupPart
                            });
                            action3.setCallback(this, function(response){
                            });
                            $A.enqueueAction(action3);
                        }
                        communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
                        //callback();
                        component.set('v.doContact', false);
                        if (!component.get('v.doContact')) {
                            component.set('v.createUsers', false);
                        }
                        component.find('consent-Manager').reInitialize();
                        component.set('v.attestAge', false);
                        this.doSaveAndExitHelper(component);
                        component.find('spinner').hide();
                    }else{
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                // log the error passed in to AuraHandledException
                                console.log("Error message1: " + 
                                            errors[0].message);
                                if(errors[0].message.includes('DUPLICATE_VALUE')){ 
                                    console.log('DUPLICATEDUPLICATE');
                                     communityService.showErrorToast('', $A.get('$Label.c.Error_Message_Participant_Duplicate'));
                                }else{
                                   communityService.showErrorToast('',  errors[0].message);
                                } 
                                component.find('spinner').hide();   
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action2);
    },
    doSaveAndExitHelper: function (component) {
        if(component.get('v.doSaveNew')){
           var mainDiv =  document.getElementsByClassName("fieldsDiv");
           mainDiv[0].focus();
           this.initData(component);
           this.setDelegate(component);
           component.find('editForm').refreshEmailInput(); 
           component.find('editForm').refreshPartDobInput(); 
        }else{
           console.clear(); 
           var urlEvent = $A.get("e.force:navigateToURL");
           urlEvent.setParams({ "url": "/my-referrals" });  
           urlEvent.fire(); 
        } 
    },
    setDelegate: function (component) {
        var ss = component.get('v.ss');
        var delegateParticipant = {
            sobjectType: 'Participant__c',
            Site__c: ss.Site__c
        };
        component.set('v.participantDelegate', delegateParticipant);
        component.set('v.emailDelegateRepeat', '');
        component.set('v.isDelegateValid', false);
        component.set('v.isValid', false);
    },

    checkFields: function (component, event, helper, doNotCheckFields) {
        let participant = component.get('v.participant');
        let needsDelegate = component.get('v.needsGuardian');
        
        let isAdultDel = component.get('v.isAdultDel');
        let attestAge = component.get('v.attestAge');
        let isNewPrimaryDelegate =  component.get('v.isNewPrimaryDelegate');

        //Guardian (Participant delegate)
        let delegateParticipant = component.get('v.participantDelegate');
        let emailDelegateRepeat = component.get('v.emailDelegateRepeat');
        let emailDelegateCmp = component.find('emailDelegateField');
        let emailDelegateRepeatCmp = component.find('emailDelegateRepeatField');
        let emailDelegateVaild =
            needsDelegate &&
            emailDelegateCmp &&
            delegateParticipant.Email__c &&
            helper.checkValidEmail(emailDelegateCmp, delegateParticipant.Email__c);
        let emailDelegateRepeatValid =
            needsDelegate &&
            emailDelegateRepeatCmp &&
            emailDelegateRepeat &&
            helper.checkValidEmail(emailDelegateRepeatCmp, emailDelegateRepeat);
        let emailValidCheck =
            needsDelegate &&
            emailDelegateCmp &&
            delegateParticipant.Email__c &&
            helper.checkValidEmail(emailDelegateCmp, delegateParticipant.Email__c);

        let isValid = false;
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
        isValid =
            isValid ||
            !needsDelegate ||
            (needsDelegate &&
                delegateParticipant &&
                participant.Health_care_proxy_is_needed__c &&
                delegateParticipant.First_Name__c &&
                delegateParticipant.Last_Name__c &&
                delegateParticipant.Phone__c &&
                delegateParticipant.Email__c);

        let isEmailValid = emailDelegateVaild && emailDelegateRepeatValid;
        if (emailValidCheck)
            if (
                needsDelegate &&
                delegateParticipant &&
                emailDelegateCmp &&
                emailDelegateRepeatCmp
            ) {
                if (
                    (delegateParticipant.Email__c && !emailDelegateRepeat) ||
                    (!delegateParticipant.Email__c && emailDelegateRepeat) ||
                    (delegateParticipant.Email__c &&
                        emailDelegateRepeat &&
                        delegateParticipant.Email__c.toLowerCase() !==
                            emailDelegateRepeat.toLowerCase())
                ) {
                    isEmailValid = false;
                    emailDelegateCmp.setCustomValidity(
                        $A.get('$Label.c.PG_Ref_MSG_Email_s_not_equals')
                    );
                    emailDelegateRepeatCmp.setCustomValidity(
                        $A.get('$Label.c.PG_Ref_MSG_Email_s_not_equals')
                    );
                } else {
                    isEmailValid = true;
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
                if (emailDelegateCmp && !emailDelegateCmp.get('v.validity').valid) {
                    isEmailValid = false;
                }
            }

        isValid = isValid && isEmailValid;
        if(isNewPrimaryDelegate)
        {
            if(!(isAdultDel && attestAge))
                isValid = false;
            
        }
        console.log('Delegate VALID: ' + isValid);
        component.set('v.isDelegateValid', isValid);
        let editForm = component.find('editForm');
        editForm.checkFields();
    },

    checkValidEmail: function (email, emailValue) {
      //  debugger;
        var isValid = false;
        var regexp = $A.get('$Label.c.RH_Email_Validation_Pattern');
        var regexpInvalid = new RegExp($A.get('$Label.c.RH_Email_Invalid_Characters'));
        var invalidCheck = regexpInvalid.test(emailValue);
        if (invalidCheck == false) {
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

    checkParticipantNeedsGuardian: function (component, helper, event) {
        var spinner = component.find('spinner');
        spinner.show();
        var participant = component.get('v.participant');
        var params = event.getParam('arguments');
        component.set('v.callback', params.callback);
        var callback = component.get('v.callback');
        console.log('checkParticipantNeedsGuardian');
        console.log(JSON.stringify(participant));
        
        communityService.executeAction(
            component,
            'checkNeedsGuardian',
            {
                participantJSON: JSON.stringify(participant)
            },
            function (returnValue) {
                console.log('isNeedGuardian: ' + returnValue);
                var isNeedGuardian = returnValue == 'true';
                if (callback) {
                    callback(!isNeedGuardian);
                }
                console.log('checkNeedsGuardian - SUCCESS: ' + isNeedGuardian);

                component.set('v.participant.Adult__c', !isNeedGuardian);
                component.set('v.participant.Health_care_proxy_is_needed__c', isNeedGuardian);
                    component.set('v.needsGuardian', isNeedGuardian);
                    if(!isNeedGuardian){            
                        component.set('v.delNotAdultErrMsg',false);
                        component.set('v.yobBlankErrMsg',false);
                    }
                    let editForm = component.find('editForm');
                    editForm.checkFields();

                    if (component.find('checkbox-delegate')) {
                        component.find('checkbox-delegate').getElement().checked = isNeedGuardian;
                    }

                    if (isNeedGuardian) {
                        component.find('checkbox-delegate').getElement().disabled = true; //REF-3070
                        helper.setDelegate(component);
                    }
                    else{
                        component.find('checkbox-delegate').getElement().disabled = false; //REF-3070
                    }
            },
            null,
            function () {
                spinner.hide();
            }
        );
    },

    checkGuardianAge: function (component, event, helper) {
        var spinner = component.find('spinner');
        spinner.show();
        if(component.get('v.attestAge'))
        {
            var attestCheckbox = component.find('checkBoxAttestation');
            attestCheckbox.setCustomValidity('');
            attestCheckbox.reportValidity('');
        }
        var participant = component.get('v.participant');
        var delegateParticipant = component.get('v.participantDelegate');
        if(delegateParticipant.Birth_Year__c == '' || delegateParticipant.Birth_Year__c == null){
        	component.set('v.yobBlankErrMsg', true);
            component.set('v.delNotAdultErrMsg', false);
            component.set('v.attestAge', false);
             component.set('v.isAdultDel', false);
            var attestCheckbox = component.find('checkBoxAttestation');
            attestCheckbox.setCustomValidity('');
            attestCheckbox.reportValidity('');
            var selectYr = component.find("yearField").find("selectList");
            $A.util.addClass(selectYr, "rr-select-error");
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
                        var selectYr = component.find("yearField").find("selectList");
                        $A.util.removeClass(selectYr, "rr-select-error");
                    }else{
                        component.set('v.isAdultDel', false); 
                        component.set('v.attestAge', false);
                        component.set('v.delNotAdultErrMsg', true);
                        var attestCheckbox = component.find('checkBoxAttestation');
                        attestCheckbox.setCustomValidity('');
                        attestCheckbox.reportValidity('');
                        var selectYr = component.find("yearField").find("selectList");
                        $A.util.addClass(selectYr, "rr-select-error");
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
    
    checkDelegateDuplicate: function (component, event, helper, email, firstName, lastName) {
        var spinner = component.find('spinner');
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
                } else{
                    component.set('v.useThisDelegate', true);
                    component.set('v.isNewPrimaryDelegate', true);
                    component.set('v.participantDelegate.Birth_Year__c','');
                    component.set('v.attestAge', false);
                    
                }
                var participantDelegate = component.get('v.participantDelegate');
                if (returnValue.email) {
                    component.set('v.emailInstance', returnValue.email.toLowerCase());
                    participantDelegate.Email__c = returnValue.email;
                    component.set('v.emailDelegateRepeat',returnValue.email.toLowerCase());
                } else {
                    component.set('v.emailInstance', '');
                }
                if (returnValue.lastName) participantDelegate.Last_Name__c = returnValue.lastName;
                if (returnValue.firstName)
                    participantDelegate.First_Name__c = returnValue.firstName;
                if(returnValue.DelegateYOB)
                    participantDelegate.Birth_Year__c = returnValue.DelegateYOB;

                component.set('v.participantDelegate', participantDelegate);
                helper.checkFields(component, event, helper, true);
                component.set('v.delegateEmailWasChanged', false);
                spinner.hide();
            }
        );
    },
    checkCommunity: function (component, event, helper) {
        component.set(
            'v.communityWithPPInv',
            communityService.getCurrentCommunityTemplateName() !=
                $A.get('$Label.c.Janssen_Community_Template_Name')
        );
    }
});