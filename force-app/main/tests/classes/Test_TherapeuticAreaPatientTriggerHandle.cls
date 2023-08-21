@IsTest
public class Test_TherapeuticAreaPatientTriggerHandle {
    @isTest
    private static void test() {
        Therapeutic_Area__c newTA = new Therapeutic_Area__c(Name = 'Cancer');
        insert newTA;

        Contact partContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States',
            Participant_Opt_In_Status_SMS__c = false,
            MailingCountryCode = 'US',
            Phone = '123',
            UserCommunityIsDelegate__c = false,
            MobilePhone = '1223',
            is_Invalid_number__c = false,
            IQVIA_Pre_recorded_Voice_Consent__c = true,
            IQVIA_Contact_info_storage_consent__c = true,
            Participant_Phone_Opt_In_Permit_Phone__c = true,
            Participant_Opt_In_Status_Emails__c = true,
            IQVIA_Direct_Mail_Consent__c = true,
            IQVIA_Assisted_Dialing_Consent__c = true,
            IQVIA_Artificial_Voice_Consent__c = true
        );
        insert partContact;

        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'pi@emil.com',
            Preferred_Language__c = 'en_US',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '2733',
            Adult__c = true,
            Contact__c = partContact.Id
        );
        insert participant;

        Therapeutic_Area_Patient__c tap = new Therapeutic_Area_Patient__c();
        tap.Therapeutic_Area__c = newTA.Id;
        tap.Participant__c = participant.Id;
        tap.Condition_Of_Interest_Order__c = 0;
        insert tap;

        Resource__c vedioPtRes = new Resource__c(
            Content_Type__c = 'Video',
            Description__c = 'testBehavior',
            Title__c = 'TestRes',
            Content_Class__c = 'Study-Specific',
            Resource_Type__c = 'Study Document',
            Language__c = 'en_US',
            RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByDeveloperName()
                .get('Video')
                .getRecordTypeId()
        );
        insert vedioPtRes;
        Therapeutic_Area_Assignment__c taaLinkObj3 = new Therapeutic_Area_Assignment__c();
        taaLinkObj3.Resource__c = vedioPtRes.Id;
        taaLinkObj3.Therapeutic_Area__c = newTA.Id;

        insert taaLinkObj3;
        Notification__c nt1 = new Notification__c(
            Target_Record_Ids__c = vedioPtRes.Id,
            Recipient__c = partContact.Id,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = participant.Id,
            Status__c = 'In Progress'
        );
        insert nt1;

        delete tap;
    }
}
