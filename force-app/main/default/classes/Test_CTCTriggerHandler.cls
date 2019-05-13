@IsTest(IsParallel=true)
public class Test_CTCTriggerHandler {

    @IsTest
    public static void afterInsert_Test() {

        Resource__c singleResource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object>{
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_THIRD_PARTY
        });
        insert singleResource;

        Id thirdPartyCOIRecordTypeId = SchemaUtil.getRecordTypeIdByName(TherapeuticAreaService.THIRD_PARTY_COI_RT_NAME, Therapeutic_Area__c.getSObjectType());
        Id cOIRecordTypeId = SchemaUtil.getRecordTypeIdByName(TherapeuticAreaService.COI_RT_NAME, Therapeutic_Area__c.getSObjectType());

        List<Therapeutic_Area__c> tAs = new List<Therapeutic_Area__c>();
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = thirdPartyCOIRecordTypeId,
                Name = 'Third Party COI 1'
        ));
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = thirdPartyCOIRecordTypeId,
                Name = 'Third Party COI 2'
        ));
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = cOIRecordTypeId,
                Name = 'COI 1'
        ));
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = cOIRecordTypeId,
                Name = 'COI 2.1'
        ));
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = cOIRecordTypeId,
                Name = 'COI 2.2'
        ));
        insert tAs;

        List<Therapeutic_Area_Assignment__c> assignments = new List<Therapeutic_Area_Assignment__c>();
        assignments.add(new Therapeutic_Area_Assignment__c(
                Resource__c = singleResource.Id,
                Therapeutic_Area__c = tAs[0].Id,
                Third_Party_COI__c = tAs[0].Id
        ));
        assignments.add(new Therapeutic_Area_Assignment__c(
                Resource__c = singleResource.Id,
                Therapeutic_Area__c = tAs[1].Id,
                Third_Party_COI__c = tAs[1].Id
        ));
        insert assignments;

        List<CTC__c> cTCs = new List<CTC__c>();
        cTCs.add(new CTC__c(
                COI_3rdParty__c = tAs[0].Id,
                COI__c = tAs[2].Id
        ));
        cTCs.add(new CTC__c(
                COI_3rdParty__c = tAs[1].Id,
                COI__c = tAs[3].Id
        ));
        cTCs.add(new CTC__c(
                COI_3rdParty__c = tAs[1].Id,
                COI__c = tAs[4].Id
        ));

        Test.startTest();
        insert cTCs;
        Test.stopTest();

        assignments = [SELECT Id, Therapeutic_Area__r.Name, Third_Party_COI__r.Name FROM Therapeutic_Area_Assignment__c WHERE Therapeutic_Area__r.RecordTypeId = :cOIRecordTypeId ORDER BY Therapeutic_Area__r.Name];
        System.assertEquals(3, assignments.size());

        System.assertEquals('COI 1', assignments[0].Therapeutic_Area__r.Name);
        System.assertEquals('Third Party COI 1', assignments[0].Third_Party_COI__r.Name);
        System.assertEquals('COI 2.1', assignments[1].Therapeutic_Area__r.Name);
        System.assertEquals('Third Party COI 2', assignments[1].Third_Party_COI__r.Name);
        System.assertEquals('COI 2.2', assignments[2].Therapeutic_Area__r.Name);
        System.assertEquals('Third Party COI 2', assignments[2].Third_Party_COI__r.Name);
    }

    @IsTest
    public static void afterDelete_Test() {

        List<Resource__c> resources = new List<Resource__c>();
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object>{
                'Title__c' => 'Resource 1',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_THIRD_PARTY
        }));
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object>{
                'Title__c' => 'Resource 2',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_THIRD_PARTY
        }));
        insert resources;

        Id thirdPartyCOIRecordTypeId = SchemaUtil.getRecordTypeIdByName(TherapeuticAreaService.THIRD_PARTY_COI_RT_NAME, Therapeutic_Area__c.getSObjectType());
        Id cOIRecordTypeId = SchemaUtil.getRecordTypeIdByName(TherapeuticAreaService.COI_RT_NAME, Therapeutic_Area__c.getSObjectType());

        List<Therapeutic_Area__c> tAs = new List<Therapeutic_Area__c>();
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = thirdPartyCOIRecordTypeId,
                Name = 'Third Party COI 1'
        ));
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = thirdPartyCOIRecordTypeId,
                Name = 'Third Party COI 2'
        ));
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = cOIRecordTypeId,
                Name = 'COI 1'
        ));
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = cOIRecordTypeId,
                Name = 'COI 2.1'
        ));
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = cOIRecordTypeId,
                Name = 'COI 2.2'
        ));
        insert tAs;

        List<Therapeutic_Area_Assignment__c> assignments = new List<Therapeutic_Area_Assignment__c>();
        assignments.add(new Therapeutic_Area_Assignment__c(
                Resource__c = resources[0].Id,
                Therapeutic_Area__c = tAs[0].Id,
                Third_Party_COI__c = tAs[0].Id
        ));
        assignments.add(new Therapeutic_Area_Assignment__c(
                Resource__c = resources[0].Id,
                Therapeutic_Area__c = tAs[1].Id,
                Third_Party_COI__c = tAs[1].Id
        ));
        assignments.add(new Therapeutic_Area_Assignment__c(
                Resource__c = resources[1].Id,
                Therapeutic_Area__c = tAs[1].Id,
                Third_Party_COI__c = tAs[1].Id
        ));
        insert assignments;

        List<CTC__c> cTCs = new List<CTC__c>();
        cTCs.add(new CTC__c(
                COI_3rdParty__c = tAs[0].Id,
                COI__c = tAs[2].Id
        ));
        cTCs.add(new CTC__c(
                COI_3rdParty__c = tAs[1].Id,
                COI__c = tAs[3].Id
        ));
        cTCs.add(new CTC__c(
                COI_3rdParty__c = tAs[1].Id,
                COI__c = tAs[4].Id
        ));
        insert cTCs;

        assignments = [SELECT Id, Therapeutic_Area__r.Name, Third_Party_COI__r.Name FROM Therapeutic_Area_Assignment__c WHERE Therapeutic_Area__r.RecordTypeId = :cOIRecordTypeId ORDER BY Therapeutic_Area__r.Name];
        System.assertEquals(5, assignments.size());

        Test.startTest();
        delete cTCs;
        Test.stopTest();

        assignments = [SELECT Id, Therapeutic_Area__r.Name, Third_Party_COI__r.Name, Resource__r.Title__c FROM Therapeutic_Area_Assignment__c ORDER BY Resource__r.Title__c];
        System.debug(assignments);
        System.assertEquals(3, assignments.size());

        System.assertEquals('Third Party COI 1', assignments[0].Therapeutic_Area__r.Name);
        System.assertEquals('Third Party COI 1', assignments[0].Third_Party_COI__r.Name);
        System.assertEquals('Third Party COI 2', assignments[1].Therapeutic_Area__r.Name);
        System.assertEquals('Third Party COI 2', assignments[1].Third_Party_COI__r.Name);
        System.assertEquals('Third Party COI 2', assignments[2].Therapeutic_Area__r.Name);
        System.assertEquals('Third Party COI 2', assignments[2].Third_Party_COI__r.Name);
    }

    @IsTest
    public static void beforeUpdate_Test() {

        Id thirdPartyCOIRecordTypeId = SchemaUtil.getRecordTypeIdByName(TherapeuticAreaService.THIRD_PARTY_COI_RT_NAME, Therapeutic_Area__c.getSObjectType());
        Id cOIRecordTypeId = SchemaUtil.getRecordTypeIdByName(TherapeuticAreaService.COI_RT_NAME, Therapeutic_Area__c.getSObjectType());

        List<Therapeutic_Area__c> tAs = new List<Therapeutic_Area__c>();
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = thirdPartyCOIRecordTypeId,
                Name = 'Third Party COI 1'
        ));
        tAs.add(new Therapeutic_Area__c(
                RecordTypeId = cOIRecordTypeId,
                Name = 'COI 1'
        ));
        insert tAs;

        List<CTC__c> cTCs = new List<CTC__c>();
        cTCs.add(new CTC__c(
                COI_3rdParty__c = tAs[0].Id,
                COI__c = tAs[1].Id
        ));
        insert cTCs;

        cTCs = [SELECT Id, COI_3rdParty__c FROM CTC__c];
        System.assertEquals(1, cTCs.size());

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            cTCs[0].COI_3rdParty__c = tAs[1].Id;
            update cTCs;
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }
}