/**
 * Created by Leonid Bartenev
 */
 ({
    doInit: function (component, event, helper) {
        var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);
        var formData = component.get('v.formData');
        var states = formData.statesByCountryMap['US'];
        component.set('v.statesLVList', states);
        component.set('v.visitPlanAvailable', formData.visitPlansLVList.length > 0);
        component.set('v.isOneVisitPlanAvailableAndSelected',false);
        component.set('v.isFirstPrimaryDelegate',false);
        window.setTimeout(function(){
            var charSize; 
        if((component.get('v.pe.Referral_Source__c') == 'PI') && component.get('v.pe.MRN_Id__c'))
        {
           charSize = component.get('v.pe.MRN_Id__c').length;
        }
        else if((component.get('v.pe.Referral_Source__c') == 'HCP') && component.get('v.pe.Patient_ID__c'))
            charSize = component.get('v.pe.Patient_ID__c').length;
        else if((component.get('v.pe.Referral_Source__c') != 'PI') && (component.get('v.pe.Referral_Source__c') != 'HCP'))
        {
            var referralIdSize;
            if(component.get('v.pe.Referral_ID__c'))
                referralIdSize = component.get('v.pe.Referral_ID__c').length;
            if(component.get('v.pe.Source_Type__c'))
                referralIdSize += component.get('v.pe.Source_Type__c').length;
            if(referralIdSize > 0)
                charSize = referralIdSize + 3;
        }
            if(charSize > 30 && charSize <=50){
            //var charSize = component.get('v.pe.MRN_Id__c').length;
       		document.getElementsByClassName('customWidth')[0].style.width = charSize+'%';
        }
            else if(charSize > 50){
                document.getElementsByClassName('customWidth')[0].style.width = 50 + '%';
            }
        },3000);

        //DOB
        component.set('v.lastDay', 31);
        try{
        helper.setDD(component, event, helper);
        helper.setMM(component, event, helper);
        helper.setYYYY(component, event, helper);
        }
        catch(e){
            console.log(e);
        }
    },

    doRefreshDateInput: function (component, event, helper) {
        if(!component.get('v.participant.Adult__c')){            
            component.set('v.resetDate', false);
            component.set('v.resetDate', true);
        }
    },
    
	/**RH-5960 */
    doRefreshDOBInput: function (component, event, helper) {
        if(!component.get('v.participant.Adult__c')){
            component.set('v.resetDOB', false);
            component.set('v.resetDOB', true);
        }
    },
    doRefreshStateInput: function (component, event, helper) {
        component.set('v.resetState', false);
        component.set('v.resetState', true);
    },
    
    doClearValidity: function (component, event, hepler) {
        let needsGuardian = component.get('v.needsGuardian');
        if (needsGuardian) {
            component.get('v.parentComponent').find('spinner').show();
            component.set('v.isRefreshPediatric', true);
            component.set('v.isRefreshPediatric', false);
            component.get('v.parentComponent').find('spinner').hide();
        }
    },

     doCheckFields: function (component, event, helper) {
       
         var formData = component.get('v.formData');
         if(formData.visitPlansLVList.length ===1 && component.get('v.pe').Visit_Plan__c && component.get('v.isVisitPlanAssigned')!= true){
             component.set('v.isOneVisitPlanAvailableAndSelected',true);
         }
         var helpText = component.find('helpText');
         var participant = component.get('v.participant');
         if( component.get('v.needsGuardian') && participant.Adult__c && (participant.email__c ==''|| !participant.email__c) ){
             component.set('v.createUsers',false);
         }
         // var participantDelegate = component.get('v.participantDelegate');
         var statesByCountryMap = component.get('v.formData.statesByCountryMap');
         var states = statesByCountryMap[participant.Mailing_Country_Code__c];
         component.set('v.statesLVList', states);
         var pe = component.get('v.pe');
         var updateMode = component.get('v.updateMode');
         var isFinalUpdate = component.get('v.isFinalUpdate');
         var stateRequired = component.get('v.statesLVList')[0];
         var stateCmp = component.find('stateField');
         //var stateVaild = stateCmp && stateCmp.get('v.validity') && stateCmp.get('v.validity').valid;
         var dataStamp = component.get('v.dataStamp');
         var isValid = false;
         const screeningIdRequiredStatuses =
             'Enrollment Success; Randomization Success; Treatment Period Started; Follow-Up Period Started; Participation Complete; Trial Complete'
             + (formData.ctp && formData.ctp.Tokenization_Support__c ? '; Screening Passed' : '');
         const visitPlanRequiredStatuses =
             'Enrollment Success; Randomization Success; Treatment Period Started; Follow-Up Period Started; Participation Complete; Trial Complete';
         let screeningIdRequired = false;
         let visitPlanRequired = false;
         var isFinalStateSuccess = false;
         var today = new Date();
         var inDate = new Date(participant.Date_of_Birth__c);
         var currentDate = today.setHours(0, 0, 0, 0);
         var inputDate = inDate.setHours(0, 0, 0, 0);
         let needsGuardian = component.get('v.needsGuardian');
         let emailParticipantRepeat = component.get('v.emailParticipantRepeat');
         /**RH-5960 */
         let emailParticipantReapetCmpArray = component.find('emailParticipantRepeatField');
         let emailParticipantCmpArray = component.find('emailInput');
         let emailParticipantReapetCmp = Array.isArray(emailParticipantReapetCmpArray)
         									? emailParticipantReapetCmpArray[0] : emailParticipantReapetCmpArray;
         let emailParticipantCmp = Array.isArray(emailParticipantCmpArray)
         									? emailParticipantCmpArray[0] : emailParticipantCmpArray;
         //let emailParticipantReapetCmp = component.find('emailParticipantRepeatField');
         //let emailParticipantCmp = component.find('emailInput');
         let emailValueFirst = emailParticipantCmp ? emailParticipantCmp.get('v.value') : null;
         let emailValueRepeat = emailParticipantReapetCmp
         ? emailParticipantReapetCmp.get('v.value')
         : null;
         //REF-3070
         if((!participant.Adult__c) && (component.get('v.fromAddParticipantPage'))){
             component.set('v.participant.Email__c', '');
             component.set('v.emailParticipantRepeat', '');
             component.set('v.participant.Phone__c', '');
             component.set('v.participant.Phone_Type__c', '');
			 emailParticipantCmp.setCustomValidity('');
             emailParticipantCmp.reportValidity();
         } 
         
         /**RH-5960 */
         if((!participant.Adult__c && participant.Adult__c!=undefined) && (component.get('v.fromAddParticipantPage'))){
         	component.refreshDOBInput();
         }
         helper.checkValidEmail(emailParticipantCmp, emailValueFirst);
         helper.checkValidEmail(emailParticipantReapetCmp, emailValueRepeat);
         var participantDelegateOld = component.get('v.participantDelegate');
         let checkDuplicateDelegate;
         
         if(participantDelegateOld && participantDelegateOld.First_Name__c &&
            participantDelegateOld.Last_Name__c &&
            participantDelegateOld.Email__c)
         {
             if(event){
                 var getAuraFromCalled = event.getSource();
                 if(getAuraFromCalled.getLocalId() == 'DelegateEmail' || 
                    getAuraFromCalled.getLocalId() == 'DelegateFirstName' ||
                    getAuraFromCalled.getLocalId() == 'DelegateLastName')
                 {
                     checkDuplicateDelegate  = true;
                 }
             }
         }
         else if(participantDelegateOld && (!participantDelegateOld.First_Name__c ||
                                            !participantDelegateOld.Last_Name__c ||
                                            !participantDelegateOld.Email__c))
         {
             component.set('v.useThisDelegate', true);
         }
         if(component.get('v.fromActionParticipant')){
             var DelegateEmail = component.find('DelegateEmail');
             var DelegateEmailValue = DelegateEmail ? DelegateEmail.get('v.value') : null ; 
         }
         helper.checkValidEmail(DelegateEmail, DelegateEmailValue);
         component.find('spinner').show(); 
         if(checkDuplicateDelegate)
         {
             helper.checkExistingValidDelegateEmail(component, event,DelegateEmail
                                                    ,DelegateEmailValue,participantDelegateOld);
         }
      
         if(component.get('v.fromActionParticipant') ){
             if(!$A.util.isEmpty(participantDelegateOld.Birth_Year__c)) {
                 checkDuplicateDelegate = true;
                 helper.checkDelegateAge(component,participant,participantDelegateOld);
             } 
         }
         var setTimeForEmail = setTimeout(function (){
             var participantDelegate = component.get('v.participantDelegate');
             
             component.find('spinner').hide(); 
             if (pe.MRN_Id__c) {
                 component.set('v.disableSourceId', true);
             } else {
                 component.set('v.disableSourceId', false);
             }
             if (pe && pe.Participant_Status__c) {
                 isFinalStateSuccess =
                     pe.Participant_Status__c === 'Randomization Success' ||
                     pe.Participant_Status__c === 'Enrollment Success';
                 screeningIdRequired =
                     isFinalUpdate ||
                     screeningIdRequiredStatuses.indexOf(pe.Participant_Status__c) !== -1;
                 visitPlanRequired =
                     isFinalUpdate || visitPlanRequiredStatuses.indexOf(pe.Participant_Status__c) !== -1;
                 component.set(
                     'v.visitPlanDisabled',
                     pe.Id && screeningIdRequiredStatuses.indexOf(pe.Participant_Status__c) !== -1
                 );
             }
             let isVisitPlanNotRequired = !component.get('v.visitPlanAvailable') || !visitPlanRequired;
             component.set('v.screeningRequired', screeningIdRequired);
             component.set('v.visitPlanRequired', visitPlanRequired);
              
             if (updateMode && !isFinalUpdate && dataStamp) {
                 var oldPE = JSON.parse(dataStamp);
                 var isRemovedValue =
                     (oldPE.Participant__r.First_Name__c.trim() && !participant.First_Name__c.trim()) ||
                     (oldPE.Participant__r.Last_Name__c.trim() && !participant.Last_Name__c.trim()) ||
                     (oldPE.Participant__r.Date_of_Birth__c && !participant.Date_of_Birth__c) ||
                     (oldPE.Participant__r.Gender__c && !participant.Gender__c) ||
                     //needsGuardian ||
                     /*(oldPE.Participant__r.Phone__c && !participant.Phone__c.trim())  || */
                     //needsGuardian ||
                     //(participant.Adult__c && oldPE.Participant__r.Phone_Type__c && !participant.Phone_Type__c.trim()) ||
                     //needsGuardian ||
                     /*  (oldPE.Participant__r.Email__c && !participant.Email__c)  || */
                     (oldPE.Participant__r.Mailing_Country_Code__c &&
                      !participant.Mailing_Country_Code__c) ||
                     (stateRequired &&
                      oldPE.Participant__r.Mailing_State_Code__c &&
                      !participant.Mailing_State_Code__c) ||
                     (oldPE.Participant__r.Mailing_Zip_Postal_Code__c.trim() &&
                      !participant.Mailing_Zip_Postal_Code__c.trim()) ||
                     (oldPE.Screening_ID__c && !pe.Screening_ID__c) ||
                     (oldPE.Referred_By__c && !pe.Referred_By__c) ||
                     (oldPE.MRN_Id__c && !pe.MRN_Id__c);
                 isValid = !isRemovedValue;
                 if (component.get('v.fromActionParticipant') && !isRemovedValue) { 
                     //checking the id of participant because from Apex controller we are sending an instance if Delegatenot found 
                     if (
                         !participantDelegate.Id &&
                         (!participant.Phone__c || !participant.Phone_Type__c || !participant.Email__c)
                     ) {
                         
                         if(!participantDelegate.Email__c.trim() || 
                            !(component.find('DelegateEmail').get('v.validity').valid) ||
                            !participantDelegate.Phone__c.trim())
                             isValid = false;
                     } else {
                         if (participant.Gender__c) {
                             isValid = false;
                             isValid =
                                 isValid ||
                                 (participant.First_Name__c.trim() &&
                                  participant.Last_Name__c.trim() &&
                                  inputDate <= currentDate &&
                                  participant.Gender__c.trim() &&
                                  (needsGuardian ||
                                   participantDelegate ||
                                   participant.Phone__c.trim()) &&
                                  (needsGuardian ||
                                   participantDelegate ||
                                   participant.Phone_Type__c.trim()) &&
                                  (needsGuardian ||
                                   participantDelegate ||
                                   (participant.Email__c &&
                                    component.find('emailInput').get('v.validity').valid)) &&
                                  participant.Mailing_Zip_Postal_Code__c.trim() !== '');
                         } else {
                             isValid = false;
                         }
                     }
                     if (
                         participantDelegate &&
                         ((participantDelegate.Phone__c && !participantDelegate.Phone__c.trim()) ||
                          (participantDelegate.First_Name__c &&  !participantDelegate.First_Name__c.trim()) ||
                          (participantDelegate.Last_Name__c && !participantDelegate.Last_Name__c.trim()) 
                         )
                     ) {
                         isValid = false;
                     }
                 }
             } else if (updateMode && isFinalUpdate) {
                 isValid =
                     isValid ||
                     (participant.First_Name__c.trim() &&
                      participant.Last_Name__c.trim() &&
                      participant.Date_of_Birth__c &&
                      participant.Gender__c &&
                      (needsGuardian || participantDelegate || participant.Phone__c.trim()) &&
                      (needsGuardian || participantDelegate || participant.Phone_Type__c.trim()) &&
                      (needsGuardian ||
                       participantDelegate ||
                       (participant.Email__c &&
                        component.find('emailInput').get('v.validity').valid)) &&
                      (!participantDelegate || participantDelegate.Phone__c.trim()) &&
                      (!participantDelegate || participantDelegate.First_Name__c.trim()) &&
                      (!participantDelegate || participantDelegate.Last_Name__c.trim()) &&
                      participant.Email__c &&
                      participant.Mailing_Zip_Postal_Code__c.trim() !== '' &&
                      pe &&
                      pe.Participant_Status__c &&
                      (pe.Visit_Plan__c || isVisitPlanNotRequired) &&
                      pe.Screening_ID__c &&
                      (!stateRequired || (stateRequired && participant.Mailing_State_Code__c)));
                 //stateVaild;
                 if (component.get('v.fromActionParticipant') && !isRemovedValue) {
                     if (
                         participant.First_Name__c.trim() &&
                         participant.Last_Name__c.trim() &&
                         inputDate <= currentDate &&
                         participant.Gender__c.trim() &&
                         (needsGuardian || participantDelegate || participant.Phone__c.trim()) &&
                         (needsGuardian || participantDelegate || participant.Phone_Type__c.trim()) &&
                         (needsGuardian ||
                          participantDelegate ||
                          (participant.Email__c &&
                           component.find('emailInput').get('v.validity').valid)) &&
                         (!participantDelegate || participantDelegate.Phone__c.trim()) &&
                         (!participantDelegate || participantDelegate.First_Name__c.trim()) &&
                         (!participantDelegate || participantDelegate.Last_Name__c.trim()) &&
                         participant.Mailing_Zip_Postal_Code__c.trim() !== ''
                     ) {
                         isValid = true;
                     } else {
                         isValid = false;
                     }
                 }
                 
                 //(!stateRequired || (stateRequired && (participant.Mailing_State_Code__c !== '' || participant.Mailing_State_Code__c !== undefined || participant.Mailing_State_Code__c !== null)));
             } else if (!updateMode) {
                 //  debugger;
                 isValid =
                     helper.checkValidEmail(emailParticipantCmp, participant.Email__c) &&
                     helper.checkValidEmail(emailParticipantReapetCmp, emailParticipantRepeat);
                 if (isValid) {
                     if (
                         participant.Email__c &&
                         emailParticipantRepeat &&
                         participant.Email__c.toLowerCase() !== emailParticipantRepeat.toLowerCase()
                     ) {
                         isValid = false;
                         emailParticipantCmp.setCustomValidity(
                             $A.get('$Label.c.PG_Ref_MSG_Email_s_not_equals')
                         );
                         emailParticipantReapetCmp.setCustomValidity(
                             $A.get('$Label.c.PG_Ref_MSG_Email_s_not_equals')
                         );
                     } else {
                         emailParticipantCmp.setCustomValidity('');
                         emailParticipantReapetCmp.setCustomValidity('');
                     }
                     if (
                         participant.Email__c &&
                         participant.Email__c !== '' &&
                         emailParticipantRepeat &&
                         emailParticipantRepeat !== ''
                     ) {
                         emailParticipantCmp.reportValidity();
                         emailParticipantReapetCmp.reportValidity();
                     }
                 }
                 if (!participantDelegate) {
                     component.set('v.isValid', false);
                 }
                 //var checkReferred = source == 'ePR' ? true : pe.Referred_By__c ? true : false;
                 if (needsGuardian || participantDelegate || participant.Phone__c) {
                    let reqFieldsFilled;
                    let allValid;
                     if (component.find('emailInput').constructor === Array) {
                      let fieldsGroup = 'emailInput';
                       allValid = component.find(fieldsGroup).reduce(function (validSoFar, inputCmp) {
                      return validSoFar && inputCmp.get('v.validity').valid;
                         }, true);
                         reqFieldsFilled = false;
                   }else if(component.find('emailInput').get('v.validity').valid){
                        reqFieldsFilled = true;
                       allValid = false;
                   } 
                     isValid = false;
                     isValid =
                         isValid ||
                         (participant.First_Name__c.trim() &&
                          participant.Last_Name__c.trim() &&
                          participant.Date_of_Birth__c &&
                          inputDate <= currentDate &&
                          participant.Gender__c &&
                          (needsGuardian || participantDelegate || participant.Phone__c.trim()) &&
                          (needsGuardian || participantDelegate || participant.Phone_Type__c) &&
                          (needsGuardian ||
                           participantDelegate ||
                           (emailParticipantRepeat &&
                            participant.Email__c &&
                            (allValid || reqFieldsFilled))) &&
                          (!participantDelegate || (participantDelegate.phone__c && participantDelegate.Phone__c.trim())) &&
                          (!participantDelegate || (participantDelegate.First_Name__c && participantDelegate.First_Name__c.trim())) &&
                          (!participantDelegate || (participantDelegate.Last_Name__c && participantDelegate.Last_Name__c.trim())) &&
                          participant.Mailing_Zip_Postal_Code__c.trim() &&
                          pe &&
                          pe.Participant_Status__c && 
                          (!screeningIdRequired || (screeningIdRequired && pe.Screening_ID__c && pe.Screening_ID__c.trim())) &&
                          (!isFinalStateSuccess || (isFinalStateSuccess && pe.Screening_ID__c && pe.Screening_ID__c.trim())) &&
                          (!stateRequired || (stateRequired && participant.Mailing_State_Code__c)) &&
                          //stateVaild &&
                          (pe.Visit_Plan__c || isVisitPlanNotRequired) &&
                          pe.Referred_By__c);
                 } else {
                     isValid = false;
                 }
             }
         
             var ParticipantEmailField = component.find('emailInputParticipant');
             var ParticipantPhoneField = component.find("phoneInputParticipant");
           
             var completeInfoField = $A.get("$Label.c.Complete_field_Info");
             
             if(participant.Adult__c && !$A.util.isEmpty(ParticipantPhoneField)
                && !$A.util.isEmpty(ParticipantEmailField)){
                 if((!participant.Email__c || (!participant.Email__c && !participant.Email__c.trim())) 
                    && (participantDelegate && (!participantDelegate.Email__c.trim() || 
                                                !(component.find('DelegateEmail').get('v.validity').valid)))){
                   
                     isValid = false;
                     ParticipantEmailField.setCustomValidity(completeInfoField);
                 }
                 else{
                     ParticipantEmailField.setCustomValidity('');                      
                 } 
                 if((!participant.Phone__c || (!participant.Phone__c && !participant.Phone__c.trim()))
                    && (participantDelegate &&
                        !participantDelegate.Phone__c.trim())){
                     isValid = false;
                     ParticipantPhoneField.setCustomValidity(completeInfoField);
                 }
                 else{
                     ParticipantPhoneField.setCustomValidity('');
                 }
                 ParticipantEmailField.reportValidity();
                 ParticipantPhoneField.reportValidity(); 
             } 
             
             /* if (!component.find('emailInput').get('v.validity').valid) {
            console.log('EMAILAIF');
            isValid = false;
        } */
             if (participant.Alternative_Phone_Number__c && !participant.Alternative_Phone_Type__c) {
                 isValid = false;
             }
             if (!updateMode && participant.Email__c && !emailParticipantRepeat) {
                 isValid = false;
             }
             if (participant.Phone__c && !participant.Phone_Type__c) {
            isValid = false;
        } 
           
           var isAllFieldsDeleted = false;
             if(component.get('v.fromActionParticipant')){
                 
                 var DelegateFnameField = component.find('DelegateFirstName');
                 var DelegateLnameField = component.find('DelegateLastName');
                 var DelegateEmailField = component.find('DelegateEmail');
                 var DelegatePhoneField = component.find('DelegatePhoneName'); 
                 if(!participant.Adult__c)
                 {
                     if(!participantDelegate.Phone__c.trim() ||
                        !participantDelegate.First_Name__c.trim() ||
                        !participantDelegate.Last_Name__c.trim() ||
                        !participantDelegate.Email__c.trim() || 
                        !(component.find('DelegateEmail').get('v.validity').valid)){
                         isValid = false;
                     }
                 }
                 else {

                     if(!((!participantDelegate.Phone__c || !participantDelegate.Phone__c.trim()) &&
                          !participantDelegate.First_Name__c.trim() &&
                          !participantDelegate.Last_Name__c.trim() &&
                          !participantDelegate.Email__c.trim())){
                        
                         if(($A.util.isEmpty(participantDelegate.Phone__c)) ||
                            ($A.util.isEmpty(participantDelegate.Phone__c.trim())))
                         {
                             DelegatePhoneField.setCustomValidity(completeInfoField);
                             isValid = false;
                         }
                         else{
                             DelegatePhoneField.setCustomValidity('');
                         }
                         if($A.util.isEmpty(participantDelegate.First_Name__c.trim()))
                         {
                             DelegateFnameField.setCustomValidity(completeInfoField);
                             isValid = false;
                         }
                         else{
                             DelegateFnameField.setCustomValidity('');
                         }
                         if($A.util.isEmpty(participantDelegate.Last_Name__c.trim()))
                         {
                             DelegateLnameField.setCustomValidity(completeInfoField);
                             isValid = false;
                         }
                         else{
                             DelegateLnameField.setCustomValidity('');
                         }
                         if($A.util.isEmpty(participantDelegate.Email__c.trim()))
                         {
                             DelegateEmailField.setCustomValidity(completeInfoField);
                             isValid = false;
                         }
                         else if(!(component.find('DelegateEmail').get('v.validity').valid)){
                             isValid = false;
                             
                         }
                             else{
                                 DelegateEmailField.setCustomValidity('');
                             }
                     }
                     else{
                         component.set('v.isFirstPrimaryDelegate',false);
                         component.set('v.isBulkImport',false);
                         DelegatePhoneField.setCustomValidity(''); 
                         DelegateFnameField.setCustomValidity('');
                         DelegateLnameField.setCustomValidity('');
                         DelegateEmailField.setCustomValidity('');
                     }
                     DelegatePhoneField.reportValidity();
                     DelegateFnameField.reportValidity();
                     DelegateLnameField.reportValidity();
                     DelegateEmailField.reportValidity();
                 }
                 
                 if(component.get('v.isFirstPrimaryDelegate') || component.get('v.isBulkImport')){
                    if($A.util.isEmpty(participantDelegateOld.Birth_Year__c))
                     {  
                         component.set('v.yobBlankErrMsg', true);
                         component.set('v.delNotAdultErrMsg', false);
                         component.set('v.attestAge',false);
                         component.set('v.isAdultDel',false); 
                         if(!component.get('v.isBulkImport')){
                         var attestCheckbox = component.find('AttestCheckbox');
                         attestCheckbox.setCustomValidity('');
                         attestCheckbox.reportValidity('');
                         }
                         isValid = false;
                     }
                     else{
                         component.set('v.yobBlankErrMsg', false);
                     }
                     if(participantDelegateOld.Birth_Year__c != '' && component.get('v.attestAge') == false
                       &&  component.get('v.isBulkImport') == false)
                     {
                         isValid = false;
                     }
                 }
                 
             }
             //check if age fields filled
             if(!component.get('v.showDay')){
                if(!component.get('v.valueAge')){
                    isValid = false;
                }
            }
             component.set('v.isValid', isValid);
             
             let parentComponent = component.get('v.parentComponent');
             if (parentComponent && parentComponent.refreshParticipant) {
                 parentComponent.refreshParticipant();
             }
             
             return isValid;
         },checkDuplicateDelegate == true ? 2000 : 0);
        
    },

    doCheckDateOfBith: function (component, event, helper) {
        helper.doCheckDateOfBith(component, event, helper); 
    },

    doCountryCodeChanged: function (component, event, helper) {
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var countryMap = component.get('v.formData.countriesLVList');
        var participant = component.get('v.participant');
        for (let i = 0; i < countryMap.length; i++) {
            if (countryMap[i].value == participant.Mailing_Country_Code__c) {
                component.set('v.participant.Mailing_Country__c', countryMap[i].label);
                break;
            }
        }
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        /**RH-5960 */
        if(!states.length){
            component.refreshStateInput();
        }
        component.set('v.participant.Mailing_State_Code__c', null);
        component.set('v.participant.Mailing_State__c', null);
        component.checkFields();
        $A.enqueueAction(component.get('c.doCheckDateOfBith'));
    },

    doStateChange: function (component, event, helper) {
        var states = component.get('v.statesLVList');
        if (states) {
            var participant = component.get('v.participant');
            for (let i = 0; i < states.length; i++) {
                if (states[i].value == participant.Mailing_State_Code__c) {
                    component.set('v.participant.Mailing_State__c', states[i].label);
                    break;
                }
            }
        }
        component.checkFields();
        $A.enqueueAction(component.get('c.doCheckDateOfBith'));
    },

    doRefreshEmailInput: function (component, event, helper) {
        component.set('v.emailParticipantRepeat', '');
    },

    doCreateDataStamp: function (component, event, helper) {
        var pe = component.get('v.pe');
        component.set('v.dataStamp', JSON.stringify(pe));
    },

    doRefreshView: function (component, event, helper) {
        component.set('v.isRefreshView', true);
        component.set('v.isRefreshView', false);
    },

    hideHelp: function (component) {
        component.set('hideHelp', false);
    },
    
     approveDelegate: function (component, event, helper) {
         if(component.get('v.BtnClicked') == 'newRecord'){
             component.set('v.isFirstPrimaryDelegate',true); 
            component.set('v.participantDelegate.Birth_Year__c','');
            component.set('v.attestAge', false);
              component.set('v.isAdultDel',false); 
             component.set('v.isBulkImport',false);
         }
        component.set('v.isEmailConfrmBtnClick',true);
        component.set('v.useThisDelegate', true); 
    },
    // DOB
    YYYYChange: function (component, event, helper){
        const myTimeout = setTimeout(helper.YYYYChange(component, event, helper), 50);
    },
    MMChange: function (component, event, helper){
        const myTimeout = setTimeout(helper.MMChange(component, event, helper), 50);
    },
    DDChange: function (component, event, helper){
        const myTimeout = setTimeout(helper.DDChange(component, event, helper), 50);
    },
    ageChange: function (component, event, helper){
        const myTimeout = setTimeout(helper.ageChange(component, event, helper), 50);
    },
    validateDOB: function (component, event, helper){
        helper.validateDOB(component, event, helper);
    },
    refreshPartDobInput: function (component, event, helper) {
        component.set('v.valueDD', '--');
        component.set('v.valueMM', '--');
        component.set('v.valueYYYY', '----');
        component.set('v.ageOpt', null);
        component.set('v.valueAge', null);
    },
});