/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TherapeuticAreaService {
    public static final String COI = 'Condition_of_Interests';

    public Set<String> getTANamesOnResource(Resource__c resource) {
        Set<String> tANames = new Set<String>();
        if(!String.isBlank(resource.Therapeutic_Areas__c)) {
            tANames.addAll(resource.Therapeutic_Areas__c.split(';'));
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

    public List<Therapeutic_Area__c> createTAsByNames(Set<String> therapeuticAreaNames) {
        List<Therapeutic_Area__c> therapeuticAreas = new List<Therapeutic_Area__c>();
        for (String singleTAName : therapeuticAreaNames) {
            therapeuticAreas.add(new Therapeutic_Area__c(Name = singleTAName));
        }
        insert therapeuticAreas;
        return therapeuticAreas;
    }

    public List<Therapeutic_Area__c> getTAsByNames(Set<String> tANames, Boolean createIfNotExist) {

        List<Therapeutic_Area__c> therapeuticAreas = [SELECT Id, Name FROM Therapeutic_Area__c WHERE Name IN :tANames];
        if(!createIfNotExist) {
            return therapeuticAreas;
        }
        Set<String> existingTANames = new Set<String>();
        for (Therapeutic_Area__c singleTA : therapeuticAreas) {
            existingTANames.add(singleTA.Name);
        }
        tANames.removeAll(existingTANames);
        if (!tANames.isEmpty()) {
            therapeuticAreas.addAll(this.createTAsByNames(tANames));
        }
        return therapeuticAreas;
    }

    public List<TherapeuticAreaService.CAWrapper> getCOIWrappers(List<Therapeutic_Area__c> therapeuticAreas) {
        List<TherapeuticAreaService.CAWrapper> caWrappers = new List<TherapeuticAreaService.CAWrapper>();
        CommunityService cService = (CommunityService) ClassFactory.newInstance(CommunityService.class);
        String participantId = cService.getParticipantId();
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
        return caWrappers;
    }

    public List<Therapeutic_Area__c> getTherapeuticAreas(String nameTA) {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String whereClause = '';
        if (!String.isBlank(nameTA)) {
            whereClause = 'AND Name LIKE \'%' + String.escapeSingleQuotes(nameTA) + '%\' ';
        }
        String tAQuery =
                'SELECT Id, ' +
                        'Name ' +
                        'FROM Therapeutic_Area__c ' +
                        'WHERE RecordType.DeveloperName = \'' + TherapeuticAreaService.COI + '\' ' +
                        whereClause +
                        'LIMIT 5';

        return (List<Therapeutic_Area__c>) databaseProxy.query(tAQuery);
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
                        'AND Therapeutic_Area__r.RecordType.DeveloperName = \'' + TherapeuticAreaService.COI + '\' ' +
                        'ORDER BY Condition_Of_Interest_Order__c) ' +
                        'FROM Participant__c ' +
                        'WHERE Id = \'' + participantId + '\'';
        return ((List<Participant__c>) databaseProxy.query(participantQuery))[0];
    }

    public class CAWrapper {
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public Therapeutic_Area_Patient__c coi;
    }
}