/**
 * Created by Dmytro Pokutnii
 */
public without sharing class VisitResultsRemote {
    @AuraEnabled
    public static InitDataWrapper getInitData(
        String visitResultsMode,
        Map<String, Map<String, List<String>>> visitResultSharings
    ) {
        try {
            List<Visit_Result__c> visitResultsForMode = [
                SELECT
                    Patient_Visit__c,
                    Id,
                    Actual_Value__c,
                    Max_Value__c,
                    Measurement__c,
                    Min_Value__c,
                    Result_Type__c,
                    RecordTypeId
                FROM Visit_Result__c
                WHERE ID = 'a1r6s000004CLcoAAG'
            ];

            InitDataWrapper wrapper = (InitDataWrapper) ClassFactory.newInstance(
                InitDataWrapper.class
            );
            wrapper.isVisitResultsAvailable = isVisitResultAvailable();
            wrapper.contact = ParticipantContext.getCurrentContact();
            wrapper.isResultsExist = existForModeAndAvailableByCTP(
                visitResultSharings.get(visitResultsMode),
                visitResultsForMode
            );
            wrapper.isCountryWiseResultExist = existResultForCountry(
                visitResultsMode,
                ParticipantContext.getCurrentPE().Participant__r.Mailing_Country_Code__c,
                visitResultsForMode
            );
            wrapper.visitResultsGroupNames = notEmptyVisitResultsGroupName(
                visitResultsMode,
                visitResultSharings,
                visitResultsForMode
            );
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
    public static InitDataWrapper getInitData_PP(
        String visitResultsMode,
        Map<String, Map<String, List<String>>> visitResultSharings,
        List<Visit_Result__c> visitResultsForMode
    ) {
        try {
            List<Visit_Result__c> visitResultsForMode = [
                SELECT
                    Patient_Visit__c,
                    Id,
                    Actual_Value__c,
                    Max_Value__c,
                    Measurement__c,
                    Min_Value__c,
                    Result_Type__c,
                    RecordTypeId
                FROM Visit_Result__c
                WHERE ID = 'a1r6s000004CLcoAAG'
            ];

            InitDataWrapper wrapper = (InitDataWrapper) ClassFactory.newInstance(
                InitDataWrapper.class
            );
            wrapper.isVisitResultsAvailable = isVisitResultAvailable();
            wrapper.contact = ParticipantContext.getCurrentContact();
            // this is to check if result is enabled on CTP
            wrapper.isResultsExist = existForModeAndAvailableByCTP(
                visitResultSharings.get(visitResultsMode),
                visitResultsForMode
            );
            // this is to check if result is enabled for country
            wrapper.isCountryWiseResultExist = existResultForCountry(
                visitResultsMode,
                ParticipantContext.getCurrentPE().Participant__r.Mailing_Country_Code__c,
                visitResultsForMode
            );
            // While displaying Biomarker, result is available for Lab, but biomarker enabled on CTP with no results
            wrapper.visitResultsGroupNames = notEmptyVisitResultsGroupName(
                visitResultsMode,
                visitResultSharings,
                visitResultsForMode
            );
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
    public static Map<String, InitDataWrapper> getInitDataForAllResultModes_PP(
        Map<String, Map<String, List<String>>> visitResultSharings
    ) {
        Map<String, InitDataWrapper> allResultWrapper = new Map<String, InitDataWrapper>();
        for (String resultMode : visitResultSharings.keySet()) {
            InitDataWrapper wrapper = getInitData(resultMode, visitResultSharings);
            allResultWrapper.put(resultMode, wrapper);
        }
        return allResultWrapper;
    }

    @AuraEnabled
    public static List<String> getVisitResultsGroupNames(String visitResultsMode) {
        try {
            return ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class))
                .getVisitResultsGroupNames(visitResultsMode);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static VisitResultsService.VisitResultsContainer getVisitResultsContainer(
        String visitResultGroupName,
        String visitResultsShares
    ) {
        try {
            return ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class))
                .getVisitResultsContainer(
                    visitResultGroupName,
                    convertJSONtoMap(visitResultsShares),
                    ParticipantContext.getCurrentPE().Clinical_Trial_Profile__c,
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
            return ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class))
                .getVisitResultWrappersForDashboard();
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static Boolean toggleState(String visitResultsMode) {
        Contact currentContact = ParticipantContext.getCurrentContact();
        String currentVisitResults = currentContact.Visit_Results_OptIn__c == null
            ? ''
            : currentContact.Visit_Results_OptIn__c;
        return currentVisitResults.contains(visitResultsMode);
    }

    @AuraEnabled
    public static Boolean toggleStateForPP(
        String visitResultsMode,
        Participant_Enrollment__c currentPE
    ) {
        String currentVisitResults = currentPE == null ||
            currentPE.Visit_Results_Opt_In__c == null
            ? ''
            : currentPE.Visit_Results_Opt_In__c;
        return currentVisitResults.contains(visitResultsMode);
    }

    @AuraEnabled
    public static Boolean showVisitResults() {
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
            .getState();
        return participantState.showVisits &&
            participantState.showResults &&
            VisitResultsRemote.isVisitResultAvailable();
    }

    @AuraEnabled
    public static void switchToggleRemote(String visitResultsMode, Boolean isToggleOn) {
        Contact currentContact = ParticipantContext.getCurrentContact();
        String currentVisitResults = currentContact.Visit_Results_OptIn__c == null
            ? ''
            : currentContact.Visit_Results_OptIn__c;
        String updatedVisitResults = '';
        if (isToggleOn) {
            if (!currentVisitResults.contains(visitResultsMode)) {
                updatedVisitResults = currentVisitResults + ';' + visitResultsMode;
            }
        } else {
            List<String> visitResults = currentVisitResults.split(';');
            for (String str : visitResults) {
                if (!str.equals(visitResultsMode))
                    updatedVisitResults += str + ';';
            }
        }
        currentContact.Visit_Results_OptIn__c = updatedVisitResults;
        update currentContact;
    }

    @AuraEnabled
    public static void switchToggleRemoteForPP(String visitResultsMode, Boolean isToggleOn) {
        Participant_Enrollment__c currentPE = ParticipantContext.getCurrentPE();
        String currentVisitResults = currentPE.Visit_Results_Opt_In__c == null
            ? ''
            : currentPE.Visit_Results_Opt_In__c;
        String updatedVisitResults = '';
        if (isToggleOn) {
            if (!currentVisitResults.contains(visitResultsMode)) {
                updatedVisitResults = currentVisitResults + ';' + visitResultsMode;
            }
        } else {
            List<String> visitResults = currentVisitResults.split(';');
            for (String str : visitResults) {
                if (!str.equals(visitResultsMode))
                    updatedVisitResults += str + ';';
            }
        }
        currentPE.Visit_Results_Opt_In__c = updatedVisitResults;
        update currentPE;
    }

    public static List<String> notEmptyVisitResultsGroupName(
        String visitResultsMode,
        Map<String, Map<String, List<String>>> visitResultSharingByGroupAndMode,
        List<Visit_Result__c> visitResultsForMode
    ) {
        List<String> availableCTPNames = getCountryWiseVisitResult(
            visitResultsMode,
            ParticipantContext.getCurrentPE().Participant__r.Mailing_Country_Code__c
        );
        VisitResultMService visitResultMService = new VisitResultMService();
        List<String> existingVisitResultGroups = new List<String>();

        if (visitResultsForMode != null) {
            for (Visit_Result__c visitResult : visitResultsForMode) {
                if (availableCTPNames.contains(visitResult.Result_Type__c)) {
                    existingVisitResultGroups.add(
                        visitResultMService.getVisitResultGroupByTypeName(
                            visitResult.Result_Type__c
                        )
                    );
                }
            }
        }

        Map<String, List<String>> visitResultGroupNamesWithTypes = visitResultSharingByGroupAndMode.get(
            visitResultsMode
        );
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

    public static Boolean existForModeAndAvailableByCTP(
        Map<String, List<String>> availableVisitResults,
        List<Visit_Result__c> visitResultsForMode
    ) {
        if (availableVisitResults != null) {
            List<String> availableAndExistResults = new List<String>();
            for (Visit_Result__c visitResult : visitResultsForMode) {
                availableAndExistResults.add(visitResult.Result_Type__c);
            }
            for (String str : availableVisitResults.keySet()) {
                List<String> availableResultsForGroup = availableVisitResults.get(str);
                for (String result : availableResultsForGroup) {
                    if (availableAndExistResults.contains(result))
                        return true;
                }
            }
        }
        return false;
    }
    public static Boolean existResultForCountry(
        String visitResultsMode,
        String strCountryCode,
        List<Visit_Result__c> visitResultsForMode
    ) {
        List<String> ctpAvailableNames = getCountryWiseVisitResult(
            visitResultsMode,
            strCountryCode
        );
        List<String> availableAndExistResults = new List<String>();
        for (Visit_Result__c visitResult : visitResultsForMode) {
            availableAndExistResults.add(visitResult.Result_Type__c);
        }
        for (String strResultType : ctpAvailableNames) {
            if (availableAndExistResults.contains(strResultType)) {
                return true;
            }
        }
        return false;
    }
    private static List<String> getCountryWiseVisitResult(
        String visitResultsMode,
        String strCountryCode
    ) {
        List<String> visitResultTypes = new List<String>();
        String ALL_COUNTRIES = 'All';
        String strShareBackCountries = '';
        Id currentCTPId = ParticipantContext.getCurrentPE().Clinical_Trial_Profile__c;
        Clinical_Trial_Profile__c ctpObject = [
            SELECT
                Id,
                Participant_Visit_Result_Group__c,
                Shareback_Settings_On_Country_Level__c,
                Shareback_Settings_Countries__c
            FROM Clinical_Trial_Profile__c
            WHERE Id = :currentCTPId
        ];
        List<String> ctpAvailableNames = new List<String>();
        if (!String.isBlank(ctpObject.Shareback_Settings_Countries__c)) {
            strShareBackCountries = ctpObject.Shareback_Settings_Countries__c;
        }
        List<Visit_Result_GroupM__mdt> resultGroups = [
            SELECT
                Id,
                Label,
                Visit_Results_Mode__c,
                (SELECT Id, DeveloperName, Label, Visit_Result_Code__c FROM Visit_Result_Types__r)
            FROM Visit_Result_GroupM__mdt
            WHERE Visit_Results_Mode__c = :visitResultsMode
        ];

        for (Visit_Result_GroupM__mdt resultGroup : resultGroups) {
            for (Visit_Result_TypeM__mdt visitResultType : resultGroup.Visit_Result_Types__r) {
                visitResultTypes.add(visitResultType.DeveloperName);
            }
        }

        List<Visit_Result_Type_Sharing__c> resultTypeSharingList = [
            SELECT Id, Include_Countries__c, Sharing_Countries__c, Type__c
            FROM Visit_Result_Type_Sharing__c
            WHERE Clinical_Trial_Profile__c = :currentCTPId AND Type__c IN :visitResultTypes
        ];
        for (Visit_Result_Type_Sharing__c visitResultTypeSharing : resultTypeSharingList) {
            if (!visitResultTypeSharing.Include_Countries__c) {
                if (
                    String.isBlank(strCountryCode) ||
                    String.isBlank(visitResultTypeSharing.Sharing_Countries__c) ||
                    visitResultTypeSharing.Sharing_Countries__c.equals(ALL_COUNTRIES) ||
                    (!visitResultTypeSharing.Sharing_Countries__c.contains(strCountryCode) &&
                    ((!String.isBlank(strShareBackCountries) &&
                    strShareBackCountries.contains(strCountryCode)) ||
                    String.isBlank(strShareBackCountries)))
                ) {
                    ctpAvailableNames.add(visitResultTypeSharing.Type__c);
                }
            } else {
                if (
                    String.isBlank(strCountryCode) ||
                    String.isBlank(visitResultTypeSharing.Sharing_Countries__c) ||
                    (!String.isBlank(strCountryCode) &&
                    visitResultTypeSharing.Sharing_Countries__c.contains(strCountryCode))
                ) {
                    ctpAvailableNames.add(visitResultTypeSharing.Type__c);
                }
            }
        }
        return ctpAvailableNames;
    }
    private static Map<String, List<String>> convertJSONtoMap(String visitResultsShares) {
        Map<String, Object> visitResultsSharesFirstStageDeserialize = (Map<String, Object>) JSON.deserializeUntyped(
            visitResultsShares
        );
        Map<String, List<String>> visitResultSharings = new Map<String, List<String>>();
        Set<String> groups = visitResultsSharesFirstStageDeserialize.keySet();
        for (String groupName : groups) {
            List<Object> visitResultsSharesSecondStageDeserialize = (List<Object>) visitResultsSharesFirstStageDeserialize.get(
                groupName
            );
            List<String> visitResultsSharesForGroup = new List<String>();
            for (Integer i = 0; i < visitResultsSharesSecondStageDeserialize.size(); i++) {
                visitResultsSharesForGroup.add(
                    visitResultsSharesSecondStageDeserialize.get(i).toString()
                );
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
        public Boolean isCountryWiseResultExist;
        @AuraEnabled
        public List<String> visitResultsGroupNames;
        @AuraEnabled
        public Map<String, List<String>> visitResultsShares;
        @AuraEnabled
        public Boolean toggleState;
    }

    public class PPInitDataWrapper {
        @AuraEnabled
        public Contact contact;
        @AuraEnabled
        public Boolean isDelegate;
        @AuraEnabled
        public Boolean isVisitResultsAvailable;
        @AuraEnabled
        public Map<String, List<String>> visitResultsShares;
        //variables related to Vitals
        @AuraEnabled
        public Boolean toggleStateForVitals;
        //variables related to Labs
        @AuraEnabled
        public Boolean toggleStateForLabs;
        //variables related to Biomarkers
        @AuraEnabled
        public Boolean toggleStateForBiomarkers;
        @AuraEnabled
        public Map<String, Map<String, List<String>>> visitResultWithSubTypesCTP;

        //to store all result types configured at CTP
        @AuraEnabled
        public List<String> visitResultsGroupNamesCTP;

        public PPInitDataWrapper() {
            this.isVisitResultsAvailable = false;
        }
    }

    public static List<Patient_Visit__c> getPatientVisits() {
        if (!isOnStudy())
            return new List<Patient_Visit__c>();

        return [
            SELECT
                Id,
                Completed_Date__c,
                Visit_Number__c,
                (
                    SELECT
                        Id,
                        Actual_Value__c,
                        Max_Value__c,
                        Measurement__c,
                        Min_Value__c,
                        Patient_Visit__r.Completed_Date__c,
                        Patient_Visit__r.Portal_Name__c,
                        Patient_Visit__r.Participant_Enrollment__c,
                        Result_Type__c,
                        RecordType.DeveloperName
                    FROM Visit_Results__r
                )
            FROM Patient_Visit__c
            WHERE
                Participant_Enrollment__c = :ParticipantContext.getCurrentPEId()
                AND Status__c = 'Completed'
            ORDER BY Visit_Number__c, Completed_Date__c
        ];
    }

    public static List<Patient_Visit__c> getPatientVisitsForPP() {
        if (!isOnStudy())
            return new List<Patient_Visit__c>();

        return [
            SELECT Id, Completed_Date__c, Visit_Number__c
            FROM Patient_Visit__c
            WHERE
                Participant_Enrollment__c = :ParticipantContext.getCurrentPEId()
                AND Status__c = 'Completed'
            ORDER BY Visit_Number__c, Completed_Date__c
        ];
    }

    public static Boolean isVisitResultAvailable() {
        if (!isOnStudy())
            return false;

        ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
        return participantState.pe.Clinical_Trial_Profile__r.Visit_Data_Shareback__c &&
            participantState.ctp.Patient_Portal_Enabled__c &&
            participantState.pe.Study_Site__r.Visit_Results_Sharing__c;
    }

    public static Boolean isOnStudy() {
        ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
        if (
            PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS.contains(
                participantState.pe.Participant_Status__c
            ) ||
            PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(
                participantState.pe.Participant_Status__c
            )
        ) {
            return true;
        }
        return false;
    }
}
