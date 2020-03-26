/**
 * Created by Slav on 21.08.2019.
 */

@IsTest(SeeAllData=false)
public class Test_DuplicateContactController {
    
    @IsTest
    public static void runTest1() {
        TestData.loadTestData();
        Test.startTest();
        
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser) {
            Integration_Patient_Referral__c referral = new Integration_Patient_Referral__c(
                    firstName__c                    = 'FirstName',
                    lastName__c                     = 'LastName',
                    email__c                        = 'test@mail.com',
                    phone__c                        = '12357890',
                    protocolId__c                   = 'tt123456789',
                    siteSelected__c                 = '_',
                    Address_State__c                = 'New York',
                    referralID__c                   = '453453',
                    Address_ZipCode__c              = '34545',
                    Address_Country__c              = 'US',
                    Language_Preference__c          = 'en_US',
                    Referred_Date__c                = '2019-10-02T10:00:00-05:00',
                    Data_Source__c                  = 'Company',
                    acceptedTermsAndConditions__c   = '2019-10-02T10:00:00-05:00'
            );
//            insert referral;


//            DuplicateContactController.checkDuplicates(referral);
//
//            Participant__c participant;
//            Participant_Enrollment__c participantEnrollment;
//            DuplicateContactController.communityReffering(participant, participantEnrollment);
        
        
        
        
        }
        
        Test.stopTest();
    }

}
