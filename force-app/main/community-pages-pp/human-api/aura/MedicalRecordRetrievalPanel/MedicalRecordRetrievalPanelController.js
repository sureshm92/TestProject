({
    
    doInit: function(component, event, helper) {
        /**helper.calloutAccessToken(component); **/
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
    }
})