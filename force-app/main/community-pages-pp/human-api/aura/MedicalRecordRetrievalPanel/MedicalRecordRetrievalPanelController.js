({
    
    doInit: function(component, event, helper) {
        var obj = component.get("v.participantState");
        console.log('obj=>',JSON.stringify(obj));
        if (communityService.getCurrentCommunityMode().hasPastStudies){
            component.set('v.hasPastStudies',communityService.getCurrentCommunityMode().hasPastStudies);
            
        }
        const humanApiVendors = component.get('v.participantState.medicalVendors');
       /** if(obj.value == 'PARTICIPANT' &&  obj.isDelegate && obj.hasPatientDelegates)
        {
            alert('set1');
             component.set('v.showMedicalCard',true);
        } **/
        let isHumanApiVendorChecked = false;
         if(humanApiVendors != null){
        for (const item in humanApiVendors) {
            if(humanApiVendors != null){
            isHumanApiVendorChecked = humanApiVendors[item].Medical_Vendor__c === "HumanApi";
            break;

            }
        }
         }
        component.set('v.isHumanApiChecked',isHumanApiVendorChecked);
        if(communityService.getCurrentCommunityMode().currentDelegateId){
            component.set('v.showAuthorizationLink',isHumanApiVendorChecked);
        }

        

              if(((component.get('v.hasPastStudies') || obj.value == 'ALUMNI') && (!obj.hasPatientDelegates || communityService.getCurrentCommunityMode().currentDelegateId))){
                  communityService.executeAction(
                component,
                'getHumanAPIPastPEList',{ 
                    contactId :obj.currentContactId
                },          
                function (returnValue) {
                    var check = false;
                    component.set('v.referrals',returnValue);
                        if(returnValue){
                            if(obj.pe != null && obj.pe.Human_Id__c != null && obj.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c && !component.get('v.isHumanApiChecked') )
                            {
                                check =true;
                            }
                            
                            //console.log('')
                        for (const item in returnValue) {
                          
                            if(communityService.getCurrentCommunityMode().currentPE && obj.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c){
                                if(returnValue[item].value.includes(communityService.getCurrentCommunityMode().currentPE)){
                                    if(!component.get('v.isHumanApiChecked') ){
                                         var list = component.get('v.referrals');
                                        if(!check)
                            {
                                         list.splice(item, 1); 
                            } 

                                         component.set('v.referrals',list);
                                        if(list[0] && !check){
                                        component.set('v.defaultStudy',list[0].value);
                                        }
                                        else{
                                            if(list.length>0 ){
                                              component.set('v.defaultStudy',list[item].value);
                                            }

                                        }

                                    }else{
                                    console.log('returnValue[item].value set',returnValue[item].value);
                                     component.set('v.defaultStudy',returnValue[item].value);
                                    }
                                break;
                            }
                            }
                            else{
                              component.set('v.defaultStudy',returnValue[0].value);
                            }
                        }
        if(component.get('v.hasPastStudies')){
                 if(component.get('v.referrals').length > 1  && component.get('v.defaultStudy').includes(communityService.getCurrentCommunityMode().currentPE)){
                          component.set('v.showAuthorizationLink',component.get('v.isHumanApiChecked'));
                 
                 }
            else{
               

                    component.set('v.showAuthorizationLink',component.get('v.hasPastStudies'));
                 }
        }

                    helper.calloutAccessToken(component,component.get('v.defaultStudy'));

                    }
                    
                }
            );  
        }
         

        if(obj.value != 'ALUMNI'){

        if(obj.pe.Human_Id__c != undefined){
        helper.calloutAccessToken(component); 
        }
        else
        {   
            
            if(obj.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c){
                   
                    if(component.get('v.isHumanApiChecked')){

                        component.set('v.showMedicalCard',true);
                        component.set('v.initialized',true);
                    }
                    else {

                        if((component.get('v.isAuthorised') && obj.pe.Human_Id__c)){
                             component.set('v.showMedicalCard',true);
                             component.set('v.initialized',true);
                        }
                    }
                }
                else{
                    component.set('v.showMedicalCard',false);
                }
            
            component.find('spinner').hide();
        }
        }
		
		//Added to create content for external disclaimer i Icon
        communityService.executeAction(component, 'getCommunityName', {}, function (returnValue) {
            if (returnValue !== null) {
                var disclaimerText =
                	$A.get('$Label.c.RH_Manage_Auth_Disclaimer') +
                    ' ' +
                    $A.get('$Label.c.RH_External_Link_Disclaimer') +
                    ' ' +
                    returnValue +
                    ' ' +
                    $A.get('$Label.c.RH_External_Link_Disclaimer1');
                component.set('v.externalLinkDisclaimer', disclaimerText);
            }
        });
                  
    },
    
    openURL : function(component, event, helper) {
        window.open('https://hapi-connect.humanapi.co?token='+component.get('v.sessionToken'));
    },
    
      
    manageSources :  function(component, event, helper) {
        helper.calloutSession(component,component.get('v.defaultStudy'));
        
    },
    doListProviders: function(component, event, helper) {
        component.set('v.initialized',false);
        component.find('spinner').show();
                if(component.get('v.hasPastStudies')){
                 if(component.get('v.defaultStudy').includes(communityService.getCurrentCommunityMode().currentPE)){
                          component.set('v.showAuthorizationLink',component.get('v.isHumanApiChecked'));
                 
                 }else{
                     component.set('v.showAuthorizationLink',component.get('v.hasPastStudies'));

                 }
        }

        helper.calloutAccessToken(component,component.get('v.defaultStudy'));
        
    },
    
    downloadPDF : function(component, event, helper) {
        communityService.executeAction(
            component,
            'downloadBlob',{},          
            function (returnValue) {
                
                //component.set('v.accessToken',returnValue);
                //self.listProviders(component);
                console.log(returnValue);
                //const url = window.URL.createObjectURL(returnValue);
                var a = document.createElement("a"); //Create <a>
                a.href = "data:application/pdf;base64," + returnValue; //Image Base64 Goes here
                a.download = "medicalreport.pdf"; //File name Here
                a.click(); //Downloaded file
                //window.open("data:application/pdf;base64," + returnValue);
                
            }
        );  
    },
    listProvidersChange : function(component, event, helper) {
        //component.find('spinner').show();
        helper.calloutAccessToken(component,component.get('v.defaultStudy')); 
       // component.set("v.success",false);
    }
})