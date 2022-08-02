@isTest
public with sharing class OpenTokTestFactory {

    public static final String TEST_API_KEY             = '12345678';
    public static final String TEST_API_SECRET          = 'test';
    public static final String TEST_API_URL             = 'https://api.opentok.com';
    public static final String TEST_API_ANALYTICS_URL   = 'https://insights.opentok.com/graphql';
    public static final String UPDATE_SUFFIX            = '-update';
    public static final String SESSION_ID               = 'test-session-id';
    public static final String PROJECT_ID               = 'test-project-id';

    private static Integer userNumber = 0;

    public static TokBoxSettings2__c getOpenTokSetting() {
        TokBoxSettings2__c tokBoxSettings  = TokBoxSettings2__c.getOrgDefaults();
        tokBoxSettings.API_Key__c          = TEST_API_KEY;
        tokBoxSettings.API_Secret__c       = TEST_API_SECRET;
        tokBoxSettings.API_URL__c          = TEST_API_URL;

        return tokBoxSettings;
    }

    public static Televisit__c getSession(String sessionId) {
        return getSession(sessionId, DateTime.now().addDays(-1), DateTime.now().addDays(1), null);
    }

    public static Televisit__c getSession(String sessionId, Datetime startDate, Datetime endDate, Datetime canceledDate) {
        return new Televisit__c(
            Session_ID__c = sessionId,
            Visit_Date_Time__c = startDate,
            Visit_End_Date_Time__c = endDate,
            Duration__c = '30 minutes',
            title__c = 'Test'
        );
    }

    public static User createSysAdmin(Boolean doInsert, String email) {
        User admin = OpenTokTestFactory.createUser('System Administrator', doInsert, email);
        return admin;
    }

    public static User createUser(String profile, Boolean doInsert) {
        Integer userNum = userNumber++;
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profile].Id;

        String email = 'testuser@' + UserInfo.getOrganizationId() + '.iqvia-televisit.com';

        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));

        User u = new User(
                FirstName = 'Test',
                LastName = 'User ',
                Email = email,
                Username = email + randomInt,
                Alias = ('tuser' + userNum).right(8),
                Phone = '123-555-45678',
                ProfileId = profileId,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US'
        );

        if (doInsert) {
            insert u;
        }
        return u;
    }

    public static User createUser(String profile, Boolean doInsert, String email) {
        Integer userNum = userNumber++;
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profile].Id;
        if (email == null) {
            email = 'testuser@' + UserInfo.getOrganizationId() + '.iqvia-televisit.com';
        }
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));

        User u = new User(
                FirstName = 'Test',
                LastName = 'User ',
                Email = email,
                Username = email + randomInt,
                Alias = ('tuser' + userNum).right(8),
                Phone = '123-555-45678',
                ProfileId = profileId,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US'
        );

        if (doInsert) {
            insert u;
        }
        return u;
    }

    public static void addPermSet(User u, String permSet) {
        Id permSetId = [SELECT Id FROM PermissionSet WHERE Name = :permSet LIMIT 1].Id;
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permSetId);
        insert psa;
    }

}