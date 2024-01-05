@IsTest
public class Test_IPRBatchDeletion {
@TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testIPRBatchDel_false() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Study_Hub_Log__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Protocol_ID__c,Participant__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c(
                Address_Country__c = 'US',
                Address_State__c = 'New York',
                Address_ZipCode__c = '2152',
                birthYear__c = '2000',
                Data_Source__c = 'IQVIA registry',
                email__c = 'some@dssd.cre',
                firstName__c = 'Nezz',
                lastName__c = 'Weg',
                Language_Preference__c = 'en_US',
                phone__c = '31444244214',
                siteSelected__c = 'SS1',
                Referred_Date__c  = '2019-10-02T10:00:00-05:00',
                referralID__c = 'SS1_NYBC12346',
                acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00',
                Condition_Of_Interests__c = 'Covid-19',
                Delegate_First_Name__c = 'Tommy',
                Delegate_Last_Name__c = 'Danny',
                Delegate_Phone_Number_Type__c = 'Home',
                Delegate_Zip_Postal_Code__c = '1003',
                Delegate_Email_Address__c = 'tommy.danny@mail.com',
            	protocolId__c=enroll.Clinical_Trial_Profile__r.Protocol_ID__c
        );
        insert ipr;
        Participant__c participant = new Participant__c(id= enroll.Participant__c);
        participant.Contact__c = con.id;
        update participant;
        
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        
        
        Database.executeBatch(new IntegrationPatientReferralBatchDeletion(enroll.Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Integration_Patient_Referral__c> iprList=[SELECT Id from Integration_Patient_Referral__c where protocolId__c=:enroll.Clinical_Trial_Profile__r.Protocol_ID__c limit 10];
        System.assertEquals(1,iprList.size());
        
    }
    @IsTest
    static void testIPRBatchDel_True() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Study_Hub_Log__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Protocol_ID__c,Participant__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c(
                Address_Country__c = 'US',
                Address_State__c = 'New York',
                Address_ZipCode__c = '2152',
                birthYear__c = '2000',
                Data_Source__c = 'IQVIA registry',
                email__c = 'some@dssd.cre',
                firstName__c = 'Nezz',
                lastName__c = 'Weg',
                Language_Preference__c = 'en_US',
                phone__c = '31444244214',
                siteSelected__c = 'SS1',
                Referred_Date__c  = '2019-10-02T10:00:00-05:00',
                referralID__c = 'SS1_NYBC12346',
                acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00',
                Condition_Of_Interests__c = 'Covid-19',
                Delegate_First_Name__c = 'Tommy',
                Delegate_Last_Name__c = 'Danny',
                Delegate_Phone_Number_Type__c = 'Home',
                Delegate_Zip_Postal_Code__c = '1003',
                Delegate_Email_Address__c = 'tommy.danny@mail.com',
            	protocolId__c=enroll.Clinical_Trial_Profile__r.Protocol_ID__c
        );
        insert ipr;
        Participant__c participant = new Participant__c(id= enroll.Participant__c);
        participant.Contact__c = con.id;
        update participant;
        
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        
        Database.executeBatch(new IntegrationPatientReferralBatchDeletion(enroll.Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Integration_Patient_Referral__c> iprList=[SELECT Id from Integration_Patient_Referral__c where protocolId__c=:enroll.Clinical_Trial_Profile__r.Protocol_ID__c limit 10];
        System.assertEquals(0,iprList.size());
        
    }
    @IsTest
    static void testIPRBatchDel_OnlyPart() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Protocol_ID__c,Participant__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        
        Participant__c participant = new Participant__c(id= enroll.Participant__c);
        participant.Contact__c = con.id;
        update participant;
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c(
                Address_Country__c = 'US',
                Address_State__c = 'New York',
                Address_ZipCode__c = '2152',
                birthYear__c = '2000',
                Data_Source__c = 'IQVIA registry',
                email__c = 'some@dssd.cre',
                firstName__c = 'Nezz',
                lastName__c = 'Weg',
                Language_Preference__c = 'en_US',
                phone__c = '31444244214',
                siteSelected__c = 'SS1',
                Referred_Date__c  = '2019-10-02T10:00:00-05:00',
                referralID__c = 'SS1_NYBC12346',
                acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00',
                Condition_Of_Interests__c = 'Covid-19',
                Delegate_First_Name__c = 'Tommy',
                Delegate_Last_Name__c = 'Danny',
                Delegate_Phone_Number_Type__c = 'Home',
                Delegate_Zip_Postal_Code__c = '1003',
                Delegate_Email_Address__c = 'tommy.danny@mail.com',
            	protocolId__c=enroll.Clinical_Trial_Profile__r.Protocol_ID__c,
            	Participant_enrollment__c=enroll.Id
        );
        insert ipr;
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking',Only_Selected_Participants__c=true);
        insert studClTest;
        Participant_Closure__c partCls= new Participant_Closure__c(Name='REF00000',Study_Closure__c=studClTest.id);
        insert partCls;
        
        
        Database.executeBatch(new IntegrationPatientReferralBatchDeletion(enroll.Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Integration_Patient_Referral__c> iclList=[SELECT Id from Integration_Patient_Referral__c where Participant_enrollment__c=:enroll.Id limit 10];
        System.assertEquals(1,iclList.size());

        
    }
}