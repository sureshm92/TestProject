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
    static void getSearchCTPsWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TrialSearchHelper.class, StubBuilder.newInstance(TrialSearchHelper.class)
                .when('getInitTrialSearchContainer')
                .then(new AuraHandledException(''))
                .build()
        );
        try{
            TrialSearchContainerRemote.getSearchCTPs();
        } catch (AuraHandledException e){
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getFilterSearchCTPs_Exception_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TrialSearchHelper.class, StubBuilder.newInstance(TrialSearchHelper.class)
                .when('getTrialSearchContainer')
                .then(new AuraHandledException(''))
                .build()
        );
        try{
            TrialSearchContainerRemote.getFilterSearchCTPs(null, null, null);
        } catch (AuraHandledException e){
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        System.assert(true, isExceptionThrown);
    }


    private static TrialSearchContainerRemote.TrialSearchContainer makeTsContainer() {
        TrialSearchContainerRemote.TrialTDO tdo = new TrialSearchContainerRemote.TrialTDO();
        tdo.ctp = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        tdo.relatedNotificationExists = true;
        tdo.isEnrollingCTP = true;
        TrialSearchContainerRemote.TrialSearchContainer container = new TrialSearchContainerRemote.TrialSearchContainer();
        container.trialTDOs = new List<TrialSearchContainerRemote.TrialTDO>{tdo};
        container.taps = new List<Therapeutic_Area_Patient__c>();
        container.participant = (Participant__c)TestDataFactory.getSObject(Participant__c.getSObjectType());

        return container;
    }


}