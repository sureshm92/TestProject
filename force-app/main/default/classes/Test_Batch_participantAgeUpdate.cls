@isTest
public class Test_Batch_UpdateAgePartBDayToday {
    @testSetup static void testSetupMethod() {
        TestData.loadTestData();
    }
    @IsTest
    static void testAge(){
        list<participant__c> plist = [select id from participant__c limit 3];
        
        
        plist[0].Birth_Year__c = '2000';
        plist[0].Birth_Month__c = '12' ;
        plist[0].Birth_Day__c = '31';
        
        plist[1].Birth_Year__c = '2001';
        plist[1].Birth_Month__c = '12' ;
        
        plist[2].Birth_Year__c = '2002';
        
        update plist;
        
        system.debug([Select Age__c from participant__c where id =:plist]);
        Test.startTest();
        Database.executeBatch(new Batch_UpdateAgeOfParticipantsBDayToday());
        Test.stopTest();
        
        system.debug([Select Age__c from participant__c where id =:plist]);
    }
}