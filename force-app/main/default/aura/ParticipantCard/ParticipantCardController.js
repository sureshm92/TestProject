/**
 * Created by Alexey Moseev.
 */

({

    doInit: function (component, event, helper) {
        if (component.get('v.hasEmancipatedParticipants') && communityService.getUserMode() != 'Participant') {
            component.getEvent('onInit').fire();
        }
    }

});