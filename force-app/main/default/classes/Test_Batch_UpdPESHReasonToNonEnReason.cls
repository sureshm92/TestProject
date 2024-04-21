/**
* @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
 * @last modified on  : 12-15-2020
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
 * Ver   Date         Author                               Modification
* 1.0   12-15-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class Test_Batch_UpdPESHReasonToNonEnReason {
    @TestSetup
    static void init() {
        Test.startTest();
        //TestDataFactory.createInitData();
        Test.stopTest();
            TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
         TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
         TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.UpdatePERReEngaged.class
        );
        //Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
        //id peId = [SELECT Id FROM Participant_Enrollment__c Limit 1].id;
        //pesh.ParticipantEnrollment__c = peId;
        //pesh.Status__c = 'Successfully Contacted';
        //pesh.Date__c = DateTime.now();
        //pesh.Reason__c = 'Test';
        //insert pesh;
        
        
    }
    @IsTest
    static void testBehavior() {
         TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.UpdateLastChangedAdditionalNotes.class
            ); 
        //TestDataFactory.createInitData();
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
        //id peId = [SELECT Id FROM Participant_Enrollment__c  Limit 1].id;
        /*pesh.ParticipantEnrollment__c = peId;
        pesh.Status__c = 'Successfully Contacted';
        pesh.Date__c = DateTime.now();
        pesh.Reason__c = 'Test';
        insert pesh;*/
        Test.startTest();
        Database.executeBatch(new Batch_UpdPESHReasonToNonEnReason(),1);   
        Test.stopTest();
    }
}