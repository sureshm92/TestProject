/**
 * Created by Alexey Moseev.
 */

({

    doInit: function (component, event, helper) {
        let participant = component.get('v.pe.Participant__r');
        if (!participant.Adult__c && participant.Date_of_Birth__c && participant.Emancipation_in_progress__c) {
            let birthDate = new Date(participant.Date_of_Birth__c);
            let todayDate = new Date();
            component.set('v.needEmancipationProcess', birthDate >= todayDate);
        }
    }

});