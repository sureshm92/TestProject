@IsTest(IsParallel=false)
private class Test_Action_AssignContactPermissions {
    static testMethod void testaddPermission() {
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        User admin = [
            SELECT Id, Username, UserRoleId
            FROM User
            WHERE
                Profile.Name = 'System Administrator'
                AND UserRoleId = :userRole_1.Id
                AND IsActive = TRUE
            LIMIT 1
        ];
        User user_1;
        System.runAs(admin) {
            Account usraccount = new Account(Name = 'Community');
            insert usraccount;

            Contact usrcontact = new Contact(AccountId = usraccount.Id, LastName = 'xgeek');
            insert usrcontact;

            user_1 = new User(
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = usrcontact.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        Test.startTest();
        System.runAs(user_1) {
            //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Community_Default'];
            String PERMISSION_COMMUNITY_DEFAULT_NAME = 'Community_Default';
            String PERMISSION_COMMUNITY_JANSSEN_NAME = 'Community_Janssen';
            Account SiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );

            insert SiteAccount;

            Contact cnt = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                AccountId = SiteAccount.Id
            );
            insert cnt;
            
            Action__c act = new Action__c();
            //act.Number_Of_Repetitions__c = 3;
            act.Status__c = 'Failed';
            act.Type__c = 'Action_SendSMS';
            insert act;
            
            Execution_History__c exeHistory = new Execution_History__c();
            exeHistory.Action__c = act.id;
            exeHistory.Error_Message__c = 'Unauthorized';
            insert exeHistory;
            
           Set<String> permissionsgrp = new Set<String>();
            permissionsgrp.add(PERMISSION_COMMUNITY_DEFAULT_NAME);
            permissionsgrp.add(PERMISSION_COMMUNITY_JANSSEN_NAME);
           Action_AssignContactPermissions action = new Action_AssignContactPermissions();
            action.addPermission(cnt.Id,PERMISSION_COMMUNITY_DEFAULT_NAME);
            action.getAssignedPermissions(cnt.Id);
            action.deletePermission(cnt.Id,PERMISSION_COMMUNITY_DEFAULT_NAME);
            action.isEmpty();
            action.execute();
            action.getType();
            action.isDMLWithSetupObjects();
            action.cleanReassignedPermissions();
            action.insertPermissions();
            action.deletePermissions();
            action.deletePermissions(cnt.Id,permissionsgrp);
            action.addPermissions(cnt.Id,permissionsgrp);
            action.postDML(act,exeHistory);
            system.assertEquals('Community_Default', PERMISSION_COMMUNITY_DEFAULT_NAME);
            system.assertNotEquals(PERMISSION_COMMUNITY_JANSSEN_NAME, PERMISSION_COMMUNITY_DEFAULT_NAME);
        }
        Test.stopTest();
    }
}