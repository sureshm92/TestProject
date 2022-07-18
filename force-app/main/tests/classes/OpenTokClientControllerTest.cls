@isTest
public with sharing class OpenTokClientControllerTest {
    private static String testEmailAddress = 'johnny.bravo@cartoon-network.com';
    private static Televisit__c testSession;

    @TestSetup
    private static void setup() {
        insert OpenTokTestFactory.getSession(OpenTokTestFactory.SESSION_ID);
        insert OpenTokTestFactory.getOpenTokSetting();
    }

    private static void setup_validateAttendeeEmail() {
        testSession = OpenTokTestFactory.getSession(OpenTokTestFactory.SESSION_ID);
        insert testSession;

        insert new Televisit_Attendee__c(Televisit__c = testSession.Id, Attendee_Email__c = testEmailAddress, User__c = UserInfo.getUserId());
    }

    @isTest
    private static void testConstructor() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Televisit__c session = OpenTokTestFactory.getSession(OpenTokTestFactory.SESSION_ID);
            insert session;

            insert new Televisit_Attendee__c(Televisit__c = session.Id, User__c = adminUser.Id);

            PageReference pageRef = Page.televisit;
            pageRef.getParameters().put(OpenTokClientController.SESSION_ID_PARAMETER, OpenTokTestFactory.SESSION_ID);
            Test.setCurrentPage(pageRef);

            Test.startTest();
            OpenTokClientController c = new OpenTokClientController();
            Test.stopTest();
            System.assert(c!=null);
        }
    }

    @isTest
    private static void validateAttendeeEmail_noMatch_nullInput() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            setup_validateAttendeeEmail();

            Test.startTest();

                OpenTokClientController controller = new OpenTokClientController();
                controller.attendeeEmailAddress = null;
                controller.session = testSession;
                controller.validateAttendeeEmail();

            Test.stopTest();

            System.assertEquals(false, controller.isAttendeeEmailValid, 'The email address should validate successfully given null input.');
        }
    }

    @isTest
    private static void validateAttendeeEmail_noMatch_blankInput() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            setup_validateAttendeeEmail();

            Test.startTest();

                OpenTokClientController controller = new OpenTokClientController();
                controller.attendeeEmailAddress = '';
                controller.session = testSession;
                controller.validateAttendeeEmail();

            Test.stopTest();

            System.assertEquals(false, controller.isAttendeeEmailValid, 'The email address should not validate successfully given blank input.');
        }
    }

    @isTest
    private static void validateAttendeeEmail_noMatch_noSessions() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Test.startTest();

                OpenTokClientController controller = new OpenTokClientController();
                controller.attendeeEmailAddress = testEmailAddress;
                controller.session = testSession;
                controller.validateAttendeeEmail();

            Test.stopTest();

            System.assertEquals(false, controller.isAttendeeEmailValid, 'The email address should not validate successfully when no sessions exist.');
        }
    }

    @isTest
    private static void validateAttendeeEmail_noMatch_noAttendees() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            testSession = OpenTokTestFactory.getSession(OpenTokTestFactory.SESSION_ID);
            insert testSession;

            Test.startTest();

                OpenTokClientController controller = new OpenTokClientController();
                controller.attendeeEmailAddress = testEmailAddress;
                controller.session = testSession;
                controller.validateAttendeeEmail();

            Test.stopTest();

            System.assertEquals(false, controller.isAttendeeEmailValid, 'The email address should not validate successfully when no attendees exist.');
        }
    }

    @isTest
    private static void validateAttendeeEmail_noMatch_otherSession() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Televisit__c testSession = OpenTokTestFactory.getSession(OpenTokTestFactory.SESSION_ID);
            Televisit__c otherSession = OpenTokTestFactory.getSession('Other Session ID');

            insert new List<Televisit__c>{
                    testSession, otherSession
            };

            Televisit_Attendee__c testAttendee = new Televisit_Attendee__c(Televisit__c = otherSession.Id, Attendee_Email__c = testEmailAddress, User__c = UserInfo.getUserId());
            insert testAttendee;

            Test.startTest();

                OpenTokClientController controller = new OpenTokClientController();
                controller.attendeeEmailAddress = testEmailAddress;
                controller.session = testSession;
                controller.validateAttendeeEmail();

            Test.stopTest();

            System.assertEquals(false, controller.isAttendeeEmailValid, 'The email address should not validate successfully when the email address matches an attendee of another session.');
        }
    }

    @isTest
    private static void validateAttendeeEmail_match_exact() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            setup_validateAttendeeEmail();

            Test.startTest();

                OpenTokClientController controller = new OpenTokClientController();
                controller.attendeeEmailAddress = testEmailAddress;
                controller.session = testSession;
                controller.validateAttendeeEmail();

            Test.stopTest();

            System.assertEquals(true, controller.isAttendeeEmailValid, 'The email address should validate successfully given an exact match.');
        }
    }

    @isTest
    private static void validateAttendeeEmail_match_differentCasing() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Televisit__c testSession = OpenTokTestFactory.getSession(OpenTokTestFactory.SESSION_ID);
            insert testSession;

            Televisit_Attendee__c testAttendee = new Televisit_Attendee__c(Televisit__c = testSession.Id, Attendee_Email__c = testEmailAddress.toLowerCase(), User__c = UserInfo.getUserId());
            insert testAttendee;

            Test.startTest();

                OpenTokClientController controller = new OpenTokClientController();
                controller.attendeeEmailAddress = testEmailAddress.toUpperCase();
                controller.session = testSession;
                controller.validateAttendeeEmail();

            Test.stopTest();

            System.assertEquals(true, controller.isAttendeeEmailValid, 'The email address should validate successfully given a case-insensitive match.');
        }
    }

    @isTest
    private static void validateAttendeeEmail_noMatch_differentUser() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Televisit__c testSession = OpenTokTestFactory.getSession(OpenTokTestFactory.SESSION_ID);
            insert testSession;

            User otherUser = OpenTokTestFactory.createUser('System Administrator', true);

            Televisit_Attendee__c testAttendee = new Televisit_Attendee__c(Televisit__c = testSession.Id, Attendee_Email__c = testEmailAddress.toLowerCase(), User__c = otherUser.Id);
            insert testAttendee;

            Test.startTest();

                OpenTokClientController controller = new OpenTokClientController();
                controller.attendeeEmailAddress = testEmailAddress;
                controller.session = testSession;
                controller.validateAttendeeEmail();

            Test.stopTest();

            System.assertEquals(false, controller.isAttendeeEmailValid, 'The email address should not validate successfully given a match with the wrong user.');
        }
    }

    @isTest
    private static void validateAttendeeEmail_noMatch_noEmailAddress() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Televisit__c testSession = OpenTokTestFactory.getSession(OpenTokTestFactory.SESSION_ID);
            insert testSession;

            Televisit_Attendee__c testAttendee = new Televisit_Attendee__c(Televisit__c = testSession.Id, Attendee_Email__c = null, User__c = UserInfo.getUserId());
            insert testAttendee;

            Test.startTest();

                try {
                    OpenTokClientController controller = new OpenTokClientController();
                    controller.attendeeEmailAddress = testEmailAddress;
                    controller.session = testSession;
                    controller.validateAttendeeEmail();

                    System.assertEquals(false, controller.isAttendeeEmailValid, 'The email address should not validate successfully when the attendee has no email address on the record.');
                } catch (NullPointerException npe) {
                    System.assert(false, 'No exception should be thrown.');
                }

            Test.stopTest();
        }
    }
    
    @isTest
    private static void test_getIsSessionJoinable_tooEarly() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Televisit__c session = OpenTokTestFactory.getSession(
                    OpenTokTestFactory.SESSION_ID,
                    DateTime.now().addMinutes(31),
                    DateTime.now().addMinutes(60),
                    null
            );

            insert session;

            OpenTokClientController controller = new OpenTokClientController();
            controller.session = session;

            Test.startTest();
            Boolean isSessionJoinable = controller.getIsSessionJoinable();
            Test.stopTest();

            System.assertEquals(false, isSessionJoinable, 'You should not be able to join a meeting if the session is n (30) number of mins before session start date');
        }
    }

    @isTest
    private static void test_getIsSessionJoinable_tooLate() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Televisit__c session = OpenTokTestFactory.getSession(
                    OpenTokTestFactory.SESSION_ID,
                    DateTime.now().addMinutes(-60),
                    DateTime.now().addMinutes(-31),
                    null
            );

            insert session;

            OpenTokClientController controller = new OpenTokClientController();
            controller.session = session;

            Test.startTest();
            Boolean isSessionJoinable = controller.getIsSessionJoinable();
            Test.stopTest();

            System.assertEquals(false, isSessionJoinable, 'You should not be able to join a meeting if the session is n (30) number of mins after session end date');

        }
    }

    @isTest
    private static void test_getIsSessionJoinable_canceled() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Televisit__c session = OpenTokTestFactory.getSession(
                    OpenTokTestFactory.SESSION_ID,
                    DateTime.now().addMinutes(-10),
                    DateTime.now().addMinutes(10),
                    DateTime.now()
            );
            insert session;

            OpenTokClientController controller = new OpenTokClientController();
            controller.session = session;

            Test.startTest();
            Boolean isSessionJoinable = controller.getIsSessionJoinable();
            Test.stopTest();

            System.assertEquals(false, isSessionJoinable, 'You should not be able to join a meeting if the session is canceled');
        }
    }

    @isTest
    private static void testUpdateAttendees() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Televisit__c session = new Televisit__c(Session_ID__c = OpenTokTestFactory.SESSION_ID);
            insert session;

            Televisit_Attendee__c attendeeRecord = new Televisit_Attendee__c(Televisit__c = session.Id, Attendee_Email__c = testEmailAddress.toLowerCase(), Firstname__c = 'First', Lastname__c = 'Last');
            insert attendeeRecord;

            OpenTokClientController.Attendee attendee = new OpenTokClientController.Attendee();
            attendee.id = attendeeRecord.Id;

            OpenTokClientController controller = new OpenTokClientController();
            controller.attendeesJson = JSON.serialize(new List<OpenTokClientController.Attendee>{
                    attendee
            });

            controller.updateAttendees();

            System.assertEquals(1, controller.attendees.size());
            System.assertEquals('First Last', controller.attendees[0].name);
        }
    }

    @isTest
    private static void testGetAttendeeName() {
        User adminUser = TelevisitTestFactory.createSysAdmin(true, 'user232423@sldkfjsdlk.org');
        System.runAs(adminUser) {
            Televisit__c session = new Televisit__c(Session_ID__c = OpenTokTestFactory.SESSION_ID);
            insert session;

            Televisit_Attendee__c attendee = new Televisit_Attendee__c(Televisit__c = session.Id, Attendee_Email__c = testEmailAddress.toLowerCase(), Firstname__c = 'First', Lastname__c = 'Last');
            insert attendee;

            String name = OpenTokClientController.getAttendeeName(attendee.Id);

            System.assertEquals('First Last', name);
        }
    }
}