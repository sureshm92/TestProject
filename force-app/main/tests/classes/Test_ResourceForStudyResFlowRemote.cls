@isTest
public class Test_ResourceForStudyResFlowRemote {
    @isTest
    private static void getResourceList() {
        List<Resource__c> resourceListTest = new List<Resource__c>();
        Resource__c resource = new Resource__c(
            Title__c = 'Test',
            Posting_Date__c = date.today(),
            Content_Class__c = 'Training',
            Resource_Type__c = 'Training',
            Body__c = 'training purpose only',
            Version_Date__c = date.today()
        );
        resourceListTest.add(resource);
        insert resourceListTest;

        TestData.loadTestData();
        Test.startTest();
        ResourceForStudyResFlowRemote.InitData obj = new ResourceForStudyResFlowRemote.InitData();
        obj.resourceList = resourceListTest;
        ResourceForStudyResFlowRemote.getResourceList();

        ResourceForStudyResFlowRemote.getSelectedResourceTitle(resource.id);

        Test.stopTest();
    }
}
