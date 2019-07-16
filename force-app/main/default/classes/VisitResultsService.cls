public inherited sharing class VisitResultsService {

    private VisitResultMService metadataService;

    public VisitResultsService() {
        this.metadataService = (VisitResultMService) ClassFactory.newInstance(VisitResultMService.class);
    }

    public List<String> getVisitResultsGroupNames(String visitResultsMode) {
        return this.metadataService.getVisitResultGroupNames(visitResultsMode);
    }

    public List<Visit_Result__c> getVisitResults(Id visitId, List<Visit_Result_TypeM__mdt> visitResultTypes) {
        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(
                'SELECT Id, ' +
                        'Name, ' +
                        'Actual_Value__c, ' +
                        'Min_Value__c, ' +
                        'Max_Value__c, ' +
                        'Measurement__c, ' +
                        'Patient_Visit__r.Completed_Date__c, ' +
                        'Result_Type__c ' +
                        ' FROM Visit_Result__c ' +
                        ' WHERE Patient_Visit__c = \'' + visitId + '\'' +
                        ((visitResultTypes != null && !visitResultTypes.isEmpty()) ?
                                (' AND Result_Type__c IN (' + CollectionUtil.joinByComa(
                                        CollectionUtil.wrapInApostrophes(
                                                this.metadataService.getVisitResultTypeDeveloperNames(visitResultTypes)
                                        )) + ')'
                                ) : ''
                        )
                , true);
    }

    public List<Patient_Visit__c> getPatientVisits() {

        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
        if (pState == null || pState.ctp == null || pState.ctp.Visit_Plan__c == null || !pState.showVisits || pState.pse == null) {
            return null;
        }

        String visitsQuery = 'SELECT ' +
                'Name, ' +
                'Completed_Date__c, ' +
                'Participant_Study_Enrollment__r.Participant__r.Contact__r.Visit_Results_Opt_In__c, ' +
                'Participant_Study_Enrollment__r.Participant__r.Contact__r.Id ' +
                'FROM Patient_Visit__c ' +
                'WHERE Visit__r.Visit_Plan__c = \'' + pState.ctp.Visit_Plan__c + '\'' +
                ' AND Participant_Study_Enrollment__c = \'' + pState.pse.Id + '\'' +
                ' AND Status__c = \'Completed\'' +
                ' ORDER BY Completed_Date__c NULLS LAST' +
                ' LIMIT 1';

        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(visitsQuery, true);
    }

    public List<Patient_Visit__c> getPatientVisitsForReport() {

        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
        if (pState == null || pState.ctp == null || pState.ctp.Visit_Plan__c == null || pState.pse == null) {
            return null;
        }

        String visitsQuery = 'SELECT ' +
                'Name, ' +
                'Completed_Date__c, ' +
                'Participant_Study_Enrollment__r.Participant__r.Contact__r.Visit_Results_Opt_In__c, ' +
                'Participant_Study_Enrollment__r.Participant__r.Full_Name__c, ' +
                'Participant_Study_Enrollment__r.Participant__r.Last_Name__c, ' +
                '(SELECT Name, Actual_Value__c, Min_Value__c, Max_Value__c, Measurement__c, Result_Type__c FROM Visit_Results__r) ' +
                'FROM Patient_Visit__c ' +
                'WHERE Visit__r.Visit_Plan__c = \'' + pState.ctp.Visit_Plan__c + '\'' +
                ' AND Participant_Study_Enrollment__c = \'' + pState.pse.Id + '\'' +
                ' AND Status__c = \'Completed\'' +
                ' ORDER BY Completed_Date__c NULLS LAST';

        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(visitsQuery, true);
    }

    public VisitResultsContainer getVisitResultsContainer(String visitResultsGroupName) {

        List<Patient_Visit__c> visits = this.getPatientVisits();
        if (visits.isEmpty()) {
            return null;
        }
        List<Visit_Result_TypeM__mdt> visitResultTypes = this.metadataService.getVisitResultTypes(visitResultsGroupName);
        List<Visit_Result__c> visitResults = this.getVisitResults(visits[0].Id, visitResultTypes);
        if (visitResults.isEmpty()) {
            return null;
        }
        Map<String, Visit_Result__c> visitResultsByTypeDeveloperNames = this.getVisitResultsByTypeDeveloperNames(visitResults);
        List<VisitResultWrapper> wrappers = new List<VisitResultsService.VisitResultWrapper>();
        Set<Id> uniqueIds = new Set<Id>();
        for (Visit_Result_TypeM__mdt singleVisitResultType : visitResultTypes) {
            Visit_Result__c singleVisitResult = visitResultsByTypeDeveloperNames.get(singleVisitResultType.DeveloperName);
            if (singleVisitResult != null && uniqueIds.add(singleVisitResult.Id)) {
                wrappers.add(new VisitResultWrapper(singleVisitResult, singleVisitResultType.Label));
            } else {
                wrappers.add(new VisitResultWrapper(singleVisitResultType.Label));
            }
        }
        return new VisitResultsContainer(visitResults[0].Patient_Visit__r, wrappers, visitResultsGroupName);
    }

    private Map<String, Visit_Result__c> getVisitResultsByTypeDeveloperNames(List<Visit_Result__c> visitResults) {
        Map<String, Visit_Result__c> result = new Map<String, Visit_Result__c>();
        for (Visit_Result__c singleResult : visitResults) {
            result.put(singleResult.Result_Type__c, singleResult);
        }
        return result;
    }

    public class VisitResultsContainer {

        @AuraEnabled
        public List<VisitResultsService.VisitResultWrapper> wrappers;
        @AuraEnabled
        public String visitDate;
        @AuraEnabled
        public String groupName;

        public VisitResultsContainer(Patient_Visit__c visit, List<VisitResultWrapper> wrappers, String groupName) {
            this.wrappers = wrappers;
            this.visitDate = visit.Completed_Date__c == null ? Label.StudyVisit_Information_Not_Available : DateService.format(visit.Completed_Date__c, 'DD-MMM-YYYY');
            this.groupName = groupName;
        }
    }
    public class VisitResultWrapper {

        @AuraEnabled
        public Double value;
        @AuraEnabled
        public Double minValue;
        @AuraEnabled
        public Double maxValue;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String measurement;

        public VisitResultWrapper(Visit_Result__c visitResult, String name) {
            this.value = visitResult.Actual_Value__c;
            this.minValue = visitResult.Min_Value__c;
            this.maxValue = visitResult.Max_Value__c;
            this.name = name;
            this.measurement = visitResult.Measurement__c;
        }

        public VisitResultWrapper(String name) {
            this.name = name;
        }
    }
}