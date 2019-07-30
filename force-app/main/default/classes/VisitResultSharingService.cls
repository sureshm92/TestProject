/**
 * Created by Igor Malyuta on 24.06.2019.
 */

public without sharing class VisitResultSharingService {

    private static ParticipantService.ParticipantState state;
    private static Boolean havePSE;
    private static Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType;
    private static Set<String> notAccessResultType;

    static {
        if ([SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId != null) {
            state = ParticipantService.getParticipantState();
            havePSE = state.pse != null;
            notAccessResultType = new Set<String>();
        }
    }

    public static Boolean isVisitResultAvailable() {
        if (!havePSE) return false;

        return state.pse.Clinical_Trial_Profile__r.Visit_Data_Shareback__c &&
                state.ctp.Participating_in_Patient_Portal__c == 'Yes' &&
                state.pse.Study_Site__r.Visit_Results_Sharing__c;
    }

    public static List<Visit_Result__c> processResults() {
        if (!havePSE) return new List<Visit_Result__c>();

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
                                Result_Type__c
                        FROM Visit_Results__r
                )
                FROM Patient_Visit__c
                WHERE Participant_Study_Enrollment__c =: state.pse.Id
                AND Status__c = 'Completed'
                AND Visit_Number__c != NULL
                ORDER BY Visit_Number__c DESC
        ];

        return getAvailableVisitResults(patientVisits);
    }

    public static List<Visit_Result__c> getAvailableVisitResults(List<Patient_Visit__c> patientVisits) {
        List<Visit_Result__c> filteredResults = new List<Visit_Result__c>();
        try {
            if (!isVisitResultAvailable() || !state.pse.Participant_Contact__r.Visit_Results_Opt_In__c) return filteredResults;

            Map<Decimal, List<Visit_Result__c>> resultsByVisitNumber = new Map<Decimal, List<Visit_Result__c>>();
            for (Patient_Visit__c pv : patientVisits) {
                if(pv.Visit_Results__r != null && !pv.Visit_Results__r.isEmpty()) {
                    resultsByVisitNumber.put(pv.Visit_Number__c, pv.Visit_Results__r);
                }
            }

            Clinical_Trial_Profile__c ctp = getCTP(state.ctp.Id);
            visitResultTypeSharingByType = getResultTypeSharingsByType(ctp.Visit_Result_Type_Sharings__r);
            String mailingCountryCode = state.pse.Participant__r.Mailing_Country_Code__c;
            Decimal timeSharing = patientVisits.get(0).Visit_Number__c - ctp.Shareback_Availability_Timing__c;

            while (true) {
                if (timeSharing < 1) break;

                if (!resultsByVisitNumber.containsKey(timeSharing)) {
                    timeSharing--;
                    continue;
                }

                for (Visit_Result__c result : resultsByVisitNumber.get(timeSharing)) {
                    if (visitResultTypeSharingByType.containsKey(result.Result_Type__c)) {
                        Visit_Result_Type_Sharing__c resultTypeSharing = visitResultTypeSharingByType.get(result.Result_Type__c);

                        if (resultTypeSharing.Sharing_Countries__c == 'All' || (resultTypeSharing.Include_Countries__c &&
                                resultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode))) {
                            filteredResults.add(result);
                        }
                    }
                }
                break;
            }
        } catch (Exception e) {
            System.debug(e.getCause() + '\n' + e.getLineNumber());
            return filteredResults;
        }
        return filteredResults;
    }

    public static List<Visit_Result__c> getAvailableVisitResultsForReport(List<Visit_Result__c> visitResults) {
        List<Visit_Result__c> filteredResults = new List<Visit_Result__c>();
        try {
            Clinical_Trial_Profile__c ctp = getCTP(state.ctp.Id);

            String mailingCountryCode = state.pse.Participant__r.Mailing_Country_Code__c;
            visitResultTypeSharingByType = getResultTypeSharingsByType(ctp.Visit_Result_Type_Sharings__r);
            for (Visit_Result__c result : visitResults) {
                if (visitResultTypeSharingByType.containsKey(result.Result_Type__c)) {
                    Visit_Result_Type_Sharing__c resultTypeSharing = visitResultTypeSharingByType.get(result.Result_Type__c);
                    if (resultTypeSharing.Sharing_Countries__c == 'All' ||
                            (resultTypeSharing.Include_Countries__c &&
                                    resultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode))
                            ) {
                        filteredResults.add(result);
                    } else {
                        notAccessResultType.add(result.Result_Type__c);
                    }
                } else {
                    notAccessResultType.add(result.Result_Type__c);
                }
            }
            return filteredResults;
        } catch (Exception e) {
            System.debug(e.getCause() + '\n' + e.getLineNumber());
            return filteredResults;
        }
    }

    public static Set<String> getNotAccessResultType() {
        return notAccessResultType;
    }

    private static Map<String, Visit_Result_Type_Sharing__c> getResultTypeSharingsByType(
            List<Visit_Result_Type_Sharing__c> visitResultTypeSharings
    ) {
        if (visitResultTypeSharingByType == null) {
            visitResultTypeSharingByType = new Map<String, Visit_Result_Type_Sharing__c>();
            for (Visit_Result_Type_Sharing__c visitResultTypeSharing : visitResultTypeSharings) {
                visitResultTypeSharingByType.put(visitResultTypeSharing.Type__c, visitResultTypeSharing);
            }
        }

        return visitResultTypeSharingByType;
    }

    public static void updateStudySitesSharing(String ctpId, List<Id> ssIds, Boolean selectionType) {
        List<Study_Site__c> studySites = (List<Study_Site__c>) DatabaseService.query(
                new List<String>{
                        'Id', 'Visit_Results_Sharing__c'
                },
                Study_Site__c.getSObjectType(),
                'Clinical_Trial_Profile__c = \'' + ctpId + '\''
        );

        if (!studySites.isEmpty()) {
            for (Study_Site__c ss : studySites) {
                if ((ssIds.isEmpty() || String.isBlank(ssIds.get(0))) && selectionType) {
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