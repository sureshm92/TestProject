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
    static void getDelegateStudyNamesTest() {
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

        EmailTemplateProviderService.setProviderType('', delegate.Id, delegate.Name,
                'en_US', 'Default', delegate.Id, '');
        EmailTemplateDelegatePartController controller = new EmailTemplateDelegatePartController();
        controller.getBottomText();
        Test.stopTest();

        System.assertEquals(td.ctp.Study_Code_Name__c, controller.getDelegateStudyNames()[0]);
    }

    @IsTest
    static void getDelegateStudyNamesWithSourceIdTest() {
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

        EmailTemplateProviderService.setProviderType('', delegate.Id, delegate.Name,
                'en_US', 'Default', delegate.Id, 'HTML');
        EmailTemplateDelegatePartController controller = new EmailTemplateDelegatePartController();
        controller.sourceIdValue = td.pe.Id;
        Test.stopTest();

        System.assertEquals(td.ctp.Study_Code_Name__c, controller.getDelegateStudyNames()[0]);
    }
}