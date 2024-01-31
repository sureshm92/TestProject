/**
 * Created by Igor Malyuta on 07.03.2019.
 */

public without sharing class ManualTaskFilter {
    private static final String PE_QUERY =
        'SELECT Id,Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c,Clinical_Trial_Profile__r.PPTemplate__c , Participant__c, ' +
        'Participant__r.Contact__c, Participant__r.Mailing_Country_Code__c ' +
        'FROM Participant_Enrollment__c WHERE Participant__r.Contact__c != NULL AND ';

    private static final String PARTICIPANT_QUERY =
        'SELECT Id, Contact__c ' + 'FROM Participant__c WHERE Contact__c != NULL ';

    private static final String THERAPEUTIC_QUERY = 'SELECT Participant__r.Contact__c,Participant__c FROM Therapeutic_Area_Patient__c WHERE ';

    private static final String PEPLATFORM_QUERY = 'SELECT Participant_Contact__c, Participant__c FROM Participant_Enrollment__c WHERE Participant__r.Contact__c != NULL ';

    public static final String SEPARATOR = '\',\'';
    public static Map<id, String> IdTypeOfContactMap = new Map<id, String>();
    public static Map<Id, Id> participantwithContact = new Map<Id, Id>();
    @AuraEnabled
    public List<String> statuses = new List<String>();
    @AuraEnabled
    public List<LookupSearchResult> areas = new List<LookupSearchResult>();
    @AuraEnabled
    public List<LookupSearchResult> sponsors = new List<LookupSearchResult>();
    @AuraEnabled
    public List<LookupSearchResult> studies = new List<LookupSearchResult>();
    @AuraEnabled
    public List<LookupSearchResult> countries = new List<LookupSearchResult>();
    @AuraEnabled
    public List<LookupSearchResult> sites = new List<LookupSearchResult>();
    @AuraEnabled
    public Boolean isPlatformLevel = false;
    @AuraEnabled
    public Map<Id, List<Id>> parPdeListofPeMap = new Map<Id, List<Id>>();

    public static Set<id> peSet = new Set<id>();

    public Map<Id, List<Participant_Enrollment__c>> getContactsWithPE() {
        List<String> searchStatuses = new List<String>();
        if (statuses.contains('Referred'))
            searchStatuses.addAll(PEStatusState.PE_STATUS_GROUP_IN_PROGRESS);
        if (statuses.contains('Enrolled'))
            searchStatuses.addAll(PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS);
        if (statuses.contains('Alumni'))
            searchStatuses.addAll(PEStatusState.PE_STATUS_GROUP_ALUMNI);

       String peQuery =
            PE_QUERY +
            (isPlatformLevel
                ? ''
                : ' Clinical_Trial_Profile__r.Tasks_Are_Available__c = TRUE AND ') +
            DatabaseService.fieldInValues('Participant_Status__c', searchStatuses) +
            getFiltersQuery();
        List<Participant_Enrollment__c> enrollments = (List<Participant_Enrollment__c>) Database.query(
            peQuery
        );
        List<String> countryCodes;
        if (!countries.isEmpty())
            countryCodes = getCountryCode();

        Map<Id, List<Participant_Enrollment__c>> peByContactIds = new Map<Id, List<Participant_Enrollment__c>>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (
                countryCodes != null &&
                !countryCodes.contains(pe.Participant__r.Mailing_Country_Code__c)
            ) {
                continue;
            }
            peSet.add(pe.Id);
            participantwithContact.put(pe.Participant__c, pe.Participant__r.Contact__c);
            if (!peByContactIds.containsKey(pe.Participant__r.Contact__c)) {
                peByContactIds.put(
                    pe.Participant__r.Contact__c,
                    new List<Participant_Enrollment__c>()
                );
            }
            peByContactIds.get(pe.Participant__r.Contact__c).add(pe);
        }

        return peByContactIds;
    }

    public Map<Id, List<Id>> getContactsWithWhatIds(TaskService.TaskConfig taskConfig) {
        string visibility = taskConfig.visibility;
        // Platform-level tasks
        /* Study-level tasks, added for delegate PEH-4365*/

        Map<Id, List<Participant_Enrollment__c>> sObjectsByContact = new Map<Id, List<SObject>>();
        List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();
        Map<Id, List<Id>> studyDelegateOwnerMap = new Map<Id, List<Id>>();
        Map<Id, List<Id>> pdeListofPeMap = new Map<Id, List<Id>>();
        sObjectsByContact = getContactsWithPE(); // cont id and list of PE map
        Map<Id, List<Id>> peIdsByContact = new Map<Id, List<Id>>();
        if (!peSet.isEmpty()) {
            pdeList = [
                SELECT
                    id,
                    Status__c,
                    Patient_Delegate__c,
                    Participant_Enrollment__c,
                    Participant_Enrollment__r.Participant_Contact__c,
                    Patient_Delegate__r.Contact__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Participant_Enrollment__c IN :peSet 
                AND Status__c = 'Active'
            ];
        }

        for (Id id : sObjectsByContact.keySet()) {
            Map<Id, Participant_Enrollment__c> peMap = new Map<Id, Participant_Enrollment__c>(
                sObjectsByContact.get(id)
            );
            if (!peMap.isEmpty()) {
                peIdsByContact.put(id, new List<Id>(peMap.keySet()));
                IdTypeOfContactMap.put(peMap.Values()[0].Participant_Contact__c, 'Participant');
            }
        }
        for (Patient_Delegate_Enrollment__c pde : pdeList) {
            if (!pdeListofPeMap.containsKey(pde.Patient_Delegate__r.Contact__c))
                pdeListofPeMap.put(pde.Patient_Delegate__r.Contact__c, new List<Id>());
            pdeListofPeMap.get(pde.Patient_Delegate__r.Contact__c)
                .add(pde.Participant_Enrollment__c);
            if (!parPdeListofPeMap.containsKey(pde.Participant_Enrollment__r.Participant_Contact__c))
                parPdeListofPeMap.put(pde.Participant_Enrollment__r.Participant_Contact__c, new List<Id>());
            parPdeListofPeMap.get(pde.Participant_Enrollment__r.Participant_Contact__c)
                .add(pde.Participant_Enrollment__c);
            
            if (
                // checks if contact type is delegate or delegate&participant
                IdTypeOfContactMap.containsKey(pde.Patient_Delegate__r.Contact__c) &&
                IdTypeOfContactMap.get(pde.Patient_Delegate__r.Contact__c) == 'Participant'
            ) {
                if(visibility == 'Delegates'){
                    IdTypeOfContactMap.put(pde.Patient_Delegate__r.Contact__c, 'Delegate'); //KK //Participant;Delegate
                }
                else{
                    String TypeOfContact = IdTypeOfContactMap.get(pde.Patient_Delegate__r.Contact__c) + ';Delegate';
                    IdTypeOfContactMap.put(pde.Patient_Delegate__r.Contact__c, TypeOfContact); //KK //Participant;Delegate
                }
            } else {
                IdTypeOfContactMap.put(pde.Patient_Delegate__r.Contact__c, 'Delegate'); //KK
            }
        }
        if (peIdsByContact != null || pdeListofPeMap != null) {
            Set<Id> commonKey = new Set<Id>(pdeListofPeMap.keySet());
            commonKey.retainAll(peIdsByContact.keySet());
            if(commonKey.size() > 0 && !commonKey.isEmpty()){ // For mutirole merge the values and active ones to be in list first
                Set<Id> parDelConkeys = new Set<Id>();
                parDelConkeys.addAll(pdeListofPeMap.keySet());
                parDelConkeys.addAll(peIdsByContact.keySet());
                
                for (Id key : parDelConkeys) {
                    List<Id> perConStudyLst = (List<Id>) peIdsByContact.get(key);
                    List<Id> pdeConStudyLst = (List<Id>) pdeListofPeMap.get(key);
                    if(parPdeListofPeMap.containskey(key)){ // To make delegate active studies in the list first
                        Set<Id> parWithDelAssStudSet = new Set<Id>();
                        List<Id> parWithDelAssStudies = (List<Id>) parPdeListofPeMap.get(key);
                        parWithDelAssStudSet.addAll(parWithDelAssStudies);
                        parWithDelAssStudSet.addAll(perConStudyLst);
                        perConStudyLst.clear();
                        perConStudyLst.addAll(parWithDelAssStudSet);
                    }
                    List<Id> multiRoleConValueMerge = new List<Id>(); // Merging the list for Multirole because of Putall behaviour
                    if (perConStudyLst != null) multiRoleConValueMerge.addAll(perConStudyLst);
                    if (pdeConStudyLst != null) multiRoleConValueMerge.addAll(pdeConStudyLst);
                    
                    studyDelegateOwnerMap.put(key, multiRoleConValueMerge);
                } 
            }
            else{
                studyDelegateOwnerMap.putAll(pdeListofPeMap);
                studyDelegateOwnerMap.putAll(peIdsByContact);
            }
        }
        if (visibility == 'Owner') {
            return peIdsByContact;
        } else if (visibility == 'Owner;Delegates') {
            return studyDelegateOwnerMap;
        }
        else if (visibility == 'Delegates') {
            return pdeListofPeMap;
        }
         else {
            return null;
        }
    }

    @TestVisible
    private String filterTherapeutic() {
        List<Therapeutic_Area_Patient__c> participantInArea = (List<Therapeutic_Area_Patient__c>) Database.query(
            THERAPEUTIC_QUERY + fieldJoin('Therapeutic_Area__c', areas)
        );

        List<String> participantIds = new List<String>();
        for (Therapeutic_Area_Patient__c areaPatient : participantInArea)
            participantIds.add(areaPatient.Participant__c);

        return DatabaseService.fieldInValues('Participant__c', participantIds);
    }

    @TestVisible
    private String getFiltersQuery() {
        List<String> filters = new List<String>();
        if (!areas.isEmpty())
            filters.add(filterTherapeutic());
        if (!sponsors.isEmpty())
            filters.add(fieldJoin('Study_Site__r.Site__c', sponsors));
        if (!studies.isEmpty())
            filters.add(fieldJoin('Clinical_Trial_Profile__c', studies));
        if (!sites.isEmpty())
            filters.add(fieldJoin('Study_Site__c', sites));
        return filters.isEmpty() ? '' : ' AND ' + String.join(filters, ' AND ');
    }

    @TestVisible
    private List<String> getCountryCode() {
        List<String> countryCodes = new List<String>();
        for (LookupSearchResult searchResult : countries)
            countryCodes.add(searchResult.id);

        return countryCodes;
    }

    @TestVisible
    private String fieldJoin(String fieldName, List<LookupSearchResult> items) {
        List<String> ids = new List<String>();
        for (LookupSearchResult result : items)
            ids.add(result.id);

        return fieldName + ' IN (\'' + String.join(ids, SEPARATOR) + '\') ';
    }
}