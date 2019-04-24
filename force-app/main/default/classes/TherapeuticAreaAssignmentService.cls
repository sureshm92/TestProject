/**
 * Created by Dmytro Pokutnii
 */
public with sharing class TherapeuticAreaAssignmentService {

    public void createTAAsForResources(List<Therapeutic_Area__c> therapeuticAreas, List<Resource__c> resources) {

        TherapeuticAreaService tAService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
        Map<String, Therapeutic_Area__c> tAsByNames = tAService.getTAsByNamesMap(therapeuticAreas);
        List<Therapeutic_Area_Assignment__c> tAAsToCreate = new List<Therapeutic_Area_Assignment__c>();
        for (Resource__c singleResource : resources) {
            tAAsToCreate.addAll(this.createTAAsForResource(tAsByNames, singleResource));
        }
        insert tAAsToCreate;
    }

    public void createDeleteTAAs(List<Resource__c> newResource, Map<Id, Resource__c> oldResourcesByIds, List<Therapeutic_Area__c> therapeuticAreas) {

        TherapeuticAreaService tAService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
        Map<String, Therapeutic_Area__c> tAsByNames = tAService.getTAsByNamesMap(therapeuticAreas);
        List<TAAWrapper> wrappers = new List<TAAWrapper>();
        for (Resource__c singleResource : newResource) {
            wrappers.add(this.getTAAWrapper(singleResource, oldResourcesByIds.get(singleResource.Id)));
        }
        this.createTAAsByWrappers(wrappers, tAsByNames);
        this.deleteTAAsByWrappers(wrappers);
    }

    public void deleteTAAs(List<Therapeutic_Area__c> oldList) {

        Map<Id, Therapeutic_Area__c> tAsByIds = new Map<Id, Therapeutic_Area__c>(oldList);
        List<Therapeutic_Area_Assignment__c> assignmentsToDelete = [
                SELECT Id
                FROM Therapeutic_Area_Assignment__c
                WHERE Therapeutic_Area__c IN :tAsByIds.keySet() OR Third_Party_COI__c IN :tAsByIds.keySet()
        ];
        delete assignmentsToDelete;
    }

    public void reparentTAAs(List<Therapeutic_Area__c> newList, Map<Id, Therapeutic_Area__c> oldMap) {

        List<Therapeutic_Area__c> tAsToReparentThirdPartyCOIToCOI = new List<Therapeutic_Area__c>();
        List<Therapeutic_Area__c> tAsToReparentCOIToCOI = new List<Therapeutic_Area__c>();
        List<Therapeutic_Area__c> tAsToReparentCOIToThirdPartyCOI = new List<Therapeutic_Area__c>();
        List<Therapeutic_Area_Assignment__c> assignmentsToUpdate = new List<Therapeutic_Area_Assignment__c>();

        for (Therapeutic_Area__c singleTA : newList) {
            if (singleTA.RecordTypeId == SchemaUtil.getRecordTypeIdByName(TherapeuticAreaService.THIRD_PARTY_COI_RT_NAME, Therapeutic_Area__c.getSObjectType()) &&
                    singleTA.Therapeutic_Area__c != oldMap.get(singleTA.Id).Therapeutic_Area__c) {
                if (String.isBlank(singleTA.Therapeutic_Area__c)) {
                    tAsToReparentCOIToThirdPartyCOI.add(singleTA);
                } else if (String.isBlank(oldMap.get(singleTA.Id).Therapeutic_Area__c)) {
                    tAsToReparentThirdPartyCOIToCOI.add(singleTA);
                } else {
                    tAsToReparentCOIToCOI.add(singleTA);
                }
            }
        }
        assignmentsToUpdate.addAll(new TAAsMapperThirdPartyCOIToCOI(tAsToReparentThirdPartyCOIToCOI).run().getResultList());
        assignmentsToUpdate.addAll(new TAAsMapperCOIToThirdPartyCOI(tAsToReparentCOIToThirdPartyCOI).run().getResultList());
        assignmentsToUpdate.addAll(new TAAsMapperCOIToCOI(tAsToReparentCOIToCOI).run().getResultList());
        update assignmentsToUpdate;
    }

    private void deleteTAAsByWrappers(List<TAAWrapper> wrappers) {

        List<Therapeutic_Area_Assignment__c> tAAs = this.getTAAsByTAAWrappers(wrappers);
        if(tAAs == null || tAAs.isEmpty()) {
            return;
        }
        Map<Id, List<Therapeutic_Area_Assignment__c>> tAAsByResourceId = this.getTAAsByResourceIdMap(tAAs);
        List<Therapeutic_Area_Assignment__c> tAAsToDelete = new List<Therapeutic_Area_Assignment__c>();
        for (TAAWrapper singleWrapper : wrappers) {
            tAAsToDelete.addAll(this.getTAAsToDelete(singleWrapper, tAAsByResourceId));
        }
        delete tAAsToDelete;
    }

    private void createTAAsByWrappers(List<TAAWrapper> wrappers, Map<String, Therapeutic_Area__c> tAsByNames) {

        List<Therapeutic_Area_Assignment__c> tAAsToCreate = new List<Therapeutic_Area_Assignment__c>();
        for (TAAWrapper singleWrapper : wrappers) {
            if(singleWrapper.tANamesToCreate != null && !singleWrapper.tANamesToCreate.isEmpty()) {
                tAAsToCreate.addAll(this.createTAAsForResource(singleWrapper.tANamesToCreate, tAsByNames, singleWrapper.resourceId));
            }
        }
        insert tAAsToCreate;
    }

    private List<Therapeutic_Area_Assignment__c> getTAAsToDelete(TAAWrapper wrapper, Map<Id, List<Therapeutic_Area_Assignment__c>> tAAsByResourceId) {

        List<Therapeutic_Area_Assignment__c> tAAsToDelete = new List<Therapeutic_Area_Assignment__c>();
        if (tAAsByResourceId.get(wrapper.resourceId) != null && !tAAsByResourceId.get(wrapper.resourceId).isEmpty()) {
            for (Therapeutic_Area_Assignment__c singleTAA : tAAsByResourceId.get(wrapper.resourceId)) {
                if (wrapper.tANamesToDelete.contains(singleTAA.Therapeutic_Area__r.Name) || wrapper.tANamesToDelete.contains(singleTAA.Third_Party_COI__r.Name)) {
                    tAAsToDelete.add(singleTAA);
                }
            }
        }
        return tAAsToDelete;
    }

    private List<Therapeutic_Area_Assignment__c> getTAAsByTAAWrappers(List<TAAWrapper> wrappers) {

        Set<String> tANamesToDelete = new Set<String>();
        Set<Id> resourceIds = new Set<Id>();
        for (TAAWrapper singleWrapper : wrappers) {
            if(singleWrapper.tANamesToDelete != null) {
                tANamesToDelete.addAll(singleWrapper.tANamesToDelete);
                resourceIds.add(singleWrapper.resourceId);
            }
        }
        if(tANamesToDelete.isEmpty()) {
            return new List<Therapeutic_Area_Assignment__c>();
        }
        TherapeuticAreaService tAService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
        Map<Id, Therapeutic_Area__c> tAsByIds = new Map<Id, Therapeutic_Area__c>(tAService.getThirdPartyCOIsByNames(tANamesToDelete, false));
        List<Therapeutic_Area_Assignment__c> tAAs = [
                SELECT Id,
                        Resource__c,
                        Therapeutic_Area__r.Name,
                        Third_Party_COI__r.Name
                FROM Therapeutic_Area_Assignment__c
                WHERE Resource__c IN :resourceIds AND (Therapeutic_Area__c IN :tAsByIds.keySet() OR Third_Party_COI__c IN :tAsByIds.keySet())
        ];
        return tAAs;
    }

    private Map<Id, List<Therapeutic_Area_Assignment__c>> getTAAsByResourceIdMap(List<Therapeutic_Area_Assignment__c> tAAs) {

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

    private List<Therapeutic_Area_Assignment__c> createTAAsForResource(Map<String, Therapeutic_Area__c> tAsByNames, Resource__c resource) {

        TherapeuticAreaService tAService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
        Set<String> tANames = tAService.getTANamesOnResource(resource);
        return this.createTAAsForResource(tANames, tAsByNames, resource.Id);
    }

    private List<Therapeutic_Area_Assignment__c> createTAAsForResource(Set<String> tAsNames, Map<String, Therapeutic_Area__c> tAsByNames, String resourceId) {

        List<Therapeutic_Area_Assignment__c> tAAs = new List<Therapeutic_Area_Assignment__c>();
        for (String singleTAName : tAsNames) {
            if (tAsByNames.get(singleTAName) != null) {
                if (tAsByNames.get(singleTAName).Therapeutic_Area__c != null) {
                    tAAs.add(new Therapeutic_Area_Assignment__c(
                            Therapeutic_Area__c = tAsByNames.get(singleTAName).Therapeutic_Area__c,
                            Resource__c = resourceId,
                            Third_Party_COI__c = tAsByNames.get(singleTAName).Id
                    ));
                } else {
                    tAAs.add(new Therapeutic_Area_Assignment__c(Therapeutic_Area__c = tAsByNames.get(singleTAName).Id, Resource__c = resourceId));
                }
            }
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

    public virtual class TAAsMapper {

        private List<Therapeutic_Area__c> tAs;
        private List<Therapeutic_Area_Assignment__c> assignmentsToUpdate;
        protected String fieldToFilter = Therapeutic_Area_Assignment__c.Third_Party_COI__c.getDescribe().getName();

        public TAAsMapper(List<Therapeutic_Area__c> therapeuticAreas) {
            this.tAs = therapeuticAreas;
            this.assignmentsToUpdate = new List<Therapeutic_Area_Assignment__c>();
        }

        public TAAsMapper run() {

            if (!this.tAs.isEmpty()) {
                Map<Id, Therapeutic_Area__c> tAsByIds = new Map<Id, Therapeutic_Area__c>(this.tAs);
                DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
                String tAAsQuery = 'SELECT Id, ' +
                        'Third_Party_COI__c, ' +
                        'Therapeutic_Area__r.Therapeutic_Area__c ' +
                        'FROM Therapeutic_Area_Assignment__c ' +
                        'WHERE ' + this.fieldToFilter + ' IN (' + String.join(CollectionUtil.getListOfIdsWrappedInApostrophes(tAsByIds.keySet()), ', ') + ') ';
                List<Therapeutic_Area_Assignment__c> assignments = (List<Therapeutic_Area_Assignment__c>) databaseProxy.query(tAAsQuery);
                for (Therapeutic_Area_Assignment__c singleTAA : assignments) {
                    this.assignmentsToUpdate.add(this.getUpdatedTAA(singleTAA, tAsByIds));
                }
            }
            return this;
        }

        public List<Therapeutic_Area_Assignment__c> getResultList() {
            return assignmentsToUpdate;
        }

        protected virtual Therapeutic_Area_Assignment__c getUpdatedTAA(Therapeutic_Area_Assignment__c assignment, Map<Id, Therapeutic_Area__c> tAsByIds) {
            return null;
        }
    }

    public class TAAsMapperCOIToCOI extends TAAsMapper {

        public TAAsMapperCOIToCOI(List<Therapeutic_Area__c> therapeuticAreas) {
            super(therapeuticAreas);
        }

        protected override Therapeutic_Area_Assignment__c getUpdatedTAA(Therapeutic_Area_Assignment__c assignment, Map<Id, Therapeutic_Area__c> tAsByIds) {
            assignment.Therapeutic_Area__c = tAsByIds.get(assignment.Third_Party_COI__c).Therapeutic_Area__c;
            return assignment;
        }
    }

    public class TAAsMapperThirdPartyCOIToCOI extends TAAsMapper {

        public TAAsMapperThirdPartyCOIToCOI(List<Therapeutic_Area__c> therapeuticAreas) {
            super(therapeuticAreas);
            this.fieldToFilter = Therapeutic_Area_Assignment__c.Therapeutic_Area__c.getDescribe().getName();
        }

        protected override Therapeutic_Area_Assignment__c getUpdatedTAA(Therapeutic_Area_Assignment__c assignment, Map<Id, Therapeutic_Area__c> tAsByIds) {
            assignment.Third_Party_COI__c = assignment.Therapeutic_Area__c;
            assignment.Therapeutic_Area__c = assignment.Therapeutic_Area__r.Therapeutic_Area__c;
            return assignment;
        }
    }

    public class TAAsMapperCOIToThirdPartyCOI extends TAAsMapper {

        public TAAsMapperCOIToThirdPartyCOI(List<Therapeutic_Area__c> therapeuticAreas) {
            super(therapeuticAreas);
        }

        protected override Therapeutic_Area_Assignment__c getUpdatedTAA(Therapeutic_Area_Assignment__c assignment, Map<Id, Therapeutic_Area__c> tAsByIds) {
            assignment.Therapeutic_Area__c = assignment.Third_Party_COI__c;
            assignment.Third_Party_COI__c = null;
            return assignment;
        }
    }
}