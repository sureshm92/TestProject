/**
 * Created by Dmytro Pokutnii
 */
public without sharing class VisitResultsRemote {

    @AuraEnabled
    public static InitDataWrapper getInitData(String visitResultsMode, Map<String, Map<String, List<String>>> visitResultSharings) {
        try {
            List<Visit_Result__c> visitResultsForMode = VisitResultsService.getVisitResults(
                    ParticipantContext.getCurrentPE().Clinical_Trial_Profile__c,
                    ParticipantContext.getCurrentPE().Participant__r.Mailing_Country_Code__c
            );
            InitDataWrapper wrapper = (InitDataWrapper) ClassFactory.newInstance(InitDataWrapper.class);
            wrapper.isVisitResultsAvailable = isVisitResultAvailable();
            wrapper.contact = ParticipantContext.getCurrentContact();
            wrapper.isResultsExist = existForModeAndAvailableByCTP(visitResultSharings.get(visitResultsMode), visitResultsForMode);
            wrapper.visitResultsGroupNames = notEmptyVisitResultsGroupName(visitResultsMode, visitResultSharings, visitResultsForMode);
            wrapper.visitResultsShares = visitResultSharings.get(visitResultsMode);
            wrapper.isDelegate = ParticipantContext.isCurrentDelegate();
            wrapper.toggleState = toggleState(visitResultsMode);
            return wrapper;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<String> getVisitResultsGroupNames(String visitResultsMode) {

        try {
            return ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class)).getVisitResultsGroupNames(visitResultsMode);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static VisitResultsService.VisitResultsContainer getVisitResultsContainer(String visitResultGroupName, String visitResultsShares) {
        try {
            return ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class)).getVisitResultsContainer(
                    visitResultGroupName, convertJSONtoMap(visitResultsShares), ParticipantContext.getCurrentPE().Clinical_Trial_Profile__c,
                    ParticipantContext.getCurrentPE().Participant__r.Mailing_Country_Code__c
            );
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<VisitResultsService.VisitResultWrapper> getVisitResultWrappersForDashboard() {

        try {
            return ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class)).getVisitResultWrappersForDashboard();
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static Boolean toggleState(String visitResultsMode) {
        Contact currentContact = ParticipantContext.getCurrentContact();
        String currentVisitResults = currentContact.Visit_Results_OptIn__c == null ? '' : currentContact.Visit_Results_OptIn__c;
        return currentVisitResults.contains(visitResultsMode);
    }

    @AuraEnabled
    public static void switchToggleRemote(String visitResultsMode, Boolean isToggleOn) {
        Contact currentContact = ParticipantContext.getCurrentContact();
        String currentVisitResults = currentContact.Visit_Results_OptIn__c == null ? '' : currentContact.Visit_Results_OptIn__c;
        String updatedVisitResults = '';
        if (isToggleOn) {
            if (!currentVisitResults.contains(visitResultsMode)) {
                updatedVisitResults = currentVisitResults + ';' + visitResultsMode;
            }
        } else {
            List<String> visitResults = currentVisitResults.split(';');
            for (String str : visitResults) {
                if (!str.equals(visitResultsMode)) updatedVisitResults += str + ';';
            }
        }
        currentContact.Visit_Results_OptIn__c = updatedVisitResults;
        update currentContact;
    }

    public static List<String> notEmptyVisitResultsGroupName(String visitResultsMode,
            Map<String, Map<String, List<String>>> visitResultSharingByGroupAndMode,
            List<Visit_Result__c> visitResultsForMode) {

        VisitResultMService visitResultMService = new VisitResultMService();
        List<String> existingVisitResultGroups = new List<String>();

        if (visitResultsForMode != null) {
            for (Visit_Result__c visitResult : visitResultsForMode) {
                existingVisitResultGroups.add(
                        visitResultMService.getVisitResultGroupByTypeName(visitResult.Result_Type__c));
            }
        }

        Map<String, List<String>> visitResultGroupNamesWithTypes =
                visitResultSharingByGroupAndMode.get(visitResultsMode);
        List<String> notEmptyVisitResultsGroupName = new List<String>();

        if (visitResultGroupNamesWithTypes != null) {
            for (String groupName : visitResultGroupNamesWithTypes.keySet()) {
                if (existingVisitResultGroups.contains(groupName)) {
                    notEmptyVisitResultsGroupName.add(groupName);
                }
            }
        }
        return notEmptyVisitResultsGroupName;
    }

    public static Boolean existForModeAndAvailableByCTP(Map<String, List<String>> availableVisitResults,
            List<Visit_Result__c> visitResultsForMode) {
        if (availableVisitResults != null) {
            List<String> availableAndExistResults = new List<String>();
            for (Visit_Result__c visitResult : visitResultsForMode) {
                availableAndExistResults.add(visitResult.Result_Type__c);
            }
            for (String str : availableVisitResults.keySet()) {
                List<String> availableResultsForGroup = availableVisitResults.get(str);
                for (String result : availableResultsForGroup) {
                    if (availableAndExistResults.contains(result)) return true;
                }
            }
        }
        return false;
    }

    private static Map<String, List<String>> convertJSONtoMap(String visitResultsShares) {
        Map<String, Object> visitResultsSharesFirstStageDeserialize = (Map<String, Object>) JSON.deserializeUntyped(visitResultsShares);
        Map<String, List<String>> visitResultSharings = new Map<String, List<String>>();
        Set <String> groups = visitResultsSharesFirstStageDeserialize.keySet();
        for (String groupName : groups) {
            List<Object> visitResultsSharesSecondStageDeserialize = (List<Object>) visitResultsSharesFirstStageDeserialize.get(groupName);
            List<String> visitResultsSharesForGroup = new List<String>();
            for (Integer i = 0; i < visitResultsSharesSecondStageDeserialize.size(); i++) {
                visitResultsSharesForGroup.add(visitResultsSharesSecondStageDeserialize.get(i).toString());
            }
            visitResultSharings.put(groupName, visitResultsSharesForGroup);
        }
        return visitResultSharings;
    }

    public class InitDataWrapper {

        @AuraEnabled
        public Contact contact;
        @AuraEnabled
        public Boolean isDelegate;
        @AuraEnabled
        public Boolean isVisitResultsAvailable;
        @AuraEnabled
        public Boolean isResultsExist;
        @AuraEnabled
        public List<String> visitResultsGroupNames;
        @AuraEnabled
        public Map<String, List<String>> visitResultsShares;
        @AuraEnabled
        public Boolean toggleState;
    }

    public static List<Patient_Visit__c> getPatientVisits() {
        if (!isOnStudy()) return new List<Patient_Visit__c>();

        return [
                SELECT
                        Id,
                        Completed_Date__c,
                        Visit_Number__c, (
                        SELECT
                                Id,
                                Actual_Value__c,
                                Max_Value__c,
                                Measurement__c,
                                Min_Value__c,
                                Patient_Visit__r.Completed_Date__c,
                                Result_Type__c,
                                RecordType.DeveloperName
                        FROM Visit_Results__r
                )
                FROM Patient_Visit__c
                WHERE Participant_Enrollment__c = :ParticipantContext.getCurrentPEId()
                AND Status__c = 'Completed'
                ORDER BY Visit_Number__c, Completed_Date__c
        ];
    }

    public static Boolean isVisitResultAvailable() {
        if (!isOnStudy()) return false;

        ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
        return participantState.pe.Clinical_Trial_Profile__r.Visit_Data_Shareback__c &&
                participantState.ctp.Patient_Portal_Enabled__c &&
                participantState.pe.Study_Site__r.Visit_Results_Sharing__c;
    }

    public static Boolean isOnStudy() {
        ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
        if (PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS.contains(participantState.pe.Participant_Status__c) ||
                PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(participantState.pe.Participant_Status__c)) {
            return true;
        }
        return false;
    }
}