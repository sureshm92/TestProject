/**
 * Created by Igor Malyuta on 12.04.2019.
 */
({
    doInit : function(component, event, helper) {
        communityService.executeAction(component, 'getParticipantVisits', null, function(response) {
            component.set('v.visits', JSON.parse(response));
            component.find('spinner').hide();
        });
    },

    onTravel : function (component, event, helper) {
        component.find('popup').show();
    },

    onClickOk : function (component, event, helper) {
        //redirect to url in new window
        window.open('https://www.iqvia.com/', '_blank') ;
        component.find('popup').hide();
    }
})