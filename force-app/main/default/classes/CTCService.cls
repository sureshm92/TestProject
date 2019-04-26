public with sharing class CTCService {

    public void deleteTAAs(List<CTC__c> oldList) {

        List<Id> cOIsIds = new List<Id>();
        List<Id> thirdPartyCOIsIds = new List<Id>();
        TherapeuticAreaAssignmentService tAAService = (TherapeuticAreaAssignmentService) ClassFactory.newInstance(TherapeuticAreaAssignmentService.class);

        for (CTC__c singleCTC : (List<CTC__c>) oldList) {
            cOIsIds.add(singleCTC.COI__c);
            thirdPartyCOIsIds.add(singleCTC.COI_3rdParty__c);
        }

        List<Therapeutic_Area_Assignment__c> assignments = [
                SELECT Id,
                        Therapeutic_Area__c,
                        Third_Party_COI__c,
                        Resource__c
                FROM Therapeutic_Area_Assignment__c
                WHERE Therapeutic_Area__c IN :cOIsIds
                AND Third_Party_COI__c IN :thirdPartyCOIsIds
        ];

        Map<Id, Therapeutic_Area__c> thirdPartyCOIsByIds = new Map<Id, Therapeutic_Area__c>([
                SELECT Id, (SELECT Id FROM CTC_Third_Party_COIs__r)
                FROM Therapeutic_Area__c
                WHERE RecordType.DeveloperName = :TherapeuticAreaService.THIRD_PARTY_COI_RT_NAME
                AND Id IN :thirdPartyCOIsIds
        ]);

        List<Therapeutic_Area_Assignment__c> tAAsToDelete = new List<Therapeutic_Area_Assignment__c>();
        List<Therapeutic_Area_Assignment__c> tAAsToCreate = new List<Therapeutic_Area_Assignment__c>();
        Map<Id, Set<Id>> resourcesIdsListByThirdPartyCOIsIds = new Map<Id, Set<Id>>();

        for (Id singleThirdPartyCOIId : thirdPartyCOIsByIds.keySet()) {
            if (thirdPartyCOIsByIds.get(singleThirdPartyCOIId).CTC_Third_Party_COIs__r.isEmpty()) {
                resourcesIdsListByThirdPartyCOIsIds.put(singleThirdPartyCOIId, new Set<Id>());
            }
        }
        for (Therapeutic_Area_Assignment__c singleTAA : assignments) {
            if (resourcesIdsListByThirdPartyCOIsIds.get(singleTAA.Third_Party_COI__c) != null) {
                resourcesIdsListByThirdPartyCOIsIds.get(singleTAA.Third_Party_COI__c).add(singleTAA.Resource__c);
            }
            for (CTC__c singleCTC : (List<CTC__c>) oldList) {
                if (singleTAA.Therapeutic_Area__c == singleCTC.COI__c &&
                        singleTAA.Third_Party_COI__c == singleCTC.COI_3rdParty__c) {
                    tAAsToDelete.add(singleTAA);
                }
            }
        }
        for (Id singleThirdPartyCOIId : resourcesIdsListByThirdPartyCOIsIds.keySet()) {
            for (Id resourceId : resourcesIdsListByThirdPartyCOIsIds.get(singleThirdPartyCOIId)) {
                Therapeutic_Area_Assignment__c tAAToCreate = tAAService.getTAAWithFilledFields(singleThirdPartyCOIId, resourceId, singleThirdPartyCOIId);
                tAAsToCreate.add(tAAToCreate);
            }
        }
        insert tAAsToCreate;
        delete tAAsToDelete;
    }

    public void createUpdateTAAs(List<CTC__c> newList) {

        TherapeuticAreaAssignmentService tAAService = (TherapeuticAreaAssignmentService) ClassFactory.newInstance(TherapeuticAreaAssignmentService.class);
        Map<Id, List<CTC__c>> cTCByThirdPartyCOIsIds = this.getCTCByThirdPartyCOIsIds(newList);

        List<Therapeutic_Area_Assignment__c> assignmentsToThirdPartyCOIs = [
                SELECT Id,
                        Therapeutic_Area__c,
                        Third_Party_COI__c
                FROM Therapeutic_Area_Assignment__c
                WHERE Therapeutic_Area__c IN :cTCByThirdPartyCOIsIds.keySet()
        ];

        List<Therapeutic_Area_Assignment__c> assignmentsToCOIs = [
                SELECT Id,
                        Resource__c,
                        Third_Party_COI__c
                FROM Therapeutic_Area_Assignment__c
                WHERE Third_Party_COI__c IN :cTCByThirdPartyCOIsIds.keySet()
        ];

        Map<Id, Set<Id>> resourcesIdsByThirdPartyCOIsIds = this.getResourcesIdsByThirdPartyCOIsIds(assignmentsToCOIs);
        Map<Id, List<Therapeutic_Area_Assignment__c>> tAAsByThirdPartyCOIsIds = this.getTAAsByThirdPartyCOIsIds(assignmentsToThirdPartyCOIs);
        List<Therapeutic_Area_Assignment__c> tAAsToUpdate = new List<Therapeutic_Area_Assignment__c>();
        List<Therapeutic_Area_Assignment__c> tAAsToCreate = new List<Therapeutic_Area_Assignment__c>();

        for (Id singleThirdPartyCOIId : cTCByThirdPartyCOIsIds.keySet()) {

            List<CTC__c> cTCs = cTCByThirdPartyCOIsIds.get(singleThirdPartyCOIId);
            Integer startIndex = 0;
            if (tAAsByThirdPartyCOIsIds.get(singleThirdPartyCOIId) != null) {
                for (Therapeutic_Area_Assignment__c singleTAA : tAAsByThirdPartyCOIsIds.get(singleThirdPartyCOIId)) {
                    singleTAA.Therapeutic_Area__c = cTCByThirdPartyCOIsIds.get(singleThirdPartyCOIId).get(0).COI__c;
                    tAAsToUpdate.add(singleTAA);
                    startIndex = 1;
                }
            }
            if (resourcesIdsByThirdPartyCOIsIds.get(singleThirdPartyCOIId) != null) {
                for (Integer i = 1; i < cTCs.size(); i++) {
                    for (Id resourceId : resourcesIdsByThirdPartyCOIsIds.get(singleThirdPartyCOIId)) {
                        tAAsToCreate.add(tAAService.getTAAWithFilledFields(cTCs.get(i).COI__c, resourceId, singleThirdPartyCOIId));
                    }
                }
            }
        }
        update tAAsToUpdate;
        insert tAAsToCreate;
    }

    private Map<Id, List<Therapeutic_Area_Assignment__c>> getTAAsByThirdPartyCOIsIds(List<Therapeutic_Area_Assignment__c> tAAs) {

        Map<Id, List<Therapeutic_Area_Assignment__c>> tAAsByThirdPartyCOIsIds = new Map<Id, List<Therapeutic_Area_Assignment__c>>();
        for (Therapeutic_Area_Assignment__c singleTAA : tAAs) {
            List<Therapeutic_Area_Assignment__c> tAAsList = tAAsByThirdPartyCOIsIds.get(singleTAA.Therapeutic_Area__c);
            if (tAAsList == null) {
                tAAsList = new List<Therapeutic_Area_Assignment__c>();
            }
            tAAsList.add(singleTAA);
            tAAsByThirdPartyCOIsIds.put(singleTAA.Therapeutic_Area__c, tAAsList);
        }
        return tAAsByThirdPartyCOIsIds;
    }

    private Map<Id, Set<Id>> getResourcesIdsByThirdPartyCOIsIds(List<Therapeutic_Area_Assignment__c> tAAs) {

        Map<Id, Set<Id>> resourcesIdsByThirdPartyCOIsIds = new Map<Id, Set<Id>>();
        for (Therapeutic_Area_Assignment__c singleTAA : tAAs) {
            Set<Id> resourceIds = resourcesIdsByThirdPartyCOIsIds.get(singleTAA.Third_Party_COI__c);
            if (resourceIds == null) {
                resourceIds = new Set<Id>();
            }
            resourceIds.add(singleTAA.Resource__c);
            resourcesIdsByThirdPartyCOIsIds.put(singleTAA.Third_Party_COI__c, resourceIds);
        }
        return resourcesIdsByThirdPartyCOIsIds;
    }

    private Map<Id, List<CTC__c>> getCTCByThirdPartyCOIsIds(List<CTC__c> cTCs) {

        Map<Id, List<CTC__c>> cTCByThirdPartyCOIsIds = new Map<Id, List<CTC__c>>();
        for (CTC__c singleCTC : cTCs) {
            List<CTC__c> cTCList = cTCByThirdPartyCOIsIds.get(singleCTC.COI_3rdParty__c);
            if (cTCList == null) {
                cTCList = new List<CTC__c>();
            }
            cTCList.add(singleCTC);
            cTCByThirdPartyCOIsIds.put(singleCTC.COI_3rdParty__c, cTCList);
        }
        return cTCByThirdPartyCOIsIds;
    }
}