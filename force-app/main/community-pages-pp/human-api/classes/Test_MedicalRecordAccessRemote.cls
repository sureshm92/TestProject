@IsTest
public class Test_MedicalRecordAccessRemote {
    
        
  @TestSetup
    static void init(){
        TestData.loadTestData();
    }

    
    @IsTest
    static void testMethod1() {
        
        Test.startTest(); 
         TestData td = new TestData();
        
        
          System.runAs(td.participantUser) {
                Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
//(String participantEmail,String referralId,String humanId,String uniqueHumanId)
              MedicalRecordAccessRemote.getSessionToken('part1@email.com','refid','humanId','uniqueHumanId');
              //MedicalRecordAccessRemote.getAccessToken('refid','part1@email.com','uniqueHumanId');
              
          }
        
        
        
    }
    
    @IsTest
    static void testMethod2() {
        
        Test.startTest(); 

         TestData td = new TestData();
        
        
          System.runAs(td.participantUser) {
                Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
//(String participantEmail,String referralId,String humanId,String uniqueHumanId)
              //MedicalRecordAccessRemote.getSessionToken('part1@email.com','refid','humanId','uniqueHumanId');
              MedicalRecordAccessRemote.getAccessToken('refid','part1@email.com','uniqueHumanId');
              
          }
        
        
        
    }
    
    @IsTest
    static void testMethod3() {

        Test.startTest(); 

        TestData td = new TestData();
        
        
          System.runAs(td.participantUser) {
              Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
    MedicalRecordAccessRemote.getHumanSourcesList('refid','part1@email.com','uniqueHumanId');
              MedicalRecordAccessRemote.getHumanAPIPastPEList(td.participant.Contact__c);
        }
    }

    
     @IsTest
    static void testMethod4() {
        
        Test.startTest(); 

        TestData td = new TestData();
        
        
          System.runAs(td.participantUser) {
                            Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 

               TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.class
            );
             List<Participant_Enrollment__c> peList= [Select Id,Participant__r.Contact__c,Human_Id__c,Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c from Participant_Enrollment__c where Participant__r.Contact__c =: td.participant.Contact__c];
               for(Participant_Enrollment__c peobj : peList)
               {
                   peobj.Human_Id__c  ='humanid';
                   peobj.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c  = true;
                   peobj.Participant__r.Contact__c =td.participant.Contact__c;
               }
              peList[0].Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c  = false;
              update peList;
//    MedicalRecordAccessRemote.getHumanSourcesList('refid','part1@email.com','uniqueHumanId');
              MedicalRecordAccessRemote.getHumanAPIPastPEList(td.participant.Contact__c);
        }
    }
}