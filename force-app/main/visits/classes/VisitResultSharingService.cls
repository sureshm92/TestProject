/**
 * Created by Igor Malyuta on 24.06.2019.
 */

public without sharing class VisitResultSharingService {
    private static ParticipantService.ParticipantState state;
    private static Map<Id, Map<String, Visit_Result_Type_Sharing__c>> visitResultTypeSharingMapByCTP = new Map<Id, Map<String, Visit_Result_Type_Sharing__c>>();
    private static Set<String> notAccessResultType = new Set<String>();

    public static final String VITAL_RECORDTYPE = 'Vital';
    public static final String LAB_RECORDTYPE = 'Lab';
    public static final String BIOMARKER_RECORDTYPE = 'Biomarker';

    private static final String VITAL_GROUP = 'Vitals';
    private static final String BIOMARKER_GROUP = 'Biomarkers';
    private static final String LAB_GROUP = 'Labs';

    private static final String METABOLICPANEL = 'MetabolicPanel';
    private static final String HEMATOLOGY = 'Hematology';
    private static final String FASTING_LIPID_PROFILE = 'FastingLipidProfile';

    static {
        //TODO split context and service methods!!!:
        if ([SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId != null) {
            state = ParticipantService.getParticipantState();
        }
    }

    public static List<Visit_Result__c> processResults(String strVisitResultGroup) {
        if (!VisitResultsRemote.isOnStudy())
            return new List<Visit_Result__c>();
        Map<Id, Clinical_Trial_Profile__c> ctpById = new Map<Id, Clinical_Trial_Profile__c>();
        List<Patient_Visit__c> patientVisits = [
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
                        Result_Type__c,
                        RecordType.DeveloperName
                    FROM Visit_Results__r
                )
            FROM Patient_Visit__c
            WHERE Participant_Enrollment__c = :state.pe.Id AND Status__c = 'Completed'
            ORDER BY Visit_Number__c, Completed_Date__c
        ];

        return getAvailableVisitResults(patientVisits, false, ctpById, strVisitResultGroup);
    }

    public static List<Visit_Result__c> getAvailableVisitResults(
        List<Patient_Visit__c> patientVisits,
        Boolean isBatch,
        Map<Id, Clinical_Trial_Profile__c> ctpById,
        String strVisitResultGroup
    ) {
        List<Visit_Result__c> filteredResults = new List<Visit_Result__c>();
        Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType = new Map<String, Visit_Result_Type_Sharing__c>();
        String strVisitResultRecordType = '';
        if (!String.isBlank(strVisitResultGroup)) {
            strVisitResultRecordType = getVisitResultRecordTypeName(strVisitResultGroup);
        }
        try {
            String mailingCountryCode = '';
            Boolean isVisitResultAvailable = false;
            Integer timeSharing = 0;
            if (!isBatch) {
                if (!VisitResultsRemote.isVisitResultAvailable())
                    return filteredResults;

                Clinical_Trial_Profile__c ctp = getCTP(state.ctp.Id);
                visitResultTypeSharingByType = getResultTypeSharingsByType(ctp);
                mailingCountryCode = state.pe.Participant__r.Mailing_Country_Code__c;
                timeSharing =
                    patientVisits.size() - (ctp.Shareback_Availability_Timing__c.intValue());
            }

            for (Integer i = patientVisits.size() - 1; i >= 0; i--) {
                if (isBatch) {
                    timeSharing =
                        patientVisits.size() -
                        patientVisits.get(i)
                            .Participant_Enrollment__r.Clinical_Trial_Profile__r.Shareback_Availability_Timing__c.intValue();
                    visitResultTypeSharingByType = getResultTypeSharingsByType(
                        ctpById.get(
                            patientVisits.get(i).Participant_Enrollment__r.Clinical_Trial_Profile__c
                        )
                    );
                    mailingCountryCode = patientVisits.get(i)
                        .Participant_Enrollment__r.Participant__r.Mailing_Country_Code__c;
                }
                if ((i + 1) <= timeSharing) {
                    if (!isBatch)
                        filteredResults = new List<Visit_Result__c>();
                    Patient_Visit__c patientVisit = patientVisits.get(i);
                    if (
                        patientVisit.Visit_Results__r != null &&
                        !patientVisit.Visit_Results__r.isEmpty()
                    ) {
                        for (Visit_Result__c result : patientVisit.Visit_Results__r) {
                            if (
                                !isBatch &&
                                result.recordType.DeveloperName == strVisitResultRecordType
                            ) {
                                isVisitResultAvailable = true;
                            }
                            if (visitResultTypeSharingByType.containsKey(result.Result_Type__c)) {
                                Visit_Result_Type_Sharing__c resultTypeSharing = visitResultTypeSharingByType.get(
                                    result.Result_Type__c
                                );
                                if (
                                    resultTypeSharing.Sharing_Countries__c == 'All' ||
                                    (resultTypeSharing.Include_Countries__c &&
                                    resultTypeSharing.Sharing_Countries__c.contains(
                                        mailingCountryCode
                                    )) ||
                                    (!resultTypeSharing.Include_Countries__c &&
                                    !resultTypeSharing.Sharing_Countries__c.contains(
                                        mailingCountryCode
                                    ))
                                ) {
                                    filteredResults.add(result);
                                }
                            }
                        }
                        if (!isBatch && isVisitResultAvailable)
                            break;
                    }
                }
            }
        } catch (Exception e) {
            System.debug(
                'ERROR in getAvailableVisitResults(), line ' +
                e.getLineNumber() +
                ':\n\t' +
                e.getMessage()
            );
            return filteredResults;
        }
        return filteredResults;
    }

    public static List<VisitResultWithAvailableSign> getVisitResultsWithAvailableCountry(
        List<Patient_Visit__c> patientVisits,
        Id ctpId,
        String participantMailingCC,
        String strVisitResultGroup
    ) {
        Map<String, VisitResultWithAvailableSign> resultWithAvailableSignByType = new Map<String, VisitResultWithAvailableSign>();
        boolean isVisitResultAvailable = false;
        String strVisitResultRecordType = '';
        if (!String.isBlank(strVisitResultGroup)) {
            strVisitResultRecordType = getVisitResultRecordTypeName(strVisitResultGroup);
        }
        if (!VisitResultsRemote.isVisitResultAvailable())
            return resultWithAvailableSignByType.values();

        Clinical_Trial_Profile__c ctp = getCTP(ctpId);
        String mailingCountryCode = String.isNotEmpty(participantMailingCC)
            ? participantMailingCC
            : '';
        Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType = getResultTypeSharingsByType(
            ctp
        );
        //Checking if country is enabled for all visit result sharing on CTP
        for (String resultType : visitResultTypeSharingByType.keySet()) {
            Visit_Result_Type_Sharing__c typeSharing = visitResultTypeSharingByType.get(resultType);
            Boolean isCountryEnabled =
                typeSharing.Sharing_Countries__c == 'All' ||
                (typeSharing.Include_Countries__c &&
                typeSharing.Sharing_Countries__c.contains(mailingCountryCode)) ||
                (!typeSharing.Include_Countries__c &&
                !typeSharing.Sharing_Countries__c.contains(mailingCountryCode));
            resultWithAvailableSignByType.put(
                resultType,
                new VisitResultWithAvailableSign(isCountryEnabled, resultType)
            );
        }

        Integer timeSharing =
            patientVisits.size() - (ctp.Shareback_Availability_Timing__c.intValue());
        for (Integer i = patientVisits.size() - 1; i >= 0; i--) {
            if ((i + 1) <= timeSharing) {
                Patient_Visit__c patientVisit = patientVisits.get(i);
                if (
                    patientVisit.Visit_Results__r == null || patientVisit.Visit_Results__r.isEmpty()
                )
                    continue;

                for (Visit_Result__c result : patientVisit.Visit_Results__r) {
                    if (
                        !String.isBlank(strVisitResultRecordType) &&
                        result.recordType.DeveloperName == strVisitResultRecordType
                    ) {
                        isVisitResultAvailable = true;
                    }

                    Visit_Result_Type_Sharing__c resultTypeSharing = visitResultTypeSharingByType.get(
                        result.Result_Type__c
                    );
                    if (resultTypeSharing != null) {
                        VisitResultWithAvailableSign availableSign = resultWithAvailableSignByType.get(
                            resultTypeSharing.Type__c
                        );
                        if (isVisitResultAvailable) {
                            availableSign.visitResult = result;
                        }
                        resultWithAvailableSignByType.put(resultTypeSharing.Type__c, availableSign);
                    }
                }
                if (!String.isBlank(strVisitResultRecordType)) {
                    if (isVisitResultAvailable) {
                        break;
                    }
                }
            }
        }
        return resultWithAvailableSignByType.values();
    }

    public Map<Id, Map<String, Visit_Result__c>> getAvailableVisitResultsByPatientVisitIds(
        Participant_Enrollment__c pe,
        List<Patient_Visit__c> patientVisits
    ) {
        Map<Id, Map<String, Visit_Result__c>> resultMap = new Map<Id, Map<String, Visit_Result__c>>();
        Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType = getResultTypeSharingsByType(
            getCTP(pe.Clinical_Trial_Profile__c)
        );
        Boolean isAlumniParticipant = PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(
            pe.Participant_Status__c
        );
        String mailingCountryCode = pe.Participant__r.Mailing_Country_Code__c;
        //Create Set notAccessResultType which must be independent of Visit_Result__c
        for (
            Visit_Result_Type_Sharing__c resultTypeSharing : visitResultTypeSharingByType.values()
        ) {
            if (
                !(resultTypeSharing.Sharing_Countries__c == 'All' ||
                (resultTypeSharing.Include_Countries__c &&
                resultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode)) ||
                (!resultTypeSharing.Include_Countries__c &&
                !resultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode)))
            ) {
                notAccessResultType.add(resultTypeSharing.Type__c);
            }
        }
        //Populate filteredResultsByType with patient accessible Visit_Result__c based on country
        for (Patient_Visit__c patientVisit : patientVisits) {
            Map<String, Visit_Result__c> filteredResultsByType = new Map<String, Visit_Result__c>();
            if (!patientVisit.Visit_Results__r.isEmpty()) {
                Set<String> visitResultGroupSet = new Set<String>();
                if (VisitResultsService.patientVisitbyVisitGroupMap != null) {
                    visitResultGroupSet = VisitResultsService.patientVisitbyVisitGroupMap.get(
                        patientVisit.Id
                    );
                }
                for (Visit_Result__c result : patientVisit.Visit_Results__r) {
                    if (
                        visitResultTypeSharingByType.containsKey(result.Result_Type__c) &&
                        ((!isAlumniParticipant &&
                        visitResultGroupSet != null &&
                        visitResultGroupSet.size() > 0 &&
                        visitResultGroupSet.contains(result.recordType.DeveloperName)) ||
                        isAlumniParticipant)
                    ) {
                        Visit_Result_Type_Sharing__c resultTypeSharing = visitResultTypeSharingByType.get(
                            result.Result_Type__c
                        );
                        if (
                            resultTypeSharing.Sharing_Countries__c == 'All' ||
                            (resultTypeSharing.Include_Countries__c &&
                            resultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode)) ||
                            (!resultTypeSharing.Include_Countries__c &&
                            !resultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode))
                        ) {
                            filteredResultsByType.put(result.Result_Type__c, result);
                        } //else {
                        //notAccessResultType.add(result.Result_Type__c);
                        //}
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

    public Map<String, Visit_Result_Type_Sharing__c> getVisitResultTypeSharingMap(Id ctpId) {
        return getResultTypeSharingsByType(getCTP(ctpId));
    }
    public Map<Id, List<VisitReportService.VisitResultWrapper>> geAvailableVisitResultTypeMSByGroupIds(
        Participant_Enrollment__c pe,
        List<Visit_Result_GroupM__mdt> visitResultGroupMs
    ) {
        Map<Id, List<VisitReportService.VisitResultWrapper>> visitResultTypeMSByGroupIds = new Map<Id, List<VisitReportService.VisitResultWrapper>>();
        Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType = getResultTypeSharingsByType(
            getCTP(pe.Clinical_Trial_Profile__c)
        );

        for (Visit_Result_GroupM__mdt groupM : visitResultGroupMs) {
            List<VisitReportService.VisitResultWrapper> visitResultWrappers = new List<VisitReportService.VisitResultWrapper>();
            for (Visit_Result_TypeM__mdt visitResultTypeM : groupM.Visit_Result_Types__r) {
                if (visitResultTypeSharingByType.containsKey(visitResultTypeM.DeveloperName)) {
                    visitResultWrappers.add(
                        new VisitReportService.VisitResultWrapper(visitResultTypeM)
                    );
                }
            }
            visitResultWrappers.sort();
            visitResultTypeMSByGroupIds.put(groupM.Id, visitResultWrappers);
        }

        return visitResultTypeMSByGroupIds;
    }

    public static Map<String, Visit_Result_Type_Sharing__c> getResultTypeSharingsByType(
        Clinical_Trial_Profile__c ctp
    ) {
        Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType = new Map<String, Visit_Result_Type_Sharing__c>();
        List<Visit_Result_Type_Sharing__c> visitResultTypeSharings = (ctp != null
            ? ctp.Visit_Result_Type_Sharings__r
            : null);

        if (visitResultTypeSharings.isEmpty())
            return visitResultTypeSharingByType;

        if (!visitResultTypeSharingMapByCTP.containsKey(ctp.Id)) {
            for (Visit_Result_Type_Sharing__c visitResultTypeSharing : visitResultTypeSharings) {
                visitResultTypeSharingByType.put(
                    visitResultTypeSharing.Type__c,
                    visitResultTypeSharing
                );
            }
            visitResultTypeSharingMapByCTP.put(ctp.Id, visitResultTypeSharingByType);
        }
        return visitResultTypeSharingMapByCTP.get(ctp.Id);
    }

    public static void updateStudySitesSharing(
        String ctpId,
        List<Id> ssIds,
        Boolean allEnabled,
        Boolean selectionType
    ) {
        List<Study_Site__c> studySites = (List<Study_Site__c>) DatabaseService.query(
            new List<String>{ 'Id', 'Visit_Results_Sharing__c' },
            Study_Site__c.getSObjectType(),
            'Clinical_Trial_Profile__c = \'' +
            ctpId +
            '\''
        );

        if (!studySites.isEmpty()) {
            for (Study_Site__c ss : studySites) {
                if (allEnabled || (ssIds.isEmpty() && selectionType)) {
                    ss.Visit_Results_Sharing__c = true;
                } else if (!selectionType && ssIds.isEmpty()) {
                    ss.Visit_Results_Sharing__c = false;
                } else if (ssIds.contains(ss.Id)) {
                    ss.Visit_Results_Sharing__c = selectionType;
                } else {
                    if (selectionType && ss.Visit_Results_Sharing__c) {
                        ss.Visit_Results_Sharing__c = false;
                    } else if (!selectionType) {
                        ss.Visit_Results_Sharing__c = true;
                    }
                }
            }
            update studySites;
        }
    }

    public static Clinical_Trial_Profile__c disableShareback(Clinical_Trial_Profile__c ctp) {
        List<Visit_Result_Type_Sharing__c> sharings = new List<Visit_Result_Type_Sharing__c>();
        for (Visit_Result_Type_Sharing__c vr : ctp.Visit_Result_Type_Sharings__r)
            sharings.add(vr);
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
                Participant_Visit_Result_Group__c,
                Visit_Data_Shareback__c,
                CommunityTemplate__c,
                (
                    SELECT
                        Id,
                        Include_Countries__c,
                        Type__c,
                        Sharing_Countries__c,
                        Custom_Tooltip__c
                    FROM Visit_Result_Type_Sharings__r
                )
            FROM Clinical_Trial_Profile__c
            WHERE Id = :ctpId
        ];
    }

    public static Map<String, Visit_Result_Type_Sharing__c> getTypeVRSharingMap(
        Clinical_Trial_Profile__c ctp
    ) {
        Map<String, Visit_Result_Type_Sharing__c> typeVRSharingMap = new Map<String, Visit_Result_Type_Sharing__c>();
        for (Visit_Result_Type_Sharing__c vr : ctp.Visit_Result_Type_Sharings__r)
            typeVRSharingMap.put(vr.Type__c, vr);
        return typeVRSharingMap;
    }

    public static Map<String, Map<String, List<String>>> visitResultSharingByGroupAndMode() {
        VisitResultMService visitResultMService = new VisitResultMService();
        List<Visit_Result_Type_Sharing__c> visitResultTypeSharings = [
            SELECT Id, Type__c
            FROM Visit_Result_Type_Sharing__c
            WHERE Clinical_Trial_Profile__c = :state.ctp.Id
        ];
        List<String> visitResultTypeSharingNames = new List<String>();
        for (Visit_Result_Type_Sharing__c visitResultTypeSharing : visitResultTypeSharings) {
            visitResultTypeSharingNames.add(visitResultTypeSharing.Type__c);
        }
        Map<String, Map<String, List<String>>> visitResultSharingByGroupAndMode = new Map<String, Map<String, List<String>>>();
        for (String resultType : visitResultTypeSharingNames) {
            String visitResultGroup = visitResultMService.getVisitResultGroupByTypeName(resultType);
            String visitResultMode = visitResultMService.getVisitResultModeByGroupName(
                visitResultGroup
            );
            if (visitResultSharingByGroupAndMode.get(visitResultMode) == null) {
                visitResultSharingByGroupAndMode.put(
                    visitResultMode,
                    new Map<String, List<String>>()
                );
            }
            if (
                visitResultSharingByGroupAndMode.get(visitResultMode).get(visitResultGroup) == null
            ) {
                visitResultSharingByGroupAndMode.get(visitResultMode)
                    .put(visitResultGroup, new List<String>());
            }
            visitResultSharingByGroupAndMode.get(visitResultMode)
                .get(visitResultGroup)
                .add(resultType);
        }
        return visitResultSharingByGroupAndMode;
    }

    public static Map<String, Map<String, List<String>>> visitResultSharingByGroupAndModeAndCountry() {
        VisitResultMService visitResultMService = new VisitResultMService();
        List<Visit_Result_Type_Sharing__c> visitResultTypeSharings = [
            SELECT Id, Type__c, Include_Countries__c, Sharing_Countries__c
            FROM Visit_Result_Type_Sharing__c
            WHERE Clinical_Trial_Profile__c = :state.ctp.Id
        ];
        List<String> visitResultTypeSharingNames = new List<String>();
        String mailingCountryCode = state.participant.Mailing_Country_Code__c;
        for (Visit_Result_Type_Sharing__c visitResultTypeSharing : visitResultTypeSharings) {
            //country check
            Boolean isCountryEnabled =
                visitResultTypeSharing.Sharing_Countries__c == 'All' ||
                (visitResultTypeSharing.Include_Countries__c &&
                visitResultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode)) ||
                (!visitResultTypeSharing.Include_Countries__c &&
                !visitResultTypeSharing.Sharing_Countries__c.contains(mailingCountryCode));
            if (isCountryEnabled) {
                visitResultTypeSharingNames.add(visitResultTypeSharing.Type__c);
            }
        }
        Map<String, Map<String, List<String>>> visitResultSharingByGroupAndMode = new Map<String, Map<String, List<String>>>();
        for (String resultType : visitResultTypeSharingNames) {
            String visitResultGroup = visitResultMService.getVisitResultGroupByTypeName(resultType);
            String visitResultMode = visitResultMService.getVisitResultModeByGroupName(
                visitResultGroup
            );
            if (visitResultSharingByGroupAndMode.get(visitResultMode) == null) {
                visitResultSharingByGroupAndMode.put(
                    visitResultMode,
                    new Map<String, List<String>>()
                );
            }
            if (
                visitResultSharingByGroupAndMode.get(visitResultMode).get(visitResultGroup) == null
            ) {
                visitResultSharingByGroupAndMode.get(visitResultMode)
                    .put(visitResultGroup, new List<String>());
            }
            visitResultSharingByGroupAndMode.get(visitResultMode)
                .get(visitResultGroup)
                .add(resultType);
        }
        return visitResultSharingByGroupAndMode;
    }

    private static String getVisitResultRecordTypeName(String strVisitResultGroup) {
        String strVisitResultRecordType = '';
        if (!String.isBlank(strVisitResultGroup)) {
            if (strVisitResultGroup.equals(VITAL_GROUP)) {
                strVisitResultRecordType = VITAL_RECORDTYPE;
            } else if (
                strVisitResultGroup.equals(METABOLICPANEL) ||
                strVisitResultGroup.equals(HEMATOLOGY) ||
                strVisitResultGroup.equals(FASTING_LIPID_PROFILE) ||
                strVisitResultGroup.equals(LAB_GROUP)
            ) {
                strVisitResultRecordType = LAB_RECORDTYPE;
            } else {
                strVisitResultRecordType = BIOMARKER_RECORDTYPE;
            }
        }
        return strVisitResultRecordType;
    }

    public class VisitResultWithAvailableSign {
        public Visit_Result__c visitResult;
        public String resultType;
        public Boolean isCountryEnabled;

        public VisitResultWithAvailableSign(Boolean isCountryEnabled, String resultType) {
            this(null, isCountryEnabled);
            this.resultType = resultType;
        }

        public VisitResultWithAvailableSign(Visit_Result__c visitResult, Boolean isCountryEnabled) {
            this.visitResult = visitResult;
            if (visitResult != null)
                this.resultType = visitResult.Result_Type__c;
            this.isCountryEnabled = isCountryEnabled;
        }
    }
}
