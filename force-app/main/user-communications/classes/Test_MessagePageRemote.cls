/**
 * Created by Igor Malyuta on 17.01.2020.
 */

@IsTest
private class Test_MessagePageRemote {

    @IsTest
    static void getInitDataTest() {
        TestData testData = new TestData();
        Conversation__c conversation = new Conversation__c(Participant_Enrollment__c = testData.pe.Id);
        insert conversation;
        insert new Message__c(
                Conversation__c = conversation.Id,
                Message_Content__c = 'Why???',
                Sender_Name__c = 'Morgan Stark'
        );

        testData.pe = [
                SELECT Id,
                        Participant_Contact__c,
                        Participant__r.Full_Name__c,
                        Participant_Status__c,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Principal_Investigator__r.Title
                FROM Participant_Enrollment__c
                WHERE Participant__c =: testData.participant.Id
        ];

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.getInitData();
        }
        Test.stopTest();
    }

    @IsTest
    static void createConversationTest() {
        TestData testData = new TestData();
        testData.pe = [
                SELECT Id,
                        Participant_Contact__c,
                        Participant__r.Full_Name__c,
                        Participant_Status__c,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Principal_Investigator__r.Title
                FROM Participant_Enrollment__c
                WHERE Participant__c =: testData.participant.Id
        ];

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.createConversation(testData.pe, 'hi everyone!');
        }
        Test.stopTest();
    }

    @IsTest
    static void markConversationAsReadTest() {
        TestData testData = new TestData();
        Conversation__c conversation = new Conversation__c(Participant_Enrollment__c = testData.pe.Id);
        insert conversation;
        insert new Message__c(
                Conversation__c = conversation.Id,
                Message_Content__c = 'Why???',
                Sender_Name__c = 'Morgan Stark'
        );

        testData.pe = [
                SELECT Id,
                        Participant_Contact__c,
                        Participant__r.Full_Name__c,
                        Participant_Status__c,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Principal_Investigator__r.Title
                FROM Participant_Enrollment__c
                WHERE Participant__c =: testData.participant.Id
        ];
        conversation.Participant_Enrollment__r = testData.pe;

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.markConversationAsRead(conversation);
        }
        Test.stopTest();
    }

    @TestSetup
    static void setup() {
        TestData.loadTestData();
    }
}