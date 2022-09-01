@IsTest
private without sharing class Test_TokenService {
      @TestSetup
    static void init(){
        TestData.loadTestData();
    }

    @IsTest
    static void tokenServiceTest() {
        Test.startTest();
       TestData testData = new TestData();
         List<Token__c> tokenData = new List<Token__c> ();
         String expiresIn = '3600';
         Token__c stoken = new Token__c();
         stoken.Participant_Enrollment__c = testData.pe.Id;
         stoken.Token_Type__c = 'session';
         stoken.Token_Value__c = 'tokenVa893e937';  
         stoken.Expiration_Date__c = System.now().addSeconds(Integer.valueOf(expiresIn));
         tokenData.add(stoken);
         String aexpiresIn = '86400';
         Token__c atoken = new Token__c();
         atoken.Participant_Enrollment__c = testData.pe.Id;
         atoken.Token_Type__c = 'access';
         atoken.Token_Value__c = 'tokenVa893e93hdyuy7';  
         atoken.Expiration_Date__c = System.now().addSeconds(Integer.valueOf(expiresIn));
         tokenData.add(atoken);
         insert tokenData;
        System.runAs(testData.participantUser) {
            TokenService.storeToken(testData.pe.Id,'session','7847hfdffhdf','hvdhg','3600');
            TokenService.storeToken(testData.pe.Id,'access','7847hfdffhdfhd78bnbnsh','hvdhgdhdc','86400');
            TokenService.fetchToken(testData.pe.Id,'access');
            TokenService.fetchToken(testData.pe.Id,'session');

        }
        Test.stopTest();
    }

}