/**
 * Created by Igor Malyuta on 22.04.2019.
 */

@IsTest
private class Test_ManualTaskFilter {

    private static final String FIELD_JOIN_EXPECTED = 'Account IN (\'' +
            '0011F00000PfTigQAF' + ManualTaskFilter.SEPARATOR +
            '0011F00000PfTihQAF' + ManualTaskFilter.SEPARATOR +
            '0011F00000PfTiiQAF' + ManualTaskFilter.SEPARATOR +
            '0011F00000PfTijQAF' + '\') ';

    @IsTest
    static void fieldJoinTest() {
        List<String> testIds = new List<String>();
        testIds.add('0011F00000PfTigQAF');
        testIds.add('0011F00000PfTihQAF');
        testIds.add('0011F00000PfTiiQAF');
        testIds.add('0011F00000PfTijQAF');

        Test.startTest();
        ManualTaskFilter manualTaskFilter = new ManualTaskFilter();
        String filterFieldJoin = manualTaskFilter.fieldJoin('Account', testIds);
        Test.stopTest();

        System.assertEquals(FIELD_JOIN_EXPECTED, filterFieldJoin);
    }
}