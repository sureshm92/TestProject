/**
 * Created by user on 23-Apr-19.
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getExternalParticipants', {
            'participantId': component.get('v.participantId')
        }, function (participants) {
            component.set('v.participants', participants);
        });
    }
})