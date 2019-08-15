@IsTest(IsParallel=true)
public class Test_FillTAOnParticipantsBatchHandler {

    public static void setup() {
        Account singleAccount = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        Account participantAccount = (Account) TestDataFactory.getSObject(Account.getSObjectType(), new Map<String, Object>{
                'Name' => 'Participant'
        });
        insert new List<Account>{
                singleAccount, participantAccount
        };

        Contact piContact = (Contact) TestDataFactory.getSObject(Contact.getSObjectType(), new Map<String, Object>{
                'AccountId' => singleAccount.Id,
                'LastName' => 'portalTestUser1',
                'Email' => 'some@email.com'
        });
        insert piContact;

        Therapeutic_Area__c tA = (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType());
        insert tA;

        List<Clinical_Trial_Profile__c> clinicalTrialProfiles = new List<Clinical_Trial_Profile__c>();
        clinicalTrialProfiles.add((Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(),
                new Map<String, Object>{
                        'Study_Title__c' => 'CTP 1',
                        'Protocol_ID__c' => 'CTP 1',
                        'Study_Code_Name__c' => 'CTP 1',
                        'NCT_Number__c' => 'NCT00000001',
                        'Therapeutic_Area__c' => tA.Id
                }));
        clinicalTrialProfiles.add((Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(),
                new Map<String, Object>{
                        'Study_Title__c' => 'CTP 2',
                        'Protocol_ID__c' => 'CTP 2',
                        'Study_Code_Name__c' => 'CTP 2',
                        'NCT_Number__c' => 'NCT00000002',
                        'Therapeutic_Area__c' => tA.Id
                }));
        insert clinicalTrialProfiles;

        List<Study_Site__c> studySites = new List<Study_Site__c>();
        studySites.add((Study_Site__c) TestDataFactory.getSObject(Study_Site__c.getSObjectType(), new Map<String, Object>{
                'Name' => 'CTP 1 SS 1',
                'Clinical_Trial_Profile__c' => clinicalTrialProfiles[0].Id,
                'Site__c' => singleAccount.Id,
                'Principal_Investigator__c' => piContact.Id,
                'Study_Site_Key__c' => '12132123132311'
        }));
        studySites.add((Study_Site__c) TestDataFactory.getSObject(Study_Site__c.getSObjectType(), new Map<String, Object>{
                'Name' => 'CTP 2 SS 1',
                'Clinical_Trial_Profile__c' => clinicalTrialProfiles[1].Id,
                'Site__c' => singleAccount.Id,
                'Principal_Investigator__c' => piContact.Id,
                'Study_Site_Key__c' => '12132123132312'
        }));
        studySites.add((Study_Site__c) TestDataFactory.getSObject(Study_Site__c.getSObjectType(), new Map<String, Object>{
                'Name' => 'CTP 2 SS 2',
                'Clinical_Trial_Profile__c' => clinicalTrialProfiles[1].Id,
                'Site__c' => singleAccount.Id,
                'Principal_Investigator__c' => piContact.Id,
                'Study_Site_Key__c' => '12132123132313'
        }));
        insert studySites;

        List<Participant__c> participants = new List<Participant__c>();
        participants.add((Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType(), new Map<String, Object>{
                'First_Name__c' => 'P1',
                'Last_Name__c' => 'P1',
                'Email__c' => 'p1@p1.com'
        }));
        participants.add((Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType(), new Map<String, Object>{
                'First_Name__c' => 'P2',
                'Last_Name__c' => 'P2',
                'Email__c' => 'p2@p2.com'
        }));
        participants.add((Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType(), new Map<String, Object>{
                'First_Name__c' => 'P3',
                'Last_Name__c' => 'P3',
                'Email__c' => 'p3@p3.com'
        }));
        insert participants;

        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>();
        enrollments.add((Participant_Enrollment__c) TestDataFactory.getSObject(Participant_Enrollment__c.getSObjectType(),
                new Map<String, Object>{
                        'Participant_Name__c' => participants[0].First_Name__c,
                        'Participant_Surname__c' => participants[0].Last_Name__c,
                        'Study_Site__c' => studySites[0].Id,
                        'Participant__c' => participants[0].Id
                }));
        enrollments.add((Participant_Enrollment__c) TestDataFactory.getSObject(Participant_Enrollment__c.getSObjectType(),
                new Map<String, Object>{
                        'Participant_Name__c' => participants[1].First_Name__c,
                        'Participant_Surname__c' => participants[1].Last_Name__c,
                        'Study_Site__c' => studySites[1].Id,
                        'Participant__c' => participants[1].Id
                }));
        enrollments.add((Participant_Enrollment__c) TestDataFactory.getSObject(Participant_Enrollment__c.getSObjectType(),
                new Map<String, Object>{
                        'Participant_Name__c' => participants[2].First_Name__c,
                        'Participant_Surname__c' => participants[2].Last_Name__c,
                        'Study_Site__c' => studySites[2].Id,
                        'Participant__c' => participants[2].Id
                }));
        insert enrollments;
        delete [SELECT Id FROM Therapeutic_Area_Patient__c];
    }

    @IsTest
    public static void batch_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );
        setup();

        Test.startTest();
        String participantsQuery = 'SELECT Id, ' +
                    '(SELECT Id FROM Therapeutic_Area_Patients__r WHERE IsRelatedToStudy__c = TRUE), ' +
                    '(SELECT Id, ' +
                        'Study_Site__r.Clinical_Trial_Profile__r.Therapeutic_Area__c, ' +
                        'Participant_Status__c ' +
                        'FROM Participant_Profile__r) ' +
                'FROM Participant__c';
        Database.executeBatch(new BatchProcess(participantsQuery, new FillTAOnParticipantsBatchHandler()), 200);
        Test.stopTest();

        List<Participant__c> participants = [SELECT Id, (SELECT Id, IsRelatedToStudy__c, Therapeutic_Area__r.Name FROM Therapeutic_Area_Patients__r) FROM Participant__c];
        System.assertEquals(3, participants.size());
        for(Participant__c singleParticipant : participants) {
            System.assertEquals(1, singleParticipant.Therapeutic_Area_Patients__r.size());
            System.assertEquals(TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType()).get('Name'), singleParticipant.Therapeutic_Area_Patients__r[0].Therapeutic_Area__r.Name);
            System.assertEquals(true, singleParticipant.Therapeutic_Area_Patients__r[0].IsRelatedToStudy__c);
        }
    }
}