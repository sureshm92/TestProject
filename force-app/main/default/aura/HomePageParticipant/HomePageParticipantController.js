/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', null,
            function (returnValue) {
                var initData = JSON.parse(returnValue);
                var pe = initData.pe;
                var welcomeMessage = $A.get('$Label.c.PG_Home_Welcome_Message');
                welcomeMessage = welcomeMessage.replace('##UserName', pe.Participant__r.Full_Name__c);
                component.set('v.welcomeMessage', welcomeMessage);
                component.set('v.pe', pe);
                component.find('spinner').hide();
            });
    }
})