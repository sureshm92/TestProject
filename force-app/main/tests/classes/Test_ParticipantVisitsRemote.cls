/**
 * Created by Igor Malyuta on 19.04.2019.
 */

@IsTest(IsParallel=false)
private class Test_ParticipantVisitsRemote {

    @IsTest
    static void test() {
        TestData.loadTestData();
        TestData testData = new TestData();

        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
        vp = [SELECT Id FROM Visit_Plan__c];

        Visit__c visit = new Visit__c(
                Name = 'TestVisit'+ 1,
                Visit_Schedule__c = 'Week ' + 1,
                Icons__c = 'Test_icon',
                Order__c = 1,
                Visit_Plan__c = vp.Id
        );
        insert visit;

        testData.ctp.Visit_Plan__c = vp.Id;
        update testData.ctp;

        testData.pe.Visit_Plan__c = vp.Id;
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testData.pe;

        Patient_Visit__c patientVisit = PatientVisitService.createPatientVisit(visit, testData.pe.Id);
        insert patientVisit;

        Icon_Details__c icon = new Icon_Details__c(Name='ICON', Label__c='icon label', Description__c='This is icon!', Visit_Plan__c = vp.Id);
        insert icon;

        Test.startTest();
        String legend;

        System.runAs(testData.participantUser){
            patientVisit.Planned_Date__c = Date.newInstance(2020, 3, 17);
            ParticipantVisitsRemote.isStudySiteHasVisits();
            ParticipantVisitsRemote.getVisitsPreview();
            ParticipantVisitsRemote.getParticipantVisits('Current');
            ParticipantVisitsRemote.getCardPatientVisits();
            ParticipantVisitsRemote.updatePatientVisit(JSON.serialize(patientVisit));
            legend = ParticipantVisitsRemote.getVisitsLegend('ICON');
        }
        Test.stopTest();

        System.assertEquals('[{"iconLegend":"'+icon.Description__c+'","iconLabel":"'+icon.Label__c+'","iconId":"'+icon.Name+'"}]', legend);
    }
}
