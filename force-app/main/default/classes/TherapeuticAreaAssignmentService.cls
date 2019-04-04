/*
Created by Dmytro Pokutnii
*/
public with sharing class TherapeuticAreaAssignmentService {

    public void createTherapeuticAreaAssignments(List<Therapeutic_Area__c> therapeuticAreas, List<Resource__c> resources) {

        TherapeuticAreaService tAService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
        Map<String, Therapeutic_Area__c> tAsByNames = tAService.getTherapeuticAreasByNames(therapeuticAreas);
        List<Therapeutic_Area_Assignment__c> tAAsToCreate = new List<Therapeutic_Area_Assignment__c>();
        for (Resource__c singleResource : resources) {
            tAAsToCreate.addAll(this.createTherapeuticAreaAssignments(tAsByNames, singleResource));
        }
        insert tAAsToCreate;
    }

    public void processAssignments(List<Resource__c> newResource, Map<Id, Resource__c> oldResourcesByIds, List<Therapeutic_Area__c> therapeuticAreas) {

        TherapeuticAreaService tAService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
        Map<String, Therapeutic_Area__c> tAsByNames = tAService.getTherapeuticAreasByNames(therapeuticAreas);
        List<TAAWrapper> wrappers = new List<TAAWrapper>();
        for (Resource__c singleResource : newResource) {
            wrappers.add(this.getTAAWrapper(singleResource, oldResourcesByIds.get(singleResource.Id)));
        }
        this.createTAAs(wrappers, tAsByNames);
        this.deleteTAAs(wrappers);
    }

    private void deleteTAAs(List<TAAWrapper> wrappers) {

        List<Therapeutic_Area_Assignment__c> tAAs = this.getTAAs(wrappers);
        Map<Id, List<Therapeutic_Area_Assignment__c>> tAAsByResourceId = this.getTAAsByResourceId(tAAs);
        List<Therapeutic_Area_Assignment__c> tAAsToDelete = new List<Therapeutic_Area_Assignment__c>();
        for (TAAWrapper singleWrapper : wrappers) {
            tAAsToDelete.addAll(this.getTAAsToDelete(singleWrapper, tAAsByResourceId));
        }
        delete tAAsToDelete;
    }

    private void createTAAs(List<TAAWrapper> wrappers, Map<String, Therapeutic_Area__c> tAsByNames) {

        List<Therapeutic_Area_Assignment__c> tAAsToCreate = new List<Therapeutic_Area_Assignment__c>();
        for (TAAWrapper singleWrapper : wrappers) {
            for (String tAName : singleWrapper.tANamesToCreate) {
                tAAsToCreate.add(new Therapeutic_Area_Assignment__c(
                        Resource__c = singleWrapper.resourceId,
                        Therapeutic_Area__c = tAsByNames.get(tAName).Id)
                );
            }
        }
        insert tAAsToCreate;
    }

    private List<Therapeutic_Area_Assignment__c> getTAAsToDelete(TAAWrapper wrapper, Map<Id, List<Therapeutic_Area_Assignment__c>> tAAsByResourceId) {

        List<Therapeutic_Area_Assignment__c> tAAsToDelete = new List<Therapeutic_Area_Assignment__c>();
        if (tAAsByResourceId.get(wrapper.resourceId) == null || tAAsByResourceId.get(wrapper.resourceId).isEmpty()) {
            return tAAsToDelete;
        }
        for (Therapeutic_Area_Assignment__c singleTAA : tAAsByResourceId.get(wrapper.resourceId)) {
            if (wrapper.tANamesToDelete.contains(singleTAA.Therapeutic_Area__r.Name)) {
                tAAsToDelete.add(singleTAA);
            }
        }
        return tAAsToDelete;
    }

    private List<Therapeutic_Area_Assignment__c> getTAAs(List<TAAWrapper> wrappers) {

        Set<String> tANamesToDelete = new Set<String>();
        Set<Id> resourceIds = new Set<Id>();
        for (TAAWrapper singleWrapper : wrappers) {
            tANamesToDelete.addAll(singleWrapper.tANamesToDelete);
            resourceIds.add(singleWrapper.resourceId);
        }
        List<Therapeutic_Area_Assignment__c> tAAs = [
                SELECT Id,
                        Resource__c,
                        Therapeutic_Area__c,
                        Therapeutic_Area__r.Name
                FROM Therapeutic_Area_Assignment__c
                WHERE Resource__c IN :resourceIds AND
                Therapeutic_Area__r.Name IN :tANamesToDelete
        ];
        return tAAs;
    }

    private Map<Id, List<Therapeutic_Area_Assignment__c>> getTAAsByResourceId(List<Therapeutic_Area_Assignment__c> tAAs) {

        Map<Id, List<Therapeutic_Area_Assignment__c>> tAAsByResourceId = new Map<Id, List<Therapeutic_Area_Assignment__c>>();
        for (Therapeutic_Area_Assignment__c singleTAA : tAAs) {
            List<Therapeutic_Area_Assignment__c> resourceTAAs = new List<Therapeutic_Area_Assignment__c>();
            if (tAAsByResourceId.get(singleTAA.Resource__c) != null) {
                resourceTAAs = tAAsByResourceId.get(singleTAA.Resource__c);
            }
            resourceTAAs.add(singleTAA);
            tAAsByResourceId.put(singleTAA.Resource__c, resourceTAAs);
        }
        return tAAsByResourceId;
    }

    private TAAWrapper getTAAWrapper(Resource__c newResource, Resource__c oldResource) {

        TherapeuticAreaService tAService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
        Set<String> newTANames = tAService.getTANamesOnResource(newResource);
        Set<String> oldTANames = tAService.getTANamesOnResource(oldResource);
        Set<String> tANamesToDelete = (Set<String>) this.getStringSetDifference(oldTANames, newTANames);
        Set<String> tANamesToCreate = (Set<String>) this.getStringSetDifference(newTANames, oldTANames);
        return new TAAWrapper(newResource.Id, tANamesToCreate, tANamesToDelete);
    }

    private Set<String> getStringSetDifference(Set<String> sourceSet, Set<String> objectsToCompare) {
        Set<String> result = new Set<String>();
        result.addAll(sourceSet);
        result.removeAll(objectsToCompare);
        return result;
    }

    private List<Therapeutic_Area_Assignment__c> createTherapeuticAreaAssignments(Map<String, Therapeutic_Area__c> tAsByNames, Resource__c resource) {
        TherapeuticAreaService tAService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
        List<Therapeutic_Area_Assignment__c> tAAs = new List<Therapeutic_Area_Assignment__c>();
        Set<String> tANames = tAService.getTANamesOnResource(resource);
        for (String singleTAName : tANames) {
            tAAs.add(new Therapeutic_Area_Assignment__c(Therapeutic_Area__c = tAsByNames.get(singleTAName).Id, Resource__c = resource.Id));
        }
        return tAAs;
    }

    public class TAAWrapper {

        public Id resourceId;
        public Set<String> tANamesToCreate;
        public Set<String> tANamesToDelete;

        public TAAWrapper(Id resourceId, Set<String> tANamesToCreate, Set<String> tANamesToDelete) {
            this.resourceId = resourceId;
            this.tANamesToCreate = tANamesToCreate;
            this.tANamesToDelete = tANamesToDelete;
        }
    }
}