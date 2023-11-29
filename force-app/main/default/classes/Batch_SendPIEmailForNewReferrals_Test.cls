/* Class Name : Batch_SendPIEmailForNewReferrals_Test
 * Decription : Test Class for Batch_SendPIEmailForNewReferrals
 * */
@isTest
public class Batch_SendPIEmailForNewReferrals_Test {
    
    @IsTest
    public static void testSendEmail(){
        TestData.loadTestData();
        TestData td = new TestData();
        List<Participant_Enrollment__c> lstPER = [ SELECT PI_Contact__c,Participant_Status__c,Study_Site__r.Suppress_Study_Site_PI_Emails__c,
                                                  Study_Site__r.Override_PI_Referral_Status__c FROM Participant_Enrollment__c  WHERE
                                                  Participant_Status__c = 'Received'
                                                  AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = FALSE
                                                  AND Study_Site__r.Override_PI_Referral_Status__c IN ('Accepted','Accepted (Admin)')];
        
        Contact objCon = [SELECT ID,Language__c,Email,LastName,AccountId,FirstName,Current_Participant_Enrollment__c
                          ,userCommunityMode__c,userCommunytyType__c,UserCommunityIsDelegate__c 
                          FROM contact Where ID=:lstPER[0].PI_Contact__c];
        
        test.startTest();
        CommunityService.createUser(objCon, null, null, null);
        Database.executeBatch(new Batch_SendPIEmailForNewReferrals()); 
        test.stoptest();
    }
    
    @isTest
    Public static void testgetBatchDescription(){
        Batch_SendPIEmailForNewReferrals objBatch = new Batch_SendPIEmailForNewReferrals();
        objBatch.getBatchDescription();
    }
     @isTest
    Public static void testgetRecommendedIntervalMode(){
        Batch_SendPIEmailForNewReferrals objBatch = new Batch_SendPIEmailForNewReferrals();
        objBatch.getRecommendedIntervalMode();
    }
     @isTest
    Public static void testgetRecommendedRelaunchInterval(){
        Batch_SendPIEmailForNewReferrals objBatch = new Batch_SendPIEmailForNewReferrals();
        objBatch.getRecommendedRelaunchInterval();
    }
    
}