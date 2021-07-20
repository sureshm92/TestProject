({
    calloutSession : function(component) {
        var self = this;     
        if(component.get('v.sessionToken')==undefined)
        {
            communityService.executeAction(
                component,
                'getSessionToken',{},          
                function (returnValue) {
                    
                    component.set('v.sessionToken',returnValue);
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
        var accessToken= component.get('v.accessToken');       
        communityService.executeAction(
            component,
            'getHumanSourcesList',{accessToken : accessToken},          
            function (returnValue) {
                component.find('spinner').hide();
                component.set('v.medicalProviders',returnValue);
                
            }
        ); 
        
    },
    
    launchConnect :  function(component) {
        console.log('session token',component.get('v.sessionToken'));
        var self = this;      
        HumanConnect.open({
            token : component.get('v.sessionToken'), // "session_token" or "id_token"
            onClose : function(response) {
                console.log("Widget closed with error", response.status);
                var results = response.sessionResults;
                console.log("User connected",results.connectedSources.length,"data sources");
                console.log("user connected sources",results.connectedSources);
                
                console.log("User closed Connect", response);
                var results = response.sessionResults;
                console.log('results',results);
                
            },
            onConnectSource : function(response) {
                
                console.log("User connected a source", response);
                self.listProviders(component);
            },
            onDisconnectSource : function(response) {
                console.log("User disconnected a source", response);
                console.log('xyz',response.status);
                self.listProviders(component);
            }
        });
        
    }
    
    
})
