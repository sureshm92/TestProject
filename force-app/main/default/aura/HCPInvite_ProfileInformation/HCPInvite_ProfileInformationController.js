({
    doInit : function(cmp, event, helper) {
        cmp.find('spinner').show();
        if(!cmp.get('v.ContactUserWrapperData')){
            var action = cmp.get('c.getInitUserDetails');
            action.setParams({ 
                userId : cmp.get("v.userId")
            });
            action.setCallback(this,function(response){
                let ReturnValue = response.getReturnValue();
                cmp.set('v.prefixList',response.prefixList);
                cmp.set('v.ContactUserWrapperData',ReturnValue);
                cmp.set('v.countriesLVList',ReturnValue.countriesLVList);
                if (ReturnValue.objCurrentContact.MailingCountryCode) {
                    let statesByCountryMap = ReturnValue.statesByCountryMap;
                    let states = statesByCountryMap[ReturnValue.objCurrentContact.MailingCountryCode];
                    cmp.set('v.statesLVList', states);
                }
                cmp.find('spinner').hide();
            });
            $A.enqueueAction(action); 
        }
        else{
            var UserContactWrapper  = cmp.get('v.ContactUserWrapperData');
            cmp.set('v.PreviousPassword',UserContactWrapper.strPassword);
            cmp.set('v.countriesLVList',UserContactWrapper.countriesLVList);
            if (UserContactWrapper.objCurrentContact.MailingCountryCode) {
                var statesByCountryMap = UserContactWrapper.statesByCountryMap;
                var states = statesByCountryMap[UserContactWrapper.objCurrentContact.MailingCountryCode];
                cmp.set('v.statesLVList', states);
            }
            cmp.find('spinner').hide();
        }
        cmp.find('spinner').hide();
        
    },
    
    doCountryCodeChanged:function(component,evt,helper){
        component.find('spinner').show();
        var statesByCountryMap = component.get('v.ContactUserWrapperData.statesByCountryMap');
        var objContact = component.get('v.ContactUserWrapperData.objCurrentContact');
        var states = statesByCountryMap[objContact.MailingCountryCode];
        component.set('v.statesLVList', states);
        component.set('v.ContactUserWrapperData.objCurrentContact.MailingState', null);
        component.find('spinner').hide();
    },  
    handleSaveBtn :function(cmp,evt){
        cmp.find('spinner').show();
        cmp.set('v.isError',false);
        communityService.executeAction(
            cmp, 
            'checkPassword',
            {
                UserId : cmp.get('v.userId'),
                strPass : cmp.get('v.ContactUserWrapperData.strPassword'),
                strCnfrmPass : cmp.get('v.ContactUserWrapperData.strConfrmPassword')
            },
            function (returnValue) {
                var ErrorMessage = ''; 
                const ErrorSuffix = ': ' + $A.get('$Label.c.RH_ProfileInfoErrorMsz') + '<br/>'   ;
                if(!cmp.get('v.ContactUserWrapperData.objCurrentContact.FirstName')) 
                    ErrorMessage += $A.get('$Label.c.RH_RP_First_Name')  + ErrorSuffix ; 
                if(!cmp.get('v.ContactUserWrapperData.objCurrentContact.LastName'))
                    ErrorMessage += $A.get('$Label.c.RH_RP_Last_Name')  + ErrorSuffix ;
                if(!cmp.get('v.ContactUserWrapperData.objCurrentContact.Account.Name'))
                    ErrorMessage += $A.get('$Label.c.PG_AS_F_Institute_Name')  + ErrorSuffix ;
                if(!cmp.get('v.ContactUserWrapperData.objCurrentContact.MailingStreet'))
                    ErrorMessage +=  $A.get('$Label.c.PG_AS_F_Institute_Address_Line')  + ErrorSuffix ; 
                if(!cmp.get('v.ContactUserWrapperData.objCurrentContact.MailingCity'))
                    ErrorMessage += $A.get('$Label.c.PG_AS_F_Institute_City')   + ErrorSuffix ;   
                if(cmp.get('v.ContactUserWrapperData.objCurrentContact.MailingCountryCode') && 
                   cmp.get('v.statesLVList').length > 0 && !cmp.get('v.ContactUserWrapperData.objCurrentContact.MailingStateCode'))
                    ErrorMessage += $A.get('$Label.c.PG_AS_F_Institute_State')   + ErrorSuffix ; 
                
                if(!cmp.get('v.ContactUserWrapperData.objCurrentContact.MailingCountryCode'))
                    ErrorMessage += $A.get('$Label.c.PG_AS_F_Institute_Country') + ErrorSuffix ; 
                if(!cmp.get('v.ContactUserWrapperData.objCurrentContact.MailingPostalCode'))
                    ErrorMessage += $A.get('$Label.c.PG_AS_F_Institute_Zip_Postal_Code')  + ErrorSuffix ;  
                if(!cmp.get('v.ContactUserWrapperData.objCurrentContact.Phone'))
                    ErrorMessage += $A.get('$Label.c.PG_AS_F_Institute_Phone_Number')  + ErrorSuffix ;  
                
                
                if(ErrorMessage != ''){
                    cmp.set('v.isError',true);
                    cmp.set('v.ErrorMessage',ErrorMessage); 
                    window.scrollTo(0, 0);
                    cmp.find('spinner').hide();
                    return; 
                }
                else{  
                    communityService.executeAction(
                        cmp,
                        'saveUserData',
                        {
                            strUserWrapper:JSON.stringify(cmp.get('v.ContactUserWrapperData')),
                            boolShouldUpdatePass : cmp.get('v.PreviousPassword') != cmp.get('v.ContactUserWrapperData.strPassword') ? true : false  
                        },
                        function (returnValue) {
                            var inviteEvt = cmp.getEvent("HCPInviteEvt"); 
                            
                            inviteEvt.setParams({ 
                                "UserName" :  cmp.get('v.UserName'),
                                "UserId" : cmp.get('v.userId'),
                                "componentCalled" : "ProfileInfo",
                                "contactUserWrapper" : cmp.get('v.ContactUserWrapperData')
                            });
                            cmp.find('spinner').hide();
                            inviteEvt.fire();
                        },
                        function (error) {
                            let errmsg = communityService.getErrorMessage(error).split('\n')[0];
                            cmp.set('v.isError',true);
                            cmp.set('v.ErrorMessage',errmsg);
                            window.scrollTo(0, 0);
                            cmp.find('spinner').hide();
                        }
                    ); 
                    
                }
                
            },
            function (error) {
                let errmsg = communityService.getErrorMessage(error).split('\n')[0];
                cmp.set('v.isError',true);
                cmp.set('v.ErrorMessage',errmsg);
                window.scrollTo(0, 0);
                cmp.find('spinner').hide();
            }
        );
        
    },
    
    validateInput : function(cmp,evt,helper){
        var password = cmp.get('v.passwrd');
        var cnfrmPass = cmp.get('v.cnfrmPasswrd');
        if(password && cnfrmPass){
            cmp.set('v.btnDisabled',false);    
        }
        else{
            cmp.set('v.btnDisabled',true);    
        }
    }
})