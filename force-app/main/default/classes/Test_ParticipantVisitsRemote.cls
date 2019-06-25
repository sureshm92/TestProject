/**
 * Created by Igor Malyuta on 19.04.2019.
 */

@IsTest(IsParallel=true)
private class Test_ParticipantVisitsRemote {

    class VisitServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs
        ) {
            switch on stubbedMethodName {
                when 'getPreviewVisits'{
                    return [
                            SELECT Id,
                                    Name,
                                    Visit_Schedule__c,
                                    Icons__c,
                                    Order__c,
                                    Visit_Plan__c,
                                    Status__c
                            FROM Visit__c
                            ORDER BY Order__c
                            LIMIT 3
                    ];
                }
                when 'getVisits' {
                    return [
                            SELECT Id,
                                    Name,
                                    Visit_Schedule__c,
                                    Icons__c,
                                    Order__c,
                                    Visit_Plan__c,
                                    Status__c
                            FROM Visit__c
                            ORDER BY Order__c
                    ];
                }
            }
            return null;
        }

    }

    @IsTest
    static void getVisitsPreviewTest() {
        VisitService.setMock(new VisitServiceMock());

        Test.startTest();
        String preview = ParticipantVisitsRemote.getVisitsPreview();
        Test.stopTest();

        List<Visit__c> previewVisits = VisitService.getInstance().getPreviewVisits();
        System.assertEquals(JSON.serialize(previewVisits), preview);
    }

    @IsTest
    static void getParticipantVisitsTest() {
        VisitService.setMock(new VisitServiceMock());

        Test.startTest();
        List<ParticipantVisitsService.VisitWrapper> participantVisits = ParticipantVisitsRemote.getParticipantVisits('Current');
        Test.stopTest();

        List<Visit__c> visitsAll = VisitService.getInstance().getVisits(null);
        System.assertEquals(visitsAll.size(), participantVisits.size());
    }

    @IsTest
    static void getVisitsLegendTest() {
        List<PicklistEntry> picklistEntries = Visit__c.Icons__c.getDescribe().picklistValues;
        List<ParticipantVisitsRemote.Legend> legends = new List<ParticipantVisitsRemote.Legend>();
        for(PicklistEntry entry : picklistEntries) {
            ParticipantVisitsRemote.Legend leg = new ParticipantVisitsRemote.Legend();
            leg.iconId = entry.value;
            leg.iconLabel = entry.label;
            leg.iconLegend = ParticipantVisitsRemote.LABELS_MAP.get(entry.label);
            legends.add(leg);
        }

        Test.startTest();
        String legend = ParticipantVisitsRemote.getVisitsLegend();
        Test.stopTest();

        System.assertEquals(JSON.serialize(legends), legend);
    }

    @TestSetup
    static void setup() {
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
        for(Integer i = 0; i < 5; i++) {
            visits.add(new Visit__c(
                    Name = 'TestVisit'+i,
                    Visit_Schedule__c = 'Week'+i,
                    Icons__c = iconsApiName.get(i),
                    Order__c = i,
                    Visit_Plan__c = vp.Id
            ));
        }
        insert visits;
    }
}