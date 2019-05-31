/**
 * Created by Igor Malyuta on 31.05.2019.
 */

({
    fillContactInfo : function (component) {
        var userMode = communityService.getUserMode();
        var init = component.get('v.initData');

        var firstName;
        var lastName;
        var phone;
        var state;
        var country;
        var zipPostal;

        if(communityService.isDelegate() && userMode === 'Participant') {
            firstName = init.myContact.FirstName;
            lastName = init.myContact.LastName;
            phone = init.myContact.Phone;
            state = init.myContact.MailingState;
            country = init.myContact.MailingCountry;
            zipPostal = init.myContact.MailingPostalCode;
        } else if(userMode === 'Participant') {
            firstName = init.participant.First_Name__c;
            lastName = init.participant.Last_Name__c;
            phone = init.participant.Phone__c;
            state = init.participant.Mailing_State__c;
            country = init.participant.Mailing_Country__c;
            zipPostal = init.participant.Mailing_Zip_Postal_Code__c;

            component.set('v.middleInitial', init.participant.Middle_Name__c);
            component.set('v.birthDate', init.participant.Date_of_Birth__c);
            component.set('v.gender', init.participant.Gender__c);
        }

        component.set('v.firstName', firstName);
        component.set('v.lastName', lastName);
        component.set('v.phone', phone);
        component.set('v.state', state);
        component.set('v.country', country);
        component.set('v.zipPostal', zipPostal);

        component.set('v.isUpdated', false);
    }
});