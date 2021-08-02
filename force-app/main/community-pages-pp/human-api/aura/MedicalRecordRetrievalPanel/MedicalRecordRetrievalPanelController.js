({
    
    doInit: function(component, event, helper) {
        var obj = component.get("v.participantState");
        console.log('obj',obj.medicalVendors);
        console.log('peggg',(obj.pe.Human_Id__c==undefined));
        console.log('ggggg',obj.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c);
        console.log(']]]]]]',component.get("v.participantState"));
        if(obj.pe.Human_Id__c != undefined){
            console.log('inside humanId undefined-->'+obj.pe.Human_Id__c);
        helper.calloutAccessToken(component); 
        }
        else
        {                
            
            console.log('inside humanId defined-->'+obj.pe.Human_Id__c);

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
        //console.log('hello');
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
       // alert('itemschange');
        component.find('spinner').show();
        helper.calloutAccessToken(component); 
       // component.set("v.success",false);
        console.log('itemsChange');
    }
})