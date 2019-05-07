/**
 * Created by user on 23-Apr-19.
 */
({
    doInit: function (component, event, helper) {
        if(component.get('v.participantId') == undefined) {
            component.set('v.participantId', null)
        }
        communityService.executeAction(component, 'getExternalParticipants', {
            'participantId': component.get('v.participantId')
        }, function (participants) {
            console.log(participants[0]);
            component.set('v.participants', participants);
        });
        communityService.executeAction(component, 'init', null, function (participant) {
            component.set('v.participant', participant);
        });
    },

    doSave: function (component, event, helper) {
        console.log(JSON.stringify(component.get('v.participant')));
        communityService.executeAction(component, 'saveParticipant', {
            'participantJSON': JSON.stringify(component.get('v.participant'))
        }, function (participants) {
            component.set('v.participants', participants);
        });
    }
})