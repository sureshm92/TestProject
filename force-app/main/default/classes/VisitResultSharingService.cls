/**
 * Created by Igor Malyuta on 24.06.2019.
 */

public without sharing class VisitResultSharingService {

    private static ParticipantService.ParticipantState state;
    private static Boolean havePSE;
    private static Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType;

    static {
        if([SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId != null){
            state = ParticipantService.getParticipantState();
            havePSE = state.pse != null;
            visitResultTypeSharingByType = new Map<String, Visit_Result_Type_Sharing__c>();
        }
    }

    public static Boolean isVisitResultAvailable() {
        if(!havePSE) return false;

        return state.pse.Clinical_Trial_Profile__r.Visit_Data_Shareback__c &&
                state.ctp.Participating_in_Patient_Portal__c == 'Yes' &&
                state.pse.Study_Site__r.Visit_Results_Sharing__c;
    }

    public static List<Visit_Result__c> processResults() {
        List<Visit_Result__c> filteredResults = new List<Visit_Result__c>();
        if(!havePSE) return filteredResults;

        try {
            List<Visit_Result__c> visitResultList = [
                    SELECT
                            Actual_Value__c,
                            Max_Value__c,
                            Measurement__c,
                            Min_Value__c,
                            Patient_Visit__c,
                            Patient_Visit__r.Completed_Date__c,
                            Patient_Visit__r.Visit__c,
                            Patient_Visit__r.Visit__r.Visit_Number__c,
                            Result_Type__c
                    FROM Visit_Result__c
                    WHERE Id IN:getPatientVisitResults()
            ];

            Clinical_Trial_Profile__c ctp = getCTP(state.ctp.Id);
            String mailingCountryCode = state.pse.Participant__r.Mailing_Country_Code__c;

            for (Visit_Result__c result : visitResultList) {
                if (!isVisitResultAvailable() || !state.pse.Participant_Contact__r.Visit_Results_Opt_In__c) continue;
                if (result.Patient_Visit__r.Visit__r.Visit_Number__c <= ctp.Shareback_Availability_Timing__c) continue;

                for (Visit_Result_Type_Sharing__c resultTypeSharing : ctp.Visit_Result_Type_Sharings__r) {
                    if (resultTypeSharing.Type__c == result.Result_Type__c) {
                        if (resultTypeSharing.Sharing_Countries__c == 'All' ||
                                (resultTypeSharing.Include_Countries__c &&
                                        resultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode))
                           ) {
                            filteredResults.add(result);
                            break;
                        }
                    }
                }
            }
            return filteredResults;
        } catch (Exception e) {
            System.debug(e.getCause() + '\n' + e.getLineNumber());
            return filteredResults;
        }
    }

    public static List<Visit_Result__c> getAvailableVisitResults(List<Visit_Result__c> visitResults) {
        List<Visit_Result__c> filteredResults = new List<Visit_Result__c>();
        if (!havePSE) return filteredResults;
        try {
            Clinical_Trial_Profile__c ctp = getCTP(state.ctp.Id);
            if (!isVisitResultAvailable() || !state.pse.Participant_Contact__r.Visit_Results_Opt_In__c) return filteredResults;
            String mailingCountryCode = state.pse.Participant__r.Mailing_Country_Code__c;
            for (Visit_Result__c result : visitResults) {
                if (result.Patient_Visit__r.Visit__r.Order__c <= ctp.Shareback_Availability_Timing__c) continue;
                if (visitResultTypeSharingByType.isEmpty()) {
                    VisitResultSharingService.getResultTypeSharingsByType(ctp.Visit_Result_Type_Sharings__r);
                }
                if (visitResultTypeSharingByType.containsKey(result.Result_Type__c)) {
                    Visit_Result_Type_Sharing__c resultTypeSharing = visitResultTypeSharingByType.get(result.Result_Type__c);
                    if (resultTypeSharing.Sharing_Countries__c == 'All' ||
                            (resultTypeSharing.Include_Countries__c &&
                                    resultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode))
                            ) {
                        filteredResults.add(result);
                    }
                }
            }
            return filteredResults;
        } catch (Exception e) {
            System.debug(e.getCause() + '\n' + e.getLineNumber());
            return filteredResults;
        }
    }

    private static void getResultTypeSharingsByType(List<Visit_Result_Type_Sharing__c> visitResultTypeSharings) {
        for (Visit_Result_Type_Sharing__c visitResultTypeSharing : visitResultTypeSharings) {
            visitResultTypeSharingByType.put(visitResultTypeSharing.Type__c, visitResultTypeSharing);
        }
    }

    private static List<Visit_Result__c> getPatientVisitResults() {
        List<Visit_Result__c> results;
        if(!havePSE) return results;

        return [
                SELECT Id
                FROM Visit_Result__c
                WHERE Patient_Visit__r.Participant_Study_Enrollment__c =: state.pse.Id
                    AND Patient_Visit__r.Participant_Study_Enrollment__r.Participant_Contact__c
                        = :state.participant.Contact__c
        ];
    }

    public static void updateStudySitesSharing(String ctpId, List<String> ssIds, Boolean selectionType) {
        List<Study_Site__c> studySites = (List<Study_Site__c>) DatabaseService.query(
                new List<String>{
                        'Id', 'Visit_Results_Sharing__c'
                },
                Study_Site__c.getSObjectType(),
                'Clinical_Trial_Profile__c = \'' + ctpId + '\''
        );
        if (!studySites.isEmpty()) {
            for (Study_Site__c ss : studySites) {
                if((ssIds.isEmpty() || String.isBlank(ssIds.get(0))) && selectionType) {
                    ss.Visit_Results_Sharing__c = selectionType;
                } else if (ssIds.contains(ss.Id)) {
                    ss.Visit_Results_Sharing__c = selectionType;
                } else {
                    ss.Visit_Results_Sharing__c = !selectionType;
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

        return ctp;
    }

    public static Clinical_Trial_Profile__c getCTP(String ctpId) {
        return [
                SELECT
                        Participating_in_Patient_Portal__c,
                        Shareback_Availability_Status__c,
                        Shareback_Availability_Timing__c,
                        Shareback_Settings_On_Participant_Level__c,
                        Shareback_Settings_on_StudySites__c,
                        Visit_Data_Shareback__c, (
                        SELECT Id, Include_Countries__c, Type__c, Sharing_Countries__c
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
}