/**
 * Created by Yehor Dobrovolskyi
 */
@IsTest
public with sharing class Test_TherapeuticAreaService {
    @IsTest
    public static void createThirdPartyCOIsByNames_Test() {
        Test.startTest();
        List<Therapeutic_Area__c> therapeuticAreas = new TherapeuticAreaService()
            .createThirdPartyCOIsByNames(new Set<String>{ 'Test' });
        Test.stopTest();
        System.assert(!therapeuticAreas.isEmpty());
    }

    @IsTest
    public static void getTherapeuticAreasByNames_Test() {
        insert (Therapeutic_Area__c) TestDataFactory.getSObject(
            Therapeutic_Area__c.getSObjectType(),
            new Map<String, Object>{
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                    TherapeuticAreaService.TA_RT_NAME,
                    Therapeutic_Area__c.getSObjectType()
                ),
                'Name' => 'Test'
            }
        );
        Test.startTest();
        List<Therapeutic_Area__c> therapeuticAreasEmpty = new TherapeuticAreaService()
            .getTherapeuticAreasByNames(null);
        List<Therapeutic_Area__c> therapeuticAreas = new TherapeuticAreaService()
            .getTherapeuticAreasByNames(new Set<String>{ 'Test' });
        Test.stopTest();
        System.assert(therapeuticAreasEmpty.isEmpty());
        System.assert(!therapeuticAreas.isEmpty());
    }

    @IsTest
    public static void getThirdPartyCOIsByNames_Test() {
        insert (Therapeutic_Area__c) TestDataFactory.getSObject(
            Therapeutic_Area__c.getSObjectType(),
            new Map<String, Object>{
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                    TherapeuticAreaService.THIRD_PARTY_COI_RT_NAME,
                    Therapeutic_Area__c.getSObjectType()
                ),
                'Name' => 'Test'
            }
        );
        Test.startTest();
        List<Therapeutic_Area__c> therapeuticAreasEmpty = new TherapeuticAreaService()
            .getThirdPartyCOIsByNames(null, false);
        List<Therapeutic_Area__c> therapeuticAreasFalse = new TherapeuticAreaService()
            .getThirdPartyCOIsByNames(new Set<String>{ 'Test' }, false);
        List<Therapeutic_Area__c> therapeuticAreasTrue = new TherapeuticAreaService()
            .getThirdPartyCOIsByNames(new Set<String>{ 'Test', 'Test 2' }, true);
        Test.stopTest();
        System.assert(therapeuticAreasEmpty.isEmpty());
        System.assertEquals(1, therapeuticAreasFalse.size());
        System.assertEquals(2, therapeuticAreasTrue.size());
    }

    @IsTest
    public static void getCOIWrappers_Test() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        List<TherapeuticAreaService.CAWrapper> caWrappers;
        List<Therapeutic_Area__c> areaList = [
            SELECT Id
            FROM Therapeutic_Area__c
            WHERE Id = :testData.ctp.Therapeutic_Area__c
        ];
        System.runAs(testData.participantUser) {
            caWrappers = new TherapeuticAreaService().getCOIWrappers(areaList);
        }
        Test.stopTest();
        System.assert(!caWrappers.isEmpty());
    }

    @IsTest
    public static void getTherapeuticAreas_Test() {
        insert new List<Therapeutic_Area__c>{
            (Therapeutic_Area__c) TestDataFactory.getSObject(
                Therapeutic_Area__c.getSObjectType(),
                new Map<String, Object>{
                    'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                        TherapeuticAreaService.COI_RT_NAME,
                        Therapeutic_Area__c.getSObjectType()
                    ),
                    'Name' => 'Test'
                }
            ),
            (Therapeutic_Area__c) TestDataFactory.getSObject(
                Therapeutic_Area__c.getSObjectType(),
                new Map<String, Object>{
                    'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                        TherapeuticAreaService.COI_RT_NAME,
                        Therapeutic_Area__c.getSObjectType()
                    ),
                    'Name' => 'Def'
                }
            )
        };
        Test.startTest();
        List<Therapeutic_Area__c> therapeuticAreasNull = new TherapeuticAreaService()
            .getTherapeuticAreas(null);
        List<Therapeutic_Area__c> therapeuticAreas = new TherapeuticAreaService()
            .getTherapeuticAreas('Test');
        Test.stopTest();
        System.assertEquals(2, therapeuticAreasNull.size());
        System.assertEquals(1, therapeuticAreas.size());
    }

    @IsTest
    public static void getParticipant_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
            CommunityService.class,
            StubBuilder.newInstance(CommunityService.class)
                .when('getParticipantId')
                .then(TestDataFactory.getFakeId(Participant__c.getSObjectType()))
                .build()
        );
        Test.startTest();
        Participant__c participant = new TherapeuticAreaService().getParticipant();
        Test.stopTest();
        System.assertEquals(null, participant);
    }

    @IsTest
    public static void deleteTA_test() {
        Therapeutic_Area__c therapeuticArea = (Therapeutic_Area__c) TestDataFactory.getSObject(
            Therapeutic_Area__c.getSObjectType()
        );
        insert therapeuticArea;
        List<Therapeutic_Area__c> tas = [SELECT Id FROM Therapeutic_Area__c];
        System.assert(!tas.isEmpty());
        delete therapeuticArea;
        tas = [SELECT Id FROM Therapeutic_Area__c];
        System.assert(tas.isEmpty());
    }
}
