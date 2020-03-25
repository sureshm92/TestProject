/**
 * Created by Igor Iosifov on 2020-03-23.
 */

@IsTest
public with sharing class Test_ParametersProviderService {

    @TestSetup
    static void testSetup() {
        TestData.loadTestData();
    }

    @IsTest
    static void test() {
        TestData testData = new TestData();
        Study_Site__c studySite = [
                SELECT Id,
                        Name,
                        Clinical_Trial_Profile__r.Study_Title__c,
                        Principal_Investigator__r.Full_Name__c,
                        Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site_Phone__c,
                        ReferralNetworkId__r.Name,
                        Principal_Investigator__r.Language__c
                FROM Study_Site__c WHERE Id = :testData.ss.Id
        ];
        String resultValue = ParametersProviderService.substituteMergeFields('##RecipientName', 'PP_Study_Site',studySite, 'en_US');
        System.assert(!resultValue.contains('##'));
    }
}