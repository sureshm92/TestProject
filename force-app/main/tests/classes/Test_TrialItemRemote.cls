/**
 * Created by Vitalii Aheienko on 9/30/2019.
 */

@IsTest
private class Test_TrialItemRemote {

    @TestSetup
    static void setup() {
        TriggerHandlerExecutor.bypassHandler(ContactTherapeuticAreaTriggerHandler.SyncContactInterestedTopics.class);
        Test.startTest();
        TestDataFactory.createInitData();
        Test.stopTest();
    }

    @IsTest
    static void createCaseToStudy_test() {
        Participant__c participant = [SELECT Id, First_Name__c, Last_Name__c, Phone_Type__c, Gender__c, Phone__c, Email__c, Mailing_Country_Code__c, Mailing_Zip_Postal_Code__c, Mailing_State_Code__c, Date_of_Birth__c FROM Participant__c];
        Clinical_Trial_Profile__c ctp = [SELECT Id, NCT_Number__c, Study_Code_Name__c FROM Clinical_Trial_Profile__c];
        Test.startTest();
        TrialItemRemote.createCaseToStudy(participant, ctp, false);
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM Case].size());
    }

    /**
     * ONLY FOR DEPLOY
     */
//    @IsTest
//    static void createTrialNotification_test() {
//        Participant__c participant = [SELECT Id, Contact__c FROM Participant__c LIMIT 1];
//        User usr = [SELECT Id FROM User WHERE ContactId = :participant.Contact__c];
//
//        Clinical_Trial_Profile__c ctp = [SELECT Id, Name, Study_Code_Name__c FROM Clinical_Trial_Profile__c LIMIT 1];
//        System.runAs(usr) {
//            TrialItemRemote.createTrialNotification(ctp.Id);
//        }
//
//        List<Trial_Notification__c> notifications = selectTrialNotifications();
//
//        System.assertEquals(1, notifications.size());
//        System.assertEquals(ctp.Id, notifications[0].Clinical_Trial_Profile__c);
//        System.assertEquals(ctp.Study_Code_Name__c, notifications[0].CTP_Name__c);
//    }

    @IsTest
    static void createCaseToStudyWithException_test() {
        Participant__c participant = [SELECT Id, First_Name__c, Last_Name__c, Phone_Type__c, Gender__c, Phone__c, Email__c, Mailing_Country_Code__c, Mailing_Zip_Postal_Code__c, Mailing_State_Code__c, Date_of_Birth__c FROM Participant__c];
        Clinical_Trial_Profile__c ctp = [SELECT Id, NCT_Number__c FROM Clinical_Trial_Profile__c];
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TrialSearchHelper.class, StubBuilder.newInstance(TrialSearchHelper.class)
                .when('createCaseAndSendNotification')
                .then(new AuraHandledException(''))
                .build()
        );
        try{
            TrialItemRemote.createCaseToStudy(participant, ctp, false);
        } catch (AuraHandledException e){
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        System.assert(true, isExceptionThrown);
    }

//    @IsTest
//    static void createTrialNotificationWithException_test() {
//        Clinical_Trial_Profile__c ctp = [SELECT Id FROM Clinical_Trial_Profile__c LIMIT 1];
//        Boolean isExceptionThrown = false;
//        ClassFactory.clearStubTypesByClassNamesMap();
//        ClassFactory.putStubTypeByClassName(TrialSearchHelper.class, StubBuilder.newInstance(TrialSearchHelper.class)
//                .when('createTrialNotification')
//                .then(new AuraHandledException(''))
//                .build()
//        );
//        try{
//            TrialItemRemote.createTrialNotification(ctp.Id);
//        } catch (AuraHandledException e){
//            isExceptionThrown = true;
//            System.assert(e.getTypeName() == 'System.AuraHandledException');
//        }
//        System.assert(true, isExceptionThrown);
//    }


    private static List<Trial_Notification__c> selectTrialNotifications() {
        return [
                SELECT Id
                        , CTP_Name__c
                        , Contact__c
                        , Clinical_Trial_Profile__c
                FROM Trial_Notification__c
        ];
    }

}