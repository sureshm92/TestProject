public without sharing class PP_VisitResultsService {
    /**RK START*/
    @AuraEnabled
    public static PPInitDataWrapper getInitDataPP(Integer ctpSharingTiming, String patientVisitId) {
        PPInitDataWrapper wrapper = (PPInitDataWrapper) ClassFactory.newInstance(
            PPInitDataWrapper.class
        );

        if (checkDataSharebackTiming(ctpSharingTiming, patientVisitId)) {
            /**CTP level configuration in Map*/
            Map<String, Map<String, List<String>>> visitResultSharings = VisitResultSharingService.visitResultSharingByGroupAndModeAndCountry();
            if (visitResultSharings != null) {
                wrapper.visitResultWithSubTypesCTP = visitResultSharings;
            }

            Set<String> visitResultSubTypeSet = new Set<String>();
            wrapper.visitResultsShares = new Map<String, List<String>>();
            Participant_Enrollment__c currentPE = ParticipantContext.getCurrentPE();
            for (String visitResultTypeCTP : visitResultSharings.keySet()) {
                Map<String, List<String>> visitResultTypeWithSubTypeCTP = visitResultSharings.get(
                    visitResultTypeCTP
                );
                if (visitResultTypeCTP == 'Vitals') {
                    wrapper.toggleStateForVitals = toggleStateForPP(visitResultTypeCTP, currentPE);
                } else if (visitResultTypeCTP == 'Labs') {
                    wrapper.toggleStateForLabs = toggleStateForPP(visitResultTypeCTP, currentPE);
                } else if (visitResultTypeCTP == 'Biomarkers') {
                    wrapper.toggleStateForBiomarkers = toggleStateForPP(
                        visitResultTypeCTP,
                        currentPE
                    );
                }
                for (String visitResultTypeInner : visitResultTypeWithSubTypeCTP.keySet()) {
                    List<String> subTypeSet = visitResultTypeWithSubTypeCTP.get(
                        visitResultTypeInner
                    );
                    visitResultSubTypeSet.addAll(subTypeSet);
                    if (wrapper.visitResultsShares.containsKey(visitResultTypeCTP)) {
                        List<String> subTypeList = wrapper.visitResultsShares.get(
                            visitResultTypeCTP
                        );
                        subTypeList.addAll(subTypeSet);
                    } else {
                        wrapper.visitResultsShares.put(visitResultTypeCTP, subTypeSet);
                    }
                }
            }

            List<Visit_Result__c> visResults = [
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
                FROM Visit_Result__c
                WHERE
                    Patient_Visit__c = :patientVisitId
                    AND Result_Type__c IN :visitResultSubTypeSet
            ];

            wrapper.visitResultsGroupNamesCTP = new List<String>(visitResultSharings.keySet());
            if (visResults != null && !visResults.isEmpty()) {
                wrapper.isVisitResultsAvailable = false;
                for (Visit_Result__c vr : visResults) {
                    List<String> subTypesList = wrapper.visitResultsShares.get(
                        vr.RecordType.DeveloperName + 's'
                    );
                    if (subTypesList != null && subTypesList.contains(vr.Result_Type__c)) {
                        wrapper.isVisitResultsAvailable = true;
                        break;
                    }
                }
            } else {
                wrapper.isVisitResultsAvailable = false;
            }
            wrapper.isDelegate = ParticipantContext.isCurrentDelegate();
            return wrapper;
        } else {
            wrapper.isVisitResultsAvailable = false;
            return wrapper;
        }
    }

    public static Boolean checkDataSharebackTiming(
        Integer ctpSharingTiming,
        String patientVisitId
    ) {
        List<Patient_Visit__c> patientVisitList = getPatientVisitsForPP();
        /**checking CTP level Data Shareback Timing Configuration*/
        if (
            patientVisitList == null ||
            (patientVisitList != null &&
            patientVisitList.size() <= ctpSharingTiming)
        ) {
            return false;
        } else {
            for (Integer i = 0; i < patientVisitList.size(); i++) {
                if (patientVisitList[i].Id == patientVisitId) {
                    Integer patientVisitPosition = i + 1;
                    if (patientVisitPosition > ctpSharingTiming) {
                        return true;
                    } else {
                        return false;
                    }
                }
            }
            return false;
        }
    }

    /**Returns toggle state for specific visit result type configured at PE level*/
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

    public class PPInitDataWrapper {
        @AuraEnabled
        public Boolean isDelegate;
        @AuraEnabled
        public Boolean isVisitResultsAvailable;
        @AuraEnabled
        public Map<String, List<String>> visitResultsShares;
        @AuraEnabled
        public Boolean toggleStateForVitals;
        @AuraEnabled
        public Boolean toggleStateForLabs;
        @AuraEnabled
        public Boolean toggleStateForBiomarkers;
        @AuraEnabled
        public Map<String, Map<String, List<String>>> visitResultWithSubTypesCTP;

        @AuraEnabled
        public List<String> visitResultsGroupNamesCTP;

        public PPInitDataWrapper() {
            this.isVisitResultsAvailable = false;
        }
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

    /**RK END*/
}
