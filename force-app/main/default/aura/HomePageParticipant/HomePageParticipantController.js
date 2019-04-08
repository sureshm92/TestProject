/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', null,
            function (returnValue) {
                var initData = JSON.parse(returnValue);
                var pe = initData.pe;
                var pse = initData.pse;
                var welcomeMessage = $A.get('$Label.c.PG_Home_Welcome_Message');
                welcomeMessage = welcomeMessage.replace('##UserName', initData.name);
                component.set('v.welcomeMessage', welcomeMessage);
                component.set('v.pe', pe);
                component.set('v.pse', pse);
                component.find('spinner').hide();
            });

        component.set('v.state', communityService.getParticipantState());
    }
})