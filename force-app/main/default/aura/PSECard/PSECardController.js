/**
 * Created by alekseymoseev on 1/31/20.
 */

({

    doInit: function (component, event, helper) {
        if (component.get('v.pe')) {
            let pe = component.get('v.pe');
            if (pe.Participant__r && pe.Participant__r.Adult__c && communityService.getUserMode() !== 'Participant') {
                component.set('v.parent.parent.hasEmancipatedParticipants', pe.Participant__r.Adult__c);
            }
        }
    }

});