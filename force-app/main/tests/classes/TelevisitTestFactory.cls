@isTest
public class TelevisitTestFactory {

    public static User createSysAdmin(Boolean doInsert, String email) {
        User admin = TelevisitTestFactory.createUser('System Administrator', doInsert, email);
        //TelevisitTestFactory.addPermSet(admin, 'Tokbox_User');
        return admin;
    }

    private static Integer userNumber = 0;
    public static User createUser(String profile, Boolean doInsert) {
        Integer userNum = userNumber++;
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profile].Id;

        String email = 'testuser@' + UserInfo.getOrganizationId() + '.iqviactms.com';

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

    private static User createUser(String profile, Boolean doInsert, String email) {
        Integer userNum = userNumber++;
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profile].Id;
        if (email == null) {
            email = 'testuser@' + UserInfo.getOrganizationId() + '.iqviactms.com';
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

    private static void addPermSet(User u, String permSet) {
        Id permSetId = [SELECT Id FROM PermissionSet WHERE Name = :permSet LIMIT 1].Id;
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permSetId);
        insert psa;
    }
}