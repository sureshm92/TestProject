/**
 * Created by Olga Skrynnikova on 10/31/2019.
 */

@IsTest
private class Test_Batch_UpdateActivityDateTime {
    @IsTest
    static void batchExecute() {
        Map<String, Account> accountsByTypes = new Map<String, Account>();
        accountsByTypes.put(
            'Common',
            (Account) TestDataFactory.getSObject(Account.getSObjectType())
        );
        accountsByTypes.put(
            'Participant',
            (Account) TestDataFactory.getSObject(
                Account.getSObjectType(),
                new Map<String, Object>{ 'Name' => 'Participant' }
            )
        );
        insert accountsByTypes.values();
         UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        User admin = [
            SELECT Id, Username, UserRoleId
            FROM User
            WHERE
                Profile.Name = 'System Administrator'
                AND UserRoleId = :userRole_1.Id
                AND IsActive = TRUE
            LIMIT 1
        ];
        User user_1;
        Contact piContact = (Contact) TestDataFactory.getSObject(
            Contact.getSObjectType(),
            new Map<String, Object>{
                'AccountId' => accountsByTypes.get('Common').Id,
                'FirstName' => 'ParticipantTD11',
                'LastName' => 'ParticipantTD12',
                'Email' => 'someexample@gmail.com'
            }
        );
        insert piContact;
         user_1 = new User(
                Email = 'someexample@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = piContact.Id,
                PortalRole = 'Manager',
                FirstName = 'ParticipantTD11',
                LastName = 'ParticipantTD12'
            );
            insert user_1;
        
        Participant__c singleParticipant = (Participant__c) TestDataFactory.getSObject(
            Participant__c.getSObjectType(),
            new Map<String, Object>{
            'Contact__c' => piContact.Id,  // TODO Contact__c mustn't be piContact
            'First_Name__c' => 'ParticipantTD11',
            'Last_Name__c' => 'ParticipantTD12',
            'Phone__c' => '55313535',
            'Email__c' => 'someexample@gmail.com',
            'Mailing_Country_Code__c' => 'US',
            'Mailing_State_Code__c' => 'AL',
            'age__c' => 23,
            'site__c' => accountsByTypes.get('Common').Id
           
            }
        );
        insert singleParticipant;
        
        Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false
            );
            insert clinical;
        
        Study_Site__c studySite = (Study_Site__c) TestDataFactory.getSObject(
            Study_Site__c.getSObjectType(),
            new Map<String, Object>{
                'Clinical_Trial_Profile__c' => clinical.Id,
                'Site__c' => accountsByTypes.get('Common').Id,
                'Principal_Investigator__c' => piContact.Id,
                'Override_PI_Referral_Status__c' => 'Accepted',
                 'Suppress_Study_Site_PI_Emails__c' => FALSE
            }
        );
        insert studySite;
        Test.startTest();
        List<Participant_Enrollment__c> enrollemntLST = new List<Participant_Enrollment__c>();
        Participant_Enrollment__c part = (Participant_Enrollment__c) TestDataFactory.getSObject(
            Participant_Enrollment__c.getSObjectType(),
            new Map<String, Object>{
                'Medical_Record_Review_Status__c' => 'Pass',
                'Pre_screening_Status__c' => 'Pass',
                'Participant_Name__c' => singleParticipant.First_Name__c,
                'Participant_Surname__c' => singleParticipant.Last_Name__c,
                'Patient_ID__c' => '12345678',
                'Participant_Status__c' => 'Received',
                'Referral_Source__c' => 'Participant',
                'Study_Site__c' => studySite.Id,
                'Participant__c' => singleParticipant.Id,
                'Participant_Contact__c' => piContact.Id
            }
        );
        insert part;
        
        ReferralProfileRemote.createUser(part.Id, piContact.Id);
        User user2 = [
            SELECT Id
            FROM User
            WHERE ContactId =:part.Participant_Contact__c
            LIMIT 1
        ];
        List<Task> tasksList = new List<Task>{
            new Task(Subject = 'Some', OwnerId = user2.Id, ActivityDate = Date.today(),WhoId = piContact.Id,WhatId = part.Id)
        };
        insert tasksList;


        new Batch_UpdateActivityDateTimeOldUsers().execute(null, tasksList);
        Test.stopTest();

        System.assertEquals(
            Datetime.newInstanceGMT(
                Date.today().year(),
                Date.today().month(),
                Date.today().day(),
                0,
                0,
                0
            ),
            tasksList[0].Activity_Datetime__c
        );
        System.assertEquals(1, tasksList.size());
    }
}