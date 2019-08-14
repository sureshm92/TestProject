/**
 * Created by Igor Malyuta on 19.04.2019.
 */
@IsTest
private class Test_VisitService {

    @IsTest
    static void getVisitsTest() {
        TestData.loadTestData();
        TestData testData = new TestData();
        testData.ctp = [SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c WHERE Id =: testData.ctp.Id];
        testData.ctp.Visit_Plan__c = getVisitPlanId();
        update testData.ctp;

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testData.pe;

        System.runAs(testData.participantUser) {
            Test.startTest();
            List<Visit__c> visits = VisitService.getInstance().getVisits(null);
            Test.stopTest();

            List<Visit__c> visits2 = [
                    SELECT Id,
                            Name,
                            Icons__c,
                            Order__c,
                            Visit_Plan__c
                    FROM Visit__c
                    ORDER BY Order__c
            ];

            System.assertEquals(visits2.size(), visits.size());

            for (Integer i = 0; i < visits2.size(); i++) {
                Visit__c v1 = visits.get(i);
                Visit__c v2 = visits2.get(i);

                System.assertEquals(v1.Id, v2.Id);
                System.assertEquals(v1.Name, v2.Name);
                System.assertEquals(v1.Icons__c, v2.Icons__c);
            }
        }
    }

    @IsTest
    static void getPreviewVisitsTest() {
        TestData.loadTestData();
        TestData testData = new TestData();
        testData.ctp = [SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c WHERE Id =: testData.ctp.Id];
        testData.ctp.Visit_Plan__c = getVisitPlanId();
        update testData.ctp;

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testData.pe;

        System.runAs(testData.participantUser) {
            Test.startTest();
            List<Visit__c> previewVisits = VisitService.getInstance().getPreviewVisits();
            Test.stopTest();

            List<Visit__c> visits2 = [
                    SELECT Id,
                            Name,
                            Icons__c,
                            Order__c,
                            Visit_Plan__c
                    FROM Visit__c
                    ORDER BY Order__c
                    LIMIT 3
            ];
            System.assertEquals(visits2.size(), previewVisits.size());

            for (Integer i = 0; i < visits2.size(); i++) {
                Visit__c v1 = previewVisits.get(i);
                Visit__c v2 = visits2.get(i);

                System.assertEquals(v1.Id, v2.Id);
                System.assertEquals(v1.Name, v2.Name);
                System.assertEquals(v1.Icons__c, v2.Icons__c);
            }
        }
    }

    static Id getVisitPlanId() {
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        List<String> iconsApiName = new List<String>{
                'icon-questionnaires;icon-ecg',
                'icon-vital-signs;icon-blood-test',
                'icon-questionnaires;icon-brief-ph-ex',
                'icon-questionnaires;icon-blood-test;icon-brief-ph-ex',
                'icon-questionnaires;icon-ecg;icon-vital-signs;icon-blood-test'
        };
        List<Visit__c> visits = new List<Visit__c>();
        for (Integer i = 0; i < 5; i++) {
            visits.add(new Visit__c(
                    Name = 'TestVisit' + i,
                    Visit_Schedule__c = 'Week' + i,
                    Icons__c = iconsApiName.get(i),
                    Order__c = i,
                    Visit_Plan__c = vp.Id
            ));
        }
        insert visits;

        return vp.Id;
    }
}