/**
     * Created by Nikita Abrazhevitch on 18-May-20.
     */
    
    @IsTest
    public class Test_LibraryRPRemote {
        @IsTest
        static void testBehavior() {
            TestData.loadTestData();
            Test.startTest();
            TestData testDataInstance = new TestData();
            List<Resource__c> resources = new List<Resource__c>{
                new Resource__c(Resource_Visibility__c = 'RP', Language__c = 'en_US',
                               RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName()
                        .get('Study Document')
                        .getRecordTypeId()),
                new Resource__c(
                    Language__c = 'en_US',
                    Resource_Visibility__c = 'RP',
                    RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName()
                        .get('Study Document')
                        .getRecordTypeId()
                )
            };
            insert resources;
            update new Clinical_Trial_Profile__c(
                Id = testDataInstance.ctp.Id,
                CommunityTemplate__c = 'Default'
            );
            Res_study__c studyRes = new Res_study__c(
                Resource__c = resources[1].Id,
                Visible_To_RP__c = true,
                Clinical_Trial_Profile__c = testDataInstance.ctp.Id
            );
            insert studyRes;
    
            string searchstr = 'study';
            System.runAs(testDataInstance.hcpUser) {
                LibraryRPRemote.getInitData(false, null, null, 'Default','');
                LibraryRPRemote.getInitData(true, null, null, 'Default','');
                LibraryRPRemote.getInitData(true, 'en_US', searchstr, 'Default','');
            }
            Test.stopTest();
        }
        @IsTest
        static void Test_Downloaddocument() {
            TestData.loadTestData();
            Test.startTest();
            TestData testDataInstance = new TestData();
            List<Resource__c> resources = new List<Resource__c>{
                new Resource__c(Resource_Visibility__c = 'RP', Language__c = 'en_US'),
                new Resource__c(
                    Language__c = 'en_US',
                    Resource_Visibility__c = 'RP',
                    RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName()
                        .get('Study Document')
                        .getRecordTypeId()
                )
            };
            insert resources;
            Res_study__c studyRes = new Res_study__c(
                Resource__c = resources[1].Id,
                Visible_To_RP__c = true,
                Clinical_Trial_Profile__c = testDataInstance.ctp.Id
            );
            insert studyRes;
    
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
    
            ContentDocumentLink DDL = new ContentDocumentLink(
                ContentDocumentId = Documents[0].id,
                LinkedEntityId = resources[1].Id
            );
            insert DDL;
            string searchstr = 'study'; 
            LibraryRPRemote.getBase64Resource(resources[1].id,'en_US' );
            Test.stopTest();
        }
    }