/**
 * Created by Vitalii Aheienko on 9/20/2019.
 */

@IsTest(IsParallel=true)
private class Test_TrialSearchContainerRemote {

    @IsTest
    static void getSearchCTPs_test() {
        TrialSearchContainerRemote.TrialSearchContainer container = makeTsContainer();


        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TrialSearchHelper.class, StubBuilder.newInstance(TrialSearchHelper.class)
                .when('getInitTrialSearchContainer')
                .then(container)
                .build()
        );
        System.assertEquals(1, TrialSearchContainerRemote.getSearchCTPs().trialTDOs.size());
    }

    @IsTest
    static void getFilterSearchCTPs_test() {
        TrialSearchContainerRemote.TrialSearchContainer container = makeTsContainer();


        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TrialSearchHelper.class, StubBuilder.newInstance(TrialSearchHelper.class)
                .when('getTrialSearchContainer')
                .then(container)
                .build()
        );
        System.assertEquals(1, TrialSearchContainerRemote.getFilterSearchCTPs(null, null, null).trialTDOs.size());
    }

    @IsTest
    static void createTrialNotification_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TrialSearchHelper.class, StubBuilder.newInstance(TrialSearchHelper.class)
                .build()
        );
        TrialSearchContainerRemote.createTrialNotification(TestDataFactory.getFakeId(Clinical_Trial_Profile__c.getSObjectType()));
    }


    private static TrialSearchContainerRemote.TrialSearchContainer makeTsContainer() {
        TrialSearchContainerRemote.TrialTDO tdo = new TrialSearchContainerRemote.TrialTDO();
        tdo.ctp = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(),
                new Map<String, Object>{
                        'Visit_Plan__c' => TestDataFactory.getFakeId(Visit_Plan__c.getSObjectType())});
        tdo.relatedNotificationExists = true;
        tdo.isEnrollingCTP = true;
        TrialSearchContainerRemote.TrialSearchContainer container = new TrialSearchContainerRemote.TrialSearchContainer();
        container.trialTDOs = new List<TrialSearchContainerRemote.TrialTDO>{tdo};
        container.taps = new List<Therapeutic_Area_Patient__c>();
        container.participant = (Participant__c)TestDataFactory.getSObject(Participant__c.getSObjectType());

        return container;
    }



}