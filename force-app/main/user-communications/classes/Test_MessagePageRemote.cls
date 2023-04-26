/**
 * Created by Igor Malyuta on 17.01.2020.
 */

@IsTest
private class Test_MessagePageRemote {
    @IsTest
    static void getInitDataTest() {
        TestData testData = new TestData();

        Conversation__c conversation = new Conversation__c(
            Participant_Enrollment__c = testData.pe.Id
        );
        insert conversation;
        insert ConversationService.createConversationSharesForUser(
            new List<Id>{ conversation.Id },
            testData.participantUser.Id
        );
        insert new Message__c(
            Conversation__c = conversation.Id,
            Message_Content__c = 'Why???',
            Sender_Name__c = 'Morgan Stark'
        );

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.getInitData('Large', false);
        }
        Test.stopTest();
    }

    @IsTest
    static void getInitDataPITest() {
        TestData testData = new TestData();
        Test.startTest();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        Conversation__c conversation = new Conversation__c(
            Participant_Enrollment__c = testData.pe.Id
        );
        insert conversation;
        insert ConversationService.createConversationSharesForUser(
            new List<Id>{ conversation.Id },
            testData.piUser.Id
        );
        insert new Message__c(
            Conversation__c = conversation.Id,
            Message_Content__c = 'Why???',
            Sender_Name__c = 'Morgan Stark'
        );

        
        System.runAs(testData.piUser) {
            MessagePageRemote.getInitData('Large', false);
        }
        Test.stopTest();
    }

    @IsTest
    static void createConversationTest() {
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.createConversation(testData.pe, 'hi everyone!', false, null, false, null);
        }
        Test.stopTest();
    }

    @IsTest
    static void sendMultipleMessageTest() {
        TestData testData = new TestData();

        Test.startTest();
         List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        System.runAs(testData.piUser) {
            MessagePageRemote.createConversation(testData.pe, 'hi everyone!', false, null, false, null);
            MessagePageRemote.sendMultipleMessage(
                new List<String>{ testData.pe.Id },
                'Hi Participant!', false,
                null,
                null
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void markConversationAsReadTest() {
        TestData testData = new TestData();
        Conversation__c conversation = new Conversation__c(
            Participant_Enrollment__c = testData.pe.Id
        );
        insert conversation;
        insert new Message__c(
            Conversation__c = conversation.Id,
            Message_Content__c = 'Why???',
            Sender_Name__c = 'Morgan Stark'
        );

        conversation.Participant_Enrollment__r = testData.pe;

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.markConversationAsRead(conversation, false, null);
        }
        Test.stopTest();
    }

    @IsTest
    static void attachFileTest() {
        String fileJSON = JSON.serialize(
            new List<String>{
                'IQVIA SMS.txt',
                'RGVhciBhbGwuDQpJZiB5b3VyIHBhc3N3b3JkIGhhcyBleHBpcmVkLCB5b3UgY2FuIHJlc3RvcmUgaXQgd2l0aG91dCBjYWxsaW5nIEhQUyBzdXBwb3J0Lg0KVG8gcmVjb3ZlciB0aGUgcGFzc3dvcmQsIHVzZSBjaXRyaXggKG5vdCBWUE4pOg0KLSBnbyB0byBodHRwczovL2ltc2FwcHMuaW1zaGVhbHRoLmNvbS92cG4vaW5kZXguaHRtbDsNCi0gZW50ZXIgeW91ciBsb2dpbiBhbmQgcGFzc3dvcmQgKElRVklBLCBub3QgSFBTIG1haWwpOw0KLSBjaGFuZ2UgcGFzc3dvcmQ7DQotIFBST0ZJVDs='
            }
        );
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
        insert ConversationService.createConversationSharesForUser(
            new List<Id>{ conversation.Id },
            testData.participantUser.Id
        );

        Test.startTest();
        System.runAs(testData.participantUser) {
            MessagePageRemote.getUnreadCount();
        }
        Test.stopTest();
    }

    @IsTest
    static void searchParticipantTest() {
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.piUser) {
            MessagePageRemote.searchParticipant('Participant', new List<String>{ '' });
            MessagePageRemote.ConversationWrapper msg = new MessagePageRemote.ConversationWrapper();
            String s = msg.fullName;
        }
        Test.stopTest();
    }

    @IsTest
    static void getPIContactFullNamesTest() {
        TestData testData = new TestData();
        List<Id> piContactIds = new List<Id>();
        piContactIds.add(testData.piContact.Id);
        Test.startTest();
        System.runAs(testData.piUser) {
            Map<Id, String> getPIContaNames = MessagePageRemote.getPIContactFullNames(piContactIds);
            try {
                MessagePageRemote.AttachmentWrapper msg = new MessagePageRemote.AttachmentWrapper(
                    null
                );
            } catch (Exception e) {
            }
        }
        Test.stopTest();
    }

    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();

        List<Study_Site__c> studySites = [SELECT Id, Messages_Are_Available__c FROM Study_Site__c];
        for (Study_Site__c ss : studySites)
            ss.Messages_Are_Available__c = true;
        update studySites;

        Test.stopTest();
    }
}