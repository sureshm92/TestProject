/**
 * Created by Denis on 15.04.2019.
 */

@IsTest
private without sharing class Test_ReferringRemote {
    @IsTest
    static void saveParticipant() {
        TestData.loadTestData();
        
        TestData testDataInstance = new TestData();
        String checkNeeds;
        String delAge;

        System.runAs(testDataInstance.hcpUser) {
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                HCP__c = testDataInstance.hcpEnrollment.Id,
                Study_Site__c = testDataInstance.ss.Id,
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Screening_ID__c = 'TestScrId12345'
            );
            Participant__c participant = new Participant__c(
                First_Name__c = 'PTest',
                Last_Name__c = 'PTest',
                Phone__c = '13413223',
                Date_of_Birth__c = '1990-11-11',
                Email__c = 'partTest@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
            );
            Participant__c participantDelegate = new Participant__c(
                First_Name__c = 'PTestDelegate',
                Last_Name__c = 'PTestDelegate',
                Phone__c = '13413123',
                Email__c = 'PTestDelegate@email.com',
                Birth_Year__c = '1980',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
            );
            checkNeeds = ReferringRemote.checkNeedsGuardian(JSON.serialize(participant));
            delAge = ReferringRemote.checkDelegateAge(
                JSON.serialize(participant),
                JSON.serialize(participantDelegate)
            );
            List<Resource__c> resources = new List<Resource__c>{
                new Resource__c(Resource_Visibility__c = 'PI', Language__c = 'en_US'),
                new Resource__c(
                    Language__c = 'en_US',
                    Resource_Visibility__c = 'PI',
                    RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName()
                        .get('Document')
                        .getRecordTypeId()
                )
            };
            insert resources;
            Res_study__c studyRes = new Res_study__c(
                Resource__c = resources[1].Id,
                Visible_To_PI__c = true,
                Visible_To_RP__c = true,
                Clinical_Trial_Profile__c = testDataInstance.ctp.Id
            );
            insert studyRes;

            List<PreScreener_Survey__c> screenerList = new List<PreScreener_Survey__c>();
            screenerList.add(new PreScreener_Survey__c(
                Link_to_Pre_screening__c = 'https://link.test',
                Prescreener__c = true,
                ProviderName__c = 'surveygizmo',
                Study__c = testDataInstance.ctp.Id,
                Survey_Name__c = 'Prescreener'
            ));

            insert screenerList;

            Participant_PrescreenerResponse__c response = new Participant_PrescreenerResponse__c(
                PreScreener_Survey__c = screenerList[0].Id,
                Screener_Response__c = 'Test Response'
            );
            
            Test.startTest();
            ReferringRemote.saveParticipant(
                testDataInstance.hcpEnrollment.Id,
                JSON.serialize(pe),
                JSON.serialize(participant),
                JSON.serialize(participantDelegate),
                JSON.serialize(response),
                null,
                null,
                null
            );

            ReferringRemote.setfailedReferral(
                JSON.serialize(pe),
                JSON.serialize(response),
                ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING
            );
            try {
                ReferringRemote.setfailedReferral(
                    'pe',
                    JSON.serialize(response),
                    ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING
                );
            } catch (exception e) {
            }
            try {
                ReferringRemote.saveParticipant(
                    testDataInstance.hcpEnrollment.Id,
                    'pe',
                    'participant',
                    'participantDelegate',
                    null,
                    null,
                    null,
                    null
                );
            } catch (exception e) {
            }
        }
        Participant_Enrollment__c per = [SELECT Id FROM Participant_Enrollment__c LIMIT 1];
        ReferringRemote.saveUpdatedPER(per.Id);

        Test.stopTest();
        List<Participant__c> testParticipants = [
            SELECT Id
            FROM Participant__c
            WHERE Email__c IN ('parttest@email.com', 'ptestdelegate@email.com')
        ];
        System.assertEquals('false', checkNeeds);
        System.assertEquals('true', delAge);
        System.assertEquals(2, testParticipants.size());
    }

    @IsTest
    static void getInitData() {
        
        Test.startTest();
        TestData.loadTestData();
        TestData testDataInstance = new TestData();
        String initDataStr;
        System.runAs(testDataInstance.hcpUser) {
            initDataStr = ReferringRemote.getInitData(
                testDataInstance.ctp.Id,
                testDataInstance.pe.Id,
                testDataInstance.hcpEnrollment.Id,
                CommunityService.USER_MODE_HCP,
                null,
                null
            );
        }
        Test.stopTest();
        ReferringRemote.InitData initData = (ReferringRemote.InitData) JSON.deserialize(
            initDataStr,
            ReferringRemote.InitData.class
        );
        System.assertEquals(1, initData.studies.size());
    }

    @IsTest
    static void deletefile() {
        Test.startTest();
        TestData.loadTestData();
       
        TestData testDataInstance = new TestData();
        String checkNeeds;
        String delAge;
      List<Resource__c> resources = new List<Resource__c>{
            new Resource__c(Resource_Visibility__c = 'PI', Language__c = 'en_US'),
            new Resource__c(
                Language__c = 'en_US',
                Resource_Visibility__c = 'PI',
                RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName()
                    .get('Document')
                    .getRecordTypeId()
            )
        };
        insert resources;
        List<Res_study__c> resStudyList = new List<Res_study__c>();
        Res_study__c studyRes = new Res_study__c(
            Resource__c = resources[1].Id,
            Visible_To_PI__c = true,
            Visible_To_RP__c = true,
            Clinical_Trial_Profile__c = testDataInstance.ctp.Id
        );
         resStudyList.add(studyRes);
        Res_study__c studyRes1 = new Res_study__c(
            Resource__c = resources[1].Id,
            Visible_To_PI__c = true,
            Visible_To_RP__c = true,
            Clinical_Trial_Profile__c = testDataInstance.ctp.Id
        );
         resStudyList.add(studyRes1);
        insert resStudyList;
       
        // Test.startTest();
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;

        // Test INSERT
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument
        ];

       List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        for(Integer i = 0; i < 2; i++){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = resStudyList[i].Id;
            cdl.ContentDocumentId =documents[0].Id;
            cdl.shareType = 'I';

            contentDocList.add(cdl);
        }
        Insert contentDocList;  
        
         //Test.startTest();
        ReferringRemote.deleteFile(Documents[0].id);

        string lang = 'en_US';
        ReferringRemote.getContentDocumentLink(testDataInstance.ctp.Id, lang);
        ReferringRemote.checkDuplicateDelegate('testtttt@dsfsss.com', 'fn', 'ln');
        try {
            ReferringRemote.saveUpdatedPER('studyid');
        } catch (exception e) {
        }

        Test.stopTest();
    }
}