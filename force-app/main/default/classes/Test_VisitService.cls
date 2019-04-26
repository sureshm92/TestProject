/**
 * Created by Igor Malyuta on 19.04.2019.
 */

@IsTest
private class Test_VisitService {

    public class DatabaseServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'queryImpl' && listOfArgs.size() == 3) {
                SObjectType sObjectType = (SObjectType) listOfArgs[1];
                if(sObjectType == Visit__c.getSObjectType()){
                    String query = 'SELECT Id, Name, Timeplane__c, Icons__c, Order__c, Visit_Plan__c FROM ' + sObjectType
                        + ' WHERE ' + (String) listOfArgs[2];
                    return Database.query(query);
                }
            }
            return null;
        }
    }

    public class ParticipantServiceMock implements System.StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs
        ) {
            if(stubbedMethodName == 'getState'){
                ParticipantService.ParticipantState state = new ParticipantService.ParticipantState();
                state.pse = [
                        SELECT Id,
                               Clinical_Trial_Profile__r.Visit_Plan__c
                        FROM Participant_Study_Enrollment__c
                ].get(0);
                return state;
            }
            return null;
        }
    }

    @IsTest
    static void getVisitsTest() {
        DatabaseService.setMock(new DatabaseServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());

        Test.startTest();
        List<Visit__c> visits = VisitService.getInstance().getVisits(null);
        Test.stopTest();

        List<Visit__c> visits2 = [
                SELECT Id,
                        Name,
                        Timeplane__c,
                        Icons__c,
                        Order__c,
                        Visit_Plan__c
                FROM Visit__c
                ORDER BY Order__c
        ];
        System.assertEquals(visits2.size(), visits.size());

        for(Integer i = 0; i < visits2.size(); i++) {
            Visit__c v1 = visits.get(i);
            Visit__c v2 = visits2.get(i);

            System.assertEquals(v1.Id, v2.Id);
            System.assertEquals(v1.Name, v2.Name);
            System.assertEquals(v1.Timeplane__c, v2.Timeplane__c);
            System.assertEquals(v1.Icons__c, v2.Icons__c);
            System.assertEquals(v1.Order__c, v2.Order__c);
            System.assertEquals(v1.Visit_Plan__c, v2.Visit_Plan__c);
        }
    }

    @IsTest
    static void getPreviewVisitsTest() {
        DatabaseService.setMock(new DatabaseServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());

        Test.startTest();
        List<Visit__c> previewVisits = VisitService.getInstance().getPreviewVisits();
        Test.stopTest();

        List<Visit__c> visits2 = [
                SELECT Id,
                        Name,
                        Timeplane__c,
                        Icons__c,
                        Order__c,
                        Visit_Plan__c
                FROM Visit__c
                ORDER BY Order__c
                LIMIT 3
        ];
        System.assertEquals(visits2.size(), previewVisits.size());

        for(Integer i = 0; i < visits2.size(); i++) {
            Visit__c v1 = previewVisits.get(i);
            Visit__c v2 = visits2.get(i);

            System.assertEquals(v1.Id, v2.Id);
            System.assertEquals(v1.Name, v2.Name);
            System.assertEquals(v1.Timeplane__c, v2.Timeplane__c);
            System.assertEquals(v1.Icons__c, v2.Icons__c);
            System.assertEquals(v1.Order__c, v2.Order__c);
            System.assertEquals(v1.Visit_Plan__c, v2.Visit_Plan__c);
        }
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
                    Timeplane__c = 'Week'+i,
                    Icons__c = iconsApiName.get(i),
                    Order__c = i,
                    Visit_Plan__c = vp.Id
            ));
        }
        insert visits;

        Clinical_Trial_Profile__c trial = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'Prot-333',
                NCT_Number__c = 'NCT02804789',
                Visit_Plan__c = vp.Id
        );
        insert trial;

        Contact patientContact = new Contact(
                FirstName = 'Richard',
                LastName = 'Wilson',
                Email = 'r.wilson@gmail.com',
                userCommunityMode__c = 'Participant'
        );
        insert patientContact;

        Participant__c participant = new Participant__c(
                First_Name__c = patientContact.FirstName,
                Contact__c = patientContact.Id
        );
        insert participant;

        Participant_Study_Enrollment__c pse = new Participant_Study_Enrollment__c(
                Clinical_Trial_Profile__c = trial.Id,
                Participant__c = participant.Id
        );
        insert pse;
    }
}