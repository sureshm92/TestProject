/**
 * Created by Yehor Dobrovolskyi
 */
@IsTest
public with sharing class Test_ConditionOfInterestRemote {

    @TestSetup
    public static void setup() {

    }

    @IsTest
    public static void getConditionOfInterest_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TherapeuticAreaService.class, StubFactory.newInstance(TherapeuticAreaService.class)
                .when('getParticipant')
                .then(Test_ConditionOfInterestRemote.getParticipant())
                .getInstance()
        );
        Test.startTest();
        List<TherapeuticAreaService.CAWrapper> caWrappers = ConditionOfInterestRemote.getConditionOfInterest();
        Test.stopTest();
        System.assert(!caWrappers.isEmpty());
    }

    private static Participant__c getParticipant() {
        Participant__c participant = (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType(), new Map<String, Object>{
                'Id' => TestDataFactory.getFakeId(Participant__c.SObjectType)
        });
        ParticipantDecoupler.therapeuticAreaPatientsByParticipantIds.put(
                participant.Id,
                new List<Therapeutic_Area_Patient__c>{
                        (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(Therapeutic_Area_Patient__c.getSObjectType())
                }
        );
        return participant;
    }
}