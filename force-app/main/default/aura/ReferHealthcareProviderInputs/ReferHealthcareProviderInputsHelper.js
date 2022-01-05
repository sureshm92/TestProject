/**
 * Created by Nikita Abrazhevitch on 10-Apr-20.
 */

 ({
    showHideProvider: function (component) {
        var parent = component.get('v.parent');
        var showProvider = parent.get('v.showReferringProvider');
        var pe = component.get('v.pe');
        communityService.executeAction(component, 'showOrHideProvider', { peId: pe.Id }, function (
            returnValue
        ) {
            if (showProvider) {
                parent.set('v.showReferringProvider', false);
            } else {
                parent.set('v.showReferringProvider', true);
            }
            parent.find('spinner').hide();
        });
    },

    doConnect: function (component, event, helper) {
        var sharingObject = component.get('v.sharingObject');
        var pe = component.get('v.pe');
        var parent = component.get('v.parent');
        console.log('>>>pe>>'+JSON.stringify(pe));
        if (sharingObject.sObjectType == 'Contact') {
            helper.showHideProvider(component);
        } else if (sharingObject.sObjectType == 'Healthcare_Provider__c') {
            console.log('HCPERROR', JSON.stringify(sharingObject));
            communityService.executeAction(
                component,
                'inviteHP',
                {
                    peId: pe.Id,
                    hp: JSON.stringify(sharingObject),
                    ddInfo: JSON.stringify(component.get('v.duplicateDelegateInfo'))
                },
                function (returnValue) {
                    var mainComponent = component.get('v.mainComponent');
                    mainComponent.refresh();
                    //mainComponent.set('v.healthCareProviders', returnValue);
                    parent.find('spinner').hide();
                }
            );
        } else {
            var isDelegateInvited = false;
            if (
                pe.Study_Site__r != undefined &&
                pe.Study_Site__r != null &&
                pe.Study_Site__r.Study_Site_Type__c != 'Virtual' &&
                pe.Study_Site__r.Study_Site_Type__c != 'Hybrid' &&
                pe.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c ==
                    false &&
                pe.Study_Site__r.Suppress_Participant_Emails__c == false &&                
                pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c != 'Janssen' && //RH-5163
                pe.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c == true
            ) {
                isDelegateInvited = true;
            }
            console.log('>>isDelegateInvited>>'+isDelegateInvited);
            communityService.executeAction(
                component,
                'invitePatientDelegate',
                {
                    participant: JSON.stringify(pe.Participant__r),
                    delegateContact: JSON.stringify(sharingObject),
                    delegateId: sharingObject.delegateId ? sharingObject.delegateId : null,
                    ddInfo: JSON.stringify(component.get('v.duplicateDelegateInfo')),
                    createUser: isDelegateInvited,
                    YearOfBirth : sharingObject.Birth_Year__c != '' ? sharingObject.Birth_Year__c : ''
                },
                function (returnValue) {
                    var mainComponent = component.get('v.mainComponent');
                    mainComponent.refresh();
                    parent.find('spinner').hide();
                }
            );
        }
    },

    doDisconnect: function (component, event, helper) {
        var mainComponent = component.get('v.mainComponent');
        var parentComponent = component.get('v.parent');
        var sharingObject = component.get('v.sharingObject');
        var params;
        if (sharingObject.sObjectType == 'Healthcare_Provider__c') {
            params = { hpId: sharingObject.Id, delegateId: null };
        } else {
            params = { hpId: null, delegateId: sharingObject.delegateId };
        }
        communityService.executeAction(component, 'stopSharing', params, function (returnValue) {
            mainComponent.refresh();
        });
    },

    checkValidEmail: function (email, emailValue) {
        var isValid = false;
        if (email && emailValue) {
            var regexp = $A.get('$Label.c.RH_Email_Validation_Pattern');
            var regexpInvalid = new RegExp($A.get('$Label.c.RH_Email_Invalid_Characters'));
            var invalidCheck = regexpInvalid.test(emailValue);
            if (invalidCheck == false) {
                email.setCustomValidity('');
                if (emailValue.match(regexp)) {
                    email.setCustomValidity('');
                    isValid = true;
                } else {
                    email.setCustomValidity($A.get('$Label.c.RH_Email_Invalid_Error'));
                    isValid = false;
                }
            } else {
                email.setCustomValidity($A.get('$Label.c.RH_Email_Invalid_Error'));
                isValid = false;
            }
            email.reportValidity();
        }

        return isValid;
    },

    doCheckContact: function (component, event, helper, firstName, lastName, email) {
        var sharingObject = component.get('v.sharingObject');
        var parent = component.get('v.parent');
        parent.find('spinner').show();
        var pe = component.get('v.pe');
        console.log('pe.Id>>>', pe.Id);
        console.log('firstName>>>', firstName);
        console.log('email>>>', email);
        console.log('lastName>>>', lastName);
        communityService.executeAction(
            component,
            'checkDuplicate',
            {
                peId: pe.Id,
                email: email,
                firstName: firstName,
                lastName: lastName,
                participantId: null
            },
            function (returnValue) { 
                if (returnValue.firstName) {
                    if (sharingObject.sObjectType == 'Object') {
                        if (
                            returnValue.isDuplicateDelegate ||
                            returnValue.contactId ||
                            returnValue.participantId
                        ) {
                            component.set('v.useThisDelegate', true);
                            component.set('v.useThisDelegate', false);
                            component.set('v.isFirstPrimaryDelegate',false);
                        } else component.set('v.useThisDelegate', true);
                        component.set('v.duplicateDelegateInfo', returnValue);
                        component.set('v.sharingObject.email', email);
                        component.set('v.sharingObject.firstName', returnValue.firstName);
                        component.find('firstNameInput').focus();
                        component.set('v.sharingObject.lastName', returnValue.lastName);
                        component.find('lastNameInput').focus();
                        component.set('v.isFirstPrimaryDelegate',false);
                    } else if (sharingObject.sObjectType == 'Contact') {
                        component.set('v.sharingObject.Email', email);
                        component.set('v.sharingObject.FirstName', returnValue.firstName);
                        component.find('firstNameInput').focus();
                        component.set('v.sharingObject.LastName', returnValue.lastName);
                        component.find('lastNameInput').focus();
                        component.set('v.isFirstPrimaryDelegate',false);
                    } else {
                        component.set('v.sharingObject.Email__c', email);
                        component.set('v.sharingObject.First_Name__c', returnValue.firstName);
                        component.find('firstNameInput').focus();
                        component.set('v.sharingObject.Last_Name__c', returnValue.lastName);
                        component.find('lastNameInput').focus();
                        component.set('v.isFirstPrimaryDelegate',false);
                    }
                    component.set('v.providerFound', true);
                    component.set('v.isDuplicate', returnValue.isDuplicate);
                    component.set('v.isDuplicateDelegate', returnValue.isDuplicateDelegate);
                    component.set('v.isFirstPrimaryDelegate',false);

                    if (returnValue.firstName && returnValue.lastName) {
                        component.set('v.isValid', true);
                    }
                    parent.find('spinner').hide();
                } else {
                    component.set('v.isDuplicate', returnValue.isDuplicate);
                    component.set('v.isDuplicateDelegate', returnValue.isDuplicateDelegate);
                    component.set('v.useThisDelegate', true);
                    component.set('v.isFirstPrimaryDelegate',true);
                    component.set('v.isAdultDel', false); 
                    parent.find('spinner').hide();
                }
                 console.log('>>Finalv.useThisDelegate>>'+component.get('v.useThisDelegate'));
            }
        );
    },
    
    checkGuradianAge : function(component,event,helper){
        
        var parent = component.get('v.parent');
        parent.find('spinner').show();
        var SharingObject = component.get('v.sharingObject');
         var pe = component.get('v.pe');
        if(SharingObject.Birth_Year__c == ''){
        	component.set('v.yobBlankErrMsg', true);
            component.set('v.delNotAdultErrMsg', false);
            component.set('v.attestAge', false);
            component.set('v.isAdultDel', false);
            parent.find('spinner').hide();
        }
        else{
        communityService.executeAction(
                component,
                'checkDelegateAge',
                {
                     participantJSON: JSON.stringify(pe.Participant__r),
                    delegateParticipantJSON: JSON.stringify(SharingObject)
                },
                function (returnValue) {
                   console.log('>>>returnValue>>'+returnValue);
                    var isAdultDelegate = returnValue == 'true';
                    if(isAdultDelegate){
                        component.set('v.isAdultDel', true);
                        component.set('v.delNotAdultErrMsg', false);
                        component.set('v.yobBlankErrMsg', false);
                        if(!component.get('v.attestAge'))
                        {
                            component.set('v.isValid',false);
                        }
                    }else{
                         component.set('v.isAdultDel', false); 
                         var attestCheckbox = component.find('AttestCheckbox');
                         attestCheckbox.setCustomValidity('');
                         attestCheckbox.reportValidity(''); 
                        component.set('v.attestAge', false);
                         component.set('v.yobBlankErrMsg', false);
                        component.set('v.delNotAdultErrMsg', true);
                    }
                   parent.find('spinner').hide();
                }
            ); 
    	}
    },

});