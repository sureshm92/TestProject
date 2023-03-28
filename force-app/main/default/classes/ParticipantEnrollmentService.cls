/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantEnrollmentService {
    // Medical Record Review statuses
    public static final String MRR_STATUS_PASS = 'Pass';
    public static final String MRR_STATUS_FAIL = 'Fail';
    public static final String MRR_STATUS_PENDING = 'Pending';
    public static final String MRR_STATUS_NOT_REQUIRED = 'Not Required';
    public static final List<String> MRR_COMPLETION_STATUSES = new List<String>{
        MRR_STATUS_FAIL,
        MRR_STATUS_PASS
    };
    // Pre Eligibility Screening statuses
    public static final String PES_STATUS_PASS = 'Pass';
    public static final String PES_STATUS_FAIL = 'Fail';
    public static final String PES_STATUS_PENDING = 'Pending';
    public static final String PES_STATUS_NOT_REQUIRED = 'Not Required';
    public static final List<String> PES_COMPLETION_STATUSES = new List<String>{
        PES_STATUS_FAIL,
        PES_STATUS_PASS
    };
    // Participant statuses
    public static final String PART_STATUS_PENDING_REFERRAL = 'Pending Referral';
    public static final String PART_STATUS_FAILED_REVIEW = 'Failed Review';
    public static final String PART_STATUS_FAILED_REFERRAL = 'Failed Referral';
    public static final String PART_STATUS_EXCLUDED_FROM_REFERRING = 'Excluded from Referring';
    public static final String PART_STATUS_RECEIVED = 'Received';
    public static final String PART_STATUS_EXCLUDE_FROM_REFERRING_RP = 'Exclude from referring';
    public static final String PART_STATUS_INCLUDE_FROM_REFERRING_RP = 'Include for referring';

    // Non referral reason
    public static final String NON_REF_REASON_STATUS_NOT_INTERESTED = 'No Longer Interested';
    public static final String NON_REF_REASON_STATUS_FAILED_PE_SCREENING = 'Failed Pre-Eligibility Screening';
    public static final String NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED = 'Had Discussion, Not Interested';
    //Referral Source
    public static final String PE_REFERRAL_SOURCE_PATIENT = 'Patient';
    public static final String PE_REFERRAL_SOURCE_HCP = 'HCP';
    public static final String PE_REFERRAL_SOURCE_PI = 'PI';
    public static final String PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT = 'Digital Recruitment';
    public static final String PE_REFERRAL_SOURCE_HCP_PRESCREEN = 'HCP Prescreen Log';
    public static final String PE_REFERRAL_SOURCE_EPR = 'ePR';
    public static final String PE_REFERRAL_SOURCE_ACOE = 'ACOE';
    public static final String PE_REFERRAL_SOURCE_3RD_PARTY = '3rd_Party';
    public static final String PE_REFERRAL_SOURCE_Ciitizen = 'Ciitizen'; //REF-2819

    //Filter Data Wrapper Fields
    public static final String STUDIES_FILTER_DATA_FIELD = 'studies';
    public static final String STUDY_SITES_FILTER_DATA_FIELD = 'studySites';
    public static final String STATUSES_FILTER_DATA_FIELD = 'statuses';

    public static final String PE_SOURCE_TYPE_PI = 'Principal Investigator';
    public static final String PE_SOURCE_TYPE_RP = 'Referring Provider';
    public static final String PE_SOURCE_TYPE_EPR = 'Digital Recruitment';
    public static final String PE_SOURCE_TYPE_Ciitizen = 'Ciitizen'; //REF-2819

    //Map <SObject value field; SObject label field> for interdependent filter data for every Filter Data Filter Map
    public static final Map<String, Map<String, String>> FILTER_FIELD_MAP = new Map<String, Map<String, String>>{
        STUDIES_FILTER_DATA_FIELD => new Map<String, String>{
            'Study_Site__r.Clinical_Trial_Profile__c' => 'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c'
        },
        STUDY_SITES_FILTER_DATA_FIELD => new Map<String, String>{
            'Study_Site__c' => 'Study_Site__r.Name'
        },
        STATUSES_FILTER_DATA_FIELD => new Map<String, String>{
            'Participant_Status__c' => 'Participant_Status__c'
        }
    };

    private static ParticipantEnrollmentService instance;

    public static ParticipantEnrollmentService getInstance() {
        if (instance == null)
            instance = new ParticipantEnrollmentService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (ParticipantEnrollmentService) Test.createStub(
            ParticipantEnrollmentService.class,
            stubProvider
        );
    }

    public List<Participant_Enrollment__c> getPEnrolmentsCommonCustomFieldsImpl(
        String userMode,
        List<String> customFields,
        String filter
    ) {
        return getPEnrolmentsCommonCustomFieldsImpl(userMode, customFields, filter, null);
    }

    /** Needs review Start */
    public List<Participant_Enrollment__c> getPEnrolmentsCommonCustomFieldsImpl(
        String userMode,
        List<String> customFields,
        String filter,
        String delegateId
    ) {
        return getPEnrolmentsCommonCustomFieldsImpl(
            userMode,
            customFields,
            filter,
            delegateId,
            true
        );
    }

    public List<Participant_Enrollment__c> getPEnrolmentsCommonCustomFieldsImpl(
        String userMode,
        List<String> customFields,
        String filter,
        String delegateId,
        Boolean translationNeeded
    ) {
        String defaultFilter = getDefaultFilter(userMode, delegateId, filter);
        //if(filter != null) defaultFilter += ' ' + filter;
        List<Participant_Enrollment__c> peList = DatabaseService.query(
            customFields,
            Participant_Enrollment__c.getSObjectType(),
            defaultFilter
        );
        if (userMode != CommunityService.USER_MODE_PARTICIPANT && translationNeeded)
            TranslateHelper.translate(peList);
        return peList;
    }
    /** Needs review End */
    public Participant_Enrollment__c getParticipantEnrollmentImpl(Id peId, String userMode) {
        return getParticipantEnrollmentImpl(peId, userMode, null);
    }

    public Participant_Enrollment__c getParticipantEnrollmentImpl(
        Id peId,
        String userMode,
        String delegateId
    ) {
        List<Participant_Enrollment__c> peList = getPEnrolmentsCommon(
            userMode,
            ' AND Id=\'' +
            peId +
            '\'',
            delegateId
        );
        if (peList.size() > 0)
            return peList[0];
        return null;
    }

    public Participant_Enrollment__c getParticipantEnrollmentImpl(
        Id peId,
        String userMode,
        String delegateId,
        List<String> fieldNames
    ) {
        List<Participant_Enrollment__c> peList = getPEnrolmentsCommonCustomFieldsWithTranslation(
            userMode,
            fieldNames,
            ' AND Id=\'' +
            peId +
            '\'',
            delegateId
        );
        if (peList.size() > 0)
            return peList[0];
        return null;
    }

    public Participant_Enrollment__c createParticipantEnrollmentImpl(
        Clinical_Trial_Profile__c trial,
        HCP_Enrollment__c hcpEnrollment,
        String participantId
    ) {
        String mrrStatus = MRR_STATUS_NOT_REQUIRED;
        if (trial.Link_to_Medical_Record_Review__c != null)
            mrrStatus = MRR_STATUS_PENDING;

        String pesStatus = PES_STATUS_NOT_REQUIRED;
        if (trial.Link_to_Pre_screening__c != null)
            pesStatus = PES_STATUS_PENDING;

        Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
            Pre_screening_Status__c = pesStatus,
            Medical_Record_Review_Status__c = mrrStatus,
            Patient_ID__c = participantId,
            Referral_Source__c = PE_REFERRAL_SOURCE_HCP
        );

        if (hcpEnrollment != null) {
            participantEnrollment.HCP__c = hcpEnrollment.Id;
            participantEnrollment.HCP__r = hcpEnrollment;
            participantEnrollment.PI_Contact__c = hcpEnrollment.Study_Site__r.Principal_Investigator__c;
            participantEnrollment.Study_Site__c = hcpEnrollment.Study_Site__c;
        }
        //insert participantEnrollment;
        return participantEnrollment;
    }

    public List<Participant_Enrollment__c> getPendingParticipantEnrollmentsImpl(
        Id trialId,
        Id hcpEnrollmentId
    ) {
        return getPendingParticipantEnrollmentsImpl(trialId, hcpEnrollmentId, null);
    }

    public List<Participant_Enrollment__c> getPendingParticipantEnrollmentsImpl(
        Id trialId,
        Id hcpEnrollmentId,
        String delegateId
    ) {
        return getPEnrolmentsCommon(
            CommunityService.USER_MODE_HCP,
            ' AND Clinical_Trial_Profile__c=\'' +
            trialId +
            '\'' +
            (hcpEnrollmentId != null ? ' AND HCP__c =\'' + hcpEnrollmentId + '\'' : '') +
            ' AND Participant_Status__c = \'' +
            PART_STATUS_PENDING_REFERRAL +
            '\'',
            delegateId
        );
    }

    // Static facade: --------------------------------------------------------------------------------------------------

    public static Participant_Enrollment__c findParticipantEnrollment(
        HCP_Enrollment__c hcpEnrollment,
        String participantId
    ) {
        //find all participant enrollments for this patientId, clinic and trial
        List<Participant_Enrollment__c> participantEnrollments = [
            SELECT
                Id,
                HCP__c,
                Name,
                Patient_ID__c,
                Medical_Record_Review_Status__c,
                Pre_screening_Status__c,
                Participant_Status__c,
                Participant_Name__c,
                Participant_Surname__c,
                Referral_Source__c,
                Screening_ID__c
            FROM Participant_Enrollment__c
            WHERE
                Study_Site__c != NULL
                AND HCP__r.HCP_Contact__r.AccountId = :hcpEnrollment.HCP_Contact__r.AccountId
                AND HCP__r.Study_Site__r.Clinical_Trial_Profile__c = :hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__c
                AND Patient_ID__c = :participantId
        ];
        if (participantEnrollments.size() > 0)
            return participantEnrollments[0];
        return null;
    }

    public static List<Participant_Enrollment__c> getParticipantEnrollmentsForParticipant() {
        return getPEnrolmentsCommon(CommunityService.USER_MODE_PARTICIPANT, null);
    }

    public static Participant_Enrollment__c getParticipantEnrollment(Id peId, String userMode) {
        return getParticipantEnrollment(peId, userMode, null);
    }

    public static Participant_Enrollment__c getParticipantEnrollment(
        Id peId,
        String userMode,
        String delegateId,
        List<String> fieldNames
    ) {
        return getInstance().getParticipantEnrollmentImpl(peId, userMode, delegateId, fieldNames);
    }

    public static Participant_Enrollment__c getParticipantEnrollment(
        Id peId,
        String userMode,
        String delegateId
    ) {
        return getInstance().getParticipantEnrollmentImpl(peId, userMode, delegateId);
    }

    public static List<Participant_Enrollment__c> getPendingParticipantEnrollments(
        Id trialId,
        Id hcpEnrollmentId
    ) {
        return getPendingParticipantEnrollments(trialId, hcpEnrollmentId, null);
    }

    public static List<Participant_Enrollment__c> getPendingParticipantEnrollments(
        Id trialId,
        Id hcpEnrollmentId,
        String delegateId
    ) {
        return getInstance()
            .getPendingParticipantEnrollmentsImpl(trialId, hcpEnrollmentId, delegateId);
    }
    

    public static Map<Id, Integer> getPreScreeningsAllByTrial(Id clinicId) {
        return getPECountMapByTrialsForPI(
            'AND Pre_screening_Status__c IN (\'' +
            String.join(PES_COMPLETION_STATUSES, '\', \'') +
            '\')' +
            ' AND HCP__r.HCP_Contact__r.AccountId = \'' +
            clinicId +
            '\' '
        );
    }

    public static Map<Id, Integer> getPreScreeningsPassedByTrial(Id clinicId) {
        return getPECountMapByTrialsForPI(
            'AND Pre_screening_Status__c = \'' +
            PES_STATUS_PASS +
            '\' ' +
            ' AND HCP__r.HCP_Contact__r.AccountId = \'' +
            clinicId +
            '\' '
        );
    }

    public static Map<Id, Integer> getMRRAllByTrial(Id clinicId) {
        return getPECountMapByTrialsForPI(
            'AND Medical_Record_Review_Status__c IN (\'' +
            String.join(MRR_COMPLETION_STATUSES, '\', \'') +
            '\')' +
            ' AND HCP__r.HCP_Contact__r.AccountId = \'' +
            clinicId +
            '\' '
        );
    }

    public static Map<Id, Integer> getMRRPassedByTrial(Id clinicId) {
        return getPECountMapByTrialsForPI(
            'AND Medical_Record_Review_Status__c = \'' +
            MRR_STATUS_PASS +
            '\'' +
            ' AND HCP__r.HCP_Contact__r.AccountId = \'' +
            clinicId +
            '\' '
        );
    }

    public static Map<Id, Integer> getPreScreeningsAllByTrial() {
        return getPECountMapByTrialsForPI(
            'AND Pre_screening_Status__c != \'' +
            PES_STATUS_NOT_REQUIRED +
            '\''
        );
    }

    public static Map<Id, Integer> getPreScreeningsPassedByTrial() {
        return getPECountMapByTrialsForPI(
            'AND Pre_screening_Status__c = \'' +
            PES_STATUS_PASS +
            '\''
        );
    }

    public static Map<Id, Integer> getMRRAllByTrial() {
        return getPECountMapByTrialsForPI(
            'AND Medical_Record_Review_Status__c != \'' +
            MRR_STATUS_NOT_REQUIRED +
            '\''
        );
    }

    public static Map<Id, Integer> getMRRPassedByTrial() {
        return getPECountMapByTrialsForPI(
            'AND Medical_Record_Review_Status__c = \'' +
            MRR_STATUS_PASS +
            '\''
        );
    }

    public static Map<Id, Integer> getReferredByTrial() {
        return getPECountMapByTrialsForPI(
            'AND Participant_Status__c IN  (\'' +
            String.join(new List<String>(PEStatusState.ALL_USED_STATUSES), '\',\'') +
            '\')'
        );
    }

    public static Map<Id, Integer> getPECountMapByTrialsForPI(String filter) {
        String query =
            'SELECT Study_Site__r.Clinical_Trial_Profile__c trialId, count(Name) amount ' +
            ' FROM Participant_Enrollment__c ' +
            ' WHERE Study_Site__c != NULL AND ' +
            getUserModeFilter(CommunityService.USER_MODE_PI);
        if (filter != null) {
            query += filter;
        }
        query += ' GROUP BY Study_Site__r.Clinical_Trial_Profile__c';
        Map<Id, Integer> resMap = new Map<Id, Integer>();
        for (AggregateResult ar : Database.query(query)) {
            resMap.put((Id) ar.get('trialId'), (Integer) ar.get('amount'));
        }
        return resMap;
    }

    public static Integer getPEnrolmentsCount(
        List<Id> trialIds,
        String userMode,
        List<String> statuses
    ) {
        return getPEnrolmentsCount(trialIds, userMode, statuses, null, null);
    }

    public static Integer getPEnrolmentsCount(
        List<Id> trialIds,
        String userMode,
        List<String> statuses,
        String delegateId
    ) {
        return getPEnrolmentsCount(trialIds, userMode, statuses, null, delegateId);
    }

    public static Integer getPEnrolmentsCount(String userMode, String status) {
        return getPEnrolmentsCount(null, userMode, new List<String>{ status }, null, null);
    }

    public static Integer getPEnrolmentsCount(String userMode, String status, String delegateId) {
        return getPEnrolmentsCount(null, userMode, new List<String>{ status }, null, delegateId);
    }

    public static Integer getPEnrolmentsCount(String userMode, List<String> statuses) {
        return getPEnrolmentsCount(null, userMode, statuses, null, null);
    }

    public static Integer getPEnrolmentsCount(
        String userMode,
        List<String> statuses,
        String delegateId
    ) {
        return getPEnrolmentsCount(null, userMode, statuses, null, delegateId);
    }

    public static Integer getPEnrolmentsCount(
        List<Id> trialIds,
        String userMode,
        String status,
        String reason
    ) {
        return getPEnrolmentsCount(
            trialIds,
            userMode,
            new List<String>{ status },
            new List<String>{ reason },
            null
        );
    }

    public static Integer getPEnrolmentsCount(
        List<Id> trialIds,
        String userMode,
        String status,
        String reason,
        String delegateId
    ) {
        return getPEnrolmentsCount(
            trialIds,
            userMode,
            new List<String>{ status },
            new List<String>{ reason },
            delegateId
        );
    }

    public static Integer getPEnrolmentsCount(
        List<Id> trialIds,
        String userMode,
        List<String> statuses,
        List<String> reasons
    ) {
        return getPEnrolmentsCount(trialIds, userMode, statuses, reasons, null);
    }

    public static Integer getPEnrolmentsCount(
        List<Id> trialIds,
        String userMode,
        List<String> statuses,
        List<String> reasons,
        String delegateId
    ) {
        String filter =
            ' AND Participant_Status__c IN (\'' +
            String.join(statuses, '\',\'') +
            '\')';
        if (trialIds != null)
            filter +=
                ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' +
                String.join(trialIds, '\',\'') +
                '\') ';
        if (reasons != null)
            filter += ' AND Non_Referral_Reason__c IN (\'' + String.join(reasons, '\',\'') + '\')';
        return getPEnrolmentsCountCommon(userMode, filter, delegateId);
    }

    public static Integer getPEnrolmentsCountCommon(String userMode, String filter) {
        return getPEnrolmentsCountCommon(userMode, filter, null);
    }

    public static Integer getPEnrolmentsCountCommon(
        String userMode,
        String filter,
        String delegateId
    ) {
        String query =
            ' SELECT count() ' +
            ' FROM Participant_Enrollment__c ' +
            ' WHERE Study_Site__c != NULL AND ' +
            getUserModeFilter(userMode, delegateId);
        query += filter;
        System.debug('PE QUERY: ' + query);
        return Database.countQuery(query);
    }

    public static List<Participant_Enrollment__c> getPEnrolmentsByStatus(
        String userMode,
        List<String> statuses,
        Integer recordsLimit
    ) {
        return getPEnrolmentsByStatus(userMode, statuses, recordsLimit, null);
    }

    public static List<Participant_Enrollment__c> getPEnrolmentsByStatus(
        String userMode,
        List<String> statuses,
        Integer recordsLimit,
        String delegateId
    ) {
        String filter =
            ' AND Participant_Status__c IN (\'' +
            String.join(statuses, '\',\'') +
            '\') ';
        if (recordsLimit != null)
            filter += ' LIMIT ' + recordsLimit;
        return getPEnrolmentsCommon(userMode, filter, delegateId);
    }

    public static List<Participant_Enrollment__c> getPEEnrollmentsByPI(String userMode, Id piId) {
        String filter =
            ' Study_Site__c != NULL AND Study_Site__r.Principal_Investigator__c = \'' +
            piId +
            '\'';
        List<Participant_Enrollment__c> peList = DatabaseService.query(
            PE_COMMON_FIELDS, //commented by sumit s
            //PE_COMMON_CUSTOM_FIELDS, // added by sumits dashboard
            Participant_Enrollment__c.getSObjectType(),
            filter
        );
        return peList;
    }

    public static List<Participant_Enrollment__c> getReferredPEList(
        String userMode,
        String filter
    ) {
        if (filter == null)
            filter = '';
        filter +=
            ' AND Participant_Status__c IN (\'' +
            String.join(new List<String>(PEStatusState.ALL_USED_STATUSES), '\',\'') +
            '\') ';
        return getPEnrolmentsCommon(userMode, filter);
    }

    public static final List<String> PE_COMMON_FIELDS = new List<String>{
        'Id',
        'Clinical_Trial_Profile__c',
        'Clinical_Trial_Profile__r.Profile_Picture__c',
        'Clinical_Trial_Profile__r.Is_Program__c',
        'Clinical_Trial_Profile__r.Override_Inclusion_Criteria__c',
        'Clinical_Trial_Profile__r.Override_Exclusion_Criteria__c',
        'Clinical_Trial_Profile__r.Patient_Portal_Enabled__c',
        'Clinical_Trial_Profile__r.Detailed_Description__c',
        'Clinical_Trial_Profile__r.Brief_Summary__c',
        'Clinical_Trial_Profile__r.Study_Sponsor__c',
        'Clinical_Trial_Profile__r.Study_Title__c',
        'Clinical_Trial_Profile__r.Study_Code_Name__c',
        'Clinical_Trial_Profile__r.Official_Title__c',
        'Clinical_Trial_Profile__r.Orientation_Required__c',
        'Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
        'Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
        'Clinical_Trial_Profile__r.Privacy_Policy_ID__c',
        'Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
        'Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
        'Clinical_Trial_Profile__r.Visit_Plan__c',
        'Clinical_Trial_Profile__r.Visit_Data_Shareback__c',
        'Clinical_Trial_Profile__r.Video_And_Articles_Are_Available__c',
        'Clinical_Trial_Profile__r.Protocol_ID__c',
        'Clinical_Trial_Profile__r.Study_Documents_Are_Available__c',
        'Clinical_Trial_Profile__r.Tasks_Are_Available__c',
        'Clinical_Trial_Profile__r.Payment_Is_Available__c',
        'Clinical_Trial_Profile__r.Travel_Vendor_Is_Available__c',
        'Clinical_Trial_Profile__r.Received_Until_Consent_Is_Available__c',
        'Clinical_Trial_Profile__r.Enrolled_Or_Randomized_Consent_Available__c',
        'Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c',
        'Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c',
        'Clinical_Trial_Profile__r.CommunityTemplate__c',
        'Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c',
        'Clinical_Trial_Profile__r.Trial_Match_Is_Available__c',
        'Clinical_Trial_Profile__r.ECOA_Is_Avaialble__c',
        'Clinical_Trial_Profile__r.Patient_Auth_Upload_Required__c',
        'Clinical_Trial_Profile__r.Shareback_Availability_Timing__c',
        'Clinical_Trial_Profile__r.Promote_to_SH__c',
        'Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c',
        'Clinical_Trial_Profile__r.Study_GUID__c',
        'Clinical_Trial_Profile__r.Visits_are_Available__c ',
        'Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c ',
        'Clinical_Trial_Profile__r.IQVIA_Outreach__c',
        'Subject_GUID__c',
        'isAuthorized__c',
        'Human_Id__c',
        'Unique_HumanId__c',
        'CreatedDate',
        'Enrolled_Date__c',
        'Enrolled_DateTime__c',
        'HCP__c',
        'HCP__r.Status__c',
        'HCP__r.Study_Site__c',
        'HCP__r.HCP_Contact__c',
        'HCP__r.HCP_Contact__r.Name',
        'HCP__r.HCP_Contact__r.FirstName',
        'HCP__r.HCP_Contact__r.LastName',
        'HCP__r.HCP_Contact__r.Email',
        'HCP__r.HCP_Contact__r.Salutation',
        'HCP__r.HCP_Contact__r.Language__c',
        'HCP__r.HCP_Contact__r.AccountId',
        'HCP__r.HCP_Contact__r.Account.Name',
        'HCP__r.HCP_Contact__r.Account.BillingCountryCode',
        'HCP__r.HCP_Contact__r.Account.BillingStateCode',
        'HCP__r.Orientation_Date__c',
        'Days_After_Enrolled__c',
        'Informed_Consent__c',
        'Is_Virtual_Study_Site__c',
        'IsSubjectIDverifiedInSDH__c',
        'Medical_Record_Review_Status__c',
        'Medical_Record_Review_Completedby_Name__c',
        'Medical_Record_Review_Completed_by__r.Id',
        'Motivational_Message_Id__c',
        'MRN_Id__c',
        'MRR_Survey_Results_URL__c',
        'Name',
        'Non_Referral_Reason__c',
        'Patient_ID__c',
        'Participant_Status__c',
        'Participant_Status_Last_Changed_Date__c',
        'Participant_Name__c',
        'Participant_Surname__c',
        'Participant__c',
        'Participant__r.Adult__c',
        'Participant__r.Marketing_Flag__c',
        'Participant__r.Emancipation_in_progress__c',
        'Participant__r.First_Name__c',
        'Participant__r.Last_Name__c',
        'Participant__r.Middle_Name__c',
        'Participant__r.Full_Name__c',
        'Participant__r.Nickname__c',
        'Participant__r.Suffix__c',
        'Participant__r.Preferred_Language__c',
        'Participant__r.Date_of_Birth__c',
        'Participant__r.Birth_Year__c',
        'Participant__r.Gender__c',
        'Participant__r.Email__c',
        'Participant__r.IsCountry_NOT_Eligible_for_Emails__c',
        'Participant__r.Phone__c',
        'Participant__r.Phone_Type__c',
        'Participant__r.Alternative_Phone_Number__c',
        'Participant__r.Alternative_Phone_Type__c',
        'Participant__r.Mailing_State__c',
        'Participant__r.Mailing_City__c',
        'Participant__r.Mailing_State_Code__c',
        'Participant__r.Mailing_Country__c',
        'Participant__r.Mailing_Country_Code__c',
        'Participant__r.Mailing_Zip_Postal_Code__c',
        'Participant__r.Contact__c',
        'Participant__r.Conditions__c',
        'Participant__r.Contact__r.Language__c',
        'Participant__r.Contact__r.Second_Choice_Language__c',
        'Participant__r.Contact__r.Third_Choice_Language__c',
        'Participant__r.Contact__r.Visit_Results_OptIn__c',
        'Participant_Contact__c',
        'Participant_Contact__r.Visit_Results_OptIn__c',
        'Participant_Opt_In_Status_Emails__c',
        'Participant_Opt_In_Status_SMS__c',
        'Participant_Phone_Opt_In_Permit_Phone__c',
        'IQVIA_Direct_Mail_Consent__c',
        'PI_Contact__c',
        'PI_Contact__r.Id',
        'PI_Contact__r.Name',
        'PI_Contact__r.Phone',
        'Pre_screening_Status__c',
        'Pre_Eligibility_Date__c',
        'Referred_Date__c',
        'Referred_By__c',
        'HCP_Contact_HCPEnroll__c',
        'HCP_Contact_HCPEnroll__r.Name',
        'Referral_ID__c',
        'Referral_Source__c',
        'Referral_Completed_by__r.Id',
        'Referral_Completedby_Name__c',
        'Source_Type__c',
        'Visit_Plan__c',
        'Visit_Plan__r.Name',
        'IVRS_IWRS__c',
        'Show_Referring_Provider__c',
        'Study_Name__c',
        'Study_Site__c',
        'Study_Site__r.Name',
        'Study_Site__r.Is_Virtual_Study_Site__c',
        'Study_Site__r.Study_Site_Type__c',
        'Study_Site__r.Approved_Lng__c',
        'Study_Site__r.Override_PI_Referral_Status__c',
        'Study_Site__r.Clinical_Trial_Profile__c',
        'Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Profile_Picture__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Is_Program__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Override_Inclusion_Criteria__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Override_Exclusion_Criteria__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Detailed_Description__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Brief_Summary__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Study_Sponsor__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Orientation_Required__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Visit_Plan__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Visit_Data_Shareback__c',
        'Study_Site__r.Site__r.Name',
        'Study_Site__r.Site__r.Phone',
        'Study_Site__r.Site__r.BillingStreet',
        'Study_Site__r.Site__r.BillingPostalCode',
        'Study_Site__r.Site__r.BillingCountryCode',
        'Study_Site__r.Principal_Investigator__c',
        'Study_Site__r.Principal_Investigator__r.Name',
        'Study_Site__r.Principal_Investigator__r.Salutation',
        'Study_Site__r.Principal_Investigator__r.Language__c',
        'Study_Site__r.Study_Site_Phone__c',
        'Study_Site__r.Visit_Results_Sharing__c',
        'Study_Site__r.Messages_Are_Available__c',
        'Study_Site__r.SMS_Are_Available__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c',
        'Study_Site__r.Suppress_Participant_Emails__c',
        'Study_Site__r.Participant_DOB_format__c',
        'Screening_ID__c',
        'Washout_Run_In_Applies__c',
        'Final_Consent_Date__c',
        'Informed_Consent_Date__c',
        'Initial_visit_occurred_flag__c',
        'Initial_visit_occurred_date__c',
        'Initial_visit_scheduled_date__c',
        'Initial_visit_scheduled_time__c',
        'Initial_visit_scheduled_flag__c',
        'Revisit_Date__c',
        'Final_consent__c',
        'Non_Enrollment_Reason__c',
        'Last_Status_Changed_Notes__c',
        'Permit_SMS_Text_for_this_study__c',
        'Permit_Voice_Text_contact_for_this_study__c',
        'Permit_Mail_Email_contact_for_this_study__c',
        'Delegate_Consent__c',
        'Delegate_SMS_Consent__c',
        'Study_Direct_Mail_Consent__c',
        'Permit_IQVIA_to_contact_about_study__c',
        'Email__c',
        'Patient_Middle_Name_Initial__c',
        'Patient_Sex__c',
        'Phone__c',
        'Country__c',
        'Patient_Phone_Type__c',
        'State__c',
        'Postal_Code__c',
        'Primary_Delegate_First_Name__c',
        'Primary_Delegate_Last_Name__c',
        'Primary_Delegate_Email__c',
        'Primary_Delegate_Phone_Number__c',
        'Primary_Delegate_Phone_Type__c',
        'Primary_Delegate_YOB__c',
        'Is_Delegate_Certify__c',
        'Birth_Month__c',
        'YOB__c',
        'Is_Contact__c',
        'Is_Email__c',
        'Is_SMS__c',
        'Is_Phone__c',
        'Mailing_State_Code__c',
        'Mailing_Country_Code__c',
        'Participant_Alternative_Phone__c',
        'Participant_Alt_Phone_Type__c',
        'Contacted__c',
        'Contacted_Date__c',
        'Consulted__c',
        'Consulted_Date__c',
        'Have_you_Documented_the_Discussion__c',
        'Discussion_Documented_Date__c',
        'Visit_Results_Opt_In__c'
    };
    public static final List<String> ACTIVE_PE_FIELDS_FOR_CTP_SS = new List<String>{
        'Id',
        'Clinical_Trial_Profile__c',
        'Study_Site__c'
    };

    public static List<Participant_Enrollment__c> getPEnrolmentsCommonCustomFields(
        String userMode,
        List<String> customFields,
        String filter
    ) {
        return getPEnrolmentsCommonCustomFields(userMode, customFields, filter, null);
    }

    public static List<Participant_Enrollment__c> getPEnrolmentsCommonCustomFields(
        String userMode,
        List<String> customFields,
        String filter,
        String delegateId
    ) {
        return getInstance()
            .getPEnrolmentsCommonCustomFieldsImpl(userMode, customFields, filter, delegateId);
    }

    public static List<Participant_Enrollment__c> getPEnrolmentsCommonCustomFields(
        String userMode,
        List<String> customFields,
        String filter,
        String delegateId,
        Boolean translationNeeded
    ) {
        return getInstance()
            .getPEnrolmentsCommonCustomFieldsImpl(
                userMode,
                customFields,
                filter,
                delegateId,
                translationNeeded
            );
    }

    public static List<Participant_Enrollment__c> getPEnrolmentsCommon(
        String userMode,
        String filter
    ) {
        return getPEnrolmentsCommon(userMode, filter, null);
    }

    public static List<Participant_Enrollment__c> getPEnrolmentsCommon(
        String userMode,
        String filter,
        String delegateId
    ) {
        return getPEnrolmentsCommonCustomFieldsWithTranslation(
            userMode,
            PE_COMMON_FIELDS,
            filter,
            delegateId
        );
    }

    public static List<Participant_Enrollment__c> getPEnrolmentsCommonCustomFieldsWithTranslation(
        String userMode,
        List<String> fieldNames,
        String filter,
        String delegateId
    ) {
        List<Participant_Enrollment__c> peList = getPEnrolmentsCommonCustomFields(
            userMode,
            fieldNames,
            filter,
            delegateId
        );
        for (Participant_Enrollment__c pe : peList) {
            if (pe.getSObject('Participant__r') != null) {
                //translate country:
                String countryCode = (String) pe.getSObject('Participant__r')
                    .get('Mailing_Country_Code__c');
                String country = CountryStateUtil.getCountryName(countryCode);
                pe.getSObject('Participant__r').put('Mailing_Country__c', country);

                //translate state
                String stateCode = (String) pe.getSObject('Participant__r')
                    .get('Mailing_State_Code__c');
                String state = CountryStateUtil.getStateName(countryCode, stateCode);
                pe.getSObject('Participant__r').put('Mailing_State__c', state);
            }
        }
        return peList;
    }

    private static String getDefaultFilter(String userMode, String delegateId, String filterStr) {
        String defaultFilter = ' Study_Site__c != NULL '; // AND ' + getUserModeFilter(userMode, delegateId);
        if (
            userMode == CommunityService.USER_MODE_HCP &&
            !(filterStr != null && filterStr.contains(' AND Id='))
        ) {
            defaultFilter +=
                '  AND (' +
                getUserModeFilter(userMode, delegateId) +
                getHealthcareProviderFilter() +
                ') ';
            defaultFilter += filterStr != null ? filterStr : '';
        } else if (userMode == CommunityService.USER_MODE_CC) {
            defaultFilter += '' + filterStr;
        } else {
            defaultFilter += ' AND ' + getUserModeFilter(userMode, delegateId);
            if (filterStr != null)
                defaultFilter += ' ' + filterStr;
        }
        return defaultFilter;
    }

    private static Map<String, Object> getSearchResult(
        String mode,
        String delegateId,
        String filterStr,
        String searchText
    ) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String soslSearchTerm = '\'(';
        for (String word : searchText.split(' ')) {
            soslSearchTerm += '\"' + word + '*\"' + ' AND ';
        }
        soslSearchTerm = soslSearchTerm.trim().removeEnd('AND') + ')\'';

        String defaultFilter = getDefaultFilter(mode, delegateId, filterStr);
        String soslSearchQuery =
            'FIND ' +
            soslSearchTerm +
            ' RETURNING Participant_Enrollment__c ( Id WHERE ' +
            defaultFilter +
            ' ) LIMIT 2000';
        System.debug('##soslSearchQuery: ' + soslSearchQuery);
        Map<Id, Participant_Enrollment__c> enrollmentSearchResult = new Map<Id, Participant_Enrollment__c>(
            (List<Participant_Enrollment__c>) Search.query(soslSearchQuery)[0]
        );
        if (!enrollmentSearchResult.isEmpty()) {
            filterStr += ' AND (';
            List<Id> enrollmentIds = new List<Id>(enrollmentSearchResult.keySet());
            filterStr += DatabaseService.fieldInValues('Id', enrollmentIds);
            filterStr += ')';
            returnMap.put('filter', filterStr);
            returnMap.put('searchResult', true);
        } else {
            returnMap.put('filter', filterStr);
            returnMap.put('searchResult', false);
        }
        return returnMap;
    }

    private static String getUserModeFilter(String userMode) {
        return getUserModeFilter(userMode, null);
    }

    private static String getUserModeFilter(String userMode, String delegateId) {
        String delegatesFilter = '';
        if (
            userMode == CommunityService.USER_MODE_PI ||
            userMode == CommunityService.USER_MODE_CC
        ) {
            List<Id> delegatedSSIds = DelegateService.getDelegatedStudySiteIds();
            if (delegatedSSIds.size() > 0)
                delegatesFilter =
                    ' OR Study_Site__c IN (\'' +
                    String.join(delegatedSSIds, '\',\'') +
                    '\')';
            return '( ' +
                '   Study_Site__r.Principal_Investigator__c = \'' +
                CommunityService.getUserContact().Id +
                '\' ' +
                delegatesFilter +
                ') ';
        } else if (
            userMode == CommunityService.USER_MODE_HCP ||
            userMode == CommunityService.USER_MODE_CC
        ) {
            String contactId = CommunityService.getUserContact().Id;
            if (delegateId != null && delegateId != '') {
                contactId = delegateId;
            }
            return '(' + '   HCP__r.HCP_Contact__c = \'' + contactId + '\'' + ') ';
        } else {
            List<Id> delegatedParticipants = PatientDelegateService.getDelegatedParticipantIds(
                CommunityService.getUserContact().Id
            );
            if (delegatedParticipants != null && delegatedParticipants.size() > 0) {
                delegatesFilter =
                    ' OR ' + DatabaseService.fieldInValues('Participant__c', delegatedParticipants);
            }
            return '( ' +
                '   Participant__r.Contact__c = \'' +
                CommunityService.getUserContact().Id +
                '\' ' +
                delegatesFilter +
                ')';
        }
    }

    public static Participant_Enrollment__c createParticipantEnrollment(
        Clinical_Trial_Profile__c trial,
        HCP_Enrollment__c hcpEnrollment,
        String participantId
    ) {
        return getInstance().createParticipantEnrollmentImpl(trial, hcpEnrollment, participantId);
    }

    //contains selected filter values
    public class PEFilter {
        public String mode;
        public List<Id> trialIds;
        public Id study;
        public Id studySite;
        public String referringStatus;
        public String enrollmentStatus;
        public String reviewResult;
        public String showExcludedFromReferring;
        public String dateRange;
        public String source;
        public String activePE;
        public String participantStatus;
        public Date startDate;
        public Date endDate;
        public String searchText;
        public List<String> searchFields;
        public String sortType = SortOrder.SORT_TYPES[0].value;
        public String additionalFilter;
        public String acceptenceStatus;
        public String referringClinic;
        public String dateField;

        public PEFilter(PEFilterData filterData) {
            mode = filterData.mode;
            trialIds = filterData.trialIds;
            dateField = filterData.dateField;
        }
    }

    //contains pick list values for PEFilter
    public class PEFilterData {
        public String mode;
        public List<Id> trialIds;
        public List<LabelValueItem> studies;
        public List<LabelValueItem> studySites;
        public List<LabelValueItem> referringStatuses = PEStatusState.getReferringStatusesLVList();
        public List<LabelValueItem> reviewResults;
        public List<LabelValueItem> source;
        public List<LabelValueItem> activePE;
        public List<LabelValueItem> statuses;
        public List<LabelValueItem> activeParticipantStatus;
        public List<LabelValueItem> inactiveParticipantStatus;
        public List<LabelValueItem> excludedFromReferring;
        public List<LabelValueItem> referringClinics;
        public List<LabelValueItem> dateRanges = DateRangeFilterData.getRanges();
        public List<LabelValueItem> sortVariants;
        public List<LabelValueItem> acceptenceStatuses = PEStatusState.getAcceptenceStatusesLVList();
        public List<LabelValueItem> enrollmentStatuses = PEStatusState.getEnrollmentStatusesLVList();
        public PEFilterData() {
            sortVariants = new List<LabelValueItem>();
            sortVariants.addAll(SortOrder.SORT_TYPES);
        }
        public String dateField = 'CreatedDate';
    }

    public static PEFilterData getPEFilterData(Id trialId, String mode, Boolean restrictTrial) {
        return getPEFilterData(trialId, mode, restrictTrial, null);
    }

    public static PEFilterData getPEFilterData(
        Id trialId,
        String mode,
        Boolean restrictTrial,
        String delegateId
    ) {
        //init trials
        Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>(
            TrialService.getAvailableTrials(mode, delegateId)
        );
        //init study sites:
        List<Study_Site__c> studySites = new List<Study_Site__c>();
        if (mode == CommunityService.USER_MODE_HCP) {
            if (restrictTrial && trialId != null) {
                studySites = StudySiteService.getStudySitesForHCPByTrialId(trialId);
            } else {
                studySites = StudySiteService.getStudySitesForHCP(
                    new List<Id>(trialsMap.keySet()),
                    delegateId
                );
            }
        }
        if (mode == CommunityService.USER_MODE_PI) {
            if (restrictTrial && trialId != null) {
                studySites = StudySiteService.getStudySiteForPIByTrialId(trialId);
            } else {
                studySites = StudySiteService.getStudySitesForPI();
            }
        }
        return createPEFilterDataForTrials(trialsMap, studySites, mode);
    }
    /*
    @Depricated - use getPEFilterDataWithSponsor instead
    Modified for performance tuning. Study Site and CTP filters are going to be static
    
    public static PEFilterData getPEFilterDataWithExistingPERecords(String activePE, Id trialId, String mode, Boolean restrictTrial, String delegateId, String additionalFilters, String sponsorName) {
        //init trials - removed filtration based on PE
        //Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>(TrialService.getAvailableTrialsWithPE(activePE, mode, delegateId, additionalFilters));
        Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>(TrialService.getAvailableTrials(mode,delegateId));
        Map<Id, Clinical_Trial_Profile__c> filterTrialsMap = new Map<Id, Clinical_Trial_Profile__c>(TrialService.filterStudyForCurrentCommunity(trialsMap.values()));
        //init study sites:
        List<Study_Site__c> studySites;
        if (mode == CommunityService.USER_MODE_HCP) {
            if (restrictTrial && trialId != null && filterTrialsMap.containsKey(trialId)) {
                studySites = StudySiteService.getStudySitesForHCPByTrialId(trialId);
            } else {
                studySites = StudySiteService.getStudySitesForHCP(new List<Id>(filterTrialsMap.keySet()), delegateId);
            }
        }
        if (mode == CommunityService.USER_MODE_PI) {
            if (restrictTrial && trialId != null && filterTrialsMap.containsKey(trialId)) {
                studySites = StudySiteService.getStudySiteForPIByTrialId(trialId);
            } else {
                //studySites = StudySiteService.getStudySitesForPI();
                studySites = StudySiteService.getStudySitesForPIBySponsor(sponsorName);
            }
        }
        //Removed filtration based on PE
        //studySites = StudySiteService.filterStudySitesWithPE(studySites, activePE, mode, delegateId, additionalFilters);
        return createPEFilterDataForTrials(filterTrialsMap, studySites, mode);
    }*/

    /*
     * Get the trials and study in a single query for a particular community.
     * Replaces getPEFilterDataWithExistingPERecords
     * @param mode community user mode eg. PI/HCP/CC
     * @param trialId CTP Id
     * @param restrictTrial in Boolean
     * @param delegateId for the PI if any
     * @param communityTemplate logged in community name eg. Default for IQVIA
     * @return PEFilterData wrapper that forms the filter dropdown in UI
     */
    public static PEFilterData getPEFilterDataWithSponsor(
        String mode,
        Id trialId,
        Boolean restrictTrial,
        String delegateId,
        String communityTemplate
    ) {
        Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>();
        List<Clinical_Trial_Profile__c> trials = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> studySites = new List<Study_Site__c>();
        if (mode == CommunityService.USER_MODE_HCP) {
            String communityFilter = communityTemplate.equalsIgnoreCase(
                    CommunityTemplateService.TEMPLATE_JANSSEN
                )
                ? 'AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
                  CommunityTemplateService.TEMPLATE_JANSSEN +
                  '\''
                : 'AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
                  CommunityTemplateService.TEMPLATE_JANSSEN +
                  '\'';
            List<HCP_Enrollment__c> hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsCommon(
                mode,
                delegateId,
                communityFilter,
                false
            );
            System.debug('hcpCommon' + hcpEnrollments);
            for (HCP_Enrollment__c hcpEnrollment : hcpEnrollments) {
                if (hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r != null)
                    trials.add(hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r);
            }
            trialsMap.putAll(trials);
            if (restrictTrial && trialId != null && trialsMap.containsKey(trialId)) {
                studySites = StudySiteService.getStudySitesForHCPByTrialId(trialId);
            } else {
                studySites = StudySiteService.getStudySitesForHCP(
                    new List<Id>(trialsMap.keySet()),
                    delegateId
                );
            }
        }
        if (mode == CommunityService.USER_MODE_PI) {
            String communityFilter = communityTemplate.equalsIgnoreCase(
                    CommunityTemplateService.TEMPLATE_JANSSEN
                )
                ? 'AND Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
                  CommunityTemplateService.TEMPLATE_JANSSEN +
                  '\''
                : 'AND Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
                  CommunityTemplateService.TEMPLATE_JANSSEN +
                  '\'';
            //List<Study_Site__c> studySitesTmp = StudySiteService.getStudySitesForPIBySponsor(communityTemplate);
            List<Study_Site__c> studySitesTmp = StudySiteService.getStudySitesCommon(
                CommunityService.USER_MODE_PI,
                communityFilter,
                false
            );
            for (Study_Site__c ss : studySitesTmp)
                trials.add(ss.Clinical_Trial_Profile__r);
            trialsMap.putAll(trials);
            if (restrictTrial && trialId != null && trialsMap.containsKey(trialId)) {
                studySites = StudySiteService.getStudySiteForPIByTrialId(trialId);
            } else {
                studySites.addAll(studySitesTmp);
            }
        }
        return createPEFilterDataForTrials(trialsMap, studySites, mode);
    }

    private static PEFilterData createPEFilterDataForTrials(
        Map<Id, Clinical_Trial_Profile__c> trialsMap,
        List<Study_Site__c> studySites,
        String mode
    ) {
        PEFilterData peFilterData = new PEFilterData();
        peFilterData.mode = mode;
        //init trials
        peFilterData.studies = new List<LabelValueItem>();
        peFilterData.studies.add(new LabelValueItem(Label.PG_MRRL_L_All_studies, null));
        peFilterData.trialIds = new List<Id>();
        Clinical_Trial_Profile__c trial;
        for (String id : trialsMap.keySet()) {
            peFilterData.trialIds.add(id);
            trial = trialsMap.get(id);
            peFilterData.studies.add(new LabelValueItem(trial.Study_Code_Name__c, trial.Id));
        }

        //init study sites:
        peFilterData.studySites = new List<LabelValueItem>();
        peFilterData.studySites.add(new LabelValueItem(Label.PG_Report_L_All_study_sites, null));
        for (Study_Site__c ss : studySites)
            peFilterData.studySites.add(new LabelValueItem(ss.Name, ss.Id));

        peFilterData.referringClinics = new List<LabelValueItem>();
        peFilterData.referringClinics.add(
            new LabelValueItem(Label.PG_Report_L_All_referring_clinics, null)
        );
        for (Account clinic : HCPEnrollmentService.getReferringClinics(peFilterData.trialIds)) {
            peFilterData.referringClinics.add(new LabelValueItem(clinic.Name, clinic.Id));
        }
        peFilterData.activePE = new List<LabelValueItem>{
            new LabelValueItem(
                TranslateHelper.getLabelValue('PG_VP_L_Active'),
                PEStatusState.PE_STATUSES_ACTIVE
            ),
            new LabelValueItem(
                TranslateHelper.getLabelValue('PG_VP_L_Inactive'),
                PEStatusState.PE_STATUSES_INACTIVE
            )
        };
        peFilterData.activeParticipantStatus = new List<LabelValueItem>();
        for (Integer i = 0, j = PEStatusState.PE_STATUS_GROUP_ACTIVE.size(); i < j; i++) {
            peFilterData.activeParticipantStatus.add(
                new LabelValueItem(
                    TranslateHelper.getPickListLabel(
                        Participant_Enrollment__c.Participant_Status__c,
                        PEStatusState.PE_STATUS_GROUP_ACTIVE[i]
                    ),
                    PEStatusState.PE_STATUS_GROUP_ACTIVE[i]
                )
            );
        }
        peFilterData.inactiveParticipantStatus = new List<LabelValueItem>();
        for (Integer i = 0, j = PEStatusState.PE_STATUS_GROUP_INACTIVE.size(); i < j; i++) {
            peFilterData.inactiveParticipantStatus.add(
                new LabelValueItem(
                    TranslateHelper.getPickListLabel(
                        Participant_Enrollment__c.Participant_Status__c,
                        PEStatusState.PE_STATUS_GROUP_INACTIVE[i]
                    ),
                    PEStatusState.PE_STATUS_GROUP_INACTIVE[i]
                )
            );
        }
        return peFilterData;
    }
    public static List<Participant_Enrollment__c> getParticipantEnrollments(
        PEFilter filter,
        PaginationData paginationData,
        String sponsorName
    ) {
        return getParticipantEnrollments(filter, paginationData, null);
    }

    public static List<Participant_Enrollment__c> getParticipantEnrollments(
        PEFilter filter,
        String delegateId,
        String sponsorName
    ) {
        return getParticipantEnrollmentsCustomFields(
            PE_COMMON_FIELDS,
            filter,
            delegateId,
            sponsorName
        );
    }

    public static List<Participant_Enrollment__c> getParticipantEnrollmentsCustomFields(
        List<String> fieldsList,
        PEFilter filter,
        String delegateId,
        String sponsorName
    ) {
        return getParticipantEnrollmentsCustomFields(
            fieldsList,
            filter,
            delegateId,
            true,
            sponsorName
        );
    }

    public static List<Participant_Enrollment__c> getParticipantEnrollmentsCustomFields(
        List<String> fieldsList,
        PEFilter filter,
        String delegateId,
        Boolean translationNeeded,
        String sponsorName
    ) {
        //prepare filter string:
        String filterStr =
            ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' +
            String.join(filter.trialIds, '\',\'') +
            '\') ';
        if (!String.isEmpty(filter.additionalFilter))
            filterStr += ' AND ' + filter.additionalFilter + ' ';
        if (filter.searchText != null)
            filter.searchText = filter.searchText.trim();
        if (String.isEmpty(filter.searchText)) {
            if (!String.isEmpty(filter.study))
                filterStr +=
                    ' AND Study_Site__r.Clinical_Trial_Profile__c = \'' +
                    filter.study +
                    '\' ';

            //Added janssen filter
            if (sponsorName == CommunityTemplateService.TEMPLATE_JANSSEN) {
                filterStr +=
                    ' AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
                    CommunityTemplateService.TEMPLATE_JANSSEN +
                    '\' ';
            }
            if (sponsorName != CommunityTemplateService.TEMPLATE_JANSSEN) {
                filterStr +=
                    ' AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
                    CommunityTemplateService.TEMPLATE_JANSSEN +
                    '\' ';
            }

            if (!String.isEmpty(filter.studySite))
                filterStr += ' AND Study_Site__c = \'' + filter.studySite + '\' ';
            if (!String.isEmpty(filter.referringStatus))
                filterStr += 'AND Participant_Status__c IN ' + filter.referringStatus + ' ';
            //if(!String.isEmpty(filter.enrollmentStatus)) filterStr += ' AND Participant_Status__c IN ' + filter.enrollmentStatus + ' ';
            //if(!String.isEmpty(filter.acceptenceStatus)) filterStr += ' AND Participant_Status__c IN ' + filter.acceptenceStatus + ' ';
            if (!String.isEmpty(filter.referringClinic))
                filterStr +=
                    ' AND HCP__r.HCP_Contact__r.AccountId = \'' +
                    filter.referringClinic +
                    '\' ';
            if (!String.isEmpty(filter.source))
                filterStr += ' AND Referral_Source_ID__c = \'' + filter.source + '\' ';
            if (!String.isEmpty(filter.participantStatus))
                filterStr += ' AND Participant_Status__c = \'' + filter.participantStatus + '\' ';
            if (!String.isEmpty(filter.activePE) && String.isEmpty(filter.participantStatus)) {
                if (filter.activePE == PEStatusState.PE_STATUSES_ACTIVE) {
                    filterStr +=
                        ' AND Participant_Status__c  IN (\'' +
                        String.join(PEStatusState.PE_STATUS_GROUP_ACTIVE, '\',\'') +
                        '\') ';
                } else {
                    filterStr +=
                        ' AND Participant_Status__c  IN (\'' +
                        String.join(PEStatusState.PE_STATUS_GROUP_INACTIVE, '\',\'') +
                        '\') ';
                }
            }
            if (
                filter.startDate != null &&
                filter.endDate != null &&
                filter.startDate < filter.endDate
            ) {
                //TODO
            }
        }
        if (!String.isEmpty(filter.dateRange)) {
            filterStr += ' AND ' + filter.dateField + ' ' + filter.dateRange + ' ';
        }
        if (!filter.sortType.contains('Alphabetical'))
            filterStr += ' ORDER BY ' + filter.sortType;
        System.debug('FILTER STRING: ' + filterStr);

        //get PE List:
        List<Participant_Enrollment__c> peList = getPEnrolmentsCommonCustomFields(
            filter.mode,
            fieldsList,
            filterStr,
            delegateId,
            translationNeeded
        );
        System.debug('**peList 2:' + peList.size());
        List<Participant_Enrollment__c> filteredPEList = new List<Participant_Enrollment__c>();
        //Filter by search string:
        if (filter != null && !String.isEmpty(filter.searchText)) {
            for (Participant_Enrollment__c pe : peList) {
                Boolean isFound = false;
                for (String searchField : filter.searchFields) {
                    String searchFieldValue =
                        SObjectHelper.getSObjectFieldValue(pe, searchField) + '';
                    for (String searchWord : filter.searchText.split(' ')) {
                        if (searchFieldValue.containsIgnoreCase(searchWord)) {
                            isFound = true;
                            break;
                        }
                    }
                }
                if (isFound)
                    filteredPEList.add(pe);
            }
            peList = filteredPEList;
        }

        //sort
        if (filter != null && filter.sortType.contains('Alphabetical')) {
            List<String> fields = filter.sortType.split(',');
            String type = fields[0];
            List<String> orderList = new List<String>();
            Map<String, Participant_Enrollment__c> peMap = new Map<String, Participant_Enrollment__c>();
            for (Participant_Enrollment__c pe : peList) {
                String key = '';
                for (String field : fields) {
                    if (!field.contains('Alphabetical'))
                        key += ' ' + SObjectHelper.getSObjectFieldValue(pe, field.trim());
                }
                key += pe.Id;
                orderList.add(key.toLowerCase());
                peMap.put(key.toLowerCase(), pe);
            }
            orderList.sort();

            if (type.equalsIgnoreCase('Alphabetical_DESC')) {
                List<String> reversed = new List<String>();
                for (Integer i = orderList.size() - 1; i >= 0; i--) {
                    reversed.add(orderList[i]);
                }
                orderList = reversed;
            }
            List<Participant_Enrollment__c> sortedList = new List<Participant_Enrollment__c>();
            for (String key : orderList)
                sortedList.add(peMap.get(key));
            peList = sortedList;
        }
        System.debug('**peList 3:' + peList.size());
        return peList;
    }
    /*
     * Modifed for performance tuning - Implemented offset
     * Sabir & Velu
     * 04-Sept-2020
     */
    public static List<Participant_Enrollment__c> getParticipantEnrollmentsCustomFields(
        List<String> fieldsList,
        PEFilter filter,
        String delegateId,
        Boolean translationNeeded,
        PaginationData paginationData,
        String sponsorName
    ) {
        //prepare filter string:
        String filterStr =
            ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' +
            String.join(filter.trialIds, '\',\'') +
            '\') ';
        if (!String.isEmpty(filter.additionalFilter))
            filterStr += ' AND ' + filter.additionalFilter + ' ';
        //Added Janssen filter
        if (!filterStr.contains('CommunityTemplate__c'))
            filterStr += sponsorName.equalsIgnoreCase(CommunityTemplateService.TEMPLATE_JANSSEN)
                ? ' AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
                  CommunityTemplateService.TEMPLATE_JANSSEN +
                  '\' '
                : ' AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
                  CommunityTemplateService.TEMPLATE_JANSSEN +
                  '\' ';
        if (!String.isEmpty(filter.searchText))
            filter.searchText = filter.searchText.trim();
        //Search on all the enrollments and not based on the applied filters
        if (String.isEmpty(filter.searchText)) {
            if (!String.isEmpty(filter.study))
                filterStr +=
                    ' AND Study_Site__r.Clinical_Trial_Profile__c = \'' +
                    filter.study +
                    '\' ';
            if (!String.isEmpty(filter.studySite))
                filterStr += ' AND Study_Site__c = \'' + filter.studySite + '\' ';
            if (!String.isEmpty(filter.referringStatus))
                filterStr += 'AND Participant_Status__c IN ' + filter.referringStatus + ' ';
            //if(!String.isEmpty(filter.enrollmentStatus)) filterStr += ' AND Participant_Status__c IN ' + filter.enrollmentStatus + ' ';
            //if(!String.isEmpty(filter.acceptenceStatus)) filterStr += ' AND Participant_Status__c IN ' + filter.acceptenceStatus + ' ';
            if (!String.isEmpty(filter.referringClinic))
                filterStr +=
                    ' AND HCP__r.HCP_Contact__r.AccountId = \'' +
                    filter.referringClinic +
                    '\' ';
            //if (!String.isEmpty(filter.source)) filterStr += ' AND Referral_Source_ID__c = \'' + filter.source + '\' ';
            if (!String.isEmpty(filter.source))
                filterStr += ' AND Source_Type__c = \'' + filter.source + '\' ';
            if (!String.isEmpty(filter.participantStatus))
                filterStr += ' AND Participant_Status__c = \'' + filter.participantStatus + '\' ';
            if (!String.isEmpty(filter.activePE) && String.isEmpty(filter.participantStatus)) {
                if (filter.activePE == PEStatusState.PE_STATUSES_ACTIVE) {
                    filterStr +=
                        ' AND Participant_Status__c  IN (\'' +
                        String.join(PEStatusState.PE_STATUS_GROUP_ACTIVE, '\',\'') +
                        '\') ';
                } else {
                    filterStr +=
                        ' AND Participant_Status__c  IN (\'' +
                        String.join(PEStatusState.PE_STATUS_GROUP_INACTIVE, '\',\'') +
                        '\') ';
                }
            }
            if (
                filter.startDate != null &&
                filter.endDate != null &&
                filter.startDate < filter.endDate
            ) {
                //TODO
            }
        }
        if (!String.isEmpty(filter.dateRange)) {
            filterStr += ' AND ' + filter.dateField + ' ' + filter.dateRange + ' ';
        }
        //Add search filter if applicable
        /*if (filter != null && !String.isEmpty(filter.searchText)) {
            String searchFilter = '';
            for (String searchField : filter.searchFields) {
                searchFilter += ((searchField.equalsIgnoreCase('Participant__r.First_Name__c') ||  searchField.equalsIgnoreCase('Participant__r.Last_Name__c')) ?  searchField + ' = \'' + String.escapeSingleQuotes(filter.searchText) + '\'' 
                                 : searchField + ' LIKE ' + '\'%' + String.escapeSingleQuotes(filter.searchText) + '%\'') + ' OR ';
            }
            searchFilter = searchFilter.trim().removeEnd('OR');
            filterStr += ' AND (' + searchFilter + ')';
        }*/
        Boolean noSearchResult = false;
        if (filter != null && !String.isEmpty(filter.searchText)) {
            Map<String, Object> searchResultMap = getSearchResult(
                filter.mode,
                delegateId,
                filterStr,
                filter.searchText
            );
            if (
                searchResultMap.containsKey('searchResult') &&
                (Boolean) searchResultMap.get('searchResult')
            ) {
                filterStr = (String) searchResultMap.get('filter');
            } else {
                noSearchResult = true;
            }
        }
        //Use ORDER BY clause for sorting based on created/ modified date
        if (!filter.sortType.contains('Alphabetical'))
            filterStr += ' ORDER BY ' + filter.sortType;
        //Modified for performance tuning - get PE List based on the offset
        List<Participant_Enrollment__c> peList;
        if (noSearchResult) {
            peList = new List<Participant_Enrollment__c>();
            paginationData.setRecordsCount(0);
        } else {
            peList = getPEnrolmentsCommonCustomFields(
                filter.mode,
                fieldsList,
                filterStr,
                delegateId,
                translationNeeded,
                paginationData
            );
        }
        //Sort the name fields alphabetically through iteration because of encryption
        if (filter != null && filter.sortType.contains('Alphabetical')) {
            List<String> fields = filter.sortType.split(',');
            String type = fields[0];
            List<String> orderList = new List<String>();
            Map<String, Participant_Enrollment__c> peMap = new Map<String, Participant_Enrollment__c>();
            for (Participant_Enrollment__c pe : peList) {
                String key = '';
                for (String field : fields) {
                    if (!field.contains('Alphabetical'))
                        key += ' ' + SObjectHelper.getSObjectFieldValue(pe, field.trim());
                }
                key += pe.Id;
                orderList.add(key.toLowerCase());
                peMap.put(key.toLowerCase(), pe);
            }
            orderList.sort();

            if (type.equalsIgnoreCase('Alphabetical_DESC')) {
                List<String> reversed = new List<String>();
                for (Integer i = orderList.size() - 1; i >= 0; i--) {
                    reversed.add(orderList[i]);
                }
                orderList = reversed;
            }
            List<Participant_Enrollment__c> sortedList = new List<Participant_Enrollment__c>();
            for (String key : orderList)
                sortedList.add(peMap.get(key));
            peList = sortedList;
        }

        return peList;
    }

    // Added for the performance tuning
    public static List<Participant_Enrollment__c> getPEnrolmentsCommonCustomFields(
        String userMode,
        List<String> customFields,
        String filter,
        String delegateId,
        Boolean translationNeeded,
        PaginationData paginationData
    ) {
        return getInstance()
            .getPEnrolmentsCommonCustomFieldsImpl(
                userMode,
                customFields,
                filter,
                delegateId,
                translationNeeded,
                paginationData
            );
    }

    // Added for the performance tuning
    public List<Participant_Enrollment__c> getPEnrolmentsCommonCustomFieldsImpl(
        String userMode,
        List<String> customFields,
        String filter,
        String delegateId,
        Boolean translationNeeded,
        PaginationData paginationData
    ) {
        String defaultFilter = getDefaultFilter(userMode, delegateId, filter);

        String replaceStr = '';
        Integer replaceStrIndext1 = defaultFilter.Indexof('ORDER BY CreatedDate DESC');
        Integer replaceStrIndext2 = defaultFilter.Indexof('ORDER BY LastModifiedDate DESC');

        if (replaceStrIndext1 > -1) {
            replaceStr = defaultFilter.replace('ORDER BY CreatedDate DESC', ' ');
        } else if (replaceStrIndext2 > -1) {
            replaceStr = defaultFilter.replace('ORDER BY LastModifiedDate DESC', ' ');
        } else {
            replaceStr = defaultFilter;
        }

        Integer count = Database.countQuery(
            'SELECT COUNT() FROM Participant_Enrollment__c WHERE ' + replaceStr
        );
        paginationData.setRecordsCount(count);

        Integer limitvalue = paginationData.pageRecordsCount;
        Integer currentpage = paginationData.currentPage;
        Integer size = currentpage - 1;
        Integer offsetvalue = size * limitvalue;

        List<Participant_Enrollment__c> peList = DatabaseService.query(
            customFields,
            Participant_Enrollment__c.getSObjectType(),
            defaultFilter,
            null,
            limitvalue,
            offsetvalue
        );

        if (userMode != CommunityService.USER_MODE_PARTICIPANT && translationNeeded)
            TranslateHelper.translate(peList);
        return peList;
    }

    public static List<Participant_Enrollment__c> getParticipantEnrollments(
        PEFilter filter,
        PaginationData paginationData,
        String delegateId,
        String sponsorName
    ) {
        List<Participant_Enrollment__c> peList = getParticipantEnrollments(
            filter,
            delegateId,
            sponsorName
        );
        return getParticipantEnrollmentsPaginated(peList, paginationData);
    }

    public static List<Participant_Enrollment__c> getParticipantEnrollmentsCustomFields(
        List<String> fieldsList,
        PEFilter filter,
        PaginationData paginationData,
        String delegateId,
        String sponsorName
    ) {
        List<Participant_Enrollment__c> peList = getParticipantEnrollmentsCustomFields(
            fieldsList,
            filter,
            delegateId,
            sponsorName
        );
        return getParticipantEnrollmentsPaginated(peList, paginationData);
    }

    public static List<Participant_Enrollment__c> getParticipantEnrollmentsPaginated(
        List<Participant_Enrollment__c> peList,
        PaginationData paginationData
    ) {
        //Pagination:
        if (paginationData != null) {
            paginationData.setRecordsCount(peList.size());
            List<Participant_Enrollment__c> pageList = new List<Participant_Enrollment__c>();
            for (Integer i = paginationData.offset; i < paginationData.endOffset; i++) {
                pageList.add(peList[i]);
            }
            return pageList;
        }
        return peList;
    }
    public static List<Participant_Enrollment__c> getParticipantEnrollments(
        PEFilter filter,
        PaginationData paginationData,
        String delegateId,
        String sponsorName,
        String userMode
    ) {
        List<Participant_Enrollment__c> peList = getParticipantEnrollments(
            filter,
            delegateId,
            sponsorName
        );
        return getParticipantEnrollmentsPaginated(peList, paginationData);
    }

    public static List<Participant_Enrollment__c> getParticipantEnrollmentsActiveFilter(
        String activePE,
        String mode,
        String delegateId,
        String additionalFilter
    ) {
        String filterStr = '';
        if (mode == CommunityService.USER_MODE_PI && activePE == PEStatusState.PE_STATUSES_ACTIVE) {
            filterStr =
                ' AND Participant_Status__c  IN (\'' +
                String.join(PEStatusState.PE_STATUS_GROUP_ACTIVE, '\',\'') +
                '\') ';
        } else if (mode == CommunityService.USER_MODE_PI) {
            filterStr =
                ' AND Participant_Status__c  IN (\'' +
                String.join(PEStatusState.PE_STATUS_GROUP_INACTIVE, '\',\'') +
                '\') ';
        }
        return getPEnrolmentsCommon(mode, filterStr + ' AND ' + additionalFilter, delegateId);
    }

    public static List<Participant_Enrollment__c> getParticipantEnrollmentsActiveFilterOptimized(
        String activePE,
        String mode,
        String delegateId,
        String additionalFilter,
        List<String> fields
    ) {
        String filterStr = '';
        if (mode == CommunityService.USER_MODE_PI && activePE == PEStatusState.PE_STATUSES_ACTIVE) {
            filterStr =
                ' AND Participant_Status__c  IN (\'' +
                String.join(PEStatusState.PE_STATUS_GROUP_ACTIVE, '\',\'') +
                '\') ';
        } else if (mode == CommunityService.USER_MODE_PI) {
            filterStr =
                ' AND Participant_Status__c  IN (\'' +
                String.join(PEStatusState.PE_STATUS_GROUP_INACTIVE, '\',\'') +
                '\') ';
        }
        return getPEnrolmentsCommonCustomFields(
            mode,
            fields,
            filterStr +
            ' AND ' +
            additionalFilter,
            delegateId
        );
    }

    public static List<Participant_Enrollment__c> getEnrollmentsByExternalKey(
        List<String> externalKeys
    ) {
        return [
            SELECT
                Id,
                External_Key__c,
                IsSubjectIDverifiedInSDH__c,
                (SELECT Id, Date__c, Status__c FROM Participant_Enrollment_Status_History__r)
            FROM Participant_Enrollment__c
            WHERE External_Key_WF__c IN :externalKeys
            LIMIT 10000
        ];
    }

    public static String getHealthcareProviderFilter() {
        List<String> enrollmentsIds = getHealthcareProviderPE();
        if (!enrollmentsIds.isEmpty()) {
            return ' OR ' + 'Id IN (\'' + String.join(enrollmentsIds, '\',\'') + '\'' + ')';
        } else
            return '';
    }

    public static List<String> getHealthcareProviderPE() {
        String contactId = CommunityService.getUserContact().Id;
        List<String> enrollmentsIds = new List<String>();
        List<Healthcare_Provider__c> hpList = [
            SELECT Id, HCP_Enrollment__c, Participant_Enrollment__c
            FROM Healthcare_Provider__c
            WHERE
                HCP_Enrollment__r.HCP_Contact__c = :contactId
                AND Status__c != :ReferHealthcareProviderRemote.HP_S_NOSHARING
        ];
        if (!hpList.isEmpty()) {
            for (Integer i = 0; i < hpList.size(); i++) {
                enrollmentsIds.add(hpList[i].Participant_Enrollment__c);
            }
        }
        return enrollmentsIds;
    }

    public static void updateParticipantState(List<Participant__c> participants) {
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>();
        if (!participants.isEmpty()) {
            enrollments = [
                SELECT Id, Participant__c, Participant_Status__c
                FROM Participant_Enrollment__c
                WHERE Participant__c IN :participants
                ORDER BY Participant__c
            ];
        }
        Map<Id, List<Participant_Enrollment__c>> peByParticipant = new Map<Id, List<Participant_Enrollment__c>>();
        for (Participant_Enrollment__c pe : enrollments) {
            Id partId = pe.Participant__c;
            if (!peByParticipant.containsKey(partId))
                peByParticipant.put(partId, new List<Participant_Enrollment__c>());
            peByParticipant.get(partId).add(pe);
        }

        Map<Id, Participant__c> allParticipants = new Map<Id, Participant__c>();
        for (Participant__c participant : participants)
            allParticipants.put(participant.Id, participant);

        List<Participant__c> updatedParticipants = new List<Participant__c>();
        for (Id partKey : allParticipants.keySet()) {
            if (!peByParticipant.containsKey(partKey))
                continue;

            Participant__c participant = allParticipants.get(partKey);
            participant.Has_Studies_In_Progress__c = false;
            participant.Has_Past_Studies__c = false;
            for (Participant_Enrollment__c pe : peByParticipant.get(partKey)) {
                if (
                    PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_ALL.contains(pe.Participant_Status__c)
                ) {
                    participant.Has_Studies_In_Progress__c = true;
                }
                if (PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pe.Participant_Status__c)) {
                    participant.Has_Past_Studies__c = true;
                }
            }
            updatedParticipants.add(participant);
        }

        if (!updatedParticipants.isEmpty())
            update updatedParticipants;
    }

    public static void updateParticipantStateById(List<Id> participantIds) {
        List<Participant__c> participants = [
            SELECT Id, Has_Studies_In_Progress__c, Has_Past_Studies__c
            FROM Participant__c
            WHERE Id IN :participantIds
        ];
        updateParticipantState(participants);
    }
}