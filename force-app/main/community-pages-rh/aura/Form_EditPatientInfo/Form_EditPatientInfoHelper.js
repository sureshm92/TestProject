({

    
    checkExistingValidDelegateEmail: function(component, event,DelegateEmail,DelegateEmailValue
                                             ,participantDelegateOld){
        var isValidData = '';
        var isValidEmail = '';
        isValidEmail = this.checkValidEmail(DelegateEmail,DelegateEmailValue);
        if(isValidEmail)
        {
            var PER = JSON.parse(JSON.stringify(component.get('v.pe')));
            console.log('>>>participantid>>'+PER.Participant__c);
            communityService.executeAction(
                component,
                'checkExisitingParticipant',
                {
                    strFirstName:participantDelegateOld.First_Name__c.trim(),
                    strLastName:participantDelegateOld.Last_Name__c.trim(),
                    strDelegateEmail: DelegateEmailValue.trim(),
                    participantId : PER.Participant__c  
                },
                
                function (returnValue) {
                    console.log('>>retunrParticiapnt>>'+JSON.stringify(returnValue));
                    if(returnValue){
                        
                        component.set('v.participantDelegate.First_Name__c',returnValue.firstName);
                        component.set('v.participantDelegate.Last_Name__c',returnValue.lastName);
                        component.set('v.participantDelegate.Email__c',returnValue.email);
                        component.set('v.participantDelegate.Phone__c',returnValue.participantPhoneNumber);
                        component.set('v.participantDelegateUseExisiting',returnValue.DelegateParticipant);
                    
                        var DelegatePhoneField = component.find('DelegatePhoneName');
                        DelegatePhoneField.setCustomValidity('');
                        DelegatePhoneField.reportValidity();
                      	component.set('v.recordFound',false); //we are using change handle in DulicateDelegateMessageComponent so for update the message we are marking as false and true
                        component.set('v.duplicateDelegateInfo',returnValue);
                        component.set('v.isEmailConfrmBtnClick',false);
                        component.set('v.recordFound',true);
                        component.set('v.useThisDelegate', false);
                         
                    }
                    else if(!$A.util.isEmpty(participantDelegateOld.Id)){
                        component.set('v.participantDelegate.Id',participantDelegateOld.Id);
                        component.set('v.participantDelegate.Contact__c',participantDelegateOld.Contact__c);
                        component.set('v.isEmailConfrmBtnClick',false);
                        component.set('v.recordFound',false);
                        component.set('v.useThisDelegate', false);
                    }
                    else{
                        component.set('v.participantDelegate.Id',null);
                        component.set('v.useThisDelegate', true);
                        component.set('v.isEmailConfrmBtnClick',true);
                    }
                    console.log('>>final participant>>>'+JSON.stringify(component.get('v.participantDelegate')));
                }
            );
        }
        return isValidEmail;
    },
    
    
    
    checkValidEmail: function (email, emailValue) {
       // debugger;
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
                    email.setCustomValidity('You have entered an invalid format');
                    isValid = false;
                }
            } else {
                email.setCustomValidity('You have entered an invalid format');
                isValid = false;
            }
            email.reportValidity();
        }

        return isValid;
    }
});