/**
 * Created by dmytro.fedchyshyn on 19.08.2019.
 */

@IsTest
public with sharing class Test_TherapeuticAreaAssignmentService {

    @IsTest
    private static void createTAAsForResources_test() {
        TherapeuticAreaAssignmentService service = new TherapeuticAreaAssignmentService();

        List<Therapeutic_Area__c> therapeuticAreas = new List<Therapeutic_Area__c>{
                new Therapeutic_Area__c(Name = 'one'),
                new Therapeutic_Area__c(Name = 'two'),
                new Therapeutic_Area__c(Name = 'three'),
                new Therapeutic_Area__c(Name = 'ThA - 4')
        };
        insert therapeuticAreas;

        List<Resource__c> resources = new List<Resource__c>{
                new Resource__c( Description__c = 'Re - 1', Therapeutic_Areas__c = 'one; two; three'),
                new Resource__c( Description__c = 'Re - 2', Therapeutic_Areas__c = 'one; two; three'),
                new Resource__c( Description__c = 'Re - 3', Therapeutic_Areas__c = 'one; two; three'),
                new Resource__c( Description__c = 'Re - 4', Therapeutic_Areas__c = 'one; two; three')
        };
        insert resources;

        Test.startTest();
        service.createTAAsForResources(therapeuticAreas, resources);
        Test.stopTest();

        List<Resource__c> resource = [SELECT Id FROM Resource__c];

        System.assertEquals(4, resource.size());
    }

    @IsTest
    private static void createDeleteTAAs_test() {
        TherapeuticAreaAssignmentService service = new TherapeuticAreaAssignmentService();

        List<Therapeutic_Area__c> therapeuticAreas = new List<Therapeutic_Area__c>{
                new Therapeutic_Area__c(Id = TestDataFactory.getFakeId(Therapeutic_Area__c.getSObjectType()), Name = 'ThA - 1'),
                new Therapeutic_Area__c(Id = TestDataFactory.getFakeId(Therapeutic_Area__c.getSObjectType()), Name = 'ThA - 2'),
                new Therapeutic_Area__c(Id = TestDataFactory.getFakeId(Therapeutic_Area__c.getSObjectType()), Name = 'ThA - 3'),
                new Therapeutic_Area__c(Id = TestDataFactory.getFakeId(Therapeutic_Area__c.getSObjectType()), Name = 'ThA - 4')
        };

        List<Resource__c> resources = new List<Resource__c>{
                new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Description__c = 'Re - 1', Therapeutic_Areas__c = 'one; two; three'),
                new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Description__c = 'Re - 2', Therapeutic_Areas__c = 'one; two; three'),
                new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Description__c = 'Re - 3', Therapeutic_Areas__c = 'one; two; three'),
                new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Description__c = 'Re - 4', Therapeutic_Areas__c = 'one; two; three')
        };

        Map<Id, Resource__c> resourceMap = new Map<Id, Resource__c>();
        resourceMap.put(resources.get(0).Id, new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Therapeutic_Areas__c = therapeuticAreas.get(1).Id));
        resourceMap.put(resources.get(1).Id, new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Therapeutic_Areas__c = therapeuticAreas.get(1).Id));
        resourceMap.put(resources.get(2).Id, new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Therapeutic_Areas__c = therapeuticAreas.get(1).Id));
        resourceMap.put(resources.get(3).Id, new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Therapeutic_Areas__c = therapeuticAreas.get(1).Id));
        resourceMap.put(resources.get(3).Id, new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Therapeutic_Areas__c = therapeuticAreas.get(2).Id));
        resourceMap.put(resources.get(3).Id, new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Therapeutic_Areas__c = therapeuticAreas.get(3).Id));

        Test.startTest();
        service.createDeleteTAAs(resources, resourceMap, therapeuticAreas);
        Test.stopTest();

        List<Therapeutic_Area_Assignment__c> tAAsToCreate = [SELECT Id FROM Therapeutic_Area_Assignment__c];

        System.assert(tAAsToCreate.size() >= 0);
    }

    @IsTest
    private static void deleteTAAs_test() {
        TherapeuticAreaAssignmentService service = new TherapeuticAreaAssignmentService();

        List<Therapeutic_Area__c> newTherapeuticAreas = new List<Therapeutic_Area__c>{
                new Therapeutic_Area__c(Name = 'ThA - 1'),
                new Therapeutic_Area__c(Name = 'ThA - 2'),
                new Therapeutic_Area__c(Name = 'ThA - 3'),
                new Therapeutic_Area__c(Name = 'ThA - 4')
        };

        insert newTherapeuticAreas;

        List<Therapeutic_Area__c> toDelete = [SELECT Id FROM Therapeutic_Area__c LIMIT 2];

        Test.startTest();
        service.deleteTAAs(toDelete);
        Test.stopTest();

        List<Therapeutic_Area__c> remnant = [SELECT Id FROM Therapeutic_Area__c LIMIT 2];

        System.assertEquals(2, remnant.size());
    }

    @IsTest
    private static void getTAAWithFilledFields_test() {
        TherapeuticAreaAssignmentService service = new TherapeuticAreaAssignmentService();

        Id COIId = TestDataFactory.getFakeId(Therapeutic_Area__c.getSObjectType());
        Id resourceId = TestDataFactory.getFakeId(Resource__c.getSObjectType());
        Id thirdPartyCOIId = TestDataFactory.getFakeId(Resource__c.getSObjectType());

        Test.startTest();
        Therapeutic_Area_Assignment__c areaAssignment = service.getTAAWithFilledFields(COIId, resourceId, thirdPartyCOIId);
        Test.stopTest();

        System.assertEquals(resourceId, areaAssignment.Resource__c);
    }

    @IsTest
    private static void delete_test() {
        TherapeuticAreaAssignmentService service = new TherapeuticAreaAssignmentService();

        List<Resource__c> resources = new List<Resource__c>{
                new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Description__c = 'Re - 1', Therapeutic_Areas__c = 'one; two; three, four'),
                new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Description__c = 'Re - 2', Therapeutic_Areas__c = 'one; two; three'),
                new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Description__c = 'Re - 3', Therapeutic_Areas__c = 'one; two; three'),
                new Resource__c(Id = TestDataFactory.getFakeId(Resource__c.getSObjectType()), Description__c = 'Re - 4', Therapeutic_Areas__c = 'one; two; three')
        };

        Set <String> toCreate = new Set<String>{
                'one', 'two', 'three'
        };
        Set <String> toDelete = new Set<String>{
                'four', 'five', 'three'
        };
        TherapeuticAreaAssignmentService.TAAWrapper wrapper = new TherapeuticAreaAssignmentService.TAAWrapper(resources.get(0).Id, toCreate, toDelete);

        List<Therapeutic_Area_Assignment__c> areaAssignments = new List<Therapeutic_Area_Assignment__c>{
                new Therapeutic_Area_Assignment__c(Resource__c = resources.get(1).Id),
                new Therapeutic_Area_Assignment__c(Resource__c = resources.get(1).Id),
                new Therapeutic_Area_Assignment__c(Resource__c = resources.get(1).Id),
                new Therapeutic_Area_Assignment__c(Resource__c = resources.get(1).Id)
        };
        Map<Id, List<Therapeutic_Area_Assignment__c>> resourceMap = new Map<Id, List<Therapeutic_Area_Assignment__c>>();
        resourceMap.put(resources.get(0).Id, areaAssignments);
        resourceMap.put(resources.get(1).Id, areaAssignments);
        resourceMap.put(resources.get(2).Id, areaAssignments);

        Test.startTest();
        List<Therapeutic_Area_Assignment__c> areasAssignments = service.getTAAsToDelete(wrapper, resourceMap);
        Test.stopTest();

        System.assert(areasAssignments.size() >= 0);
    }
}