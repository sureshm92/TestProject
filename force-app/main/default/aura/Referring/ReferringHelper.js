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
                        var survey = component.get('v.preScreenerSurvey') || {};	
                        var response = component.get('v.preScreenerResponse') || {};	
                        response.PreScreener_Survey__c = survey.Id;	
                        response.Screener_Response__c = e.data.pdfContent;
                        component.set('v.preScreenerResponse',response);
                        window.scrollTo(0, 0);
                    } else {
                        var survey = component.get('v.preScreenerSurvey') || {};	
                        var response = component.get('v.preScreenerResponse') || {};	
                        response.PreScreener_Survey__c = survey.Id;	
                        response.Screener_Response__c = e.data.pdfContent;
                        component.set('v.preScreenerResponse',response);
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
        var response = component.get('v.preScreenerResponse');
        spinner.show();
        let action = component.get("c.setfailedReferral");
        action.setParams({
            peJSON: JSON.stringify(pEnrollment),
            preScreenerResponseJSON: response ? JSON.stringify(response) : '',
            reason: reason 
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
               successCallBack();
               spinner.hide();
            }
            else {
                console.log(action.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
       /**  communityService.executeAction(
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
        );**/
    },
    
    
    setParticipant: function (component, pe, markers) {
        //let patientVeiwRedirection = communityService.getUrlParameter('patientVeiwRedirection');
        let patientVeiwRedirection = component.get('v.patientVeiwRedirection');
        if(patientVeiwRedirection){ 
            var participant = {
                sobjectType: 'Participant__c',
                First_Name__c: pe.Participant_Name__c,
                Last_Name__c: pe.Participant_Surname__c,
                Email__c: pe.Email__c,
                Middle_Name__c:pe.Patient_Middle_Name_Initial__c,
                Gender__c:pe.Patient_Sex__c,
                Phone__c:pe.Phone__c,
                Phone_Type__c:pe.Patient_Phone_Type__c,
                Mailing_Country_Code__c:pe.Mailing_Country_Code__c,
                Mailing_State_Code__c:pe.Mailing_State_Code__c,
                Mailing_Zip_Postal_Code__c:pe.Postal_Code__c,
                
                // Mailing_Country_Code__c: pe.HCP__r.HCP_Contact__r.Account.BillingCountryCode,
                // Mailing_State_Code__c: pe.HCP__r.HCP_Contact__r.Account.BillingStateCode
            };

            if(pe != undefined &&  pe.Mailing_Country_Code__c != undefined && pe.Mailing_Country_Code__c != null   
               && pe.Mailing_Country_Code__c != ''){
                component.set('v.mailingCountryCode',pe.Mailing_Country_Code__c);
            }else if(pe != undefined && pe.Study_Site__c != undefined  && pe.Study_Site__r != undefined 
                && pe.Study_Site__r.Site__r != undefined 
                && pe.Study_Site__r.Site__r.BillingCountryCode != undefined && pe.Study_Site__r.Site__r.BillingCountryCode != null 
                     && pe.Study_Site__r.Site__r.BillingCountryCode != ''){
                component.set('v.mailingCountryCode',pe.Study_Site__r.Site__r.BillingCountryCode);
            }else{
                component.set('v.mailingCountryCode','US');
            }

            component.set('v.emailRepeat',pe.Email__c);
            component.set('v.primaryDelegateFirstname',pe.Primary_Delegate_First_Name__c);
            component.set('v.primaryDelegateLastname',pe.Primary_Delegate_Last_Name__c);
            component.set('v.primaryDelegateEmail',pe.Primary_Delegate_Email__c);
            component.set('v.primaryDelegatePhonenumber',pe.Primary_Delegate_Phone_Number__c);
            component.set('v.primaryDelegatePhonetype',pe.Primary_Delegate_Phone_Type__c);
            component.set('v.primaryDelegateYob',pe.Primary_Delegate_YOB__c);
            component.set('v.emailDelegateRepeat',pe.Primary_Delegate_Email__c);
            component.set('v.isDelegateCertify',pe.Is_Delegate_Certify__c);
            component.set('v.attestAge',pe.Is_Delegate_Certify__c);
            
            component.set('v.birthMonth',pe.Birth_Month__c);
            if(pe.Birth_Month__c != null){
                component.set('v.pmonth',pe.Birth_Month__c);
            }else{
                component.set('v.pmonth',null);
            }
            
            component.set('v.yearofBirth',pe.YOB__c);
            if(pe.YOB__c != null){
                component.set('v.pyear',pe.YOB__c);
            }else{
                component.set('v.pyear',null);
            }
             
          if( (( pe.Mailing_Country_Code__c == 'US' && (pe.Permit_SMS_Text_for_this_study__c || pe.Delegate_Consent__c)) || 
                   pe.Mailing_Country_Code__c != 'US' ) && 
                ( (pe.Permit_Voice_Text_contact_for_this_study__c && 
                 pe.Permit_Mail_Email_contact_for_this_study__c) || pe.Delegate_Consent__c)
              ){
              component.set('v.agreePolicy',true);   
            }

        }else{
            var participant = {
                sobjectType: 'Participant__c',
                First_Name__c: pe.Participant_Name__c,
                Last_Name__c: pe.Participant_Surname__c
                // Mailing_Country_Code__c: pe.HCP__r.HCP_Contact__r.Account.BillingCountryCode,
                // Mailing_State_Code__c: pe.HCP__r.HCP_Contact__r.Account.BillingStateCode
            };

             if(pe != undefined &&  pe.Mailing_Country_Code__c != undefined && pe.Mailing_Country_Code__c != null   
                && pe.Mailing_Country_Code__c != ''){
                 component.set('v.mailingCountryCode',pe.Mailing_Country_Code__c);
             }else if(pe != undefined && pe.Study_Site__c != undefined  && pe.Study_Site__r != undefined 
                 && pe.Study_Site__r.Site__r != undefined 
                 && pe.Study_Site__r.Site__r.BillingCountryCode != undefined && pe.Study_Site__r.Site__r.BillingCountryCode != null 
                      && pe.Study_Site__r.Site__r.BillingCountryCode != ''){
                 component.set('v.mailingCountryCode',pe.Study_Site__r.Site__r.BillingCountryCode);
             }else{
                 component.set('v.mailingCountryCode','US');
             }
             
            if (pe.HCP__r) {
                participant.Mailing_Country_Code__c =
                    pe.HCP__r.HCP_Contact__r.Account.BillingCountryCode;
                participant.Mailing_State_Code__c = pe.HCP__r.HCP_Contact__r.Account.BillingStateCode;
                component.set('v.selectedCountry', participant.Mailing_Country_Code__c);
            }
        }
        
        
        component.set('v.participant', participant);
    },
    
    setDelegate: function (component, helper, participant) {
        //let patientVeiwRedirection = communityService.getUrlParameter('patientVeiwRedirection');
        let patientVeiwRedirection =  component.get('v.patientVeiwRedirection');
        if(patientVeiwRedirection){ 
            if(!component.get('v.delegateValueRemoved')){
                var delegateParticipant = {
                    sobjectType: 'Participant__c',
                    First_Name__c:component.get('v.primaryDelegateFirstname'),
                    Last_Name__c:component.get('v.primaryDelegateLastname'),
                    Email__c:component.get('v.primaryDelegateEmail'),
                    Phone__c:component.get('v.primaryDelegatePhonenumber'),
                    Phone_Type__c:component.get('v.primaryDelegatePhonetype'),
                    Birth_Year__c:component.get('v.primaryDelegateYob')
                };
                component.set('v.delegateParticipant', delegateParticipant);
            }
        }else{
            var delegateParticipant = {
                sobjectType: 'Participant__c'
            };
            component.set('v.delegateParticipant', delegateParticipant);
            component.set('v.emailDelegateRepeat', '');  
            component.set('v.confirmConsent', false);  
        }
    },
    
    checkFields: function (component, event, helper, doNotCheckFields) {
        let isAdultDel = component.get('v.isAdultDel');
        let attestAge = component.get('v.attestAge');
        let states = component.get('v.states');
        let confirmConsent;
        if( component.get('v.isConfirmConsentNeeded')){
         confirmConsent= component.get('v.confirmConsent');
        }
         else{
            confirmConsent=true;
         }
        
        if(component.get('v.patientVeiwRedirection')){
            if(component.get('v.hasGaurdian')){
                var needsDelegate = component.get('v.hasGaurdian');
            }else{
                var needsDelegate = component.get('v.needsGuardian');
            }
        }else{
            var needsDelegate = component.get('v.needsGuardian');
        }
        
        
        
        let isNewPrimaryDelegate =  component.get('v.isNewPrimaryDelegate');
        
        //Participant
        let participant = component.get('v.participant');
        let emailRepeat = component.get('v.emailRepeat');
        let emailCmp = component.find('emailField');
        let emailRepeatCmp = component.find('emailRepeatField');
        let emailVaild = emailCmp && communityService.isValidEmail(participant.Email__c);
        let emailValidIndependent = emailVaild;
        let emailRepeatValid = emailRepeatCmp && communityService.isValidEmail(emailRepeat);
        let emailValidRepeatIndependent = emailRepeatValid;
        let selectedCountry = participant.Mailing_Country_Code__c;
        let selectedState = participant.Mailing_State_Code__c;        
        component.set('v.agreePolicy',false);
        let per = component.get('v.pEnrollment');
        let delegateParticipant = component.get('v.delegateParticipant'); 
        //RH-8091 
        if( per != null && per != undefined && per != '' &&
            (
                (component.get('v.participant').Mailing_Country_Code__c == 'US' &&( per.Permit_SMS_Text_for_this_study__c || per.Delegate_Consent__c)) || 
                 component.get('v.participant').Mailing_Country_Code__c != 'US' ) && 
                 ((per.Permit_Voice_Text_contact_for_this_study__c && 
                per.Permit_Mail_Email_contact_for_this_study__c )|| per.Delegate_Consent__c)
              ){
              component.set('v.agreePolicy',true);   
            }
        //RH-8091
        let agreePolicy = component.get('v.agreePolicy');

        //Guardian (Participant delegate) 
        
        let emailDelegateRepeat = component.get('v.emailDelegateRepeat');
        
         agreePolicy = component.get('v.agreePolicy');
        //REF-3070
        let delegateParticipantemail = component.get('v.delegateParticipant.Email__c');
        let emailDelegateCmp = component.find('emailDelegateField');
        let emailDelegateRepeatCmp = component.find('emailDelegateRepeatField');
        //REF-3070
        let emailDelegateVaild = false;        
        if(delegateParticipantemail){
            emailDelegateVaild = needsDelegate &&
                emailDelegateCmp &&
                helper.checkValidEmail(emailDelegateCmp, delegateParticipant.Email__c);
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

        if(participant.Email__c){
            emailVaild = 
            needsDelegate ||
                emailCmp &&
                helper.checkValidEmail(emailCmp, participant.Email__c);
        }
        if(emailRepeat){
            emailRepeatValid = 
             needsDelegate ||
                emailRepeatCmp  &&
                 helper.checkValidEmail(emailRepeatCmp, emailRepeat);
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
        let dateToday = new Date();
        let bDay = component.get('v.pday');
        let bMonth = component.get('v.pmonth');
        let bYear = component.get('v.pyear');
        let dobFormat = component.get('v.studySiteFormat');
        let participantDOB = new Date(bYear+"-"+bMonth+"-"+bDay);
        let selectedParticipantAge = component.get('v.selectedAge');
        let isDobValid = (dobFormat == 'DD-MM-YYYY' && participantDOB <= dateToday && selectedParticipantAge!='') || (!dobFormat != 'DD-MM-YYYY' && selectedParticipantAge!='');
        let isValid = false;
        isValid =
            isValid ||
            (participant.First_Name__c &&
             participant.Last_Name__c &&
             //participant.Date_of_Birth__c &&
             //participant.Date_of_Birth__c <= component.get('v.todayDate') &&
             isDobValid &&
             (needsDelegate || participant.Email__c) &&
             (needsDelegate || emailVaild) &&
             (needsDelegate || emailRepeatValid) &&
             (needsDelegate || participant.Phone__c) &&
             (
                ((participant.Email__c ==undefined || participant.Email__c =='') 
                && (emailRepeat ==undefined || emailRepeat =='')) ||
                (participant.Email__c !=undefined && emailRepeat !=undefined &&
                    participant.Email__c.toUpperCase() == emailRepeat.toUpperCase() &&
                    emailValidIndependent   && emailValidRepeatIndependent
                ) 
               ) &&
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
               emailDelegateRepeat &&
               confirmConsent &&
               emailDelegateVaild &&
               emailDelegateVaild &&
               emailDelegateRepeatValid &&
               delegateParticipant.Email__c.toUpperCase() == emailDelegateRepeat.toUpperCase() ))&&
             agreePolicy);
        
         if(component.get('v.patientVeiwRedirection')){
              
              let needsGuardian = false;
              if(component.get('v.needsGuardian')){
                  needsGuardian = true;
              }
            
                  if( component.get('v.needsGuardian') && participant.Adult__c && (participant.email__c ==''|| !participant.email__c) ){
                      emailCmp.setCustomValidity('');
                        emailRepeatCmp.setCustomValidity('');
                        emailCmp.reportValidity();
                        emailRepeatCmp.reportValidity();
                        var PhoneField = component.find('PhoneName');
                        PhoneField.setCustomValidity('');
                        PhoneField.reportValidity();
                     }
              if(needsDelegate && needsGuardian &&
               delegateParticipant &&
               participant.Health_care_proxy_is_needed__c &&
               delegateParticipant.First_Name__c &&
               delegateParticipant.Last_Name__c &&
               delegateParticipant.Phone__c &&
               delegateParticipant.Email__c &&
               emailDelegateRepeat &&
               delegateParticipant.Email__c.toUpperCase() == emailDelegateRepeat.toUpperCase() &&
               emailDelegateVaild &&
               emailDelegateRepeatValid &&
               agreePolicy && attestAge && confirmConsent &&
               participant.First_Name__c &&
               participant.Last_Name__c &&
               //participant.Date_of_Birth__c &&
               //participant.Date_of_Birth__c <= component.get('v.todayDate')&&
               isDobValid &&
               (
                ((participant.Email__c ==undefined || participant.Email__c =='') 
                && (emailRepeat ==undefined || emailRepeat =='')) ||
                (participant.Email__c !=undefined && emailRepeat !=undefined &&
                    participant.Email__c.toUpperCase() == emailRepeat.toUpperCase() &&
                    emailValidIndependent   && emailValidRepeatIndependent
                ) 
               )  &&
               participant.Mailing_Zip_Postal_Code__c &&
              selectedCountry &&
              (selectedState || states.length === 0))
              {
                   isValid = true;
                  
              }else if(needsDelegate && !needsGuardian &&
               delegateParticipant &&
               participant.Health_care_proxy_is_needed__c &&
               delegateParticipant.First_Name__c &&
               delegateParticipant.Last_Name__c &&
               delegateParticipant.Phone__c &&
               delegateParticipant.Email__c &&
               emailDelegateRepeat &&
               delegateParticipant.Email__c.toUpperCase() == emailDelegateRepeat.toUpperCase() &&
               emailDelegateVaild &&
               emailDelegateRepeatValid &&
               agreePolicy && attestAge && confirmConsent &&
               participant.First_Name__c &&
               participant.Last_Name__c &&
               //participant.Date_of_Birth__c &&
               //participant.Date_of_Birth__c <= component.get('v.todayDate')&&
               isDobValid &&
               participant.Email__c &&
               participant.Email__c && emailRepeat !=undefined  ? emailValidIndependent  && emailValidRepeatIndependent && participant.Email__c.toUpperCase() == emailRepeat.toUpperCase(): null &&
               participant.Phone__c &&
               participant.Mailing_Zip_Postal_Code__c &&
              selectedCountry &&
              (selectedState || states.length === 0))
              {
                    isValid = true;
                  
              }else if(!needsDelegate && !needsGuardian &&
               agreePolicy &&
               participant.First_Name__c &&
               participant.Last_Name__c &&
               //participant.Date_of_Birth__c &&
               //participant.Date_of_Birth__c <= component.get('v.todayDate')&&
               isDobValid &&
               participant.Email__c &&
               emailVaild &&
               emailRepeatValid &&
               participant.Email__c && emailRepeat !=undefined  ? participant.Email__c.toUpperCase() == emailRepeat.toUpperCase(): false &&
               participant.Phone__c &&
               participant.Mailing_Zip_Postal_Code__c &&
              selectedCountry &&
              (selectedState || states.length === 0))
              {
                    isValid = true;
              }else{
                   isValid = false;
              }
            
        }

        if(needsDelegate && isNewPrimaryDelegate)
        {
            if(  needsDelegate && participant.Adult__c && (participant.email__c ==''|| !participant.email__c) ){
                emailCmp.setCustomValidity('');
                  emailRepeatCmp.setCustomValidity('');
                  emailCmp.reportValidity();
                  emailRepeatCmp.reportValidity();
                  var PhoneField = component.find('PhoneName');
                  PhoneField.setCustomValidity('');
                  PhoneField.reportValidity();
               } 
            if(!(isAdultDel && attestAge && confirmConsent))
                isValid = false;
        }
        //It will 
        if(participant.Adult__c ===  false){
            emailCmp.setCustomValidity('');
                emailRepeatCmp.setCustomValidity('');
                emailCmp.reportValidity();
                emailRepeatCmp.reportValidity();
                var PhoneField = component.find('PhoneName');
                PhoneField.setCustomValidity('');
                PhoneField.reportValidity(); 
        }
        if(selectedParticipantAge == "null" && selectedParticipantAge == undefined && selectedParticipantAge == ''){
            isValid = false; 
        }
        if(isValid == undefined){
            component.set('v.allRequiredCompleted', false);
        }else{
            component.set('v.allRequiredCompleted', isValid);
        } 
        if(participant.Email__c){
            emailVaild = 
             needsDelegate &&
                 emailCmp &&
                 helper.checkValidEmail(emailCmp, participant.Email__c);
         }
         if(emailRepeat){
           emailRepeatValid  = 
             needsDelegate &&
                emailRepeatCmp  &&
                 helper.checkValidEmail(emailRepeatCmp, emailRepeat);
         }
 
         if (needsDelegate && emailCmp && emailRepeatCmp) {
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
                 helper.checkValidEmail(emailCmp,participant.Email__c );
                 emailRepeatCmp.reportValidity();
                 helper.checkValidEmail(emailRepeatCmp, emailRepeat);
             }
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
                helper.checkValidEmail(emailCmp,participant.Email__c );
                emailRepeatCmp.reportValidity();
                helper.checkValidEmail(emailRepeatCmp, emailRepeat);

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
                helper.checkValidEmail(emailDelegateCmp, delegateParticipant.Email__c);
                emailDelegateRepeatCmp.reportValidity();
                helper.checkValidEmail(emailDelegateRepeatCmp, emailDelegateRepeat);
            }
        }
        
        console.log('VALIDATION isValid RESULT2: ' + isValid);
        console.log(component.get('v.allRequiredCompleted'));
    },
    
    checkValidEmail: function (email, emailValue) {
        var isValid = false;
        var regexp = $A.get('$Label.c.RH_Email_Validation_Pattern');
        var regexpInvalid = new RegExp($A.get('$Label.c.RH_Email_Invalid_Characters'));
        var invalidCheck = regexpInvalid.test(emailValue);
        if (invalidCheck == false) {
            if (emailValue.match(regexp)) {
                isValid = true;
            } else {
                if(emailValue != ''){
                    email.setCustomValidity('You have entered an invalid format');}
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
                    component.set('v.emailDelegateRepeat',returnValue.email.toLowerCase());
                } else component.set('v.emailInstance', null);
                if (returnValue.lastName) participantDelegate.Last_Name__c = returnValue.lastName;
                if (returnValue.firstName)
                    participantDelegate.First_Name__c = returnValue.firstName;
                if(returnValue.DelegateYOB)
                    participantDelegate.Birth_Year__c = returnValue.DelegateYOB;
                
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
        if (component.get('v.states').length === 0) {
            component.set('v.participant.Mailing_State_Code__c', ''); 
            component.set('v.participantToInsert', participant); 
        }else{
            component.set('v.participantToInsert', participant); 
        }
        var participantToInsert = component.get('v.participantToInsert');
          
        communityService.executeAction(
            component,
            'checkNeedsGuardian',
            {
                participantJSON: JSON.stringify(participantToInsert)
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
                    component.set('v.participant.Adult__c', false);
                    helper.setDelegate(component);
                }else{
                    component.set('v.enableGuardian', false);
                    component.set('v.needsGuardian', false);
                    component.set('v.participant.Adult__c', true);
                }  
                if(component.get('v.patientVeiwRedirection')){
                    if(component.get('v.primaryDelegateFirstname') != null && !component.get('v.delegateValueRemoved')){
                        component.set('v.hasGaurdian', true);
                        component.set('v.participant.Health_care_proxy_is_needed__c', true);
                         component.set('v.needsGuardian', true); /*change -5124**/
                    }else{
                        if(isNeedGuardian){
                            component.set('v.hasGaurdian', true);
                        }else{
                            component.set('v.hasGaurdian', false);
                        }
                        
                    }
                }
                //RH-8091 
                if(!component.get('v.participant.Health_care_proxy_is_needed__c') && component.get('v.participant.Adult__c')){
                    component.set('v.isConfirmConsentNeeded', true);
                }
                else{
                    component.set('v.isConfirmConsentNeeded', false); 
                }
                //RH-8091 
                helper.checkFields(component, event, helper, true);
                
                if(component.get('v.patientVeiwRedirection')){
                    if(component.get('v.primaryDelegateYob') != null && component.get('v.primaryDelegateYob') != ''){
                        helper.checkGuardianAge(component, event, helper);  
                    }
                }
            } ,         
            null,
            function () {
                spinner.hide();
            }
        );
    },
    
    //added by sumit
    checkGuardianAge: function (component, event, helper) {
        //let frmpatientVeiw = communityService.getUrlParameter('patientVeiwRedirection');
        let frmpatientVeiw =  component.get('v.patientVeiwRedirection');
        if(component.get('v.attestAge') && component.find('checkBoxAttestation')!=undefined)
        {
            var attestCheckbox = component.find('checkBoxAttestation');
            attestCheckbox.setCustomValidity('');
            attestCheckbox.reportValidity('');
        }
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
    },
    //dob changes
    doParticipantAge: function (component) {
        var pday = component.get('v.pday');
        var pmonth = component.get('v.pmonth');
        var pyear = component.get('v.pyear');
        let studyDobFormat = component.get('v.studySiteFormat');
        if(studyDobFormat == "DD-MM-YYYY" && pyear && pmonth && pday){
            let dateToday = new Date();
            var dob = new Date(pyear+"-"+pmonth+"-"+pday);
            //calculate month difference from current date in time
            var month_diff = Date.now() - dob.getTime();
            //convert the calculated difference in date format
            var age_dt = new Date(month_diff); 
            //extract year from date    
            var year = age_dt.getUTCFullYear();
            //now calculate the age of the user
            var age = ((year - 1970) >=0 ? (year - 1970) : 0);
            if(dob > dateToday){
                age = '';
            }
            component.set('v.selectedAge',age);
            component.set('v.participant.Age__c',age);
    }
    },
    //dob changes
    generateAgeOptions: function (component) {
        var opt = [];
        let todayDate = new Date();
        let cMonth = todayDate.getMonth()+1;
        let cYear = parseInt(todayDate.getUTCFullYear());
        var pmonth = component.get('v.pmonth');
        var pyear = component.get('v.pyear');
        let higherAge = Number(todayDate.getUTCFullYear())-Number(pyear);
        let lowerAge = Number(higherAge)-1;
        let studyDobFormat = component.get('v.studySiteFormat');
        if((studyDobFormat == 'YYYY' || (studyDobFormat == 'MM-YYYY' && pmonth && pmonth >= cMonth )) && pyear && pyear!=cYear){
            console.log('lower age');
            opt.push({label: lowerAge, value: lowerAge });
        }
        if((studyDobFormat == 'YYYY' || (studyDobFormat == 'MM-YYYY' && pmonth && pmonth <= cMonth)) && pyear){
            console.log('higher age');
            opt.push({label: higherAge, value: higherAge });
        }
        
        component.set('v.ageOptions', opt);
    },

    checkForLeapYear : function (component, event, helper) {
        let pYear = component.get('v.pyear');
        if (parseInt(pYear) % 400 == 0) {
            return true;
    }
        if (parseInt(pYear) % 100 == 0) {
            return false;
        }
        if (parseInt(pYear) % 4 == 0) {
            return true;
        }
        return false;
    },

    doMonthPLVChange: function (component, event, helper) {
        let maxDayMonths = ['01', '03', '05', '07', '08', '10', '12'];
        let minDayMonths = ['04', '06', '09', '11'];
        let lastDay=30;
        let pMonth = component.get('v.pmonth');
        let pYear = component.get('v.pyear');
        let pDay = component.get('v.pday');
        if (maxDayMonths.includes(pMonth)) {
            lastDay = 31;
        }
        else if (minDayMonths.includes(pMonth)) {
            lastDay = 30;
        }
        else if (pMonth == '02') {
            if (pYear == null || helper.checkForLeapYear(component, event, helper)) {
                lastDay = 29;
            }
            else {
                lastDay = 28;
            }
        }
        var dayList = [];
        var obj = {};
        for (var i = 1; i <= lastDay; i++) {
            if(i >= 10){
                obj.label = ""+i;
                obj.value = ""+i;
            }else{
                obj.label = "0"+i;
                obj.value = "0"+i;
            }
            dayList.push(obj);
            obj = {};
        }
        component.set('v.days', dayList);
        component.set('v.toggleAge',false);
        component.set('v.toggleAge',true);
        
        if (pDay && lastDay && (parseInt(pDay) > lastDay) ) {
            component.set('v.pday',lastDay.toString());
        }
    },
    validateDOB: function (component,event,helper){
        var format = component.get("v.studySiteFormat");
        var part = component.get("v.participant");
        var dobDate;
        var today = new Date();
        component.set("v.futureDate",false);
        component.set("v.futureDateDDErr",null);
        component.set("v.futureDateMMErr",null);
        let lastDay;
        if(format !== 'YYYY'){
            var maxDayMonths = ['01','03','05','07','08','10','12'];
            var minDayMonths = ['04','06','09','11'];
            lastDay = 31;
            if(maxDayMonths.includes(component.get('v.pmonth'))){
                lastDay = 31;
            }
            else if(minDayMonths.includes(component.get('v.pmonth'))){
                lastDay = 30;
            }
            else if(component.get('v.pmonth') == '02'){
                if(component.get('v.pyear') =='----' || helper.checkForLeapYear(component,event, helper)){
                    lastDay = 29;
                }     
                else{
                    lastDay = 28;
                }            
            }
        }
        if(format == 'DD-MM-YYYY'){
            part.Date_of_Birth__c = component.get('v.pyear')+'-'+component.get('v.pmonth')+'-'+component.get('v.pday');            
        }
        else if(format == 'MM-YYYY'){
            part.Date_of_Birth__c = component.get('v.pyear')+'-'+component.get('v.pmonth')+'-'+lastDay;            
        }
        else if(format == 'YYYY'){
            part.Date_of_Birth__c = component.get('v.pyear')+'-12-31';
        }        
        if(!part.Date_of_Birth__c.includes('--')){
            component.set("v.participant",part);
            //helper.doCheckDateOfBith(component, event, helper);
            if(format == 'DD-MM-YYYY'){
                dobDate = new Date(part.Date_of_Birth__c).setHours(0,0,0,0); 
                today = today.setHours(0,0,0,0);        
                if(today<dobDate){
                    component.set("v.futureDate",true);
                    if(new Date().getMonth()<new Date(part.Date_of_Birth__c).getMonth()){
                        component.set("v.futureDateMMErr","Value must be current month or earlier");
                    }
                    component.set("v.futureDateDDErr","Value must be current date or earlier ");
                    
                }
            }
            else if(format == 'MM-YYYY'){
                dobDate = new Date(part.Date_of_Birth__c);
                if(dobDate.getFullYear()==today.getFullYear() && today.getMonth()<dobDate.getMonth()){
                    component.set("v.futureDate",true);
                    component.set("v.futureDateMMErr","Value must be current month or earlier");
                }
            }
        }
    }

});