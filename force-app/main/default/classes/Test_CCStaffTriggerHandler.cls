@IsTest
public class Test_CCStaffTriggerHandler {
    @IsTest
    public static void runTest() {
        Account account_1 = new Account(Name = 'Community');
        insert account_1;
        
        Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',userCommunityMode__c='CC');
        insert contact_1;
        
        CC_Staff__c cstaff = new CC_Staff__c(Contact__c= contact_1.id,CC_Staff_Status__c= 'Invited');
        insert cstaff;
        
        cstaff.CC_Staff_Status__c ='Not Invited';
        update cstaff;
    }
}