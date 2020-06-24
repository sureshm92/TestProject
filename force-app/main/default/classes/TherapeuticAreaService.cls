/**
 * Created by Yehor Dobrovolskyi
 */
public without sharing class TherapeuticAreaService {
    public static final String COI_RT_NAME = 'Condition_of_Interests';
    public static final String TA_RT_NAME = 'Therapeutic_Area';
    public static final String THIRD_PARTY_COI_RT_NAME = 'Third_Party_Condition_of_Interests';
    public static final String SEARCH_COI_SOQL_COUNT_DEFAULT = 'SearchCOIDefaultSoqlLimit';
    public static final String SEARCH_COI_SOQL_COUNT_MAX = 'SearchCOIMaxSoqlLimit';

    public Set<String> getTANamesOnResource(Resource__c resource) {
        Set<String> tANames = new Set<String>();
        if (!String.isBlank(resource.Therapeutic_Areas__c)) {
            for (String singleTAName : resource.Therapeutic_Areas__c.split(';')) {
                tANames.add(singleTAName.trim());
            }
        }
        return tANames;
    }

    public Map<String, Therapeutic_Area__c> getTAsByNamesMap(List<Therapeutic_Area__c> therapeuticAreas) {
        Map<String, Therapeutic_Area__c> tAsByNames = new Map<String, Therapeutic_Area__c>();
        for (Therapeutic_Area__c singleTA : therapeuticAreas) {
            tAsByNames.put(singleTA.Name, singleTA);
        }
        return tAsByNames;
    }

    public List<Therapeutic_Area__c> createThirdPartyCOIsByNames(Set<String> therapeuticAreaNames) {

        String recordTypeThirdPartyCOI = SchemaUtil.getRecordTypeIdByName(TherapeuticAreaService.THIRD_PARTY_COI_RT_NAME, Therapeutic_Area__c.getSObjectType());
        List<Therapeutic_Area__c> therapeuticAreas = new List<Therapeutic_Area__c>();
        for (String singleTAName : therapeuticAreaNames) {
            therapeuticAreas.add(new Therapeutic_Area__c(Name = singleTAName, RecordTypeId = recordTypeThirdPartyCOI));
        }
        insert therapeuticAreas;
        return therapeuticAreas;
    }

    public List<Therapeutic_Area__c> getTherapeuticAreasByNames(Set<String> therapeuticAreasNames) {

        if (therapeuticAreasNames == null || therapeuticAreasNames.isEmpty()) {
            return new List<Therapeutic_Area__c>();
        }

        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String therapeuticAreasQuery = 'SELECT Id, ' +
                'Name ' +
                'FROM Therapeutic_Area__c ' +
                'WHERE RecordType.DeveloperName = \'' + TherapeuticAreaService.TA_RT_NAME + '\' AND ' +
                'Name IN (' + String.join(CollectionUtil.wrapInApostrophes(therapeuticAreasNames), ', ') + ')';
        return (List<Therapeutic_Area__c>) databaseProxy.query(therapeuticAreasQuery);
    }

    public List<Therapeutic_Area__c> getThirdPartyCOIsByNames(Set<String> tANames, Boolean createIfNotExist) {

        if (tANames == null || tANames.isEmpty()) {
            return new List<Therapeutic_Area__c>();
        }

        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String tAsQuery = 'SELECT Id, ' +
                'Name, ' +
                '(SELECT Id, COI__c FROM CTC_Third_Party_COIs__r) ' +
                'FROM Therapeutic_Area__c ' +
                'WHERE RecordType.DeveloperName = \'' + TherapeuticAreaService.THIRD_PARTY_COI_RT_NAME +
                '\' AND Name IN (' + String.join(CollectionUtil.wrapInApostrophes(tANames), ', ') + ')';
        List<Therapeutic_Area__c> therapeuticAreas = (List<Therapeutic_Area__c>) databaseProxy.query(tAsQuery);
        if (!createIfNotExist) {
            return therapeuticAreas;
        }
        Set<String> existingTANames = new Set<String>();
        for (Therapeutic_Area__c singleTA : therapeuticAreas) {
            existingTANames.add(singleTA.Name);
        }
        tANames.removeAll(existingTANames);
        if (!tANames.isEmpty()) {
            therapeuticAreas.addAll(this.createThirdPartyCOIsByNames(tANames));
        }
        return therapeuticAreas;
    }

    public List<TherapeuticAreaService.CAWrapper> getCOIWrappers(List<Therapeutic_Area__c> therapeuticAreas) {
        List<TherapeuticAreaService.CAWrapper> caWrappers = new List<TherapeuticAreaService.CAWrapper>();
        String participantId;
        try {
        participantId = ParticipantService.getInstance().getState().participant.Id;
        
        for (Therapeutic_Area__c areaPatient : therapeuticAreas) {
            TherapeuticAreaService.CAWrapper caWrapper = new TherapeuticAreaService.CAWrapper ();
            caWrapper.isSelected = false;
            caWrapper.coi = new Therapeutic_Area_Patient__c(
                    Participant__c = participantId,
                    Therapeutic_Area__c = areaPatient.Id,
                    Therapeutic_Area__r = areaPatient,
                    Condition_Of_Interest_Order__c = 100
            );
            caWrappers.add(caWrapper);
        }
        } catch(exception e) {system.debug(e.getmessage());}
        
        return caWrappers;
    }

    public List<Therapeutic_Area__c> getTherapeuticAreas(String nameTA) {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        Map<String, Integer> numberOfLimitsMapDecimalsByStrings = new Map<String, Integer>();
        Number_Of_Limits__mdt[] numberOfLimits = [
                SELECT
                        Label,
                        Count_Limit__c
                FROM Number_Of_Limits__mdt
                WHERE Label IN (:SEARCH_COI_SOQL_COUNT_DEFAULT, :SEARCH_COI_SOQL_COUNT_MAX)
        ];
        for (Number_Of_Limits__mdt numberOfLimit : numberOfLimits) {
            numberOfLimitsMapDecimalsByStrings.put(numberOfLimit.Label, (Integer) numberOfLimit.Count_Limit__c);
        }
        String limitsClause = 'LIMIT 5';
        String whereClause = 'WHERE RecordType.DeveloperName = \'' + TherapeuticAreaService.COI_RT_NAME + '\' ';
        if (!numberOfLimits.isEmpty()) {
            limitsClause = 'LIMIT ' + numberOfLimitsMapDecimalsByStrings.get(SEARCH_COI_SOQL_COUNT_DEFAULT);
        }
        if (!String.isBlank(nameTA)) {
            whereClause += 'AND Name LIKE \'%' + String.escapeSingleQuotes(nameTA) + '%\' ';
            limitsClause = 'LIMIT ' + numberOfLimitsMapDecimalsByStrings.get(SEARCH_COI_SOQL_COUNT_MAX);
        }
        String tAQuery =
                'SELECT Id, ' +
                        'Name ' +
                        'FROM Therapeutic_Area__c ' +
                        whereClause +
                        limitsClause;
        List<Therapeutic_Area__c> taList = (List<Therapeutic_Area__c>) databaseProxy.query(tAQuery);
        TranslateHelper.translate(taList);
        return taList;
    }

    public Participant__c getParticipant() {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        CommunityService cService = (CommunityService) ClassFactory.newInstance(CommunityService.class);
        String participantId = cService.getParticipantId();
        String participantQuery =
                'SELECT Id, ' +
                        'Conditions__c, ' +
                        '(SELECT Id, Therapeutic_Area__c, Therapeutic_Area__r.Name, Therapeutic_Area__r.RecordType.DeveloperName, IsRelatedToStudy__c, Condition_Of_Interest_Order__c ' +
                        'FROM Therapeutic_Area_Patients__r ' +
                        'WHERE Condition_Of_Interest_Order__c > 0 ' +
                        'AND Therapeutic_Area__r.RecordType.DeveloperName = \'' + TherapeuticAreaService.COI_RT_NAME + '\' ' +
                        'ORDER BY Condition_Of_Interest_Order__c) ' +
                        'FROM Participant__c ' +
                        'WHERE Id = \'' + participantId + '\'';
        List<Participant__c> participants = (List<Participant__c>) databaseProxy.query(participantQuery);
        if (!participants.isEmpty()) {
            return participants[0];
        }
        return null;
    }

    public class CAWrapper {
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public Therapeutic_Area_Patient__c coi;
    }
}