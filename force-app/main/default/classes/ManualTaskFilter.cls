/**
 * Created by Igor Malyuta on 07.03.2019.
 */

public with sharing class ManualTaskFilter {

    private static final String PROFILE = 'IQVIA Customer Community Plus Login User';

    private static final String ENROLLED_QUERY =
            'SELECT Id, Participant__r.Contact__c, Participant__r.Mailing_Country_Code__c ' +
                    'FROM Participant_Study_Enrollment__c ' +
                    'WHERE Status__c = \'Enrolled\'';

    private static final String REFERRED_QUERY =
            'SELECT Id, Participant__r.Contact__c, Participant__r.Mailing_Country_Code__c ' +
                    'FROM Participant_Enrollment__c ' +
                    'WHERE Participant_Status__c IN ';

    private static final String THERAPEUTIC_QUERY = 'SELECT Participant__r.Id FROM Therapeutic_Area_Patient__c ' +
            'WHERE ';

    //Color filters (statuses)
    private static final String[] PE_STATUSES_GREEN = new String[]{
            'Referral Sent to PI', 'Referral Accepted', 'Contact Successful', 'Eligibility Passed', 'Screening Complete'
    };
    private static final String[] PE_STATUSES_YELLOW = new String[]{
            'Referral On Hold', 'Contact Attempt In Progress', 'Screening In Progress'
    };

    private static final String SEPARATOR = '\',\'';

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

    public List<User> getUsers() {
        Set<Participant__c> participants = new Set<Participant__c>();

        if (statuses.contains('Enrolled')) {
            String query = ENROLLED_QUERY + getFiltersQuery();
            System.debug('Enrolled query is: ' + query);

            List<Participant_Study_Enrollment__c> participantStudyEnrollment =
                    (List<Participant_Study_Enrollment__c>) Database.query(query);

            for (Participant_Study_Enrollment__c pse : participantStudyEnrollment) {
                participants.add(pse.Participant__r);
            }
        }

        if (statuses.contains('Referred')) {
            String query = REFERRED_QUERY + getColorFilters() + getFiltersQuery();
            System.debug('Referred query is: ' + query);

            List<Participant_Enrollment__c> participantEnrollments =
                    (List<Participant_Enrollment__c>) Database.query(query);

            for (Participant_Enrollment__c pe : participantEnrollments) {
                participants.add(pe.Participant__r);
            }
        }

        Set<Id> contacts = new Set<Id>();
        List<String> countryCodes = getCountryCode();
        for (Participant__c partic : participants) {
            if (!countries.isEmpty()) {
                if (countryCodes.contains(partic.Mailing_Country_Code__c)) {
                    contacts.add(partic.Contact__c);
                }
            }else {
                contacts.add(partic.Contact__c);
            }
        }

        return [
                SELECT Id, Name
                FROM User
                WHERE ContactId IN :contacts
                AND IsActive = TRUE
                AND Profile.Name = :PROFILE
        ];
    }

    //Add green and yellow status 'IN(...)'
    private String getColorFilters() {
        return '(\'' +
                String.join(PE_STATUSES_GREEN, ManualTaskFilter.SEPARATOR) +
                ManualTaskFilter.SEPARATOR +
                String.join(PE_STATUSES_YELLOW, ManualTaskFilter.SEPARATOR) +
                '\') ';
    }

    private String filterTherapeutic() {
        List<Therapeutic_Area_Patient__c> participantInArea = (List<Therapeutic_Area_Patient__c>)
                Database.query(THERAPEUTIC_QUERY + fieldJoin('Therapeutic_Area__c', areas));

        List<String> participantIds = new List<String>();
        for (Therapeutic_Area_Patient__c areaPatientpart : participantInArea)
            participantIds.add(areaPatientpart.Participant__r.Id);

        return fieldJoin('Participant__c', participantIds);
    }

    private String getFiltersQuery() {
        List<String> filters = new List<String>();

        if (!areas.isEmpty()) filters.add(filterTherapeutic());

        if (!sponsors.isEmpty()) filters.add(fieldJoin('Study_Site__r.Site__c', sponsors));

        if (!studies.isEmpty()) filters.add(fieldJoin('Clinical_Trial_Profile__c', studies));

        if (!sites.isEmpty()) filters.add(fieldJoin('Study_Site__c', sites));

        return filters.isEmpty() ? '' : ' AND ' + String.join(filters, ' AND ');
    }

    private String fieldJoin(String fieldName, List<LookupSearchResult> items) {
        List<String> ids = new List<String>();
        for (LookupSearchResult result : items) ids.add(result.getId());

        return fieldName + ' IN (\'' + String.join(ids, SEPARATOR) + '\') ';
    }

    private String fieldJoin(String fieldName, List<String> items) {
        return fieldName + ' IN (\'' + String.join(items, SEPARATOR) + '\') ';
    }

    private List<String> getCountryCode() {
        List<String> countryCodes = new List<String>();
        for (LookupSearchResult searchResult : countries) countryCodes.add(searchResult.getId());

        return countryCodes;
    }
}