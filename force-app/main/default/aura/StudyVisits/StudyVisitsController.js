/**
 * Created by Igor Malyuta on 12.04.2019.
 */
({
    doInit : function(component, event, helper) {
        component.find('spinner').show();
        component.set('v.initialized', false);
        communityService.executeAction(component, 'getParticipantVisits', {
            'visitMode': component.get('v.visitMode')
        }, function(response) {
            component.set('v.visitWrappers', response);
            component.set('v.initialized', true);
            component.find('spinner').hide();
        });
    },

    onTravel : function (component, event, helper) {
        component.find('popup').execute(function () {
            window.open($A.get('$Label.c.Travel_Support_Link'), '_blank');
        });
    },

    createEditTask : function (component, event, helper) {
        console.log('asdasds');
    }
})