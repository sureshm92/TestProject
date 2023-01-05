/**
 * Created by Igor Malyuta on 07.03.2019.
 */

public without sharing class ManualTaskFilter {
    private static final String PE_QUERY =
        'SELECT Id,Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c, Participant__c, ' +
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
            peSet.add(pe.Id);
            if (
                countryCodes != null &&
                !countryCodes.contains(pe.Participant__r.Mailing_Country_Code__c)
            ) {
                continue;
            }
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

    @TestVisible
    private Map<Id, List<Id>> getContactsWithParticipantIds(string visibility) {
        Map<Id, List<Id>> participantByContactIds = new Map<Id, List<Id>>();
        Map<Id, List<Id>> delegateParticipantByContactIds = new Map<Id, List<Id>>();
        Map<Id, List<Id>> delegateOwnerMap = new Map<Id, List<Id>>();

        List<Patient_Delegate__c> patientDelegateLST = new List<Patient_Delegate__c>();
        set<id> contactIds = new Set<id>();
        set<id> participantIds = new Set<id>();
        set<id> ParticipantHavingDelegateIds = new Set<id>();
        List<Participant_Enrollment__c> pes = new List<Participant_Enrollment__c>();

        if (!studies.isEmpty() || !sites.isEmpty()) {
            /* If studies or sites were chosen we get Participants from PEs */
            Map<Id, List<Participant_Enrollment__c>> contactsWithPEs = getContactsWithPE();
            for (Id id : contactsWithPEs.keySet()) {
                List<Id> studyparticipantIds = new List<Id>();
                List<Participant_Enrollment__c> enrollments = contactsWithPEs.get(id);
                for (Participant_Enrollment__c pe : enrollments) {
                    studyparticipantIds.add(pe.Participant__c);
                    ParticipantHavingDelegateIds.add(pe.Participant__c);
                    IdTypeOfContactMap.put(pe.Participant_Contact__c, 'Participant');
                }
                participantByContactIds.put(id, studyparticipantIds);
            }
            //return participantByContactIds;
        }

        List<String> searchStatuses = new List<String>();
        if (statuses.contains('Referred'))
            searchStatuses.addAll(PEStatusState.PE_STATUS_GROUP_IN_PROGRESS);
        if (statuses.contains('Enrolled'))
            searchStatuses.addAll(PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS);
        if (statuses.contains('Alumni'))
            searchStatuses.addAll(PEStatusState.PE_STATUS_GROUP_ALUMNI);

        String filter = '';
        if (!countries.isEmpty()) {
            filter =
                ' AND ' +
                DatabaseService.fieldInValues(
                    'Participant__r.Mailing_Country_Code__c',
                    getCountryCode()
                );
        }
        String peQuery =
            PEPLATFORM_QUERY +
            ' AND ' +
            DatabaseService.fieldInValues('Participant_Status__c', searchStatuses) +
            filter;

        if (!areas.isEmpty()) {
            List<String> therapeuticfilters = new List<String>();
            therapeuticfilters.add(fieldJoin('Therapeutic_Area__c', areas));
            if (!countries.isEmpty()) {
                therapeuticfilters.add(
                    DatabaseService.fieldInValues(
                        'Participant__r.Mailing_Country_Code__c',
                        getCountryCode()
                    )
                );
            }
            String theraQuery =
                ' AND Participant__c IN (SELECT Participant__c FROM Therapeutic_Area_Patient__c WHERE ' +
                String.join(therapeuticfilters, ' AND ');
            theraQuery += ')';
            peQuery += theraQuery;
        }

        //List<Participant_Enrollment__c> pes = (List<Participant_Enrollment__c>) Database.query(peQuery);
        if (studies.isEmpty() && sites.isEmpty()) {
            pes = Database.query(peQuery);

            for (Participant_Enrollment__c pe : pes) {
                participantByContactIds.put(
                    pe.Participant_Contact__c,
                    new List<Id>{ pe.Participant__c }
                );
                ParticipantHavingDelegateIds.add(pe.Participant__c);
                IdTypeOfContactMap.put(pe.Participant_Contact__c, 'Participant'); //KK
            }
        }
        if (!ParticipantHavingDelegateIds.isEmpty() && visibility != 'Owner') {
            patientDelegateLST = [
                SELECT id, Contact__c, Participant__c
                FROM Patient_Delegate__c
                WHERE Participant__c IN :ParticipantHavingDelegateIds
            ];
        }
        if (!patientDelegateLST.isEmpty()) {
            for (Patient_Delegate__c pd : patientDelegateLST) {
                delegateParticipantByContactIds.put(
                    pd.Contact__c,
                    new List<Id>{ pd.Participant__c }
                );
                if (
                    IdTypeOfContactMap.containsKey(pd.Contact__c) &&
                    IdTypeOfContactMap.get(pd.Contact__c) == 'Participant'
                ) {
                    String TypeOfContact = IdTypeOfContactMap.get(pd.Contact__c) + ';Delegate';
                    IdTypeOfContactMap.put(pd.Contact__c, TypeOfContact); //KK //Participant;Delegate
                } else {
                    IdTypeOfContactMap.put(pd.Contact__c, 'Delegate'); //KK
                }
            }
        }

        if (participantByContactIds != null || delegateParticipantByContactIds != null) {
            delegateOwnerMap.putAll(participantByContactIds);
            delegateOwnerMap.putAll(delegateParticipantByContactIds);
        }
        if (visibility == 'Owner') {
            return participantByContactIds;
        } else if (visibility == 'Owner;Delegates') {
            return delegateOwnerMap;
        } else if (visibility == 'Delegates') {
            return delegateParticipantByContactIds;
        } else {
            return null;
        }
    }

    public Map<Id, List<Id>> getContactsWithWhatIds(TaskService.TaskConfig taskConfig) {
        string visibility = taskConfig.visibility;
        // Platform-level tasks
        if (isPlatformLevel && String.isNotBlank(visibility))
            return getContactsWithParticipantIds(visibility);

        /* Study-level tasks, added for delegate PEH-4365*/

        Map<Id, List<Participant_Enrollment__c>> sObjectsByContact = new Map<Id, List<SObject>>();
        set<id> extractDelegateId = new Set<id>();
        List<Patient_Delegate__c> StudyDelegateLST = new List<Patient_Delegate__c>();
        List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();
        Map<Id, List<Id>> studyDelegateParticipantIds = new Map<Id, List<Id>>();
        Map<Id, List<Id>> studyDelContactPerIds = new Map<Id, List<Id>>();
        Map<Id, List<Id>> studyDelegateContactsIds = new Map<Id, List<Id>>(); // dlgtparticipant and list of delegate cont ids

        Map<Id, List<Id>> studyParticipantPErIds = new Map<Id, List<Id>>();
        Map<Id, List<Id>> studyDelegateOwnerMap = new Map<Id, List<Id>>();
        Map<Id, List<Id>> pdeListofPeMap = new Map<Id, List<Id>>();
        sObjectsByContact = getContactsWithPE(); // cont id and list of PE map
        Map<Id, List<Id>> peIdsByContact = new Map<Id, List<Id>>();
        if (!isPlatformLevel && !peSet.isEmpty()) {
            pdeList = [
                SELECT
                    id,
                    Status__c,
                    Patient_Delegate__c,
                    Participant_Enrollment__c,
                    Patient_Delegate__r.Contact__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Participant_Enrollment__c IN :peSet 
                AND Status__c = 'Active'
            ];
        }
        for (Patient_Delegate_Enrollment__c pde : pdeList) {
            if (!pdeListofPeMap.containsKey(pde.Patient_Delegate__r.Contact__c))
                pdeListofPeMap.put(pde.Patient_Delegate__r.Contact__c, new List<Id>());
            pdeListofPeMap.get(pde.Patient_Delegate__r.Contact__c)
                .add(pde.Participant_Enrollment__c);
        }
        //List<Participant_Enrollment__c> participantEnrollmentLST = new List<Participant_Enrollment__c>();
        for (Id id : sObjectsByContact.keySet()) {
            Map<Id, Participant_Enrollment__c> peMap = new Map<Id, Participant_Enrollment__c>(
                sObjectsByContact.get(id)
            );
            if (!peMap.isEmpty()) {
                peIdsByContact.put(id, new List<Id>(peMap.keySet()));
                extractDelegateId.add(peMap.Values()[0].Participant__c);
                IdTypeOfContactMap.put(peMap.Values()[0].Participant_Contact__c, 'Participant');
            }
        }
        if (!extractDelegateId.isEmpty() && visibility != 'Owner') {
            StudyDelegateLST = [
                SELECT id, Contact__c, Participant__c
                FROM Patient_Delegate__c
                WHERE Participant__c IN :extractDelegateId
            ];
        }
        if (!StudyDelegateLST.isEmpty()) {
            for (Patient_Delegate__c pd : StudyDelegateLST) {
                studyDelegateParticipantIds.put(pd.Contact__c, new List<Id>{ pd.Participant__c });
                if (!studyDelegateContactsIds.containsKey(pd.Participant__c))
                    studyDelegateContactsIds.put(pd.Participant__c, new List<Id>());
                studyDelegateContactsIds.get(pd.Participant__c).add(pd.Contact__c);

                if (
                    // checks if contact type is delegate or delegate&participant
                    IdTypeOfContactMap.containsKey(pd.Contact__c) &&
                    IdTypeOfContactMap.get(pd.Contact__c) == 'Participant'
                ) {
                    String TypeOfContact = IdTypeOfContactMap.get(pd.Contact__c) + ';Delegate';
                    IdTypeOfContactMap.put(pd.Contact__c, TypeOfContact); //KK //Participant;Delegate
                } else {
                    IdTypeOfContactMap.put(pd.Contact__c, 'Delegate'); //KK
                }
            }
        }
        set<Id> delconIds = new Set<Id>();
        if (!studyDelegateContactsIds.isEmpty()) {
            for (Id parId : studyDelegateContactsIds.keySet()) {
                if (participantwithContact.containskey(parId)) {
                    Map<Id, Participant_Enrollment__c> peMap = new Map<Id, Participant_Enrollment__c>(
                        sObjectsByContact.get(participantwithContact.get(parId))
                    );
                    delconIds.addAll(studyDelegateContactsIds.get(parId));
                    for (Id delcon : delconIds) {
                        studyDelContactPerIds.put(delcon, new List<Id>(peMap.keySet()));
                    }
                    system.debug('studyDelContactPerIds:::' + studyDelContactPerIds);
                }
            }
        }
        if (peIdsByContact != null || studyDelContactPerIds != null) {
            if(isPlatformLevel){
                studyDelegateOwnerMap.putAll(studyDelContactPerIds);
            }else{
                studyDelegateOwnerMap.putAll(pdeListofPeMap);
            }
            studyDelegateOwnerMap.putAll(peIdsByContact);
        }

        if (visibility == 'Owner') {
            return peIdsByContact;
        } else if (visibility == 'Owner;Delegates') {
            return studyDelegateOwnerMap;
        } else if (visibility == 'Delegates' && isPlatformLevel) {
            return studyDelContactPerIds;
        }else if (visibility == 'Delegates' && !isPlatformLevel) {
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
