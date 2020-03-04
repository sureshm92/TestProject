/**
 * Created by Igor Malyuta on 17.01.2020.
 */

@IsTest
private class Test_MessagePageRemote {

    @IsTest
    static void getInitDataTest() {
        TestData testData = new TestData();
//        testData.pe = [
//                SELECT Id,
//                        Participant_Contact__c,
//                        Participant__r.Full_Name__c,
//                        Participant_Status__c,
//                        Study_Site__r.Principal_Investigator__c,
//                        Study_Site__r.Principal_Investigator__r.Name,
//                        Study_Site__r.Principal_Investigator__r.Title
//                FROM Participant_Enrollment__c
//                WHERE Participant__c =: testData.participant.Id
//        ];

        Conversation__c conversation = new Conversation__c(Participant_Enrollment__c = testData.pe.Id);
        insert conversation;
        insert ConversationService.createConversationSharesForUser(new List<Id>{conversation.Id}, testData.participantUser.Id);
        insert new Message__c(
                Conversation__c = conversation.Id,
                Message_Content__c = 'Why???',
                Sender_Name__c = 'Morgan Stark'
        );

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.getInitData('Large');
        }
        Test.stopTest();
    }

    @IsTest
    static void getInitDataPITest() {
        TestData testData = new TestData();
//        testData.pe = [
//                SELECT Id,
//                        Participant_Contact__c,
//                        Participant__r.Full_Name__c,
//                        Participant_Status__c,
//                        Study_Site__r.Principal_Investigator__c,
//                        Study_Site__r.Principal_Investigator__r.Name,
//                        Study_Site__r.Principal_Investigator__r.Title
//                FROM Participant_Enrollment__c
//                WHERE Participant__c =: testData.participant.Id
//        ];

        Conversation__c conversation = new Conversation__c(Participant_Enrollment__c = testData.pe.Id);
        insert conversation;
        insert ConversationService.createConversationSharesForUser(new List<Id>{conversation.Id}, testData.piUser.Id);
        insert new Message__c(
                Conversation__c = conversation.Id,
                Message_Content__c = 'Why???',
                Sender_Name__c = 'Morgan Stark'
        );

        Test.startTest();
        System.runAs(testData.piUser) {
            MessagePageRemote.getInitData('Large');
        }
        Test.stopTest();
    }

    @IsTest
    static void createConversationTest() {
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.createConversation(testData.pe, 'hi everyone!', null);
        }
        Test.stopTest();
    }

    @IsTest
    static void sendMultipleMessageTest() {
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.piUser) {
            MessagePageRemote.sendMultipleMessage(new List<String>{testData.pe.Id}, 'Hi Participant!', null);
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

//        testData.pe = [
//                SELECT Id,
//                        Participant_Contact__c,
//                        Participant__r.Full_Name__c,
//                        Participant_Status__c,
//                        Study_Site__r.Principal_Investigator__c,
//                        Study_Site__r.Principal_Investigator__r.Name,
//                        Study_Site__r.Principal_Investigator__r.Title
//                FROM Participant_Enrollment__c
//                WHERE Participant__c =: testData.participant.Id
//        ];
        conversation.Participant_Enrollment__r = testData.pe;

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.markConversationAsRead(conversation);
        }
        Test.stopTest();
    }

    @IsTest
    static void attachFileTest() {
        String fileJSON = JSON.serialize(new List<String>{'IQVIA SMS.txt', 'RGVhciBhbGwuDQpJZiB5b3VyIHBhc3N3b3JkIGhhcyBleHBpcmVkLCB5b3UgY2FuIHJlc3RvcmUgaXQgd2l0aG91dCBjYWxsaW5nIEhQUyBzdXBwb3J0Lg0KVG8gcmVjb3ZlciB0aGUgcGFzc3dvcmQsIHVzZSBjaXRyaXggKG5vdCBWUE4pOg0KLSBnbyB0byBodHRwczovL2ltc2FwcHMuaW1zaGVhbHRoLmNvbS92cG4vaW5kZXguaHRtbDsNCi0gZW50ZXIgeW91ciBsb2dpbiBhbmQgcGFzc3dvcmQgKElRVklBLCBub3QgSFBTIG1haWwpOw0KLSBjaGFuZ2UgcGFzc3dvcmQ7DQotIFBST0ZJVDs='});
        TestData testData = new TestData();
        Test.startTest();
        MessagePageRemote.attachFile(testData.ctp.Id, fileJSON);
        Test.stopTest();
    }

    @IsTest
    static void getUnreadCountTest() {
        TestData testData = new TestData();
        Conversation__c conversation = new Conversation__c(
                Participant_Enrollment__c = testData.pe.Id,
                haveUnreadForParticipant__c = true
        );
        insert conversation;
        insert ConversationService.createConversationSharesForUser(new List<Id>{conversation.Id}, testData.participantUser.Id);

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.getUnreadCount();
        }
        Test.stopTest();
    }

    @TestSetup
    static void setup() {
        TestData.loadTestData();
        List<Study_Site__c> studySites = [SELECT Id, Messages_Are_Available__c FROM Study_Site__c];
        for(Study_Site__c ss : studySites) ss.Messages_Are_Available__c = true;
        update studySites;
    }
}
