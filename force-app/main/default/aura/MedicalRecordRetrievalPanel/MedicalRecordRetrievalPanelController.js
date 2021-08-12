({
    
    doInit: function(component, event, helper) {
        var obj = component.get("v.participantState");
        const humanApiVendors = component.get('v.participantState.medicalVendors');
        let isHumanApiVendorChecked = false;
        for (const item in humanApiVendors) {
            isHumanApiVendorChecked = humanApiVendors[item].Medical_Vendor__c === "HumanApi";
            break;
         }
        component.set('v.isHumanApiChecked',isHumanApiVendorChecked);
       
        if(obj.pe.Human_Id__c != undefined){
        helper.calloutAccessToken(component); 
        }
        else
        {                
            
            component.find('spinner').hide();
        }
                  
    },
    
    openURL : function(component, event, helper) {
        window.open('https://hapi-connect.humanapi.co?token='+component.get('v.sessionToken'));
    },
    
    
    manageSources :  function(component, event, helper) {
        helper.calloutSession(component);
        
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
        component.find('spinner').show();
        helper.calloutAccessToken(component); 
       // component.set("v.success",false);
        console.log('itemsChange');
    }
})