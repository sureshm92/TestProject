/**
 * Created by Igor Malyuta on 22.04.2019.
 */

@IsTest
public class Test_ManualTaskFilter {

    private static final String FIELD_JOIN_EXPECTED = 'Account IN (\'' +
            '0011F00000PfTigQAF' + ManualTaskFilter.SEPARATOR +
            '0011F00000PfTihQAF' + ManualTaskFilter.SEPARATOR +
            '0011F00000PfTiiQAF' + ManualTaskFilter.SEPARATOR +
            '0011F00000PfTijQAF' + '\') ';

    @IsTest
    public static void fieldJoinTest() {
        List<String> testIds = new List<String>();
        testIds.add('0011F00000PfTigQAF');
        testIds.add('0011F00000PfTihQAF');
        testIds.add('0011F00000PfTiiQAF');
        testIds.add('0011F00000PfTijQAF');
    
        TestData.loadTestData();
        TestData testDataInstance = new TestData();

        Test.startTest();
        
        ManualTaskFilter manualTaskFilter = new ManualTaskFilter();
        String filterFieldJoin = manualTaskFilter.fieldJoin('Account', testIds);
        System.assertEquals(FIELD_JOIN_EXPECTED, filterFieldJoin);

        manualTaskFilter.countries.add(new LookupSearchResult('US', 'Participant_Status__c', 'icon', 'title', 'subtitle'));
    
        manualTaskFilter.statuses.add('Enrolled');
        manualTaskFilter.statuses.add('Referred');
        
        manualTaskFilter.getUsers();
        
        manualTaskFilter.filterTherapeutic();
        manualTaskFilter.getCountryCode();

        Test.stopTest();
    }
}