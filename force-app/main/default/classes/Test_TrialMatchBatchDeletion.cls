@IsTest
public class Test_TrialMatchBatchDeletion {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testTrialMatchBatchDel_false() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Clinical_Trial_Profile__c from Participant_Enrollment__c limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        List<Trial_Match__c> triMatchLst= new List<Trial_Match__c>();
        for(integer i =0; i<10;i++){
            Trial_Match__c tm = new Trial_Match__c(
            Clinical_Trial_Profile__c = enroll.Clinical_Trial_Profile__c,
            Is_Eligible__c = true,
            Matched_Date__c = Datetime.now().dateGmt(),
            Matching_Details__c = 'Sample Matching Details'+i,
            Matching_Score__c = 77+i,
            Is_User_notified__c = true,
            Participant_Enrollment__c = enroll.Id,
            Passed__c = false,
            Therapeutic_Area__c = 'Therapeutic Area Sample test data'
        	);
            triMatchLst.add(tm);
        }
        insert triMatchLst;
        Database.executeBatch(new TrialMatchBatchDeletion(enroll.Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Trial_Match__c> trailMatList=[SELECT Id from Trial_Match__c where Participant_Enrollment__c=:enroll.Id limit 20];
        System.assertEquals(10,trailMatList.size());
    }
    @IsTest
    static void testTrialMatchBatchDel_True() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Clinical_Trial_Profile__c from Participant_Enrollment__c limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        List<Trial_Match__c> triMatchLst= new List<Trial_Match__c>();
        for(integer i =0; i<10;i++){
            Trial_Match__c tm = new Trial_Match__c(
            Clinical_Trial_Profile__c = enroll.Clinical_Trial_Profile__c,
            Is_Eligible__c = true,
            Matched_Date__c = Datetime.now().dateGmt(),
            Matching_Details__c = 'Sample Matching Details'+i,
            Matching_Score__c = 77+i,
            Is_User_notified__c = true,
            Participant_Enrollment__c = enroll.Id,
            Passed__c = false,
            Therapeutic_Area__c = 'Therapeutic Area Sample test data'
        	);
            triMatchLst.add(tm);
        }
        insert triMatchLst;
        Database.executeBatch(new TrialMatchBatchDeletion(enroll.Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Trial_Match__c> trailMatList=[SELECT Id from Trial_Match__c where Participant_Enrollment__c=:enroll.Id limit 20];
        System.assertEquals(0,trailMatList.size());
    }
}