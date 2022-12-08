@IsTest
public class Test_ResourceStudyDocumentService {
    @TestSetup
    static void setup(){
        TestData.loadTestData();
    }

    @IsTest
    static void resourceStudyDocService_Test() {
        List<Clinical_Trial_Profile__c> ctp = [SELECT Id, Protocol_ID__c, CommunityTemplate__c FROM Clinical_Trial_Profile__c];
        ctp[0].CommunityTemplate__c = CommunityTemplateService.TEMPLATE_PP;
        update ctp;
        
        Participant__c participant = [SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Status__c, Balance__c, Contact__c, Mailing_Country_Code__c, Mailing_Country__c, Contact__r.AccountId 
                                      FROM Participant__c WHERE Last_Name__c = 'ParticipantTD'];
        
        List<String> contactLastNames = new List<String>{participant.Name, 'HCPTD', 'PITD', 'HCPDelTD', 'PIDelTD', 'CCID'};
        List<User> users = [ SELECT Id, ContactId, LastName FROM User WHERE Contact.LastName IN :contactLastNames];
        
        User participantUser;
        for (User user : users) {
            if (user.LastName == participant.Name) 
                participantUser = user;
        }
        Test.startTest();
        System.runAs(participantUser) {
            ResourceStudyDocumentService rs = new ResourceStudyDocumentService();
			rs.getOrderByClause();
            System.assertEquals('ORDER BY Version_Date__c DESC NULLS LAST', rs.getOrderByClause());
        }
        Test.stopTest();
        
    } 
    
    @IsTest
    static void resourceStudyDocServiceNoResources_Test() {
        
        TestData td = new TestData();
        Resource__c relLink = new Resource__c( Content_Type__c = 'Relevant_Link', Title__c = 'Test', Type__c = 'Helpful Links',
                                              URL__c = 'https://www.google.com/', Languages__c = 'en_US');
        insert relLink;

        List<Resource__c> resources = [SELECT Id FROM Resource__c WHERE Content_Type__c = 'Relevant_Link'];
        Res_study__c resStudy = new Res_study__c(Resource__c = resources[0].Id, 
                                                 Clinical_Trial_Profile__c = td.ctp.Id, Visible_To_Participant__c = true);
        insert resStudy;

        Test.startTest();
        System.runAs(td.participantUser) {
            ResourceStudyDocumentService rs = new ResourceStudyDocumentService();
			rs.getErrorNoResources();
            ResourceService.ResourceWrapperContainer wr = rs.getErrorNoResources();
            System.assertEquals('Content will be published shortly. Check back for updates.', wr.errorMessage);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void resourceArticleVideo_Test() {
        TestData td = new TestData();
        Resource__c relLink = new Resource__c(Content_Type__c = 'Relevant_Link', Title__c = 'Test', Type__c = 'Helpful Links',
                                              URL__c = 'https://www.google.com/', Languages__c = 'en_US');
        insert relLink;

        List<Resource__c> resources = [SELECT Id FROM Resource__c WHERE Content_Type__c = 'Relevant_Link'];
        Res_study__c resStudy = new Res_study__c(Resource__c = resources[0].Id, Clinical_Trial_Profile__c = td.ctp.Id, 
                                                 Visible_To_Participant__c = true);
        insert resStudy;

        Test.startTest();
        System.runAs(td.participantUser) {
            ResourceArticleVideoService rs = new ResourceArticleVideoService();
			rs.getErrorNoResources();
            
            ResourceService.ResourceWrapperContainer wr = rs.getErrorNoResources();
            System.assertEquals('Articles will be published shortly. Check back for updates.', wr.errorMessage);
        }
        Test.stopTest();        
    }
    
    @IsTest
    static void resourceArticleVideoObjectMissing_Test() {
        TestData td = new TestData();
        Resource__c relLink = new Resource__c(Content_Type__c = 'Relevant_Link', Title__c = 'Test', Type__c = 'Helpful Links', 
                                              URL__c = 'https://www.google.com/', Languages__c = 'en_US');
        insert relLink;

        List<Resource__c> resources = [SELECT Id FROM Resource__c WHERE Content_Type__c = 'Relevant_Link'];
        Res_study__c resStudy = new Res_study__c(Resource__c = resources[0].Id, Clinical_Trial_Profile__c = td.ctp.Id, 
                                                 Visible_To_Participant__c = true);
        insert resStudy;

        Test.startTest();
        System.runAs(td.participantUser) {
            ResourceArticleVideoService rs = new ResourceArticleVideoService();
			rs.isObjectsToFilterMissing();
            System.assertEquals(False, rs.isObjectsToFilterMissing());
        }
        Test.stopTest();        
    }
}