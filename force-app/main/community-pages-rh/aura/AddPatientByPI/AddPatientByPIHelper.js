/**
 * Created by Leonid Bartenev
 */
({
    initData: function (component) {
        var ss = component.get('v.ss');
        component.set('v.participant', {
            sobjectType: 'Participant__c',
            Mailing_Country_Code__c: 'US',
            Mailing_State_Code__c: ss.Principal_Investigator__r.Account.BillingStateCode
        });
        let formData = component.get('v.formData');
        let pe = {
            sobjectType: 'Participant_Enrollment__c',
            Study_Site__c: ss.Id
        }
        if(formData.visitPlansLVList && formData.visitPlansLVList.length === 1){
            pe.Visit_Plan__c = formData.visitPlansLVList[0].value;
        }
        component.set('v.pe', pe);
        component.set('v.isValid', false);
        component.set('v.isDelegateValid', false);
        component.set('v.needsGuardian', false);
        component.find('checkbox-delegate').getElement().checked = false;
    },

    createParticipant: function (component, callback) {
        component.find('spinner').show();
        var pe = component.get('v.pe');
        var participant = component.get('v.participant');
        var userLanguage = component.get('v.userLanguage');
        var ssId = communityService.getUrlParameter('ssId');
        communityService.executeAction(component, 'saveParticipant', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe),
            userLanguage: userLanguage,
            ssId: (ssId ? ssId : component.get('v.ss').Id),
            createUser: component.get('v.createUsers'),
            participantDelegateJSON: JSON.stringify(component.get('v.participantDelegate'))
        }, function (createdPE) {
            communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
            callback();
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    setDelegate: function (component) {
        var delegateParticipant = {
            sobjectType: 'Participant__c',
        };
        component.set('v.participantDelegate', delegateParticipant);
        component.set('v.emailDelegateRepeat', '');
    },

    checkFields: function (component) {
        let participant = component.get('v.participant');
        let needsDelegate = component.get('v.needsGuardian');

        //Guardian (Participant delegate)
        let delegateParticipant = component.get('v.participantDelegate');
        let emailDelegateRepeat = component.get('v.emailDelegateRepeat');
        let emailDelegateCmp = component.find('emailDelegateField');
        let emailDelegateRepeatCmp = component.find('emailDelegateRepeatField');
        let emailDelegateVaild = needsDelegate && emailDelegateCmp && emailDelegateCmp.get('v.validity') && emailDelegateCmp.get('v.validity').valid;
        let emailDelegateRepeatValid = needsDelegate && emailDelegateRepeatCmp && emailDelegateRepeatCmp.get('v.validity') && emailDelegateRepeatCmp.get('v.validity').valid;

        let isValid = false;
        isValid = isValid || (!needsDelegate ||
                    (needsDelegate && delegateParticipant &&
                        participant.Health_care_proxy_is_needed__c &&
                        delegateParticipant.First_Name__c &&
                        delegateParticipant.Last_Name__c &&
                        delegateParticipant.Phone__c &&
                        delegateParticipant.Email__c &&
                        emailDelegateVaild &&
                        emailDelegateRepeatValid));

        if (needsDelegate && delegateParticipant && emailDelegateCmp && emailDelegateRepeatCmp) {
            if (delegateParticipant.Email__c && emailDelegateRepeat && delegateParticipant.Email__c.toLowerCase() !== emailDelegateRepeat.toLowerCase()) {
                isValid = false;
                emailDelegateCmp.setCustomValidity($A.get("$Label.c.PG_Ref_MSG_Email_s_not_equals"));
                emailDelegateRepeatCmp.setCustomValidity($A.get("$Label.c.PG_Ref_MSG_Email_s_not_equals"));
            } else {
                emailDelegateCmp.setCustomValidity("");
                emailDelegateRepeatCmp.setCustomValidity("");
            }
            if (delegateParticipant.Email__c && delegateParticipant.Email__c !== '' && emailDelegateRepeat && emailDelegateRepeat !== '') {
                emailDelegateCmp.reportValidity();
                emailDelegateRepeatCmp.reportValidity();
            }
        }

        console.log('Delegate VALID: ' + isValid);
        component.set('v.isDelegateValid', isValid);
    },

    checkParticipantNeedsGuardian: function (component, helper) {
        var spinner = component.find('spinner');
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

            if (isNeedGuardian != component.get('v.needsGuardian')) {
                component.set('v.needsGuardian', isNeedGuardian);
                component.set('v.participant.Health_care_proxy_is_needed__c', isNeedGuardian);
                component.set('v.participant.Adult__c', !isNeedGuardian);

                component.find('checkbox-delegate').getElement().checked = isNeedGuardian;

                if (isNeedGuardian) {
                    helper.setDelegate(component);
                }
            }
        }, null, function () {
            spinner.hide();
        });
    }

})