/**
 * Created by Leonid Bartenev
 */

public without sharing class ViewPatientsRemote {
    public static List<String> pshStatus = new List<String>();

    public static List<String> getPshStatus() {
        if (pshStatus.isEmpty()) {
            for (Promote_to_SH__mdt psl : [
                SELECT DeveloperName, status__c
                FROM Promote_to_SH__mdt
            ]) {
                pshStatus.add(psl.status__c);
            }
        }
        return pshStatus;
    }

    public static final List<String> EXCLUDED_STATUSES_COMMON = new List<String>{
        ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
        ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
        ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING
    };
    public static final List<String> EXCLUDED_STATUSES_PI = new List<String>{
        ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
        ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
        ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING,
        ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL
    };
    public static final List<String> EXCLUDED_REASONS = new List<String>{
        ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED,
        ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING,
        ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED
    };

    public static final List<String> PE_MY_PARTICIPANTS_FIELDS = new List<String>{
        'Id',
        'Clinical_Trial_Profile__c',
        'Clinical_Trial_Profile__r.Id',
        'Clinical_Trial_Profile__r.Study_Sponsor__c',
        'Clinical_Trial_Profile__r.Study_Title__c',
        'Clinical_Trial_Profile__r.Study_Code_Name__c',
        'Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
        'Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
        'Clinical_Trial_Profile__r.Protocol_ID__c',
        'Clinical_Trial_Profile__r.CommunityTemplate__c',
        'Clinical_Trial_Profile__r.Initial_Visit_Required__c',
        'Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c',
        'Clinical_Trial_Profile__r.Promote_to_SH__c',
        'Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c',
        'CreatedDate',
        'Enrolled_Date__c',
        'Enrolled_DateTime__c',
        'HCP__r.HCP_Contact__c',
        'HCP__r.HCP_Contact__r.Name',
        'HCP__r.HCP_Contact__r.FirstName',
        'HCP__r.HCP_Contact__r.LastName',
        'HCP__r.HCP_Contact__r.Email',
        'Days_After_Enrolled__c',
        'Informed_Consent__c',
        'Is_Virtual_Study_Site__c',
        'IsSubjectIDverifiedInSDH__c',
        'Medical_Record_Review_Status__c',
        'Medical_Record_Review_Completedby_Name__c',
        'Motivational_Message_Id__c',
        'MRN_Id__c',
        'MRR_Survey_Results_URL__c',
        'Name',
        'Human_Id__c',
        'Unique_HumanId__c',
        'Non_Referral_Reason__c',
        'Patient_ID__c',
        'Participant_Status__c',
        'Participant_Status_Last_Changed_Date__c',
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
        'Participant__r.Conditions__c',
        'Participant__r.Contact__c',
        'Participant__r.Site__c',
        'Participant_Contact__c',
        'Participant_Contact__r.Is_Patient_User_Created__c',
        'Participant__r.Preferred_Contact_Time__c',
        'PI_Contact__r.Name',
        'PI_Contact__r.Phone',
        'Pre_screening_Status__c',
        'Pre_Eligibility_Date__c',
        'Referred_Date__c',
        'Referred_By__c',
        'Referral_ID__c',
        'Referral_Source__c',
        'Referral_Completedby_Name__c',
        'Source_Type__c',
        'IVRS_IWRS__c',
        'Show_Referring_Provider__c',
        'Study_Name__c',
        'Study_Site__c',
        'Study_Hub_Log__c',
        'Study_Hub_Log__r.Response_Status_Code__c',
        'Study_Site__r.Id',
        'Study_Site__r.Name',
        'Study_Site__r.Is_Virtual_Study_Site__c',
        'Study_Site__r.Study_Site_Type__c',
        'Study_Site__r.Approved_Lng__c',
        'Study_Site__r.Override_PI_Referral_Status__c',
        'Study_Site__r.Clinical_Trial_Profile__c',
        'Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Brief_Summary__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Study_Sponsor__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
        'Study_Site__r.Study_Site_Phone__c',
        'Study_Site__r.Visit_Results_Sharing__c',
        'Study_Site__r.Messages_Are_Available__c',
        'Study_Site__r.SMS_Are_Available__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c',
        'Study_Site__r.Suppress_Participant_Emails__c',
        'Screening_ID__c',
        'Visit_Plan__c',
        'Visit_Plan__r.Name',
        'Washout_Run_In_Applies__c',
        'Final_Consent_Date__c',
        'Informed_Consent_Date__c',
        'Initial_visit_occurred_flag__c',
        'Initial_visit_occurred_date__c',
        'Initial_visit_scheduled_date__c',
        'Initial_visit_scheduled_time__c',
        'PI_Contact__c',
        'Initial_visit_scheduled_flag__c',
        'Revisit_Date__c',
        'Final_consent__c',
        'Non_Enrollment_Reason__c',
        'Last_Status_Changed_Notes__c',
        'HCP_Contact_HCPEnroll__c',
        'HCP_Contact_HCPEnroll__r.Name',
        'HCP__r.Status__c',
        'Permit_Mail_Email_contact_for_this_study__c',
        'Permit_Voice_Text_contact_for_this_study__c',
        'Permit_SMS_Text_for_this_study__c',
        'Permit_IQVIA_to_contact_about_study__c',
        'Site_Communication_Preference__c',
        'Invited_To_PP_Date__c'
    };

    @AuraEnabled
    public static String getInitData(
        Id trialId,
        Id siteId,
        String userMode,
        String delegateId,
        String sponsorName
    ) {
        try {
            List<String> pshStatus = new List<String>();
            for (Promote_to_SH__mdt psl : [
                SELECT DeveloperName, status__c
                FROM Promote_to_SH__mdt
            ]) {
                pshStatus.add(psl.status__c);
            }
            InitData initData = new InitData();
            String additionalFilter = getAdditionalFilter(
                userMode,
                false,
                null,
                sponsorName,
                false,
                false
            );
            initData.paginationData = new PaginationData();
            initData.peFilterData = createPEFilterData(
                userMode == 'PI' ? 'Active' : null,
                trialId,
                siteId,
                userMode,
                true,
                delegateId,
                additionalFilter,
                initData.paginationData,
                sponsorName
            );
            initData.peFilter = new ParticipantEnrollmentService.PEFilter(initData.peFilterData);
            initData.peFilter.studySite = siteId;
            initData.peFilter.study = trialId;
            initData.peFilter.activePE = userMode == 'PI' ? 'Active' : null;
            initData.peFilter.searchFields = new List<String>{
                'Participant__r.First_Name__c',
                'Participant__r.Last_Name__c',
                'Screening_ID__c',
                'Name'
            };
            initData.peFilter.additionalFilter = additionalFilter;
            List<Participant_Enrollment__c> peList;
            if (userMode != CommunityService.USER_MODE_PI) {
                peList = ParticipantEnrollmentService.getParticipantEnrollments(
                    initData.peFilter,
                    delegateId,
                    sponsorName
                );
            } else {
                peList = ParticipantEnrollmentService.getParticipantEnrollmentsCustomFields(
                    PE_MY_PARTICIPANTS_FIELDS,
                    initData.peFilter,
                    delegateId,
                    false,
                    initData.paginationData,
                    sponsorName
                );
            }
            initData.hasEmancipatedParticipants = false;
            //peList = ParticipantEnrollmentService.getParticipantEnrollmentsPaginated(peList, initData.paginationData);
            if (userMode == CommunityService.USER_MODE_PI) {
                TranslateHelper.translate(peList);
            }
            initData.currentPageList = convertToPEWrapperList(peList, userMode, delegateId);
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String getRecords(
        String filterJSON,
        String paginationJSON,
        String userMode,
        String changedItem,
        String delegateId,
        Boolean emancipatedPE,
        String sponsorName
    ) {
        Boolean isEligibilityPassed = false;
        Boolean isSentToSH = false;
        try {
            SearchResult result = new SearchResult();
            result.peFilter = (ParticipantEnrollmentService.PEFilter) JSON.deserialize(
                filterJSON,
                ParticipantEnrollmentService.PEFilter.class
            );
            if (result.peFilter.participantStatus == 'Sent to Study Hub') {
                isSentToSH = true;
                result.peFilter.participantStatus = 'Eligibility Passed';
            } else if (result.peFilter.participantStatus == 'Eligibility Passed') {
                isEligibilityPassed = true;
            }
            result.paginationData = (PaginationData) JSON.deserialize(
                paginationJSON,
                PaginationData.class
            );
            result.peFilter.additionalFilter = getAdditionalFilter(
                userMode,
                emancipatedPE,
                null,
                sponsorName,
                isEligibilityPassed,
                isSentToSH
            );
            updateSearchResultAccordingItemChanged(result, changedItem);
            result.peFilterData = createPEFilterData(
                result.peFilter.activePE,
                result.peFilter.study,
                result.peFilter.studySite,
                userMode,
                true,
                delegateId,
                result.peFilter.additionalFilter,
                result.paginationData,
                sponsorName
            );
            List<Participant_Enrollment__c> peList;
            if (userMode != CommunityService.USER_MODE_PI) {
                peList = ParticipantEnrollmentService.getParticipantEnrollments(
                    result.peFilter,
                    delegateId,
                    sponsorName
                );
            } else {
                peList = ParticipantEnrollmentService.getParticipantEnrollmentsCustomFields(
                    PE_MY_PARTICIPANTS_FIELDS,
                    result.peFilter,
                    delegateId,
                    false,
                    result.paginationData,
                    sponsorName
                );
            }
            //peList = ParticipantEnrollmentService.getParticipantEnrollmentsPaginated(peList, result.paginationData);
            if (userMode == CommunityService.USER_MODE_PI) {
                TranslateHelper.translate(peList);
            }
            result.peList = convertToPEWrapperList(peList, userMode, delegateId);
            return JSON.serialize(result);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String getInitDataForPatientProfile(
        Id participantId,
        String mode,
        String delegateId,
        String sponsorName
    ) {
        try {
            InitDataForPatientProfile initData = new InitDataForPatientProfile();
            //filters data:
            ParticipantEnrollmentService.PEFilterData peFilterData = ParticipantEnrollmentService.getPEFilterData(
                null,
                mode,
                false,
                delegateId
            );
            //init filters:
            ParticipantEnrollmentService.PEFilter peFilter = new ParticipantEnrollmentService.PEFilter(
                peFilterData
            );
            peFilter.additionalFilter = getAdditionalFilter(
                mode,
                false,
                participantId,
                sponsorName,
                false,
                false
            );
            //retrieve records:
            initData.peList = ParticipantEnrollmentService.getParticipantEnrollments(
                peFilter,
                null,
                delegateId,
                sponsorName
            );
            if (initData.peList == null)
                return null;
            initData.participant = [
                SELECT Id, First_Name__c, Last_Name__c, Email__c, Phone__c
                FROM Participant__c
                WHERE Id = :participantId
            ];
            String filter =
                ' AND Participant_Status__c IN (\'' +
                String.join(
                    PEStatusState.STATUS_STEPS_TABLE[4]
                        .states.get(PEStatusState.STATUS_STATE_SUCCESS),
                    '\',\''
                ) +
                '\') ';
            filter += ' AND Participant__c=\'' + participantId + '\'';
            initData.alreadyEnrolled =
                ParticipantEnrollmentService.getPEnrolmentsCountCommon(mode, filter, delegateId) >
                0;
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static Boolean checkHasEmancipatedParticipants(List<Participant_Enrollment__c> peList) {
        for (Participant_Enrollment__c pe : peList) {
            if (pe.Participant__r != null && pe.Participant__r.Emancipation_in_progress__c) {
                return true;
            }
        }
        return false;
    }

    private static List<PEWrapper> convertToPEWrapperList(
        List<Participant_Enrollment__c> participantEnrollments,
        String userMode
    ) {
        return convertToPEWrapperList(participantEnrollments, userMode, null);
    }
    public static List<PEWrapper> convertToPEWrapperList(
        List<Participant_Enrollment__c> participantEnrollments,
        String userMode,
        String delegateId
    ) {
        List<PEWrapper> resultList = new List<PEWrapper>();
        List<ParticipantItem> participantItems = new List<ParticipantItem>();
        Set<Id> idParticipants = new Set<Id>();
        Set<Id> participantIds = new Set<Id>();
        Map<Id, Id> peParticipantMap = new Map<Id, Id>();
        Set<Id> idParticipantsOnUser = new Set<Id>();
        Map<Id, String> refSourceNames = new Map<Id, String>();
        List<Id> refSourceIds = new List<Id>();
        for (Participant_Enrollment__c pe : participantEnrollments) {
            idParticipants.add(pe.Participant_Contact__c);
            peParticipantMap.put(pe.Participant__c, pe.Id);
            participantIds.add(pe.Participant__c);
            if (userMode == CommunityService.USER_MODE_PI) {
                if (pe.Referral_Source__c == Label.RH_PI) {
                    refSourceIds.add(pe.PI_Contact__c);
                } else if (pe.Referral_Source__c == Label.RH_HCP) {
                    refSourceIds.add(pe.HCP__r.HCP_Contact__c);
                }
            }
            if (userMode == CommunityService.USER_MODE_HCP) {
                refSourceIds.add(pe.Study_Site__r.Principal_Investigator__c);
            }
        }
        if (!refSourceIds.isEmpty()) {
            List<Participant__c> RHParticipants = [
                SELECT Id, Contact__c, First_Name__c, Middle_Name__c, Last_Name__c, Suffix__c
                FROM Participant__c
                WHERE Contact__c IN :refSourceIds
            ];
            for (Participant__c RHParticipant : RHParticipants) {
                String Name;
                if (RHParticipant.First_Name__c != null) {
                    Name = Name == null
                        ? RHParticipant.First_Name__c
                        : Name + ' ' + RHParticipant.First_Name__c;
                }
                if (RHParticipant.Middle_Name__c != null) {
                    Name = Name == null
                        ? RHParticipant.Middle_Name__c
                        : Name + ' ' + RHParticipant.Middle_Name__c;
                }
                if (RHParticipant.Last_Name__c != null) {
                    Name = Name == null
                        ? RHParticipant.Last_Name__c
                        : Name + ' ' + RHParticipant.Last_Name__c;
                }
                if (RHParticipant.Suffix__c != null) {
                    Name = Name == null
                        ? RHParticipant.Suffix__c
                        : Name + ' ' + RHParticipant.Suffix__c;
                }
                refSourceNames.put(RHParticipant.Contact__c, Name);
            }
        }

        Map<Id, Integer> cmap = new Map<Id, Integer>();
        for (participant__c p : [
            SELECT id, (SELECT id FROM ContentDocumentLinks)
            FROM participant__c
            WHERE id = :participantIds
        ])
            cmap.put(p.id, p.ContentDocumentLinks.size());
        // system.debug(cmap);
        Map<Id, User> usersMapId = new Map<Id, User>(
            [SELECT Id, ContactId FROM User WHERE ContactId IN :idParticipants]
        );
        for (User us : usersMapId.values()) {
            idParticipantsOnUser.add(us.ContactId);
        }
        for (Participant_Enrollment__c pe : participantEnrollments) {
            PEWrapper newPeWrapper;
            if (userMode == CommunityService.USER_MODE_HCP) {
                String sourceName;
                if (refSourceNames.containsKey(pe.Study_Site__r.Principal_Investigator__c)) {
                    sourceName = refSourceNames.get(pe.Study_Site__r.Principal_Investigator__c);
                }
                newPeWrapper = new PEWrapper(
                    pe,
                    new StudyActionsHCP(pe, delegateId).actions,
                    sourceName
                );
                newPeWrapper.pItem.containsFile = cmap.containsKey(pe.Id)
                    ? cmap.get(pe.Id) > 0
                    : false;
                resultList.add(newPeWrapper);
                participantItems.add(newPeWrapper.pItem);

                //refSourceIds.add(pe.HCP__c);
            } else {
                if (userMode == CommunityService.USER_MODE_PI) {
                    String sourceName;
                    if (
                        pe.Referral_Source__c == Label.RH_PI &&
                        refSourceNames.containsKey(pe.PI_Contact__c)
                    ) {
                        sourceName = refSourceNames.get(pe.PI_Contact__c);
                    } else if (
                        pe.Referral_Source__c == Label.RH_HCP &&
                        refSourceNames.containsKey(pe.HCP__r.HCP_Contact__c)
                    ) {
                        sourceName = refSourceNames.get(pe.HCP__r.HCP_Contact__c);
                    }
                    if (
                        pe.Participant_Contact__c != null &&
                        idParticipantsOnUser.contains(pe.Participant_Contact__c)
                    ) {
                        newPeWrapper = new PEWrapper(
                            pe,
                            new StudyActionsPI(pe).actions,
                            true,
                            sourceName
                        );
                        resultList.add(newPeWrapper);
                        participantItems.add(newPeWrapper.pItem);
                    } else {
                        newPeWrapper = new PEWrapper(
                            pe,
                            new StudyActionsPI(pe).actions,
                            false,
                            sourceName
                        );
                        resultList.add(newPeWrapper);
                        participantItems.add(newPeWrapper.pItem);
                    }
                } else {
                    newPeWrapper = new PEWrapper(pe, new StudyActionsPI(pe).actions);
                    resultList.add(newPeWrapper);
                    participantItems.add(newPeWrapper.pItem);
                }
            }
        }
        ParticipantWorkflowService.populatePatientItemsWithPathWrappers(participantItems);
        return resultList;
    }

    public static Map<String, List<LabelValueItem>> getInterdependentFilterData(
        List<SObject> recordsList,
        Map<String, Map<String, String>> fieldMapping
    ) {
        try {
            Map<String, Map<String, String>> filterData = new Map<String, Map<String, String>>();
            for (SObject obj : recordsList) {
                for (String key : fieldMapping.keySet()) {
                    String fieldLabelValue;
                    String fieldValue;
                    Map<String, String> fields = fieldMapping.get(key);
                    String valueKey = new List<String>(fields.keySet()).get(0);
                    String labelKey = fields.get(valueKey);
                    List<String> fieldsForValues = valueKey.split('\\.');
                    List<String> fieldsForLabels = labelKey.split('\\.');
                    SObject valuesObject = obj;
                    SObject labelObject = obj;
                    for (Integer i = 0, j = fieldsForValues.size(); i < j; i++) {
                        if (i + 1 != j) {
                            valuesObject = valuesObject.getSObject(fieldsForValues[i]);
                        } else {
                            fieldValue = String.valueOf(valuesObject.get(fieldsForValues[i]));
                        }
                    }
                    for (Integer x = 0, y = fieldsForLabels.size(); x < y; x++) {
                        if (x + 1 != y) {
                            labelObject = labelObject.getSObject(fieldsForLabels[x]);
                        } else {
                            fieldLabelValue = String.valueOf(labelObject.get(fieldsForLabels[x]));
                        }
                    }
                    if (filterData.containsKey(key)) {
                        filterData.get(key).put(fieldValue, fieldLabelValue);
                    } else {
                        filterData.put(
                            key,
                            new Map<String, String>{ fieldValue => fieldLabelValue }
                        );
                    }
                }
            }
            Map<String, List<LabelValueItem>> finalfilterData = new Map<String, List<LabelValueItem>>();
            for (String key : filterData.keySet()) {
                Map<String, String> data = filterData.get(key);
                List<LabelValueItem> dataItems = new List<LabelValueItem>();
                for (String dataKey : data.keySet()) {
                    dataItems.add(new LabelValueItem(data.get(dataKey), dataKey));
                }
                finalfilterData.put(key, dataItems);
            }
            return finalfilterData;
        } catch (Exception e) {
            return (Map<String, List<LabelValueItem>>) AuraHelper.throwException(e);
        }
    }

    private static String getAdditionalFilter(
        String mode,
        Boolean emancipatedPE,
        Id participantId,
        String sponsorName,
        Boolean isEligibilityPassed,
        Boolean isSentToSH
    ) {
        String filter =
            ' Participant_Status__c NOT IN ' +
            DatabaseService.listToString(
                (mode != CommunityService.USER_MODE_PI ||
                    participantId != null)
                    ? EXCLUDED_STATUSES_COMMON
                    : EXCLUDED_STATUSES_PI
            );
        if (mode == CommunityService.USER_MODE_HCP && participantId == null) {
            filter +=
                ' AND Non_Referral_Reason__c NOT IN ' +
                DatabaseService.listToString(EXCLUDED_REASONS);
        }
        if (emancipatedPE) {
            filter += ' AND Participant__r.Emancipation_in_progress__c = true ';
        }
        if (participantId != null) {
            filter += ' AND Participant__c=\'' + participantId + '\'';
        }
        //Added filter janssen
        if (sponsorName == CommunityTemplateService.TEMPLATE_JANSSEN) {
            filter +=
                ' AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
                CommunityTemplateService.TEMPLATE_JANSSEN +
                '\' ';
        } else {
            filter +=
                ' AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
                CommunityTemplateService.TEMPLATE_JANSSEN +
                '\' ';
        }
        if (isEligibilityPassed == true) {
            filter +=
                'AND Study_Site__r.Clinical_Trial_Profile__r.Initial_Visit_Required__c = false ' +
                ' AND Study_Site__r.Clinical_Trial_Profile__r.Promote_to_SH__c = false';
        } else if (isSentToSH == true) {
            filter +=
                'AND ( Study_Site__r.Clinical_Trial_Profile__r.Initial_Visit_Required__c = true ' +
                ' OR Study_Site__r.Clinical_Trial_Profile__r.Promote_to_SH__c = true)';
        }
        return filter;
    }

    // Modified for performance tuning
    // Sabir & Velu 09/04/2020
    private static ParticipantEnrollmentService.PEFilterData createPEFilterData(
        String activePE,
        Id trialId,
        Id siteId,
        String mode,
        Boolean restrictTrial,
        String delegateId,
        String additionalFilter,
        PaginationData paginationData,
        String sponsorName
    ) {
        //ParticipantEnrollmentService.PEFilterData filterData = ParticipantEnrollmentService.getPEFilterDataWithExistingPERecords(activePE, trialId, mode, restrictTrial, delegateId, additionalFilter,sponsorName);
        ParticipantEnrollmentService.PEFilterData filterData = ParticipantEnrollmentService.getPEFilterDataWithSponsor(
            mode,
            trialId,
            restrictTrial,
            delegateId,
            sponsorName
        );
        ParticipantEnrollmentService.PEFilter filter = new ParticipantEnrollmentService.PEFilter(
            filterData
        );
        filter.activePE = activePE;
        filter.study = trialId;
        filter.studySite = siteId;
        filter.additionalFilter = additionalFilter;
        filterData.dateField = 'Referred_Date__c';
        filterData.sortVariants.addAll(
            new List<LabelValueItem>{
                new LabelValueItem(
                    SortOrder.ORDER_A_Z,
                    'Alphabetical_ASC,Participant__r.First_Name__c,Participant__r.Last_Name__c'
                ),
                new LabelValueItem(
                    SortOrder.ORDER_Z_A,
                    'Alphabetical_DESC,Participant__r.First_Name__c,Participant__r.Last_Name__c'
                )
            }
        );
        List<LabelValueItem> peSource = new List<LabelValueItem>{
            new LabelValueItem(Label.PG_MRR_L_All_Sources, null),
            new LabelValueItem(Label.Referring_Provider, 'Referring Provider'),
            new LabelValueItem(Label.Principal_Investigator, 'Principal Investigator'),
            new LabelValueItem(Label.Digital_Recruitment, 'Digital Recruitment')
        };

        List<LabelValueItem> statusFilterData;
        if (activePE == 'Active') {
            statusFilterData = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRR_L_All_Statuses, null),
                new LabelValueItem(Label.Received, 'Received'),
                new LabelValueItem(Label.Pre_review_Passed, 'Pre-review Passed'),
                new LabelValueItem(Label.Contact_Attempted, 'Contact Attempted'),
                new LabelValueItem(Label.Successfully_Contacted, 'Successfully Contacted'),
                new LabelValueItem(Label.Screening_In_Progress, 'Screening In Progress'),
                new LabelValueItem(
                    Label.In_Wash_Out_Period,
                    'Screening In Progress - Wash Out Period'
                ),
                new LabelValueItem(Label.Screening_Passed, 'Screening Passed'),
                new LabelValueItem(Label.Enrollment_Success, 'Enrollment Success'),
                new LabelValueItem(Label.Sent_to_Study_Hub, 'Sent to Study Hub'),
                new LabelValueItem(Label.Eligibility_Passed, 'Eligibility Passed'),
                new LabelValueItem(Label.Ready_to_Screen, 'Ready to Screen'),
                new LabelValueItem(Label.Randomization_Success, 'Randomization Success')
            };
        } else {
            statusFilterData = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRR_L_All_Statuses, null),
                new LabelValueItem(Label.Pre_review_Failed, 'Pre-review Failed'),
                new LabelValueItem(Label.Unable_to_Reach, 'Unable to Reach'),
                new LabelValueItem(Label.Contacted_Not_Suitable, 'Contacted - Not Suitable'),
                new LabelValueItem(Label.Eligibility_Failed, 'Eligibility Failed'),
                new LabelValueItem(Label.Declined_Consent, 'Declined Consent'),
                new LabelValueItem(Label.Unable_to_Screen, 'Unable to Screen'),
                new LabelValueItem(Label.Withdrew_Consent, 'Withdrew Consent'),
                new LabelValueItem(Label.Screening_Failed, 'Screening Failed'),
                new LabelValueItem(
                    Label.Withdrew_Consent_After_Screening,
                    'Withdrew Consent After Screening'
                ),
                new LabelValueItem(Label.Enrollment_Failed, 'Enrollment Failed'),
                new LabelValueItem(Label.Randomization_Failed, 'Randomization Failed')
            };
        }
        filterData.statuses = statusFilterData;
        filterData.source = peSource;
        return filterData;
    }

    private static Boolean labelValueItemsHaveItem(
        List<LabelValueItem> labelValueItems,
        String item
    ) {
        for (LabelValueItem lvi : labelValueItems) {
            if (lvi.value == item) {
                return true;
            }
        }
        return false;
    }

    private static void updateSearchResultAccordingItemChanged(
        SearchResult result,
        String changedItem
    ) {
        if (changedItem == 'active' || changedItem == 'emancipation') {
            result.peFilter.study = null;
        }
        if (changedItem == 'active' || changedItem == 'emancipation' || changedItem == 'study') {
            result.peFilter.studySite = null;
        }
        if (
            changedItem == 'active' ||
            changedItem == 'emancipation' ||
            changedItem == 'study' ||
            changedItem == 'site'
        ) {
            result.peFilter.source = null;
            result.peFilter.dateRange = null;
            result.peFilter.participantStatus = null;
            result.peFilter.referringStatus = null;
        }
        if (changedItem != 'filter-pagination' && changedItem != 'pagination') {
            result.paginationData.currentPage = 1;
        }
    }

    public class InitData {
        public ParticipantEnrollmentService.PEFilter peFilter;
        public ParticipantEnrollmentService.PEFilterData peFilterData;
        public List<PEWrapper> currentPageList;
        public PaginationData paginationData;
        public List<Id> trialIds;
        public Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        public List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        public Boolean isInvited;
        public Boolean hasEmancipatedParticipants;
        public Map<Id, String> RefSourceNames;
    }

    public class SearchResult {
        List<PEWrapper> peList;
        PaginationData paginationData;
        ParticipantEnrollmentService.PEFilter peFilter;
        ParticipantEnrollmentService.PEFilterData peFilterData;
        public Map<Id, String> RefSourceNames;
    }

    public class PEWrapper {
        public boolean isInvited;
        public Boolean hasEmancipatedParticipants;
        public boolean sendToSH;
        public Date sendToSHDate;
        public String sendToSHReason;
        public ParticipantItem pItem;
        public Map<String, StudyActions.Action> actions;
        public List<StudyActions.Action> participantCardActions;
        public List<StudyActions.Action> healthcareProviderActions;
        public String sourceName;

        public PEWrapper(Participant_Enrollment__c pe, Map<String, StudyActions.Action> actions) {
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
        }

        public PEWrapper(
            Participant_Enrollment__c pe,
            Map<String, StudyActions.Action> actions,
            String sourceName
        ) {
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
            this.sourceName = sourceName;
        }
        public PEWrapper(
            Participant_Enrollment__c pe,
            Map<String, StudyActions.Action> actions,
            Boolean isInvited
        ) {
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
            this.isInvited = isInvited;
            this.hasEmancipatedParticipants = pe.Participant__r != null
                ? pe.Participant__r.Emancipation_in_progress__c
                : false;
            this.sendToSH = ListViewParticipantController.ifAllowedForSH(pe, getPshStatus(), false);
            this.sendToSHDate = pe != null
                ? ((pe.Participant_Enrollment_Status_History__r != null &&
                      !pe.Participant_Enrollment_Status_History__r.isEmpty())
                      ? (pe.Participant_Enrollment_Status_History__r[0].Date__c != null
                            ? Date.valueOf(pe.Participant_Enrollment_Status_History__r[0].Date__c)
                            : null)
                      : null)
                : null;
            this.sendToSHReason = pe != null
                ? ((pe.Participant_Enrollment_Status_History__r != null &&
                      !pe.Participant_Enrollment_Status_History__r.isEmpty())
                      ? pe.Participant_Enrollment_Status_History__r[0].Non_Enrollment_Reason__c
                      : null)
                : null;
        }

        public PEWrapper(
            Participant_Enrollment__c pe,
            Map<String, StudyActions.Action> actions,
            Boolean isInvited,
            String sourceName
        ) {
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
            this.isInvited = isInvited;
            this.sourceName = sourceName;
            this.hasEmancipatedParticipants = pe.Participant__r != null
                ? pe.Participant__r.Emancipation_in_progress__c
                : false;
            this.sendToSH = ListViewParticipantController.ifAllowedForSH(pe, getPshStatus(), false);
            this.sendToSHDate = pe != null
                ? ((pe.Participant_Enrollment_Status_History__r != null &&
                      !pe.Participant_Enrollment_Status_History__r.isEmpty())
                      ? (pe.Participant_Enrollment_Status_History__r[0].Date__c != null
                            ? Date.valueOf(pe.Participant_Enrollment_Status_History__r[0].Date__c)
                            : null)
                      : null)
                : null;
            this.sendToSHReason = pe != null
                ? ((pe.Participant_Enrollment_Status_History__r != null &&
                      !pe.Participant_Enrollment_Status_History__r.isEmpty())
                      ? pe.Participant_Enrollment_Status_History__r[0].Non_Enrollment_Reason__c
                      : null)
                : null;
        }
    }

    class InitDataForPatientProfile {
        Participant__c participant;
        List<Participant_Enrollment__c> peList;
        Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        Boolean alreadyEnrolled = false;
    }

    @AuraEnabled
    public static Map<Id, String> getPIRefRevNames(List<Id> referralsPIsAndMedRevsContacts) {
        Set<Id> refAndPIContactIDs = new Set<Id>();
        refAndPIContactIDs.addAll(referralsPIsAndMedRevsContacts);
        return ParticipantWorkflowService.getContactFullNamesFromParticipants(refAndPIContactIDs);
    }

    @AuraEnabled
    public static Map<Id, String> getPINames(List<Id> piContacts) {
        return ParticipantWorkflowService.getPIContactNames(piContacts);
    }

    @AuraEnabled
    public static CsvWrapper getExportAllList(
        List<Id> studies,
        List<Id> studySites,
        Integer startPos,
        Integer endPos
    ) {
        CsvWrapper wrap = new CsvWrapper();
        List<Participant_Enrollment__c> lstPER = new List<Participant_Enrollment__c>();
        List<Participant_Enrollment__c> lstPERs = new List<Participant_Enrollment__c>();
        List<WrapRecords> wprc = new List<WrapRecords>();
        String qCountString = 'SELECT COUNT() FROM Participant_Enrollment__c WHERE ';
        String queryString =
            'SELECT Id,Name,PI_Contact__c,PI_Contact__r.Full_Name__c,Non_Enrollment_Reason__c,Medical_Record_Review_Status__c,Medical_Record_Review_Completed_by__c,Medical_Record_Review_Completedby_Name__c,Medical_Record_Review_Completed_Date__c,Referral_Completedby_Name__c,PerCounter__c,Referred_Date__c,Study_Name__c,Participant_Status_Last_Changed_Date__c,Last_Status_Changed_Notes__c,Referral_Completed_by__c,Participant_Name__c,Participant_Contact__c,Referral_Source__c,MRN_Id__c,Patient_ID__c,Referral_ID__c,Study_Hub_Log__c,Study_Hub_Log__r.Response_Status_Code__c,' +
            'Participant__r.Full_Name__c,Participant__r.Age__c,Participant__r.Gender_Technical__c,Participant__r.BMI__c,Study_Site__c,Study_Site__r.Name,Clinical_Trial_Profile__c,' +
            'Clinical_Trial_Profile__r.Study_Code_Name__c,Clinical_Trial_Profile__r.Promote_to_SH__c,Participant__r.Ethnicity__c,' +
            'Source_Type__c,Participant_Status__c,HighRisk_Indicator__c,CreatedDate,Referral_Source_ID__c,' +
            'Initial_visit_scheduled_flag__c,Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c,High_Priority__c,Comorbidities__c FROM Participant_Enrollment__c WHERE ';

        String filter = '';
        filter =
            filter + ' Clinical_Trial_Profile__c IN : studies AND Study_Site__c IN : studySites ';
        String addCondition = '  AND Participant_Status__c  IN (\'Received\',\'Pre-review Passed\',\'In Wash Out Period\',\'Successfully Contacted\',\'Contact Attempted\',\'Eligibility Passed\',\'Screening Passed\',\'Screening In Progress\',\'Screening In Progress - Wash Out Period\',\'Ready to Screen\',\'Enrollment Success\',\'Randomization Success\',\'Pre-review Failed\',\'Unable to Reach\',\'Contacted - Not Suitable\',\'Eligibility Failed\',\'Declined Consent\',\'Unable to Screen\',\'Withdrew Consent\',\'Screening Failed\', \'Withdrew Consent After Screening\', \'Enrollment Failed\', \'Randomization Failed\')';
        filter = filter + addCondition;
        String queryCount = qCountString + filter;
        String strTemp = ' AND PerCounter__c >= :startPos ' + ' AND PerCounter__c <= :endPos ';
        filter = filter + strTemp;
        String sortBy = ' ORDER BY ';
        sortBy += ' Name ASC';
        String OffsetLimit = ' LIMIT 49500';
        String Query = queryString + filter + sortBy + OffsetLimit;
        system.debug('@@@@@@@@ ' + Query);
        lstPER = Database.query(Query);
        Integer totalCount = Database.countQuery(queryCount);
        List<String> FOVTime = new List<String>();
        Set<Id> referralsPIsAndMedRevsContacts = new Set<Id>();
        for (Participant_Enrollment__c per : lstPER) {
            referralsPIsAndMedRevsContacts.add(per.Referral_Completed_by__c);
            String Fovtim = String.ValueOf(per.Initial_visit_scheduled_time__c);
            if (Fovtim != '' && Fovtim != null) {
                FOVTime.add(Fovtim.replace('.000Z', ''));
            } else {
                FOVTime.add('');
            }
            lstPERs.add(per);
            String initialVisitScheduleTime = String.ValueOf(per.Initial_visit_scheduled_time__c);
            if (initialVisitScheduleTime != '' && initialVisitScheduleTime != null) {
                initialVisitScheduleTime = initialVisitScheduleTime.replace('.000Z', '');
            } else {
                initialVisitScheduleTime = '';
            }
            wprc.add(new WrapRecords(per, initialVisitScheduleTime));
        }

        //wrap.partList = lstPERs;
        //wrap.initialVisitScheduleTime=FOVTime;
        wrap.startPos = startPos;
        wrap.endPos = endPos;
        wrap.totalCount = totalCount;
        wrap.referralsPIsAndMedRevsContacts = referralsPIsAndMedRevsContacts;
        wrap.partLists = wprc;
        return wrap;
    }

    public class CsvWrapper {
        @AuraEnabled
        public List<Participant_Enrollment__c> partList { get; set; }
        @AuraEnabled
        public List<Id> studies { get; set; }
        @AuraEnabled
        public List<String> initialVisitScheduleTime { get; set; }
        @AuraEnabled
        public List<Id> studySites { get; set; }
        @AuraEnabled
        public Integer startPos { get; set; }
        @AuraEnabled
        public Integer endPos { get; set; }
        @AuraEnabled
        public Integer totalCount { get; set; }
        @AuraEnabled
        public Set<Id> referralsPIsAndMedRevsContacts { get; set; }
        @AuraEnabled
        public List<WrapRecords> partLists { get; set; }
    }
    public class WrapRecords {
        @AuraEnabled
        public Participant_Enrollment__c pe { get; set; }
        @AuraEnabled
        public String initialVisitScheduleTime { get; set; }

        public WrapRecords(Participant_Enrollment__c pe, String initialVisitScheduleTime) {
            this.pe = pe;
            this.initialVisitScheduleTime = initialVisitScheduleTime;
        }
    }

    //fix REF-4633
    @AuraEnabled
    public static String getDelAcceslevel(String delegateId) {
        return CommunityService.getInstance().getUserAccessLevel(delegateId);
    }
    //
}
