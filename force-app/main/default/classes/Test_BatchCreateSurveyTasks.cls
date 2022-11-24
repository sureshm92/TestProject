@IsTest
public class Test_BatchCreateSurveyTasks {
    
    @isTest
    public static void testBatch(){
        TestData.loadTestData();
        TestData testdata = new TestData();
        System.runAs(testdata.hcpUser){
        User userRec = [Select Id, Email from user Limit 1];
        userRec.Email = 'abc@test.com';
        update userRec;
        Map<Id, String> invitationsVisible = new Map<Id, String>();
        invitationsVisible.put('0051I000001CrZEQA0', 'ABC');
        invitationsVisible.put('0053N000005s46MQAQ', 'QWE');
        Test.startTest();
        Batch_CreateSurveyTasks obj = new Batch_CreateSurveyTasks(invitationsVisible,userRec.Id,3,5);
        DataBase.executeBatch(obj); 
        }
        test.stoptest();
    
    }
    
    @isTest
    public static void testBatchMethods(){
       
        TestData.loadTestData();
        TestData testdata = new TestData();
        SurveyInvitation surInv = new SurveyInvitation();
        surInv.Participant_Enrollment__c = testdata.pe.id;
        surInv.SurveyId = '0Kd1I000000PBpYSAW';
        surInv.Name = 'ABC';
        insert surInv;
               
       Map<Id, String> invitationsVisible = new Map<Id, String>();
       invitationsVisible.put(surInv.Id,testdata.piContact.id);
       Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = testdata.piContact.id,
           // Contact__r = delegate,
            Participant__c =testdata.participant.Id
            //Participant__r = participant
        );
        insert patientDelegate; 
        Test.startTest();
        Batch_CreateSurveyTasks.countFailedTask(invitationsVisible);
        Batch_CreateSurveyTasks.launch(invitationsVisible);
        test.stoptest();
    }

}