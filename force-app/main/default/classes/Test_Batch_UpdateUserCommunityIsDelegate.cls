@isTest(IsParallel=false)
public class Test_Batch_UpdateUserCommunityIsDelegate {
     @IsTest
    static void testCommunityIsDelegate(){
         Test.startTest();
            Account SiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );

            insert SiteAccount;
            Contact con = new Contact(
                FirstName = 'ParticipantTD',
                LastName = 'ParticipantTD',
                AccountId = SiteAccount.Id,
                UserCommunityIsDelegate__c = False
            );
            insert con;
            
            
            Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false
            );
            insert clinical;
            //clinicalLST.add(clinical);
           
            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'part1@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            age__c = 23,
            site__c = SiteAccount.id,
            Contact__c = con.Id,
            Gender_Technical__c = 'Male',
            // Present_Age__c = 24,
            Adult__c = true,
            Ethnicity__c = ''
        );
        insert participant;
            Site_Staff__c siteStaff = new Site_Staff__c(
                Delegate_Level__c = 'Level 1',
                Study_Site__c = studySite.Id,
                Site_Contact__c = con.Id,
                is_Invited__c=true
            );
            insert siteStaff;
        Database.executeBatch(new Batch_UpdateUserCommunityIsDelegate());
        Test.stopTest();
        
    }

}