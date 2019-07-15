public inherited sharing class VisitResultsService {

    private VisitResultMService metadataService;

    public VisitResultsService() {
        this.metadataService = (VisitResultMService) ClassFactory.newInstance(VisitResultMService.class);
    }

    public List<String> getVisitResultsGroupNames(String visitResultsMode) {
        return this.metadataService.getVisitResultGroupNames(visitResultsMode);
    }

//    public List<Visit_Result__c> getVisitResults(Id visitId, List<Visit_Result_TypeM__mdt> visitResultTypes) {
//        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(
//                'SELECT Id, ' +
//                        'Name, ' +
//                        'Actual_Value__c, ' +
//                        'Min_Value__c, ' +
//                        'Max_Value__c, ' +
//                        'Measurement__c, ' +
//                        'Patient_Visit__r.Completed_Date__c, ' +
//                        'Result_Type__c ' +
//                        ' FROM Visit_Result__c ' +
//                        ' WHERE Patient_Visit__c = \'' + visitId + '\'' +
//                        ((visitResultTypes != null && !visitResultTypes.isEmpty()) ?
//                                (' AND Result_Type__c IN (' + CollectionUtil.joinByComa(
//                                        CollectionUtil.wrapInApostrophes(
//                                                this.metadataService.getVisitResultTypeDeveloperNames(visitResultTypes)
//                                        )) + ')'
//                                ) : ''
//                        )
//                , true);
//    }

//    public List<Patient_Visit__c> getPatientVisits() {
//
//        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
//        if (pState == null || pState.ctp == null || pState.ctp.Visit_Plan__c == null || !pState.showVisits || pState.pse == null) {
//            return null;
//        }
//
//        String visitsQuery = 'SELECT ' +
//                'Name, ' +
//                'Completed_Date__c, ' +
//                'Participant_Study_Enrollment__r.Participant__r.Contact__r.Visit_Results_Opt_In__c, ' +
//                'Participant_Study_Enrollment__r.Participant__r.Contact__r.Id ' +
//                'FROM Patient_Visit__c ' +
//                'WHERE Visit__r.Visit_Plan__c = \'' + pState.ctp.Visit_Plan__c + '\'' +
//                ' AND Participant_Study_Enrollment__c = \'' + pState.pse.Id + '\'' +
//                ' AND Status__c = \'Completed\'' +
//                ' ORDER BY Completed_Date__c NULLS LAST' +
//                ' LIMIT 1';
//
//        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(visitsQuery, true);
//    }

    public List<VisitResultsService.VisitResultWrapper> getVisitResultWrappersForDashboard() {

        /** todo do refactoring*/
        Map<String, Double> visitResultValuesByNames = new Map<String, Double>();
        VisitResultsContainer container = this.getVisitResultsContainer('Vitals');
        List<VisitResultWrapper> wrappers = new List<VisitResultWrapper>();
        if(!VisitResultSharingService.isVisitResultAvailable() || container == null || container.wrappers == null || container.wrappers.isEmpty()) {
            return wrappers;
        }
        for(VisitResultWrapper singleWrapper : container.wrappers) {
            visitResultValuesByNames.put(singleWrapper.name, singleWrapper.value);
        }
        VisitResultWrapper singleWrapper = new VisitResultWrapper('Weight');
        singleWrapper.value = visitResultValuesByNames.get('Weight');
        wrappers.add(singleWrapper);

        singleWrapper = new VisitResultWrapper('Pulse');
        singleWrapper.value = visitResultValuesByNames.get('Pulse');
        wrappers.add(singleWrapper);

        singleWrapper = new VisitResultWrapper('Systolic');
        singleWrapper.value = visitResultValuesByNames.get('Systolic Blood Pr.');
        wrappers.add(singleWrapper);

        singleWrapper = new VisitResultWrapper('Diastolic');
        singleWrapper.value = visitResultValuesByNames.get('Diastolic Blood Pr.');
        wrappers.add(singleWrapper);

        if(wrappers[0].value == null && wrappers[1].value == null && wrappers[2].value == null && wrappers[3].value == null) {
            return new List<VisitResultWrapper>();
        }

        return wrappers;
    }

    public VisitResultsContainer getVisitResultsContainer(String visitResultsGroupName) {

        List<Visit_Result_TypeM__mdt> visitResultTypes = this.metadataService.getVisitResultTypes(visitResultsGroupName);
        List<Visit_Result__c> visitResults = VisitResultSharingService.processResults();
        if(visitResults.isEmpty()) {
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