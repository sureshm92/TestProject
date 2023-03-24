/**
 * Created by Alexey Moseev.
 */

@IsTest
public with sharing class Test_PatientDelegateTriggerHandler {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
     static void testPatientDelegateStatus() {
        TriggerHandlerExecutor.bypassHandler(
            TermsAndConditionsTriggerHandler.ActivePortalFieldsHandler.class
        );

        TestData testData = new TestData();

        Participant__c participant = testData.participant;
        Contact cnt = [SELECT Id FROM Contact WHERE LastName = :participant.Name LIMIT 1];

        Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
        ptDelegateRef.Participant__c = participant.Id;
        ptDelegateRef.Contact__c = cnt.Id;
        insert ptDelegateRef;

        ptDelegateRef = [
            SELECT Id, Contact__c, Status__c, Participant__c
            FROM Patient_Delegate__c
            WHERE Id = :ptDelegateRef.Id
        ];
        System.debug('ptDelegateRef.Status__c'+ptDelegateRef.Status__c);

        ptDelegateRef.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS;
        update ptDelegateRef;
        system.assertEquals(
            PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS,
             ptDelegateRef.Status__c
         );
        ptDelegateRef = [
            SELECT Id, Contact__c, Status__c, Participant__c,Primary_Delegate__c
            FROM Patient_Delegate__c
            WHERE Id = :ptDelegateRef.Id
        ];
        system.assertEquals(
            PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS,
            ptDelegateRef.Status__c
        );
    }
    
    
    @IsTest
    static void testnotDeletePrimaryDelegate() {
        TriggerHandlerExecutor.bypassHandler(
            TermsAndConditionsTriggerHandler.ActivePortalFieldsHandler.class
        );

        TestData testData = new TestData();

        Participant__c participant = testData.participant;
        Contact cnt = [SELECT Id FROM Contact WHERE LastName = :participant.Name LIMIT 1];

        Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
        ptDelegateRef.Participant__c = participant.Id;
        ptDelegateRef.Contact__c = cnt.Id;
        ptDelegateRef.Primary_Delegate__c= true;
        insert ptDelegateRef;
        
        List<Patient_Delegate__c> ptDelegateRefList= new List<Patient_Delegate__c>{ptDelegateRef};
                Map<Id,Patient_Delegate__c> ptDelegateRefMap= new Map<Id,Patient_Delegate__c>();
                ptDelegateRefMap.put(ptDelegateRef.id,ptDelegateRef);

        PatientDelegateTriggerHandler.notDeletePrimaryDelegate(ptDelegateRefList);
        try{
        PatientDelegateTriggerHandler.updatePrimaryDelegate(ptDelegateRefList,ptDelegateRefMap);
        }
        catch(Exception e)
        {
        }

    }
    
}