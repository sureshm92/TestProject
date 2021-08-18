({
    calloutSession : function(component) {
        var self = this;     
        if(component.get('v.sessionToken')==undefined)
        {
            communityService.executeAction(
                component,
                'getSessionToken',{},          
                function (returnValue) {
                    component.set('v.humanid',returnValue.humanId);
                    component.set('v.sessionToken',returnValue.id_token);
                    self.launchConnect(component);
                }
            );  
        }
        else
        {
            self.launchConnect(component);  
        }
        
    },
    calloutAccessToken : function(component) {
        var self = this;      
        try{
            if(component.get('v.accessToken')==undefined)
            {
                communityService.executeAction(
                    component,
                    'getAccessToken',{},          
                    function (returnValue) {
                        component.set('v.accessToken',returnValue);
                        
                        self.listProviders(component);
                    }
                );  
            }
            else
            {
                self.listProviders(component);
            }
        }
        catch(e)
        {
            alert(e.message());
        }
        
    },
    
    listProviders : function(component) {   
        var obj = component.get("v.participantState");
        communityService.executeAction(
            component,
            'getHumanSourcesList',{},          
            function (returnValue) {
                component.find('spinner').hide();
                component.set('v.medicalProviders',returnValue);
                if(returnValue.length > 0){
                    component.set('v.isAuthorised', true);
                }
                else{
                    component.set('v.isAuthorised', false);
                }
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
        ); 
        
    },
    
    launchConnect :  function(component) {
        var self = this;      
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