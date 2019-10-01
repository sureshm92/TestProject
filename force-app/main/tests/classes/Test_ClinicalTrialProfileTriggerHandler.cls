/**
 * Created by AlexKetch on 4/17/2019.
 */
@IsTest(IsParallel=true)
public with sharing class Test_ClinicalTrialProfileTriggerHandler {

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
                        'Therapeutic_Area__c' => tA.Id,
                        'Synch_with_TMDH__c' => true
                }));
        clinicalTrialProfiles.add((Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(),
                new Map<String, Object>{
                        'Study_Title__c' => 'CTP 2',
                        'Protocol_ID__c' => 'CTP 2',
                        'Study_Code_Name__c' => 'CTP 2',
                        'NCT_Number__c' => 'NCT00000002',
                        'Therapeutic_Area__c' => tA.Id,
                        'Synch_with_TMDH__c' => true
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
    }

    @IsTest
    public static void updateCTP_ChangeTAOnCTP_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );
        setup();
        List<Clinical_Trial_Profile__c> cTPs = [
                SELECT Id,
                        Therapeutic_Area__c
                FROM Clinical_Trial_Profile__c
                ORDER BY Name
        ];
        Therapeutic_Area__c newTA = (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType(), new Map<String, Object>{
                'Name' => 'NewTA'
        });
        insert newTA;
        System.assertEquals(2, cTPs.size());
        cTPs[1].Therapeutic_Area__c = newTA.Id;
        Test.startTest();
        update cTPs;
        Test.stopTest();

        List<Participant__c> participants = [
                SELECT Id, (SELECT Id, Therapeutic_Area__c FROM Therapeutic_Area_Patients__r WHERE IsRelatedToStudy__c = TRUE)
                FROM Participant__c
                ORDER BY Name
        ];
        System.assertEquals(3, participants.size());
        List<Therapeutic_Area__c> tAs = [
                SELECT Id
                FROM Therapeutic_Area__c
                WHERE Name != :newTA.Name
        ];
        System.assertEquals(1, tAs.size());
        for(Participant__c singleParticipant : participants) {
            System.assertEquals(1, singleParticipant.Therapeutic_Area_Patients__r.size());
        }
        System.assertEquals(tAs[0].Id, participants[0].Therapeutic_Area_Patients__r[0].Therapeutic_Area__c);
        System.assertEquals(newTA.Id, participants[1].Therapeutic_Area_Patients__r[0].Therapeutic_Area__c);
        System.assertEquals(newTA.Id, participants[2].Therapeutic_Area_Patients__r[0].Therapeutic_Area__c);
    }

    @IsTest
    public static void updateCTP_RemoveTAOnCTP_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );
        setup();
        List<Clinical_Trial_Profile__c> cTPs = [
                SELECT Id,
                        Therapeutic_Area__c
                FROM Clinical_Trial_Profile__c
                ORDER BY Name
        ];
        System.assertEquals(2, cTPs.size());
        cTPs[1].Therapeutic_Area__c = null;
        Test.startTest();
        update cTPs;
        Test.stopTest();

        List<Participant__c> participants = [
                SELECT Id, (SELECT Id, Therapeutic_Area__c FROM Therapeutic_Area_Patients__r WHERE IsRelatedToStudy__c = TRUE)
                FROM Participant__c
                ORDER BY Name
        ];
        System.assertEquals(3, participants.size());
        System.assertEquals(1, participants[0].Therapeutic_Area_Patients__r.size());
        System.assertEquals(0, participants[1].Therapeutic_Area_Patients__r.size());
        System.assertEquals(0, participants[2].Therapeutic_Area_Patients__r.size());
    }

    @IsTest
    public static void deleteRelatedToStudyDocuments_Test_ResInDiffStudies() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );
        setup();
        delete [SELECT Id FROM Clinical_Trial_Profile__c];
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        //t1.Status__c = 'Completed';
        Clinical_Trial_Profile__c t2 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t2.NCT_Number__c = 'NCT00000001';
        t2.Protocol_ID__c = 'NCT00000001';
        //t2.Status__c = 'Completed';
        Clinical_Trial_Profile__c t3 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t3.NCT_Number__c = 'NCT00000002';
        t3.Protocol_ID__c = 'NCT00000002';

        List<Clinical_Trial_Profile__c> profiles = new List<Clinical_Trial_Profile__c>();
        List<Resource__c> resources = new List<Resource__c>();
        profiles.add(t1);
        profiles.add(t2);
        profiles.add(t3);
        insert profiles;
        Resource__c r1StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r1StudyDoc.Title__c = 'testStudy';
        r1StudyDoc.Content_Class__c = 'Study-Specific';
        Resource__c r2StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r2StudyDoc.Title__c = 'testStudy2';
        r2StudyDoc.Content_Class__c = 'Study-Specific';
        Resource__c r3 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r3.Content_Class__c = 'Study-Specific';
        Resource__c r4 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r4.Content_Class__c = 'Study-Specific';
        r1StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT].Id;
        r2StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT].Id;
        resources.add(r1StudyDoc);
        resources.add(r2StudyDoc);
        resources.add(r3);
        resources.add(r4);
        insert resources;
        List<Res_study__c> resStudies = new List<Res_study__c>();

        Res_study__c resStudy = new Res_study__c();
        resStudy.Resource__c = r1StudyDoc.Id;
        resStudy.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy1 = new Res_study__c();
        resStudy1.Resource__c = r2StudyDoc.Id;
        resStudy1.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy2 = new Res_study__c();
        resStudy2.Clinical_Trial_Profile__c = t1.Id;
        resStudy2.Resource__c = r3.Id;

        Res_study__c resStudy3 = new Res_study__c();
        resStudy3.Resource__c = r4.Id;
        resStudy3.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy4 = new Res_study__c();
        resStudy4.Resource__c = r2StudyDoc.Id;
        resStudy4.Clinical_Trial_Profile__c = t3.Id;

        Res_study__c resStudy5 = new Res_study__c();
        resStudy5.Resource__c = r4.Id;
        resStudy5.Clinical_Trial_Profile__c = t1.Id;

        resStudies.add(resStudy);
        resStudies.add(resStudy1);
        resStudies.add(resStudy2);
        resStudies.add(resStudy3);
        resStudies.add(resStudy4);
        resStudies.add(resStudy5);
        insert resStudies;
        t1.Status__c = 'Completed';
        t2.Status__c = 'Completed';
        update profiles;
        List<Resource__c> res = [SELECT Id,Name,Title__c FROM Resource__c];
        System.assertEquals(3, res.size());
        for (Resource__c r : res) {
            System.assert(r.Title__c != 'testStudy');
        }
        List<Res_study__c> resStudeis = [SELECT Id,Name,Clinical_Trial_Profile__c,Resource__c FROM Res_study__c];
        System.assertEquals(4, resStudeis.size());
    }

    @IsTest
    public static void deleteRelatedToStudyDocuments_TestAllResInStudies() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );
        setup();
        delete [SELECT Id FROM Clinical_Trial_Profile__c];
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';

        Clinical_Trial_Profile__c t2 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t2.NCT_Number__c = 'NCT00000001';
        t2.Protocol_ID__c = 'NCT00000001';
        Clinical_Trial_Profile__c t3 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t3.NCT_Number__c = 'NCT00000002';
        t3.Protocol_ID__c = 'NCT00000002';
        List<Clinical_Trial_Profile__c> profiles = new List<Clinical_Trial_Profile__c>();
        List<Resource__c> resources = new List<Resource__c>();
        profiles.add(t1);
        profiles.add(t2);
        profiles.add(t3);
        insert profiles;
        Resource__c r1StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r1StudyDoc.Title__c = 'testStudy';
        r1StudyDoc.Content_Class__c = 'Study-Specific';

        Resource__c r2StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r2StudyDoc.Title__c = 'testStudy2';
        r2StudyDoc.Content_Class__c = 'Study-Specific';
        Resource__c r3 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r3.Content_Class__c = 'Study-Specific';
        Resource__c r4 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r4.Content_Class__c = 'Study-Specific';
        r1StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT].Id;
        r2StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT].Id;
        resources.add(r1StudyDoc);
        resources.add(r2StudyDoc);
        resources.add(r3);
        resources.add(r4);
        insert resources;
        List<Res_study__c> resStudies = new List<Res_study__c>();

        Res_study__c resStudy = new Res_study__c();
        resStudy.Resource__c = r1StudyDoc.Id;
        resStudy.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy1 = new Res_study__c();
        resStudy1.Resource__c = r2StudyDoc.Id;
        resStudy1.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy2 = new Res_study__c();
        resStudy2.Clinical_Trial_Profile__c = t1.Id;
        resStudy2.Resource__c = r3.Id;


        Res_study__c resStudy3 = new Res_study__c();
        resStudy3.Resource__c = r4.Id;
        resStudy3.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy5 = new Res_study__c();
        resStudy5.Resource__c = r4.Id;
        resStudy5.Clinical_Trial_Profile__c = t1.Id;

        resStudies.add(resStudy);
        resStudies.add(resStudy1);
        resStudies.add(resStudy2);
        resStudies.add(resStudy3);
        resStudies.add(resStudy5);
        insert resStudies;
        t1.Status__c = 'Completed';
        t2.Status__c = 'Completed';
        update profiles;
        List<Resource__c> res = [SELECT Id,Name,Title__c FROM Resource__c];
        System.assertEquals(2, res.size());
        for (Resource__c r : res) {
            System.assert(r.Title__c != 'testStudy');
        }
        List<Res_study__c> resStudeis2 = [SELECT Id,Name,Clinical_Trial_Profile__c,Resource__c FROM Res_study__c];
        System.assertEquals(3, resStudeis2.size());
    }

    @IsTest
    public static void deleteRelatedToStudyDocuments_Test_NotCompletedStudy() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );
        setup();
        delete [SELECT Id FROM Clinical_Trial_Profile__c];
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        Clinical_Trial_Profile__c t2 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t2.NCT_Number__c = 'NCT00000001';
        t2.Protocol_ID__c = 'NCT00000001';
        Clinical_Trial_Profile__c t3 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t3.NCT_Number__c = 'NCT00000002';
        t3.Protocol_ID__c = 'NCT00000002';
        List<Clinical_Trial_Profile__c> profiles = new List<Clinical_Trial_Profile__c>();
        List<Resource__c> resources = new List<Resource__c>();
        profiles.add(t1);
        profiles.add(t2);
        profiles.add(t3);
        insert profiles;
        Resource__c r1StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r1StudyDoc.Title__c = 'testStudy';
        r1StudyDoc.Content_Class__c = 'Study-Specific';
        Resource__c r2StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r2StudyDoc.Title__c = 'testStudy2';
        r2StudyDoc.Content_Class__c = 'Study-Specific';
        Resource__c r3 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r3.Content_Class__c = 'Study-Specific';
        Resource__c r4 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r1StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT].Id;
        r2StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT].Id;
        resources.add(r1StudyDoc);
        resources.add(r2StudyDoc);
        resources.add(r3);
        resources.add(r4);
        r4.Content_Class__c = 'Study-Specific';
        insert resources;
        List<Res_study__c> resStudies = new List<Res_study__c>();

        Res_study__c resStudy = new Res_study__c();
        resStudy.Resource__c = r1StudyDoc.Id;
        resStudy.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy1 = new Res_study__c();
        resStudy1.Resource__c = r2StudyDoc.Id;
        resStudy1.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy2 = new Res_study__c();
        resStudy2.Clinical_Trial_Profile__c = t1.Id;
        resStudy2.Resource__c = r3.Id;
        Res_study__c resStudy3 = new Res_study__c();
        resStudy3.Resource__c = r4.Id;
        resStudy3.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy5 = new Res_study__c();
        resStudy5.Resource__c = r4.Id;
        resStudy5.Clinical_Trial_Profile__c = t1.Id;
        resStudies.add(resStudy);
        resStudies.add(resStudy1);
        resStudies.add(resStudy2);
        resStudies.add(resStudy3);
        resStudies.add(resStudy5);
        insert resStudies;
        update profiles;
        List<Resource__c> res = [SELECT Id,Name,Title__c FROM Resource__c];
        System.assertEquals(4, res.size());
        List<Res_study__c> resStudeis = [SELECT Id,Name,Clinical_Trial_Profile__c,Resource__c FROM Res_study__c];
        System.assertEquals(5, resStudeis.size());
    }
}