/**
 * Created by Igor Malyuta on 31.05.2019.
 */

({
    setParticipantSnapshot: function(component){
        var participant = component.get('v.participant');
        if(!participant.First_Name__c) participant.First_Name__c = '';
        if(!participant.Last_Name__c) participant.Last_Name__c = '';
        if(!participant.Middle_Name__c) participant.Middle_Name__c = '';
        if(!participant.Date_of_Birth__c) participant.Date_of_Birth__c = null;
        component.set('v.participantSnapshot', JSON.stringify(participant));
        component.set('v.participantChanged', false);
    },

    setContactSnapshot: function(component){
        var contact = component.get('v.contact');
        if(!contact.FirstName) contact.FirstName = '';
        if(!contact.LastName) contact.LastName = '';
        if(!contact.MailingCountryCode) contact.MailingCountryCode = '';
        if(!contact.MailingStateCode) contact.MailingStateCode = '';
        if(!contact.Phone) contact.Phone = '';
        component.set('v.contactSnapshot', JSON.stringify(contact));
        component.set('v.contactChanged', false);
    }

});