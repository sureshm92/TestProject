({
    calloutSession : function(component,referralId) {
        console.log('inside calloutSession referralId--->'+referralId)
        var self = this;     
            communityService.executeAction(
                component,
                'getSessionToken',{
                    
                    referralId : referralId
                    
                    
                },          
                function (returnValue) {
                    console.log('inside calloutSession',returnValue)

                    component.set('v.humanid',returnValue.humanId);
                    component.set('v.sessionToken',returnValue.id_token);
                    self.launchConnect(component);
                }
            );  
       
        
    },
    calloutAccessToken : function(component,referralId) {
        //debugger;
        //component.find('spinner').show();
        var self = this;
        
        try{
            
                
                console.log('referralId:-:',referralId);
               //var referralId = referralNewId
               component.set('v.peId',referralId);
                communityService.executeAction(
                    component,
                    'getAccessToken',{
                        referralId : referralId
                    },          
                    function (returnValue) {
                        component.set('v.accessToken',returnValue);
                        
                        self.listProviders(component,referralId);
                    }
                );  
            
        }
        catch(e)
        {
            alert(e.message());
        }
        
    },
    
    listProviders : function(component,referralId) {   
        console.log('referralId in listProviders',referralId);
        var obj = component.get("v.participantState");
        
        communityService.executeAction(
            component,
            'getHumanSourcesList',{
                 referralId : referralId
            },          
            function (returnValue) {
                
                console.log('listproviders',returnValue);
                component.set('v.medicalProviders',returnValue);
                if(returnValue.length > 0){
                    component.set('v.isAuthorised', true);
                }
                else{
                    component.set('v.isAuthorised', false);
                }
                if(obj.value != 'ALUMNI'){
                if(obj.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c){
                   
                    if(component.get('v.isHumanApiChecked')){

                        component.set('v.showMedicalCard',true);
                    }
                    else {

                        if((component.get('v.isAuthorised') && obj.pe.Human_Id__c)){
                             component.set('v.showMedicalCard',true);
                        }
                    }
                }
                else{
                    component.set('v.showMedicalCard',false);
                }
                }
                component.find('spinner').hide();
                component.set('v.initialized',true);
            }
        ); 
        
    },
    
    launchConnect :  function(component) {
        var self = this;     
        console.log('sess',component.get('v.sessionToken'));
        HumanConnect.open({
            token : component.get('v.sessionToken'), // "session_token" or "id_token"
            onClose : function(response) {
                console.log("Widget closed with error", response.status);
                var results = response.sessionResults;
                var results = response.sessionResults;
                component.set("v.success",results.connectedSources);                
               
            },
            onConnectSource : function(response) {
                
              var results = response.sessionResults;
                var results = response.sessionResults;
                component.set("v.success",results.connectedSources);     
            },
            onDisconnectSource : function(response) {
               var results = response.sessionResults;
                var results = response.sessionResults;
                component.set("v.success",results.connectedSources);     
            }
        });
        
    }
    
    
})