/**
 * Created by Igor Malyuta on 19.04.2019.
 */

@IsTest(IsParallel=false)
private class Test_ParticipantVisitsRemote {

    @IsTest
    static void getVisitsPreviewTest() {
        TestData.loadTestData();

        Test.startTest();
        User user = getSomeData();
        System.runAs(user){
            ParticipantVisitsRemote.getVisitsPreview();
        }
        Test.stopTest();
    }

    @IsTest
    static void getParticipantVisitsTest() {
        TestData.loadTestData();

        Test.startTest();
        User user = getSomeData();
        System.runAs(user){
            ParticipantVisitsRemote.getParticipantVisits('Current');
        }
        Test.stopTest();
    }

    @IsTest
    static void getVisitsLegendTest() {
        TestData.loadTestData();

        Visit_Plan__c vp = [SELECT Id FROM Visit_Plan__c];
        Icon_Details__c icon = new Icon_Details__c(Name='ICON', Label__c='icon label', Description__c='This is icon!', Visit_Plan__c = vp.Id);
        insert icon;

        String legend;
        Test.startTest();
        User user = getSomeData();
        System.runAs(user){
            legend = ParticipantVisitsRemote.getVisitsLegend('ICON');
        }
        Test.stopTest();

        System.assertEquals('[{"iconLegend":"'+icon.Description__c+'","iconLabel":"'+icon.Label__c+'","iconId":"'+icon.Name+'"}]', legend);
    }

    @TestSetup
    static void setup() {
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        List<Visit__c> visits = new List<Visit__c>();
        for(Integer i = 0; i < 5; i++) {
            visits.add(new Visit__c(
                    Name = 'TestVisit'+i,
                    Visit_Schedule__c = 'Week'+i,
                    Icons__c = 'Test_icon',
                    Order__c = i,
                    Visit_Plan__c = vp.Id
            ));
        }
        insert visits;
    }

    static User getSomeData(){
        TestData testData = new TestData();

        Clinical_Trial_Profile__c ctp = [SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c WHERE Id =: testData.ctp.Id];
        Visit_Plan__c vp = [SELECT Id FROM Visit_Plan__c];
        ctp.Visit_Plan__c = vp.Id;
        update ctp;
        Participant_Enrollment__c pe = [SELECT Id, Visit_Plan__c FROM Participant_Enrollment__c WHERE Clinical_Trial_Profile__c = :ctp.Id];
        pe.Visit_Plan__c = vp.Id;
        update pe;

        return testData.participantUser;
    }
}
