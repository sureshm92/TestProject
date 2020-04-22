/**
 * Created by Yulia Yakushenkova on 23.03.2020.
 */

@IsTest
private class Test_EmailTemplateDelegatePartController {

    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void test_getDelegateStudyNames() {
        TestData td = new TestData();
        User delegate = td.createPatientDelegate();
        insert delegate;

        Test.startTest();
        Id delegateContactId = [SELECT ContactId FROM User WHERE Id = :delegate.Id].ContactId;
        Patient_Delegate__c patientDelegate = [
                SELECT Id, Participant__c, Contact__c
                FROM Patient_Delegate__c
                WHERE Contact__c = :delegateContactId
        ];
        patientDelegate.Status__c = 'Active';
        update patientDelegate;

        EmailTemplateDelegatePartController controller = new EmailTemplateDelegatePartController();
        controller.delegateUserId = delegate.Id;
        controller.commTemplateStr = 'Default';
        Test.stopTest();

        System.assertEquals(td.ctp.Study_Code_Name__c, controller.getDelegateStudyNames()[0]);
    }

    @IsTest
    static void test_getDelegateStudyNames_emptyList() {
        TestData td = new TestData();
        User delegate = td.createPatientDelegate();
        insert delegate;

        Test.startTest();
        EmailTemplateDelegatePartController controller = new EmailTemplateDelegatePartController();
        controller.delegateUserId = delegate.Id;
        Test.stopTest();

        System.assert(controller.getDelegateStudyNames().isEmpty());
    }
}