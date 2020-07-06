/**
 * Created by Yehor Dobrovolskyi
 */
@IsTest(IsParallel=false)
public without sharing class Test_SearchConditionsOfInterestRemote {
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    public static void searchConditionOfInterest_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TherapeuticAreaService.class, StubBuilder.newInstance(TherapeuticAreaService.class)
                .when('getTherapeuticAreas')
                .then(new List<Therapeutic_Area__c>{
                        (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType())
                })
                .when('getCOIWrappers')
                .then(new List<TherapeuticAreaService.CAWrapper>{
                        new TherapeuticAreaService.CAWrapper()
                })
                .build()
       );
        Test.startTest();
        List<TherapeuticAreaService.CAWrapper> caWrappers = SearchConditionsOfInterestRemote.searchConditionOfInterest('test');

        Test.stopTest();
        System.assert(!caWrappers.isEmpty());
    }

    @IsTest
    public static void searchConditionOfInterest_Exception_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TherapeuticAreaService.class, StubBuilder.newInstance(TherapeuticAreaService.class)
                .when('getTherapeuticAreas')
                .then(new AuraHandledException('Test Exception'))
                .build()
       );
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            SearchConditionsOfInterestRemote.searchConditionOfInterest('test');
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
        SearchConditionsOfInterestRemote.deleteCOI(new List<Id>{
                tap.Id
        });
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
            SearchConditionsOfInterestRemote.deleteCOI(new List<Id>{
                    tap.Id
            });
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(isExceptionThrown);
    }

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
            SearchConditionsOfInterestRemote.getConditionOfInterest();
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
        List<Therapeutic_Area_Patient__c> taps = SearchConditionsOfInterestRemote.upsertListCoi(new List<Therapeutic_Area_Patient__c>{
                tap
        });
		SearchConditionsOfInterestRemote.createSubscribeConnection(taps);
        
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
            List<Therapeutic_Area_Patient__c> taps = SearchConditionsOfInterestRemote.upsertListCoi(new List<Therapeutic_Area_Patient__c>{
                    tap
            });
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(isExceptionThrown);
    }
    
    @isTest
    public static void getConditionsOfInterest() {
        TestData testDataInstance = new TestData();
        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA TD1');
        insert area;
        Therapeutic_Area_Patient__c tap = new Therapeutic_Area_Patient__c();
        tap.Condition_Of_Interest_Order__c=1;
        tap.Participant__c = testDataInstance.participant.Id;
        tap.Therapeutic_Area__c=area.id;
        insert tap;
        Test.startTest();
        
        
       System.runAs(testDataInstance.participantUser) {
           SearchConditionsOfInterestRemote.getConditionOfInterest();
        }
        Test.stopTest();
    }
    
}