/**
 * Created by Leonid Bartenev
 */
({
    initData: function (component) {
        component.set('v.participant', {
            sobjectType: 'Participant__c',
            Mailing_Country_Code__c: 'US'
        });
        component.set('v.pe', {
            sobjectType: 'Participant_Enrollment__c',
            Study_Site__c: component.get('v.ss.Id')
        });
    },

    createParticipant: function (component, callback) {
        component.find('spinner').show();
        var pe = component.get('v.pe');
        var participant = component.get('v.participant');
        communityService.executeAction(component, 'saveParticipant', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe)
        }, function () {
            communityService.showSuccessToast('','Participant successfully added');
            callback();
        }, null, function () {
            component.find('spinner').hide();
        });
    }
})