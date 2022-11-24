({
    doInit: function (component, event, helper) {
        var language = communityService.getUrlParameter('language');
        if (!language || language === '') {
            language = 'en_US';
        }
        var rtl_language = $A.get('$Label.c.RTL_Languages');
        component.set('v.isRTL', rtl_language.includes(language));
    },

    handleChanged: function(component, message, event) { 
        // Read the message argument to get the values in the message payload
       if (message != null) {
           var SuccessMessage = message.getParam("SuccessMessage");
            component.set("v.showSuccessMessage", SuccessMessage);
       }
     }
});
