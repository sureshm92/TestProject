/**
 * Created by Igor Malyuta on 12.04.2019.
 */
({
    doInit : function(component, event, helper) {
        communityService.executeAction(component, 'getParticipantVisits', null, function(response) {
            component.set('v.visits', JSON.parse(response));
            component.set('v.initialized', true);
            component.find('spinner').hide();
        });
    },

    onTravel : function (component, event, helper) {
        component.find('popup').execute(function () {
            window.open($A.get('$Label.c.Travel_Support_Link'), '_blank');
        });
    }
})