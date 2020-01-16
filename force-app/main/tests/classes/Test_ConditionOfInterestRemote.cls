/**
 * Created by Yehor Dobrovolskyi
 */
@IsTest
public with sharing class Test_ConditionOfInterestRemote {

//    @IsTest
//    public static void getConditionOfInterest_Test() {
//        ClassFactory.clearStubTypesByClassNamesMap();
//        ClassFactory.putStubTypeByClassName(TherapeuticAreaService.class, StubBuilder.newInstance(TherapeuticAreaService.class)
//                .when('getParticipant')
//                .then(Test_ConditionOfInterestRemote.getParticipant())
//                .build()
//       );
//        Test.startTest();
//        List<TherapeuticAreaService.CAWrapper> caWrappers = ConditionOfInterestRemote.getConditionOfInterest();
//        Test.stopTest();
//        System.assert(!caWrappers.isEmpty());
//    }

    @IsTest
    public static void getConditionOfInterest_Exception_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TherapeuticAreaService.class, StubBuilder.newInstance(TherapeuticAreaService.class)
                .when('getParticipant')
                .then(new AuraHandledException('Test Exception'))
                .build()
       );
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ConditionOfInterestRemote.getConditionOfInterest();
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(isExceptionThrown);
    }

    @IsTest
    public static void upsertListCoi_Test() {
        Account account = (Account) TestDataFactory.getSObject(Account.getSObjectType(), new Map<String, Object>{
                'Name' => CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        });
        Participant__c participant = (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType());
        Therapeutic_Area__c ta = (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType());
        insert new List<SObject>{
                account,
                participant,
                ta
        };

        Therapeutic_Area_Patient__c tap = (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(Therapeutic_Area_Patient__c.getSObjectType(), new Map<String, Object>{
                'Participant__c' => participant.Id,
                'Therapeutic_Area__c' => ta.Id,
                'Condition_Of_Interest_Order__c' => 0
        });
        Test.startTest();
        List<Therapeutic_Area_Patient__c> taps = ConditionOfInterestRemote.upsertListCoi(new List<Therapeutic_Area_Patient__c>{
                tap
        });
        Test.stopTest();
        System.assert(!taps.isEmpty());
        System.assertNotEquals(null, taps[0].Id);

    }

    @IsTest
    public static void upsertListCoi_Exception_Test() {
        Therapeutic_Area_Patient__c tap = (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(Therapeutic_Area_Patient__c.getSObjectType());
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            List<Therapeutic_Area_Patient__c> taps = ConditionOfInterestRemote.upsertListCoi(new List<Therapeutic_Area_Patient__c>{
                    tap
            });
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(isExceptionThrown);
    }

    @IsTest
    public static void deleteCOI_Test() {
        Account account = (Account) TestDataFactory.getSObject(Account.getSObjectType(), new Map<String, Object>{
                'Name' => CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        });
        Participant__c participant = (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType());
        Therapeutic_Area__c ta = (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType());
        insert new List<SObject>{
                account,
                participant,
                ta
        };

        Therapeutic_Area_Patient__c tap = (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(Therapeutic_Area_Patient__c.getSObjectType(), new Map<String, Object>{
                'Participant__c' => participant.Id,
                'Therapeutic_Area__c' => ta.Id,
                'Condition_Of_Interest_Order__c' => 0
        });
        insert tap;
        Test.startTest();
        ConditionOfInterestRemote.deleteCOI(new List<Id>{tap.Id});
        Test.stopTest();
        List<Therapeutic_Area_Patient__c> taps = [
                SELECT Id
                FROM Therapeutic_Area_Patient__c
        ];
        System.assert(taps.isEmpty());
    }

    @IsTest
    public static void deleteCOI_Exception_Test() {
        Therapeutic_Area_Patient__c tap = (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(Therapeutic_Area_Patient__c.getSObjectType(), new Map<String, Object>{
                'Id' => TestDataFactory.getFakeId(Therapeutic_Area_Patient__c.getSObjectType())
        });
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ConditionOfInterestRemote.deleteCOI(new List<Id>{
                    tap.Id
            });
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(isExceptionThrown);
    }

//    private static Participant__c getParticipant() {
//        Participant__c participant = (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType(), new Map<String, Object>{
//                'Id' => TestDataFactory.getFakeId(Participant__c.SObjectType)
//        });
//        ParticipantDecoupler.therapeuticAreaPatientsByParticipantIds.put(
//                participant.Id,
//                new List<Therapeutic_Area_Patient__c>{
//                        (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(Therapeutic_Area_Patient__c.getSObjectType())
//                }
//        );
//        return participant;
//    }
}