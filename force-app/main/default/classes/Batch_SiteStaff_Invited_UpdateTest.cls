@isTest
private class Batch_SiteStaff_Invited_UpdateTest {
    static testmethod void test() {
     
    List<Site_Staff__c> SS = new List<Site_Staff__c>();
    Contact c = new Contact(Email='testsitestaff@gmail.com',LastName='conlast');
    insert c;
    for (Integer i=0;i<20;i++) {
        Site_Staff__c s = new Site_Staff__c(Email__c= 'sitestaff' + i+'@emil.com',Site_Contact__c=c.id,Delegate_Level__c='Level 1');
        SS.add(s);
    }
    insert SS;
 
        Test.startTest();
            Batch_SiteStaff_Invited_Update b = new Batch_SiteStaff_Invited_Update();
        Database.executeBatch(b);
        Test.stopTest();
     
    }
}