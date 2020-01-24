/**
 * Created by Alexey Moseev.
 */

@IsTest
public with sharing class Test_PatientDelegateTriggerHandler {

    @IsTest
    public static void testPatientDelegateStatus() {
        TriggerHandlerExecutor.bypassHandler(TermsAndConditionsTriggerHandler.ActivePortalFieldsHandler.class);

        TestData.loadTestData();
        TestData testData = new TestData();

        Participant__c participant = testData.participant;
        Contact cnt = [SELECT Id FROM Contact WHERE LastName = :participant.Name LIMIT 1];

        Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
        ptDelegateRef.Participant__c = participant.Id;
        ptDelegateRef.Contact__c = cnt.Id;
        insert ptDelegateRef;

        ptDelegateRef = [SELECT Id, Contact__c, Status__c, Participant__c FROM Patient_Delegate__c WHERE Id = :ptDelegateRef.Id];
        system.assertEquals(PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS, ptDelegateRef.Status__c);

        ptDelegateRef.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS;
        update ptDelegateRef;

        ptDelegateRef = [SELECT Id, Contact__c, Status__c, Participant__c FROM Patient_Delegate__c WHERE Id = :ptDelegateRef.Id];
        system.assertEquals(PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS, ptDelegateRef.Status__c);
    }
}