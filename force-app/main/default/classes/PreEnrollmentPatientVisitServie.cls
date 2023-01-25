/**
 * @description       : This class with Create the Pre Enrollment Patient Visits for the Participant Enrollment present
 *                      in Pre Enrollment status after checking Pre Enrollment toggles are ON and Travel Vendor is configured for the
 *                      Study Site Of the participant and no pre enrollment Patient Visit is created for them.
 * @author            : Krishna Mahto
 * @group             : IQVIA Patient Portal
 * @last modified on  : 03-05-2022
 * @last modified by  : Krishna Mahto
 **/
public inherited sharing class PreEnrollmentPatientVisitServie {
    public static boolean bypassPatientVisitUpdFromBatch = false;

    /**
     * @description: This is the main method to create the Pre enrollment Visits aftert checking the eligibility of PERs.
     * @author Krishna Mahto
     * @param peIdInPreEnrollmentStatusStudySiteMap
     **/
    public static void processPreEnrollmentPatientVisits(
        Map<Id, Id> peIdInPreEnrollmentStatusStudySiteMap
    ) {
        Map<Id, Participant_Enrollment__c> peWithCTPPreEnrollConsentIsOnMap = new Map<Id, Participant_Enrollment__c>();
        Map<Id, Participant_Enrollment__c> peEligibilityQualified = new Map<Id, Participant_Enrollment__c>();
        List<Patient_Visit__c> patentientVisitsToInsert = new List<Patient_Visit__c>();

        //Fetch Participant Enrollments with CPT toogle datas.
        peWithCTPPreEnrollConsentIsOnMap = getPreEnrollToggleDatafromCTPforPERs(
            peIdInPreEnrollmentStatusStudySiteMap.Keyset()
        );
        if (
            peWithCTPPreEnrollConsentIsOnMap != null && !peWithCTPPreEnrollConsentIsOnMap.isEmpty()
        ) {
            //check Pre Enrollment Patient Visit Creation eligibility.
            peEligibilityQualified = checkPreEnrollmentVisitEligibility(
                peWithCTPPreEnrollConsentIsOnMap
            );
        }
        if (peEligibilityQualified != null && !peEligibilityQualified.isEmpty()) {
            //Create Pre Enrollment patient Visits record data.
            patentientVisitsToInsert = preparePreEnrollmentVisits(peWithCTPPreEnrollConsentIsOnMap);
        }
        //Insert Pre Enrollment patient Visits.
        if (patentientVisitsToInsert != null && !patentientVisitsToInsert.isEmpty()) {
            insert patentientVisitsToInsert;
        }
    }

    /**
     * @description: This method will return the query results from PER.
     * @author Krishna Mahto
     * @param peIdInPreEnrollmentStatusStudySiteMap
     * @return Map<Id, Participant_Enrollment__c>
     **/
    public static Map<Id, Participant_Enrollment__c> getPreEnrollToggleDatafromCTPforPERs(
        Set<Id> peIds
    ) {
        //Fetch the Participant Enrollments where any of the Pre Enrollment Toggles is on under study configuration at CTP.
        Map<Id, Participant_Enrollment__c> peWithCTPPreEnrollConsentIsOnMap = new Map<id, Participant_Enrollment__c>(
            [
                SELECT
                    Id,
                    Study_Site__c,
                    Initial_Visit_Scheduled_DateTime__c,
                    Initial_visit_occurred_flag__c,
                    Initial_visit_occurred_date__c,
                    Participant_Status__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Clinical_Trial_Profile__r.Received_Until_Consent_Is_Available__c,
                    Clinical_Trial_Profile__r.Enrolled_Or_Randomized_Consent_Available__c
                FROM Participant_Enrollment__c
                WHERE
                    Id IN :peIds
                    AND (((Clinical_Trial_Profile__r.Received_Until_Consent_Is_Available__c = TRUE
                    OR Clinical_Trial_Profile__r.Enrolled_Or_Randomized_Consent_Available__c = TRUE)
                    AND Clinical_Trial_Profile__r.CommunityTemplate__c != 'PatientPortal')
                    OR (Clinical_Trial_Profile__r.CommunityTemplate__c = 'PatientPortal'
                    AND Clinical_Trial_Profile__r.Is_Program__c = FALSE
                    AND Clinical_Trial_Profile__r.Initial_Visit_required__c = TRUE))
            ]
        );
        return peWithCTPPreEnrollConsentIsOnMap;
    }

    /**
     * @description: This method will check the eligibility of Participant Enrollment to create Pre Enrollment Visit.
     * @author: Krishna Mahto
     * @param: peWithCTPPreEnrollConsentIsOnMap
     * @return: Map<Id, Participant_Enrollment__c>
     **/
    public static Map<Id, Participant_Enrollment__c> checkPreEnrollmentVisitEligibility(
        Map<Id, Participant_Enrollment__c> peWithCTPPreEnrollConsentIsOnMap
    ) {
        Set<Id> studySiteWithTravelVendor = new Set<id>();
        List<Patient_Visit__c> existingPreEnrollPatientVisits = new List<Patient_Visit__c>();
        Set<Id> studySiteIdSet = new Set<Id>();

        //Bypass below code if this method is being called from the Batch class(which creates Patient visits for Existing Participants)
        //Batch is already passing the PER where there is no Pre Enrollment Patient Visit.
        if (!bypassPatientVisitUpdFromBatch) {
            //Fetch the Patient visits if it is already created for any of the Participant enrollment.
            existingPreEnrollPatientVisits = fetchPreEnrollmentPatientVisits(
                peWithCTPPreEnrollConsentIsOnMap.keySet()
            );

            if (
                existingPreEnrollPatientVisits != null && !existingPreEnrollPatientVisits.isEmpty()
            ) {
                //Update the Status of Pre Enrollment Visits to completed
                updatePreEnrollmentVisitAsCompleted(
                    existingPreEnrollPatientVisits,
                    peWithCTPPreEnrollConsentIsOnMap
                );
                //Bypass the participant Enrollment for which Pre Enrollment Visit is already created.
                for (Patient_Visit__c pv : existingPreEnrollPatientVisits) {
                    if (
                        peWithCTPPreEnrollConsentIsOnMap.keySet()
                            .contains(pv.Participant_Enrollment__c)
                    ) {
                        peWithCTPPreEnrollConsentIsOnMap.remove(pv.Participant_Enrollment__c);
                    }
                }
            }
        }

        //Store the Study Site Ids for each PERs in a Set.
        for (Participant_Enrollment__c pe : peWithCTPPreEnrollConsentIsOnMap.Values()) {
            if (pe.Clinical_Trial_Profile__r.CommunityTemplate__c != 'PatientPortal') {
                studySiteIdSet.Add(pe.Study_Site__c);
            }
        }
        //Fetch the Travel Vendor Setting for the study sites of each Participant Enrollments.
        list<TravelVendorSettings__c> travelVendorSetting = [
            SELECT id, Study_Site__c, TravelVendor__c
            FROM TravelVendorSettings__c
            WHERE Study_Site__c IN :studySiteIdSet
        ];
        for (TravelVendorSettings__c tvs : travelVendorSetting) {
            studySiteWithTravelVendor.Add(tvs.Study_Site__c);
        }

        //Remove the Participant Enrollment from the map if  traval Vendor is configured not for Study sites for that PER.
        for (Participant_Enrollment__c pe : peWithCTPPreEnrollConsentIsOnMap.Values()) {
            if (
                !studySiteWithTravelVendor.contains(pe.Study_Site__c) &&
                pe.Clinical_Trial_Profile__r.CommunityTemplate__c != 'PatientPortal'
            ) {
                peWithCTPPreEnrollConsentIsOnMap.remove(pe.Id);
            }

            //Handle PER based on the Pre Enrollment Toggles on/Off and PER status for creating Pre Enrollment Patient Visits.
            boolean ignorePER = handlePreEnrollVisitForPreConsetToggles(pe);
            if (ignorePER) {
                peWithCTPPreEnrollConsentIsOnMap.remove(pe.Id);
            }
        }

        return peWithCTPPreEnrollConsentIsOnMap;
    }

    /**
     * @description: This method will return the Pre Enrollment patient Visits to be created for the Participant which are in Pre enrollment Status.
     * @author: Krishna Mahto
     * @param: peWithCTPPreEnrollConsentIsOnMap
     * @return: List<Patient_Visit__c>
     **/
    public static List<Patient_Visit__c> preparePreEnrollmentVisits(
        Map<Id, Participant_Enrollment__c> peWithCTPPreEnrollConsentIsOnMap
    ) {
        List<Patient_Visit__c> patientVisitsToInsert = new List<Patient_Visit__c>();
        Map<Id, Patient_Visit__c> peIdPatientVisitMap = new Map<Id, Patient_Visit__c>();
        Set<Id> participantEnrollmentId = new Set<Id>();
        List<Visit__c> preEnrollVisit = new List<Visit__c>();
        String preEnrollmentVisitPlanName = label.Pre_Enrollment_Visit_Plan;
        //Fetch the Pre Enrollment Visit Plan.
        List<Visit_Plan__c> PreEnrollVisitPlan = [
            SELECT
                Id,
                (
                    SELECT Id, Name, Visit_Number__c, Visit_Schedule__c, Patient_Portal_Name__c
                    FROM Visits__r
                )
            FROM Visit_Plan__c
            WHERE Name = :preEnrollmentVisitPlanName AND Is_Pre_Enrollment_Visit_Plan__c = TRUE
        ];
        if (!PreEnrollVisitPlan.isEmpty()) {
            preEnrollVisit = PreEnrollVisitPlan.get(0).Visits__r;

            //Prepare the list of pre enrollment patient Visit record data for each participant Enrollments.
            for (Participant_Enrollment__c pe : peWithCTPPreEnrollConsentIsOnMap.Values()) {
                patientVisitsToInsert.Add(
                    PatientVisitService.createInitialVisit(preEnrollVisit[0], pe)
                );
            }
        }

        return patientVisitsToInsert;
    }

    /**
     * @description: This method will return the existing Pre Enrollment Patient Visit for the PER.
     * @author: Krishna Mahto
     * @param perIds
     * @return List<Patient_Visit__c>
     **/
    public static List<Patient_Visit__c> fetchPreEnrollmentPatientVisits(Set<Id> perIds) {
        //Check if the pre Enrollment Visit is already created for the Participant Enrollments.
        List<Patient_Visit__c> existingPreEnrollPatientVisits = new List<Patient_Visit__c>();
        String preEnrollmentVisitPlanName = label.Pre_Enrollment_Visit_Plan;

        existingPreEnrollPatientVisits = [
            SELECT
                id,
                Status__c,
                Participant_Enrollment__c,
                Visit__r.Visit_Plan__r.Id,
                Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Patient_Visit__c
            WHERE
                Participant_Enrollment__c IN :perIds
                AND Visit__r.Visit_Plan__r.Name = :preEnrollmentVisitPlanName
                AND Is_Pre_Enrollment_Patient_Visit__c = TRUE
        ];

        return existingPreEnrollPatientVisits;
    }

    /**
     * @description: This method will return true if PER needs to be ignore or false if PER needs to be considered for Pre Enrollment Visit Creation
     *               based of Pre consent toggle On/OFF and PER status.
     * @author Krishna Mahto
     * @param pe
     * @return Boolean
     **/
    public static Boolean handlePreEnrollVisitForPreConsetToggles(Participant_Enrollment__c pe) {
        boolean ignorePER = false;
        boolean preConcentToggle = pe.Clinical_Trial_Profile__r.Received_Until_Consent_Is_Available__c;
        boolean enrollRandomizeConsentToggle = pe.Clinical_Trial_Profile__r.Enrolled_Or_Randomized_Consent_Available__c;
        boolean isPatientPortalNew = pe.Clinical_Trial_Profile__r.CommunityTemplate__c ==
            'PatientPortal'
            ? true
            : false;

        if (
            isPatientPortalNew &&
            !PEStatusState.PE_STATUS_GROUP_PRE_ENROLLMENT.contains(pe.Participant_Status__c)
        ) {
            ignorePER = true;
            return ignorePER;
        } else if (preConcentToggle && enrollRandomizeConsentToggle) {
            //If Both "Pre-consent" and "Consent through Enrolled/Randomized" toggles are On at Visit Configuration at CTP.
            if (!PEStatusState.PE_STATUS_GROUP_PRE_ENROLLMENT.contains(pe.Participant_Status__c)) {
                ignorePER = true;
            }
        } else if (preConcentToggle && !enrollRandomizeConsentToggle) {
            //If "Pre-consent" toggles is on and "Consent through Enrolled/Randomized" toggles is Off at Visit Configuration at CTP.
            if (
                !PEStatusState.PE_STATUS_GROUP_FOR_PRE_CONSENT_TOGGLE.contains(
                    pe.Participant_Status__c
                )
            ) {
                ignorePER = true;
            }
        } else if (!preConcentToggle && enrollRandomizeConsentToggle) {
            //If "Pre-consent" toggles is Off and "Consent through Enrolled/Randomized" toggles is On at Visit Configuration at CTP.
            if (
                !PEStatusState.PE_STATUS_GROUP_FOR_CONSENT_ENROLL_RANDMZ_TOGGLE.contains(
                    pe.Participant_Status__c
                )
            ) {
                ignorePER = true;
            }
        }

        return ignorePER;
    }

    /**
     * @description: This method will updated the Status of Pre Enrollment Visits to Completed depending upon the Pre Enrollment Toggle On/Off at CTP
     *               and participant Enrollment status values.
     * @author: Krisha Mahto
     * @param: preEnrollPatientVisits
     * @param: peMap
     **/
    public static void updatePreEnrollmentVisitAsCompleted(
        list<Patient_Visit__c> preEnrollPatientVisits,
        Map<Id, Participant_Enrollment__c> peMap
    ) {
        list<Patient_Visit__c> preEnrollPatientVisitsToUpdate = new List<Patient_Visit__c>();
        for (Patient_Visit__c pv : preEnrollPatientVisits) {
            Participant_Enrollment__c pe = peMap.get(pv.Participant_Enrollment__c);
            boolean preConcentToggle = pe.Clinical_Trial_Profile__r.Received_Until_Consent_Is_Available__c;
            boolean enrollRandomizeConsentToggle = pe.Clinical_Trial_Profile__r.Enrolled_Or_Randomized_Consent_Available__c;
            boolean isPatientPortalNew = pe.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                'PatientPortal'
                ? true
                : false;
            if (isPatientPortalNew) {
                //ignore these records
            } else if (preConcentToggle && !enrollRandomizeConsentToggle) {
                //If "Pre-consent" toggles is on and "Consent through Enrolled/Randomized" toggles is Off at Visit Configuration at CTP.
                if (
                    PEStatusState.PE_STATUS_GROUP_FOR_CONSENT_ENROLL_RANDMZ_TOGGLE.contains(
                        pe.Participant_Status__c
                    )
                ) {
                    pv.Status__c = 'Completed';
                    preEnrollPatientVisitsToUpdate.Add(pv);
                }
            } else if (!preConcentToggle && enrollRandomizeConsentToggle) {
                //If "Pre-consent" toggles is Off and "Consent through Enrolled/Randomized" toggles is On at Visit Configuration at CTP.
                if (
                    pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS ||
                    pe.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS
                ) {
                    pv.Status__c = 'Completed';
                    preEnrollPatientVisitsToUpdate.Add(pv);
                }
            } else if (preConcentToggle && enrollRandomizeConsentToggle) {
                //If Both "Pre-consent" and "Consent through Enrolled/Randomized" toggles are On at Visit Configuration at CTP.
                if (
                    pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS ||
                    pe.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS
                ) {
                    pv.Status__c = 'Completed';
                    preEnrollPatientVisitsToUpdate.Add(pv);
                }
            }
        }
        if (preEnrollPatientVisitsToUpdate != null && !preEnrollPatientVisitsToUpdate.isEmpty()) {
            update preEnrollPatientVisitsToUpdate;
        }
    }
}
