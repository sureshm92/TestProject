/**
* Created by Sravani Dasari on 6/25/2020.
*/

@IsTest
private class Test_TrialMatchDataController {
    
    @IsTest
    static void TrialMatchDataController_test() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        TestData testData = new TestData();
        Trial_Match__c tm = new Trial_Match__c(	
            Clinical_Trial_Profile__c = testData.ctp.id,	
            Is_Eligible__c = true,	
            Matched_Date__c = Datetime.now().dateGmt(),	
            Matching_Details__c = 'Sample Matching Details',	
            Matching_Score__c = 77,	
            Participant_Enrollment__c = testData.pe.id,	
            Passed__c = false,	
            Therapeutic_Area__c = 'Therapeutic Area Sample test data'	
        );	
        insert tm;
        System.runAs(testData.participantUser) {
            PageReference myVfPage = Page.TrialMatchData;
            Test.setCurrentPage(myVfPage);
            
            ApexPages.currentPage().getParameters().put('id', testData.participant.id);
            new TrialMatchDataController(); 
        }
    } 
}