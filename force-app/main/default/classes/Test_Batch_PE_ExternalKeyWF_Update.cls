/**
 * Created by Sravani Dasari on 8-Feb-2021.
 */

@IsTest
private class Test_Batch_PE_ExternalKeyWF_Update {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        Test.startTest();
        	TestData td = new TestData();
        	TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
        	td.pe.Clinical_Trial_Profile__c = td.ctp.id;
        	td.pe.External_Key_WF__c = null;
        	update td.pe;
        	Database.executeBatch(new Batch_PE_ExternalKeyWF_Update());
        Test.stopTest();

       // System.assertEquals(, );
    }
}