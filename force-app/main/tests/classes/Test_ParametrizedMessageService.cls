/**
 * Created by Igor Iosifov on 2020-03-23.
 */

@IsTest
public with sharing class Test_ParametrizedMessageService {

    @TestSetup
    static void testSetup() {
        TestData.loadTestData();
    }

    @IsTest
    static void test() {
        String label = 'PP_Study_Site';
        TestData testData = new TestData();
        List<Parameters_Provider__mdt> parametersProvider = [
                SELECT Id,
                        Parameters__c
                FROM Parameters_Provider__mdt
                WHERE Label = :label
        ];
        String parametersText = String.valueOf(parametersProvider.get(0)).substringBetween('{', '}');
        List<String> parameters = String.valueOf(parametersText).split('\n');
        String tempString = parameters.get(0).substringBefore(' =');
        String parameter = '##' + tempString.substringAfterLast('=');

        List<String> fields = new List<String>();
        for (String str : parameters) fields.add(str.substringAfter('= '));
        List<Study_Site__c> studySites = DatabaseService.query(fields, Study_Site__c.getSObjectType(), DatabaseService.fieldEqual('Id', testData.ss.Id));
        
        ParametrizedMessageService parametrizedMessageService = new ParametrizedMessageService();
        parametrizedMessageService.addMessage ('Message 1', parameter, studySites.get(0).Id, label, 'en_US');
        parametrizedMessageService.processMessages();

        System.assert(!parametrizedMessageService.getMessage('Message 1').contains('##'));
    }
}
