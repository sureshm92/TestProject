/**
 * Created by Igor Malyuta on 31.05.2019.
 */

({
    setParticipantSnapshot: function(component){
        var participant = component.get('v.participant');
        if(!participant.First_Name__c) participant.First_Name__c = '';
        if(!participant.Last_Name__c) participant.Last_Name__c = '';
        if(!participant.Middle_Name__c) participant.Middle_Name__c = '';
        if(!participant.Gender__c) participant.Gender__c = '';
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
    },

    setFieldsValidity: function(component){
        var fieldsGroup = 'cField';
        if(component.get('v.participant')) fieldsGroup = 'pField';
        var allValid = component.find(fieldsGroup).reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        component.set('v.isAllFieldsValid', allValid);
    },

    changeSMSOption: function (component) {
        var initData = component.get('v.initData');
        communityService.executeAction(component, 'changeOptInSMS', {
            participantOptInStatusSMS: initData.myContact.Participant_Opt_In_Status_SMS__c
        }, function () {
            if(initData.myContact.Participant_Opt_In_Status_SMS__c) {
                let contact = component.get('v.contact');
                if(!contact.MobilePhone) {
                    communityService.scrollInto('mobileAnchor');
                    communityService.showInfoToast('', $A.get('$Label.c.Toast_Enter_Mob_Num'));
                }
            }
        });
    }
});