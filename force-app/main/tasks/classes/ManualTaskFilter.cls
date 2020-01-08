/**
 * Created by Igor Malyuta on 07.03.2019.
 */

public with sharing class ManualTaskFilter {

    private static final String QUERY =
            'SELECT Id, Participant__r.Contact__c, Participant__r.Mailing_Country_Code__c ' +
                    'FROM Participant_Enrollment__c WHERE Clinical_Trial_Profile__r.Tasks_Are_Available__c = TRUE AND ';

    private static final String THERAPEUTIC_QUERY = 'SELECT Participant__c FROM Therapeutic_Area_Patient__c WHERE ';

    public static final String SEPARATOR = '\',\'';

    @AuraEnabled public List<String> statuses = new List<String>();
    @AuraEnabled public List<LookupSearchResult> areas = new List<LookupSearchResult>();
    @AuraEnabled public List<LookupSearchResult> sponsors = new List<LookupSearchResult>();
    @AuraEnabled public List<LookupSearchResult> studies = new List<LookupSearchResult>();
    @AuraEnabled public List<LookupSearchResult> countries = new List<LookupSearchResult>();
    @AuraEnabled public List<LookupSearchResult> sites = new List<LookupSearchResult>();

    public Map<Id, List<Participant_Enrollment__c>> getContactsWithPE() {
        List<String> searchStatuses = new List<String>();
        if (statuses.contains('Referred')) searchStatuses.addAll(PEStatusState.PE_STATUS_GROUP_IN_PROGRESS);
        if (statuses.contains('Enrolled')) searchStatuses.addAll(PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS);
        if (statuses.contains('Alumni')) searchStatuses.addAll(PEStatusState.PE_STATUS_GROUP_ALUMNI);

        String peQuery = QUERY +
                DatabaseService.fieldInValues('Participant_Status__c', searchStatuses) + getFiltersQuery();
        List<Participant_Enrollment__c> enrollments = (List<Participant_Enrollment__c>) Database.query(peQuery);

        List<String> countryCodes;
        if (!countries.isEmpty()) countryCodes = getCountryCode();

        Map<Id, List<Participant_Enrollment__c>> peByContactIds = new Map<Id, List<Participant_Enrollment__c>>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (pe.Participant__r.Contact__c != null) {
                if (countryCodes != null && !countryCodes.contains(pe.Participant__r.Mailing_Country_Code__c)) {
                    continue;
                }

                if (!peByContactIds.containsKey(pe.Participant__r.Contact__c)) {
                    peByContactIds.put(pe.Participant__r.Contact__c, new List<Participant_Enrollment__c>());
                }
                peByContactIds.get(pe.Participant__r.Contact__c).add(pe);
            }
        }

        return peByContactIds;
    }

    @TestVisible
    private String filterTherapeutic() {
        List<Therapeutic_Area_Patient__c> participantInArea = (List<Therapeutic_Area_Patient__c>)
                Database.query(THERAPEUTIC_QUERY + fieldJoin('Therapeutic_Area__c', areas));

        List<String> participantIds = new List<String>();
        for (Therapeutic_Area_Patient__c areaPatient : participantInArea) participantIds.add(areaPatient.Participant__c);

        return DatabaseService.fieldInValues('Participant__c', participantIds);
    }

    @TestVisible
    private String getFiltersQuery() {
        List<String> filters = new List<String>();
        if (!areas.isEmpty()) filters.add(filterTherapeutic());
        if (!sponsors.isEmpty()) filters.add(fieldJoin('Study_Site__r.Site__c', sponsors));
        if (!studies.isEmpty()) filters.add(fieldJoin('Clinical_Trial_Profile__c', studies));
        if (!sites.isEmpty()) filters.add(fieldJoin('Study_Site__c', sites));
        return filters.isEmpty() ? '' : ' AND ' + String.join(filters, ' AND ');
    }

    @TestVisible
    private List<String> getCountryCode() {
        List<String> countryCodes = new List<String>();
        for (LookupSearchResult searchResult : countries) countryCodes.add(searchResult.id);

        return countryCodes;
    }

    @TestVisible
    private String fieldJoin(String fieldName, List<LookupSearchResult> items) {
        List<String> ids = new List<String>();
        for (LookupSearchResult result : items) ids.add(result.id);

        return fieldName + ' IN (\'' + String.join(ids, SEPARATOR) + '\') ';
    }
}