/**
 * Created by Igor Iosifov on 2020-02-26.
 */

@IsTest
private class Test_Batch_ConversationReminder {

    @TestSetup
    static void setup() {

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();

        Contact contactWithoutUnreadConversations = new Contact(
                FirstName = 'Empty',
                LastName = 'Empty',
                Email = 'Empty@email.com',
                Unread_Conversation_Count__c = 0
        );
        insert contactWithoutUnreadConversations;

        Participant_Enrollment__c pe = [SELECT Id,PI_Contact__c FROM Participant_Enrollment__c LIMIT 1];

        Conversation__c conversation = new Conversation__c(
                Participant_Enrollment__c = pe.Id,
                haveUnreadForPI__c = true,
                FirstUnreadDate__c = Datetime.now().addDays(-6)
        );
        insert conversation;
    }

    @IsTest
    static void test() {
        delete [SELECT Id FROM Notification__c];

        Test.startTest();
        Database.executeBatch(new Batch_ConversationReminder());
        Test.stopTest();
        List<Contact> allContacts = [
                SELECT Id
                FROM Contact
        ];
        List<Contact> updatedContacts = [
                SELECT Id
                FROM Contact
                WHERE Unread_Conversation_Count__c != NULL
        ];
        System.assertEquals(allContacts.size(), updatedContacts.size());
        List<Contact> contactsToReceiveEmail = [
                SELECT Id
                FROM Contact
                WHERE Unread_Conversation_Count__c != NULL
                AND Unread_Conversation_Count__c != 0
        ];
        List<Notification__c> notifications = [SELECT Id FROM Notification__c];
        System.assertEquals(contactsToReceiveEmail.size(), notifications.size());
    }
}
