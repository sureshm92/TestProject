/**
 * Created by Igor Malyuta on 24.06.2019.
 */

public without sharing class VisitResultSharingService {

    private static ParticipantService.ParticipantState state;
    private static Boolean onStudy;
    private static Map<Id, Map<String, Visit_Result_Type_Sharing__c>> visitResultTypeSharingMapByCTP =
            new Map<Id, Map<String, Visit_Result_Type_Sharing__c>>();
    private static Set<String> notAccessResultType = new Set<String>();

    static {
        //TODO split context and service methods!!!:
        if ([SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId != null) {
            state = ParticipantService.getParticipantState();
            onStudy = PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS.contains(state.pe.Participant_Status__c) ||
                    PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(state.pe.Participant_Status__c);
        }
    }

    public static Boolean isVisitResultAvailable() {
        if (!onStudy) return false;

        return state.pe.Clinical_Trial_Profile__r.Visit_Data_Shareback__c &&
                state.ctp.Patient_Portal_Enabled__c &&
                state.pe.Study_Site__r.Visit_Results_Sharing__c;
    }

    public static List<Visit_Result__c> processResults() {
        if (!onStudy) return new List<Visit_Result__c>();
        Map<Id, Clinical_Trial_Profile__c> ctpById = new Map<Id, Clinical_Trial_Profile__c>();
        List<Patient_Visit__c> patientVisits = [
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
                WHERE Participant_Enrollment__c = :state.pe.Id
                AND Status__c = 'Completed'
                ORDER BY Visit_Number__c, Completed_Date__c
        ];

        return getAvailableVisitResults(patientVisits, false, ctpById);
    }

    public static List<Visit_Result__c> getAvailableVisitResults(List<Patient_Visit__c> patientVisits, Boolean isBatch, Map<Id, Clinical_Trial_Profile__c> ctpById) {
        List<Visit_Result__c> filteredResults = new List<Visit_Result__c>();
        Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType = new Map<String, Visit_Result_Type_Sharing__c>();

        try {
            String mailingCountryCode = '';
            Integer timeSharing = 0;
            if(!isBatch){
                if (!isVisitResultAvailable()) return filteredResults;

                Clinical_Trial_Profile__c ctp = getCTP(state.ctp.Id);
                visitResultTypeSharingByType = getResultTypeSharingsByType(ctp);
                mailingCountryCode = state.pe.Participant__r.Mailing_Country_Code__c;
                timeSharing = patientVisits.size() - (ctp.Shareback_Availability_Timing__c.intValue());
            }

            for(Integer i = patientVisits.size() - 1; i >= 0; i--) {
                if(isBatch){
                    timeSharing = patientVisits.size() - patientVisits.get(i).Participant_Enrollment__r.Clinical_Trial_Profile__r.Shareback_Availability_Timing__c.intValue();
                    visitResultTypeSharingByType = getResultTypeSharingsByType(ctpById.get(patientVisits.get(i).Participant_Enrollment__r.Clinical_Trial_Profile__c));
                    mailingCountryCode = patientVisits.get(i).Participant_Enrollment__r.Participant__r.Mailing_Country_Code__c;
                }
                if ((i + 1) <= timeSharing) {
                    Patient_Visit__c patientVisit = patientVisits.get(i);
                    if(patientVisit.Visit_Results__r != null && !patientVisit.Visit_Results__r.isEmpty()) {
                        for (Visit_Result__c result : patientVisit.Visit_Results__r) {
                            if (visitResultTypeSharingByType.containsKey(result.Result_Type__c)) {
                                Visit_Result_Type_Sharing__c resultTypeSharing =
                                        visitResultTypeSharingByType.get(result.Result_Type__c);
                                if (resultTypeSharing.Sharing_Countries__c == 'All' || (resultTypeSharing.Include_Countries__c &&
                                        resultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode))) {
                                    filteredResults.add(result);
                                }
                            }
                        }
                        if(!isBatch) break;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('ERROR in getAvailableVisitResults(), line ' + e.getLineNumber() + ':\n\t' + e.getMessage());
            return filteredResults;
        }
        return filteredResults;
    }

    public  Map<Id, Map<String, Visit_Result__c>> getAvailableVisitResultsByPatientVisitIds(Participant_Enrollment__c pe, List<Patient_Visit__c> patientVisits) {
        Map<Id, Map<String, Visit_Result__c>> resultMap = new Map<Id, Map<String, Visit_Result__c>>();
        Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType =
                getResultTypeSharingsByType(getCTP(pe.Clinical_Trial_Profile__c));

        String mailingCountryCode = pe.Participant__r.Mailing_Country_Code__c;
        for (Patient_Visit__c patientVisit : patientVisits) {
            Map<String, Visit_Result__c> filteredResultsByType = new Map<String, Visit_Result__c>();
            if (!patientVisit.Visit_Results__r.isEmpty()) {
                for (Visit_Result__c result : patientVisit.Visit_Results__r) {
                    if (visitResultTypeSharingByType.containsKey(result.Result_Type__c)) {
                        Visit_Result_Type_Sharing__c resultTypeSharing = visitResultTypeSharingByType.get(result.Result_Type__c);
                        if (resultTypeSharing.Sharing_Countries__c == 'All' ||
                                (resultTypeSharing.Include_Countries__c &&
                                        resultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode))
                                ) {
                            filteredResultsByType.put(result.Result_Type__c, result);
                        } else {
                            notAccessResultType.add(result.Result_Type__c);
                        }
                    }
                }
            }
            if (!filteredResultsByType.isEmpty()) {
                resultMap.put(patientVisit.Id, filteredResultsByType);
            }
        }
        return resultMap;
    }

    public Set<String> getNotAccessResultType() {
        return notAccessResultType;
    }

    public Map<Id, List<VisitReportService.VisitResultWrapper>> geAvailableVisitResultTypeMSByGroupIds(Participant_Enrollment__c pe, List<Visit_Result_GroupM__mdt> visitResultGroupMs) {
        Map<Id, List<VisitReportService.VisitResultWrapper>> visitResultTypeMSByGroupIds = new Map<Id, List<VisitReportService.VisitResultWrapper>>();
        Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType =
                getResultTypeSharingsByType(getCTP(pe.Clinical_Trial_Profile__c));

        for (Visit_Result_GroupM__mdt groupM : visitResultGroupMs) {
            List<VisitReportService.VisitResultWrapper> visitResultWrappers = new List<VisitReportService.VisitResultWrapper>();
            for (Visit_Result_TypeM__mdt visitResultTypeM : groupM.Visit_Result_Types__r) {
                if (visitResultTypeSharingByType.containsKey(visitResultTypeM.DeveloperName)) {
                    visitResultWrappers.add(new VisitReportService.VisitResultWrapper(visitResultTypeM));
                }
            }
            visitResultWrappers.sort();
            visitResultTypeMSByGroupIds.put(groupM.Id, visitResultWrappers);
        }

        return visitResultTypeMSByGroupIds;
    }

    private static Map<String, Visit_Result_Type_Sharing__c> getResultTypeSharingsByType(Clinical_Trial_Profile__c ctp) {
        Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType = new Map<String, Visit_Result_Type_Sharing__c>();
        List<Visit_Result_Type_Sharing__c> visitResultTypeSharings = (ctp != null ? ctp.Visit_Result_Type_Sharings__r : null);

        if (visitResultTypeSharings.isEmpty()) return visitResultTypeSharingByType;

        if (!visitResultTypeSharingMapByCTP.containsKey(ctp.Id)) {
            for (Visit_Result_Type_Sharing__c visitResultTypeSharing : visitResultTypeSharings) {
                visitResultTypeSharingByType.put(visitResultTypeSharing.Type__c, visitResultTypeSharing);
            }
            visitResultTypeSharingMapByCTP.put(ctp.Id, visitResultTypeSharingByType);
        }
        return visitResultTypeSharingMapByCTP.get(ctp.Id);
    }

    public static void updateStudySitesSharing(String ctpId, List<Id> ssIds, Boolean allEnabled, Boolean selectionType) {
        List<Study_Site__c> studySites = (List<Study_Site__c>) DatabaseService.query(
                new List<String>{
                        'Id', 'Visit_Results_Sharing__c'
                },
                Study_Site__c.getSObjectType(),
                'Clinical_Trial_Profile__c = \'' + ctpId + '\''
        );

        if (!studySites.isEmpty()) {
            for (Study_Site__c ss : studySites) {
                if(allEnabled || (ssIds.isEmpty() && selectionType)) {
                    ss.Visit_Results_Sharing__c = true;
                } else if(!selectionType && ssIds.isEmpty()) {
                    ss.Visit_Results_Sharing__c = false;
                } else if (ssIds.contains(ss.Id)) {
                    ss.Visit_Results_Sharing__c = selectionType;
                } else {
                    if(selectionType && ss.Visit_Results_Sharing__c) {
                        ss.Visit_Results_Sharing__c = false;
                    } else if(!selectionType) {
                        ss.Visit_Results_Sharing__c = true;
                    }
                }
            }
            update studySites;
        }
    }

    public static Clinical_Trial_Profile__c disableShareback(Clinical_Trial_Profile__c ctp) {
        List<Visit_Result_Type_Sharing__c> sharings = new List<Visit_Result_Type_Sharing__c>();
        for (Visit_Result_Type_Sharing__c vr : ctp.Visit_Result_Type_Sharings__r) sharings.add(vr);
        delete sharings;

        ctp.Shareback_Availability_Timing__c = 0;
        ctp.Shareback_Availability_Status__c = '';
        ctp.Shareback_Settings_On_Participant_Level__c = false;
        ctp.Shareback_Settings_on_StudySites__c = false;
        ctp.Participant_Visit_Result_Group__c = '';
        return ctp;
    }

    public static Clinical_Trial_Profile__c getCTP(String ctpId) {
        return [
                SELECT
                        Patient_Portal_Enabled__c,
                        Shareback_Availability_Status__c,
                        Shareback_Availability_Timing__c,
                        Shareback_Settings_On_Participant_Level__c,
                        Shareback_Settings_on_StudySites__c,
                        Shareback_Settings_On_Country_Level__c,
                        Shareback_Settings_Countries__c,
                        Participant_Visit_Result_Group__c
                        Visit_Data_Shareback__c, (
                        SELECT Id,
                                Include_Countries__c,
                                Type__c,
                                Sharing_Countries__c
                        FROM Visit_Result_Type_Sharings__r
                )
                FROM Clinical_Trial_Profile__c
                WHERE Id = :ctpId
        ];
    }

    public static Map<String, Visit_Result_Type_Sharing__c> getTypeVRSharingMap(Clinical_Trial_Profile__c ctp) {
        Map<String, Visit_Result_Type_Sharing__c> typeVRSharingMap = new Map<String, Visit_Result_Type_Sharing__c>();
        for (Visit_Result_Type_Sharing__c vr : ctp.Visit_Result_Type_Sharings__r) typeVRSharingMap.put(vr.Type__c, vr);
        return typeVRSharingMap;
    }

    public static Map<String,Map<String,List<String>>> visitResultSharingByGroupAndMode() {
        VisitResultMService visitResultMService = new VisitResultMService();
        List<Visit_Result_Type_Sharing__c> visitResultTypeSharings = [
                SELECT Id,
                        Type__c
                FROM Visit_Result_Type_Sharing__c
                WHERE Clinical_Trial_Profile__c =:state.ctp.Id
        ];
        List<String> visitResultTypeSharingNames = new List<String>();
        for (Visit_Result_Type_Sharing__c visitResultTypeSharing : visitResultTypeSharings) {
            visitResultTypeSharingNames.add(visitResultTypeSharing.Type__c);
        }
        Map<String,Map<String,List<String>>> visitResultSharingByGroupAndMode = new Map<String, Map<String, List<String>>>();
        for (String resultType : visitResultTypeSharingNames) {
            String visitResultGroup = visitResultMService.getVisitResultGroupByTypeName(resultType);
            String visitResultMode = visitResultMService.getVisitResultModeByGroupName(visitResultGroup);
            if(visitResultSharingByGroupAndMode.get(visitResultMode)==null) {
                visitResultSharingByGroupAndMode.put(visitResultMode,new Map <String,List<String>>());
            }
            if(visitResultSharingByGroupAndMode.get(visitResultMode).get(visitResultGroup)==null) {
                visitResultSharingByGroupAndMode.get(visitResultMode).put(visitResultGroup, new List<String>());
            }
            visitResultSharingByGroupAndMode.get(visitResultMode).get(visitResultGroup).add(resultType);
        }
        return visitResultSharingByGroupAndMode;
    }
}
