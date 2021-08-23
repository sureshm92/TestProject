({
    
    doInit: function(component, event, helper) {
        var obj = component.get("v.participantState");
        console.log('ob-->'+obj.hasPatientDelegates);
        if (communityService.getCurrentCommunityMode().hasPastStudies){
            component.set('v.hasPastStudies',communityService.getCurrentCommunityMode().hasPastStudies);
            
        }

              if((component.get('v.hasPastStudies')|| obj.value == 'ALUMNI') && !obj.hasPatientDelegates){
            communityService.executeAction(
                component,
                'getHumanAPIPastPEList',{ 
                    contactId :obj.currentContactId
                },          
                function (returnValue) {
                    component.set('v.referrals',returnValue);
                    if(returnValue){
                    component.set('v.defaultStudy',returnValue[0].value);
                        console.log('ob'+returnValue[0].value);
                    helper.calloutAccessToken(component,returnValue[0].value);

                    }
                    
                }
            );  
        }
         
        const humanApiVendors = component.get('v.participantState.medicalVendors');
        console.log('humanApiVendors'+humanApiVendors);
        let isHumanApiVendorChecked = false;
         if(humanApiVendors != null){
        for (const item in humanApiVendors) {
            console.log('humanApiVendors'+humanApiVendors);
            if(humanApiVendors != null){
            isHumanApiVendorChecked = humanApiVendors[item].Medical_Vendor__c === "HumanApi";
            break;

            }
        }
         }
        component.set('v.isHumanApiChecked',isHumanApiVendorChecked);
                console.log('obj.value'+obj.value);

        if(obj.value != 'ALUMNI'){
                    console.log('obj.value'+obj.value);

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
                  
    },
    
    openURL : function(component, event, helper) {
        window.open('https://hapi-connect.humanapi.co?token='+component.get('v.sessionToken'));
    },
    
    
    manageSources :  function(component, event, helper) {
        console.log('inisde-->'+component.get('v.defaultStudy'));
        helper.calloutSession(component,component.get('v.defaultStudy'));
        
    },
    doListProviders: function(component, event, helper) {
        component.set('v.initialized',false);
       component.find('spinner').show();
        console.log('inisde-->'+component.get('v.defaultStudy'));
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
        console.log('itemsChange');
    }
})