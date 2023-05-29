({

    
    checkExistingValidDelegateEmail: function(component, event,DelegateEmail,DelegateEmailValue
                                             ,participantDelegateOld){
        var isValidData = '';
        var isValidEmail = '';
        isValidEmail = this.checkValidEmail(DelegateEmail,DelegateEmailValue);
        if($A.util.isEmpty(component.get('v.isBulkImportOld')) && component.get('v.isBulkImport'))
        {
            component.set('v.isBulkImportOld',true);
        }
        if(isValidEmail)
        {
            var PER = JSON.parse(JSON.stringify(component.get('v.pe')));
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
                    if(returnValue){
                        component.set('v.participantDelegate.First_Name__c',returnValue.firstName);
                        component.set('v.participantDelegate.Last_Name__c',returnValue.lastName);
                        component.set('v.participantDelegate.Email__c',returnValue.email);
                        component.set('v.participantDelegate.Phone__c',returnValue.participantPhoneNumber);
                         component.set('v.participantDelegate.Attestation__c',returnValue.DelegateParticipant.Attestation__c);
                        component.set('v.participantDelegateUseExisiting',returnValue.DelegateParticipant);
                        if($A.util.isEmpty(returnValue.DelegateParticipant.Birth_Year__c))
                            component.set('v.participantDelegate.Birth_Year__c','');
                        else
                            component.set('v.participantDelegate.Birth_Year__c',returnValue.DelegateParticipant.Birth_Year__c);   
                        var DelegatePhoneField = component.find('DelegatePhoneName');
                        DelegatePhoneField.setCustomValidity('');
                        DelegatePhoneField.reportValidity();
                      	component.set('v.recordFound',false); //we are using change handle in DulicateDelegateMessageComponent so for update the message we are marking as false and true
                        component.set('v.duplicateDelegateInfo',returnValue);
                        component.set('v.isEmailConfrmBtnClick',false);
                        component.set('v.recordFound',true);
                        component.set('v.useThisDelegate', false);
                        component.set('v.isFirstPrimaryDelegate',false);
                        component.set('v.isBulkImport',returnValue.isBulkImport);
                    }
                    else if(!$A.util.isEmpty(participantDelegateOld.Id)){
                        component.set('v.participantDelegate.Id',participantDelegateOld.Id);
                        component.set('v.participantDelegate.Contact__c',participantDelegateOld.Contact__c);
                        component.set('v.isEmailConfrmBtnClick',false);
                        component.set('v.recordFound',false);
                        component.set('v.useThisDelegate', false);
                        component.set('v.isFirstPrimaryDelegate',false);
                        if(component.get('v.isBulkImportOld'))
                            component.set('v.isBulkImport',true);
                    }
                    else{
                        if(!component.get('v.isFirstPrimaryDelegate')){
                        component.set('v.participantDelegate.Birth_Year__c','');
                        component.set('v.attestAge', false);
                        }
                        component.set('v.participantDelegate.Id',null);
                        component.set('v.isFirstPrimaryDelegate',true); //TO show YOB and picklist when user tries to insert new delegate
                        component.set('v.useThisDelegate', true);
                        component.set('v.isEmailConfrmBtnClick',true);
                        component.set('v.isBulkImport',false);
                    }
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
    },
    
    checkDelegateAge:function(component,participant,participantDelegateOld){
        if(component.get('v.attestAge'))
        {
            var attestCheckbox = component.find('AttestCheckbox');
            attestCheckbox.setCustomValidity('');
            attestCheckbox.reportValidity('');
        }
         communityService.executeAction(
                component,
                'checkDelegateAge',
                {
                    participantJSON: JSON.stringify(participant),
                    delegateParticipantJSON: JSON.stringify(participantDelegateOld)
                },
                function (returnValue) {
                    var isAdultDelegate = returnValue == 'true';
                  //  alert('isAdultDelegate--> ' + isAdultDelegate);
                    if(isAdultDelegate){
                        component.set('v.isAdultDel', true);
                        component.set('v.delNotAdultErrMsg', false);
                        component.set('v.yobBlankErrMsg', false);
                    }else{
                       component.set('v.isAdultDel', false); 
                        if(!component.get('v.isBulkImport')){
                        var attestCheckbox = component.find('AttestCheckbox');
                         attestCheckbox.setCustomValidity('');
                         attestCheckbox.reportValidity('');
                        }
                        component.set('v.attestAge', false);
                         component.set('v.yobBlankErrMsg', false);
                        component.set('v.delNotAdultErrMsg', true);
                       
                    }
                }        
                
            );
    },
    //DOB    
    setDD: function (component, event, helper) {
        var opt = [];
        // opt.push({label: '--', value:'--' });
        var lastDay = component.get('v.lastDay');
        for(var i = 1 ; i<=lastDay ;i++){
            var x = i.toString();
            if(i<10)
                x='0'+x;
            opt.push({label: x, value: x });
        }
        component.set("v.optionsDD",opt);
    },
    setMM: function (component, event, helper) {
        var opt = [];
        // opt.push({label: '----', value:'--' });
        opt.push({label: 'January', value:'01' });
        opt.push({label: 'February', value:'02' });
        opt.push({label: 'March', value:'03' });
        opt.push({label: 'April', value:'04' });
        opt.push({label: 'May', value:'05' });
        opt.push({label: 'June', value:'06' });
        opt.push({label: 'July', value:'07' });
        opt.push({label: 'August', value:'08' });
        opt.push({label: 'September', value:'09' });
        opt.push({label: 'October', value:'10' });
        opt.push({label: 'November', value:'11' });
        opt.push({label: 'December', value:'12' });       
        component.set("v.optionsMM",opt);
    },
    setYYYY: function (component, event, helper) {
        var opt = [];
        // opt.push({label: '----', value:'----' });
        for(var i = parseInt(new Date().getFullYear()) ; i>=1900 ;i--){
            opt.push({label: i.toString(), value: i.toString() });
        }        
        //helper.setAge(component,event,helper);
        component.set("v.optionsYYYY",opt);
        var format = component.get("v.dobConfig");
        component.set("v.showDay",format.includes('DD'));
        component.set("v.showMonth",format.includes('MM'));
        component.set("v.showDate",true);
        
    },
    setAge: function (component, event, helper){
        var opt = [];
        var ageStart = parseInt(component.get("v.ageStart"));
        var ageEnd = parseInt(component.get("v.ageEnd"));
        component.set("v.valueAge",null);

        for(var i = ageStart ; i<= ageEnd ;i++){
            opt.push({label: i.toString(), value: i.toString() });
        }
        component.set("v.ageOpt",opt);
    },
    setMinMaxAge: function (component, event, helper){
        var format = component.get("v.dobConfig");
        var partDOB='';
        if(format != 'DD-MM-YYYY'){
            if(format == 'MM-YYYY'){
                partDOB = component.get('v.valueYYYY')+'-'+component.get('v.valueMM')+'-'+component.get('v.lastDay');
            }
            else if(format == 'YYYY'){
                partDOB = component.get('v.valueYYYY')+'-12-31';
            }
            if(!partDOB.includes('--')){
                var dob = new Date(partDOB);  
                var month_diff = Date.now() - dob.getTime();
                var age_dt = new Date(month_diff); 
                var year = age_dt.getUTCFullYear();  
                if((year - 1970)>=0){
                    var age = Math.abs(year - 1970);  
                    component.set("v.ageStart",age);
                    var endAge = age;
                    if((dob.getMonth()==new Date().getMonth() && dob.getDate()!=new Date().getDate() ) || format == 'YYYY'){
                        endAge++;
                    }
                    component.set("v.ageEnd",endAge);
                    helper.setAge(component, event, helper); 
                }
                else{
                    component.set("v.ageStart",'0');
                    component.set("v.ageEnd",'0');
                    helper.setAge(component, event, helper);
                }
            }   
        }
    },
    YYYYChange: function (component, event, helper){
        if(component.get('v.valueMM')=='02'){
            if(component.get('v.valueYYYY') =='----' || helper.isLeapYear(component, event, helper)){
                component.set("v.lastDay",29);
            }     
            else{
                component.set("v.lastDay",28);
            }
        }
        if( parseInt(component.get('v.valueDD')) > component.get('v.lastDay')){
            component.set("v.valueDD",component.get("v.lastDay").toString());
        }
        helper.setDD(component, event, helper);
        component.set("v.showDate",false);
        component.set("v.showDate",true);
        helper.validateDOB(component, event, helper);
        helper.setMinMaxAge(component, event, helper);

        //this.handleDateChange();
    },
    isLeapYear: function (component, event, helper){
        var valYYY = component.get('v.valueYYYY');
        if(parseInt(valYYY)%400==0){
            return true;
        }
        if(parseInt(valYYY)%100==0){
            return false;
        }
        if(parseInt(valYYY)%4==0){
            return true;
        }
        return false;
    },
    MMChange: function (component, event, helper){
        
        var maxDayMonths = ['01','03','05','07','08','10','12'];
        var minDayMonths = ['04','06','09','11'];
        component.set("v.lastDay",31);
        if(maxDayMonths.includes(component.get('v.valueMM'))){
            component.set("v.lastDay",31);
        }
        else if(minDayMonths.includes(component.get('v.valueMM'))){
            component.set("v.lastDay",30);
        }
        else if(component.get('v.valueMM') == '02'){
            if(component.get('v.valueYYYY') =='----' || helper.isLeapYear(component, event, helper)){
                component.set("v.lastDay",29);
            }     
            else{
                component.set("v.lastDay",28);
            }            
        }
        if( parseInt(component.get('v.valueDD')) > component.get("v.lastDay")){
            component.set('v.valueDD', component.get("v.lastDay").toString());
        }
        helper.setDD(component, event, helper);
        component.set("v.showDate",false);
        component.set("v.showDate",true);
        helper.validateDOB(component, event, helper);
        helper.setMinMaxAge(component, event, helper);

        //this.handleDateChange();
    },
    DDChange: function (component, event, helper){
        helper.validateDOB(component, event, helper);
    },
    ageChange: function (component, event, helper){
        var age = component.get("v.valueAge");
        var part = component.get("v.participant");
        part.Age__c	= age;
        var agemax = component.get("v.ageEnd");
        var agemin = component.get("v.ageStart");
        if(agemin!=agemax && age==agemax){            
            var format = component.get("v.dobConfig");
            if(format == 'YYYY'){
                part.Date_of_Birth__c = component.get('v.valueYYYY')+'-01-01';
            } 
            else if(format == 'MM-YYYY'){
                part.Date_of_Birth__c = component.get('v.valueYYYY')+'-'+component.get('v.valueMM')+'-01';   
            }            
            helper.doCheckDateOfBith(component, event, helper); 
        }
        else if(agemin!=agemax && age==agemin){
            helper.validateDOB(component, event, helper);
        }
        else if(agemin==agemax && age==0){
            var format = component.get("v.dobConfig");
            if(format == 'YYYY'){
                part.Date_of_Birth__c = component.get('v.valueYYYY')+'-01-01';
            } 
            else if(format == 'MM-YYYY'){
                part.Date_of_Birth__c = component.get('v.valueYYYY')+'-'+component.get('v.valueMM')+'-01';   
            }            
            helper.doCheckDateOfBith(component, event, helper); 
        }
        $A.enqueueAction(component.get('c.doCheckFields'));
    },
    validateDOB: function (component, event, helper){
        var format = component.get("v.dobConfig");
        var part = component.get("v.participant");
        var dobDate;
        var today = new Date();
        component.set("v.futureDate",false);
        component.set("v.futureDateDDErr",null);
        component.set("v.futureDateMMErr",null);
        if(format == 'DD-MM-YYYY'){
            part.Date_of_Birth__c = component.get('v.valueYYYY')+'-'+component.get('v.valueMM')+'-'+component.get('v.valueDD');            
        }
        else if(format == 'MM-YYYY'){
            part.Date_of_Birth__c = component.get('v.valueYYYY')+'-'+component.get('v.valueMM')+'-'+component.get('v.lastDay');            
        }
        else if(format == 'YYYY'){
            part.Date_of_Birth__c = component.get('v.valueYYYY')+'-12-31';
        }        
        if(!part.Date_of_Birth__c.includes('--')){
            component.set("v.participant",part);
            helper.doCheckDateOfBith(component, event, helper);
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
    },
    doCheckDateOfBith: function (component, event, helper) {
        component.find('spinner').show();
        let parent = component.get('v.parentComponent');
        if (parent!=null && parent.checkDateOfBith) {
            parent.checkDateOfBith(function(result) {
                component.set('v.participant.Adult__c', result);
                 $A.enqueueAction(component.get('c.doCheckFields'));
                component.find('spinner').hide(); 
            });
        }else {
            if(parent!=null && parent.checkParticipantDateOfBith){
                parent.checkParticipantDateOfBith(function(result) {
                    component.set('v.participant.Adult__c', result);
                    $A.enqueueAction(component.get('c.doCheckFields'));
                    component.find('spinner').hide(); 
                });
            }
        }
        if( component.get('v.needsGuardian') && 
           component.get('v.participant.Adult__c') 
           && (component.get('v.participant.email__c') ==''
               || !component.get('v.participant.email__c')
              ) 
          ){
            component.set('v.createUsers',false);
        }
    }

});