/**
 * Created by Igor Malyuta on 22.04.2019.
 */

@IsTest
public class Test_ManualTaskFilter {
    private static final String FIELD_JOIN_EXPECTED =
        ' Account IN (\'' +
        '0011F00000PfTigQAF' +
        ManualTaskFilter.SEPARATOR +
        '0011F00000PfTihQAF' +
        ManualTaskFilter.SEPARATOR +
        '0011F00000PfTiiQAF' +
        ManualTaskFilter.SEPARATOR +
        '0011F00000PfTijQAF' +
        '\') ';

    @IsTest
    public static void fieldJoinTest() {
        List<String> testIds = new List<String>();
        testIds.add('0011F00000PfTigQAF');
        testIds.add('0011F00000PfTihQAF');
        testIds.add('0011F00000PfTiiQAF');
        testIds.add('0011F00000PfTijQAF');

        TestData.loadTestData();
        TestData td = new TestData();

        List<Participant_Enrollment__c> testPEs;
        String filterResult;
        List<String> filteredCountryCodes;

        Test.startTest();
        ManualTaskFilter manualTaskFilter = new ManualTaskFilter();
        System.assertEquals(FIELD_JOIN_EXPECTED, DatabaseService.fieldInValues('Account', testIds));

        manualTaskFilter.countries.add(
            new LookupSearchResult('US', 'Participant_Status__c', 'icon', 'title', 'subtitle')
        );
        manualTaskFilter.statuses.add('Enrolled');
        manualTaskFilter.statuses.add('Referred');

        testPEs = manualTaskFilter.getContactsWithPE().get(td.participant.Contact__c);
        TaskService.TaskConfig taskConfig = new TaskService.TaskConfig();
        taskConfig.visibility ='Delegates';
        filterResult = manualTaskFilter.filterTherapeutic();
        filteredCountryCodes = manualTaskFilter.getCountryCode();
        manualTaskFilter.isPlatformLevel = true;
        manualTaskFilter.getContactsWithWhatIds(taskConfig);
        manualTaskFilter.getContactsWithParticipantIds(taskConfig.visibility);
        Test.stopTest();

        System.assertEquals('US', testPEs[0].Participant__r.Mailing_Country_Code__c);
        System.assert(filterResult.contains('Participant__c'));
        System.assert(filteredCountryCodes.contains('US'));
    }
}
