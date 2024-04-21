@isTest
public class Test_ResourceStudyRelatedService {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    public static void test1(){
        TestData testData = new TestData();
        Resource__c vedioPtRes = new Resource__c(
            Content_Type__c = 'Video',
            Description__c = 'testBehavior',
            Title__c = 'TestRes',
            Content_Class__c = 'Study-Specific',
            Resource_Type__c = 'Study Document'
        );
        insert vedioPtRes;
        Res_study__c resVideoStudy = new Res_study__c(
            Active_After_Days__c = 0.00,
            Active_On_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 5,
            Expires_On_Status__c = PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
            Notify_On_Availability__c = true,
            Resource__c = vedioPtRes.Id, 
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resVideoStudy;
        
        ContentVersion contentVersion = new ContentVersion(
            LanguageCode__c = 'en_US',
            Title = 'Test Content',
            PathOnClient = 'Irregular verbs.pdf',
            VersionData = EncodingUtil.base64Decode('fdsgg5465w')
        );
        insert contentVersion;
        
        Resource__c docPtRes = new Resource__c(
            Content_Type__c = 'Study_Document',
            Description__c = 'testBehavior',
            document_type__c = 'Document',
            Content_Class__c = 'Study-Specific',
            Title__c = 'TestRes'
        );
        insert docPtRes;
        Id docId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Title = 'Test Content'
            LIMIT 1
        ]
            .ContentDocumentId;
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = docPtRes.Id
        );
        insert contentDocumentLink;
        
        Res_study__c resDocStudy = new Res_study__c(
            Active_After_Days__c = 0.00,
            Active_On_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 5,
            Expires_On_Status__c = PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
            Notify_On_Availability__c = true,
            Resource__c = docPtRes.Id,
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resDocStudy;
        
        System.runAs(testData.participantUser){
            ResourceStudyRelatedService rs = ResourceStudyRelatedService.getInstance();
            try{
                rs.init('Video',vedioPtRes.Id,'PT',testData.ctp.Id);
                rs.getResourcesIds();
                rs.init('Study_Document;Video',null,'Study-Specific',testData.ctp.Id);
                rs.getResourcesIds();
                Id cId;
                rs.init('Video',null,'Study-Specific',cId);
                rs.getResourcesIds();
                rs.isObjectsToFilterMissing();
                rs.getErrorNoObjectsToFilter();
            }catch(Exception e){
                
            }
            rs.getResourcesIds();
        }
    }
}