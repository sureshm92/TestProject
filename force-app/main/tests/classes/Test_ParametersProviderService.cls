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
                        Principal_Investigator__r.Full_Name__c,
                        Name,
                        ReferralNetworkId__r.Name
                FROM Study_Site__c WHERE Id = :testData.ss.Id
        ];

        String resultValue = ParametersProviderService.substituteMergeFields('##PIName', 'PP_Study_Site',studySite, 'en_US');
        System.assert(!resultValue.contains('##'));
    }
}