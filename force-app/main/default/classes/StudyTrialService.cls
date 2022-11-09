/**
 * Created by D.Yasinskyi on 26.02.2018
 */

public without sharing class StudyTrialService {
    public static String ACTIVELY_ENROLLING_STATUS = 'Actively Enrolling';

    private static List<String> TRIAL_FIELDS = new List<String>{
        'Id',
        'Name',
        'Study_Sponsor__c',
        'Detailed_Description__c',
        'Override_Recruitment_Status__c',
        'Terms_And_Conditions_ID__c',
        'Link_to_Medical_Record_Review__c',
        'Link_to_Pre_screening__c',
        'Share_URL__c',
        'Study_Title__c',
        'Study_Code_Name__c',
        'Official_Title__c',
        'Sponsor_Pays_for_Referral_Activity__c',
        'Override_Inclusion_Criteria__c',
        'Override_Description__c',
        'Brief_Summary__c',
        'Therapeutic_Area__r.Name',
        'NCT_Number__c'
    };

    private static List<String> TRIAL_SEARCH_FIELDS = new List<String>{
        'Official_Title__c',
        'Study_Code_Name__c',
        'Study_Sponsor__c',
        'Override_Inclusion_Criteria__c',
        'Brief_Summary__c'
    };

    public class StudyFilterData {
        public String enrollmentStatus;
        public List<LabelValueItem> enrollmentStatuses;
        public String therapeuticArea;
        public List<LabelValueItem> therapeuticAreas;
        public String distance;
        public List<LabelValueItem> distances;
        public String searchText;
    }

    public class StudySortData {
        public String sortType;
        public List<LabelValueItem> sortVariants;
    }

    public class EnrollmentWrapper {
        public HCP_Enrollment__c enrollment;
        public Boolean isActivated;
        public Boolean isDeclined;
        public Boolean isPending;
    }

    public class SearchResults {
        public List<StudyDetailItem> records;
        public List<LabelValueItem> therapeuticAreas;
        public PaginationData paginationData;
    }

    private static List<LabelValueItem> studyEnrollmentStatuses = null;
    public static List<LabelValueItem> getStudyEnrollmentStatuses {
        get {
            if (studyEnrollmentStatuses == null) {
                List<LabelValueItem> enrollmentStatuses = new List<LabelValueItem>();
                Schema.DescribeFieldResult statusDescribe = Clinical_Trial_Profile__c.Override_Recruitment_Status__c.getDescribe();
                for (Schema.PicklistEntry currPicklistEntry : statusDescribe.getPicklistValues()) {
                    enrollmentStatuses.add(
                        new LabelValueItem(
                            currPicklistEntry.getLabel(),
                            currPicklistEntry.getValue()
                        )
                    );
                }

                studyEnrollmentStatuses = enrollmentStatuses;
            }
            return studyEnrollmentStatuses;
        }
    }

    public static List<LabelValueItem> therapeuticAreaFilterOptions;

    public static StudyFilterData getStudyFilterData() {
        StudyFilterData filterData = new StudyFilterData();

        filterData.enrollmentStatuses = getStudyEnrollmentStatuses;
        filterData.enrollmentStatus = getStudyEnrollmentStatuses[0].value;

        filterData.therapeuticAreas = therapeuticAreaFilterOptions;
        filterData.therapeuticArea = null;

        filterData.distances = new List<LabelValueItem>{
            new LabelValueItem(Label.PG_SFS_L_Any_distance, null),
            new LabelValueItem('5   ' + DistanceHelper.getUnitsOfMeasurementLabel(), '5'),
            new LabelValueItem('15  ' + DistanceHelper.getUnitsOfMeasurementLabel(), '15'),
            new LabelValueItem('30  ' + DistanceHelper.getUnitsOfMeasurementLabel(), '30'),
            new LabelValueItem('60  ' + DistanceHelper.getUnitsOfMeasurementLabel(), '60'),
            new LabelValueItem('150 ' + DistanceHelper.getUnitsOfMeasurementLabel(), '150'),
            new LabelValueItem('300 ' + DistanceHelper.getUnitsOfMeasurementLabel(), '300')
        };
        filterData.distance = null;

        return filterData;
    }

    public static StudySortData getStudySortData() {
        StudySortData sortData = new StudySortData();
        sortData.sortType = SortOrder.SORT_TYPES[0].value;
        sortData.sortVariants = SortOrder.SORT_TYPES;

        return sortData;
    }

    public static PaginationData getPaginationData() {
        PaginationData pd = new PaginationData();
        pd.pageRecordsCount = 5;
        pd.recordCountVariants = new List<LabelValueItem>{
            new LabelValueItem('3', '3'),
            new LabelValueItem('5', '5'),
            new LabelValueItem('10', '10')
        };

        return pd;
    }

    public static StudySortData getStudySortDataForHCP() {
        StudySortData sortData = new StudySortData();
        sortData.sortType = SortOrder.STUDIES_HCP_SORT_TYPES[0].value;
        sortData.sortVariants = SortOrder.STUDIES_HCP_SORT_TYPES;

        return sortData;
    }

    public static String getStudiesJSON(
        String filterDataJSON,
        String sortDataJSON,
        String paginationDataJSON,
        Boolean isSearchResume
    ) {
        return getStudiesJSON(
            filterDataJSON,
            sortDataJSON,
            paginationDataJSON,
            isSearchResume,
            null,
            null
        );
    }

    public static String getStudiesJSON(
        String filterDataJSON,
        String sortDataJSON,
        String paginationDataJSON,
        Boolean isSearchResume,
        String delegateId,
        String userMode
    ) {
        StudyFilterData filterData = (StudyFilterData) JSON.deserialize(
            filterDataJSON,
            StudyFilterData.class
        );
        StudySortData sortData = (StudySortData) JSON.deserialize(
            sortDataJSON,
            StudySortData.class
        );
        PaginationData paginationData = (PaginationData) JSON.deserialize(
            paginationDataJSON,
            PaginationData.class
        );

        List<StudyDetailItem> studies = new List<StudyDetailItem>();
        System.debug('IS SEARCH RESUME>>>>>' + isSearchResume);
        if (isSearchResume) {
            studies = searchStudiesGlobal(
                filterData,
                sortData,
                paginationData,
                delegateId,
                userMode
            );
        } else {
            studies = getStudies(filterData, sortData, paginationData, delegateId);
        }

        SearchResults sr = new SearchResults();
        sr.records = studies;
        sr.paginationData = paginationData;
        sr.therapeuticAreas = therapeuticAreaFilterOptions;

        return JSON.serialize(sr);
    }

    public static List<String> transformToStudySiteFields(List<String> fields) {
        String prefix = 'Clinical_Trial_Profile__r.';

        List<String> res = new List<String>();
        for (String currField : fields) {
            res.add(prefix + currField);
        }

        return res;
    }

    public static List<StudyDetailItem> searchStudiesGlobal(
        StudyFilterData filterData,
        StudySortData sortData,
        PaginationData paginationData,
        String delegateId,
        String userMode
    ) {
        Location userLocation = DistanceHelper.getUserLocation();
        Contact userContact = CommunityService.getUserContact();
        String userCountry;
        if (userContact.MailingCountry != null && userContact.MailingCountry != '') {
            userCountry = userContact.MailingCountry;
        } else {
            userCountry = 'United States';
        }
        String query =
            'SELECT ' +
            String.join(transformToStudySiteFields(TRIAL_FIELDS), ', ') +
            ', Name, Principal_Investigator__r.Account.BillingLatitude, Principal_Investigator__r.Account.BillingLongitude, Principal_Investigator__r.Account.BillingGeocodeAccuracy, Site__c, Study_Site_Type__c FROM Study_Site__c WHERE ';
        if (userMode == 'HCP') {
            query +=
                '(Clinical_Trial_Profile__r.Override_Recruitment_Status__c = \'' +
                ACTIVELY_ENROLLING_STATUS +
                '\' AND Clinical_Trial_Profile__r.Include_in_RP_trial_search__c = TRUE' +
                '  AND Override_PI_Referral_Status__c != NULL ' +
                '  AND Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
                CommunityTemplateService.TEMPLATE_JANSSEN +
                '\' ' +
                '  AND Override_PI_Referral_Status__c IN (\'' +
                String.join(StudySiteService.STATUS_GROUP_ACCEPTED, '\',\'') +
                '\')' +
                '  AND Principal_Investigator__r.Account.BillingCountry = :userCountry ' +
                ') ';
        } else {
            query +=
                '(Clinical_Trial_Profile__r.Override_Recruitment_Status__c = \'' +
                ACTIVELY_ENROLLING_STATUS +
                '\' AND Clinical_Trial_Profile__r.Include_in_RP_trial_search__c = TRUE' +
                '  AND Override_PI_Referral_Status__c != NULL ' +
                '  AND Override_PI_Referral_Status__c IN (\'' +
                String.join(StudySiteService.STATUS_GROUP_ACCEPTED, '\',\'') +
                '\')' +
                '  AND Principal_Investigator__r.Account.BillingCountry = :userCountry ' +
                ') ';
        }

        if (sortData.sortType == 'CreatedDate DESC') {
            query += 'ORDER BY CreatedDate DESC ';
        }

        if (sortData.sortType == 'Distance ASC') {
            if (userLocation != null) {
                query +=
                    'ORDER BY DISTANCE(Principal_Investigator__r.Account.BillingAddress, GEOLOCATION(' +
                    userLocation.Latitude +
                    ', ' +
                    userLocation.Longitude +
                    '), \'mi\') ASC NULLS LAST ';
            }
        }
        List<Study_Site__c> allStudySites = Database.query(query);
        Map<Id, List<Study_Site__c>> trialIdToStudySites = new Map<Id, List<Study_Site__c>>();
        List<Clinical_Trial_Profile__c> trials = new List<Clinical_Trial_Profile__c>();
        for (Study_Site__c currStudySite : allStudySites) {
            if (!trialIdToStudySites.containsKey(currStudySite.Clinical_Trial_Profile__r.Id)) {
                trialIdToStudySites.put(
                    currStudySite.Clinical_Trial_Profile__r.Id,
                    new List<Study_Site__c>()
                );
                trials.add(currStudySite.Clinical_Trial_Profile__r);
            }
            trialIdToStudySites.get(currStudySite.Clinical_Trial_Profile__r.Id).add(currStudySite);
        }

        Map<Id, Double> trialIdToDistance = new Map<Id, Double>();
        Set<Id> trialsWithVirtualSites = new Set<Id>();
        for (Id currTrialId : trialIdToStudySites.keySet()) {
            Double minDistance;
            for (Study_Site__c currStudySite : trialIdToStudySites.get(currTrialId)) {
                if (currStudySite.Study_Site_Type__c == StudySiteService.SS_TYPE_VIRTUAL) {
                    trialsWithVirtualSites.add(currTrialId);
                } else {
                    Double currDistance = DistanceHelper.calculateDistanceTo(
                        currStudySite.Principal_Investigator__r.Account
                    );
                    if (currDistance != null) {
                        if (minDistance == null) {
                            minDistance = currDistance;
                        } else if (minDistance > currDistance) {
                            minDistance = currDistance;
                        }
                    }
                }
            }
            if (minDistance != null) {
                trialIdToDistance.put(currTrialId, minDistance);
            }
        }
        if (sortData.sortType == 'Distance ASC') {
            List<Clinical_Trial_Profile__c> tempStudies = new List<Clinical_Trial_Profile__c>();
            List<Clinical_Trial_Profile__c> tempStudiesWithVirtual = new List<Clinical_Trial_Profile__c>();
            for (Clinical_Trial_Profile__c study : trials) {
                if (trialsWithVirtualSites.contains(study.Id)) {
                    tempStudiesWithVirtual.add(study);
                } else {
                    tempStudies.add(study);
                }
            }
            tempStudiesWithVirtual.addAll(tempStudies);
            trials = tempStudiesWithVirtual;
        }
        // search and filters
        Double currMaxDistance = String.isNotBlank(filterData.distance)
            ? Double.valueOf(filterData.distance)
            : null;
        List<Clinical_Trial_Profile__c> filteredTrials = new List<Clinical_Trial_Profile__c>();
        List<Clinical_Trial_Profile__c> filteredByDistanceTrials = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c currTrial : trials) {
            Boolean isMatchTerm = true;
            Boolean isMatchTherapeuticAreaFilter = true;
            Boolean isMatchDistance = true;
            if (String.isNotBlank(filterData.searchText)) {
                isMatchTerm = false;
                for (String field : TRIAL_SEARCH_FIELDS) {
                    String fieldValue = (String) currTrial.get(field);
                    if (
                        fieldValue != null &&
                        fieldValue.indexOfIgnoreCase(filterData.searchText) != -1
                    ) {
                        isMatchTerm = true;
                        break;
                    }
                }
            }

            if (
                String.isNotBlank(filterData.therapeuticArea) &&
                currTrial.Therapeutic_Area__r.Name != filterData.therapeuticArea
            ) {
                isMatchTherapeuticAreaFilter = false;
            }

            Double distance = trialIdToDistance.get(currTrial.Id);
            if (
                currMaxDistance != null &&
                (distance == null ||
                distance > currMaxDistance) &&
                !trialsWithVirtualSites.contains(currTrial.Id)
            ) {
                isMatchDistance = false;
            }

            if (isMatchTerm && isMatchTherapeuticAreaFilter && isMatchDistance) {
                filteredTrials.add(currTrial);
            }
            if (isMatchDistance) {
                filteredByDistanceTrials.add(currTrial);
            }
        }

        setTherapeuticAreaFilterOptions(filteredByDistanceTrials, filterData.therapeuticArea);

        List<Clinical_Trial_Profile__c> trialsOnPage = new List<Clinical_Trial_Profile__c>();
        Integer leftRecord = (paginationData.currentPage - 1) * paginationData.pageRecordsCount;
        Integer rightRecord = Math.min(
            leftRecord + paginationData.pageRecordsCount,
            filteredTrials.size()
        );
        for (Integer i = leftRecord; i < rightRecord; i++) {
            trialsOnPage.add(filteredTrials[i]);
        }
        paginationData.setRecordsCount(filteredTrials.size());

        Map<Id, List<HCP_Enrollment__c>> trialIdToEnrollments = getTrialIdToEnrollments();

        List<StudyDetailItem> pageRecords = new List<StudyDetailItem>();

        for (Clinical_Trial_Profile__c trial : trialsOnPage) {
            StudyActions.Action openStudySite = new StudyActionsHCP(trial, null, null, delegateId)
                .actions.get(StudyActions.ACT_HCP_LINK_STUDY_SITES);
            StudyDetailItem studyDetailItem = new StudyDetailItem();
            studyDetailItem.trial = trial;
            studyDetailItem.studyActions = new List<StudyActions.Action>{ openStudySite };
            studyDetailItem.trialRecruitmentStatusLabel = TranslateHelper.getPickListLabel(
                Clinical_Trial_Profile__c.Override_Recruitment_Status__c,
                trial.Override_Recruitment_Status__c
            );
            studyDetailItem.hasHCPEnrollments =
                trialIdToEnrollments.get(trial.Id) != null &&
                trialIdToEnrollments.get(trial.Id).size() > 0;
            if (trialIdToDistance.get(trial.Id) != null) {
                studyDetailItem.distance =
                    DistanceHelper.roundDouble(trialIdToDistance.get(trial.Id)) +
                    '&nbsp;' +
                    DistanceHelper.getUnitsOfMeasurementLabel();
            }
            studyDetailItem.therapeuticArea = trial.Therapeutic_Area__r.Name;
            pageRecords.add(studyDetailItem);
        }

        return pageRecords;
    }

    private static Map<Id, List<HCP_Enrollment__c>> getTrialIdToEnrollments() {
        String contactId = CommunityService.getUserContact().Id;
        List<HCP_Enrollment__c> relatedEnrollments = [
            SELECT Id, Clinical_Trial_Profile__c
            FROM HCP_Enrollment__c
            WHERE HCP_Contact__c = :contactId AND Clinical_Trial_Profile__c != NULL
        ];
        Map<Id, List<HCP_Enrollment__c>> trialIdToEnrollments = new Map<Id, List<HCP_Enrollment__c>>();
        for (HCP_Enrollment__c currEnrollment : relatedEnrollments) {
            if (!trialIdToEnrollments.containsKey(currEnrollment.Clinical_Trial_Profile__c)) {
                trialIdToEnrollments.put(
                    currEnrollment.Clinical_Trial_Profile__c,
                    new List<HCP_Enrollment__c>()
                );
            }
            trialIdToEnrollments.get(currEnrollment.Clinical_Trial_Profile__c).add(currEnrollment);
        }
        return trialIdToEnrollments;
    }

    public static List<StudyDetailItem> getStudies(
        StudyFilterData filterData,
        StudySortData sortData,
        PaginationData paginationData,
        String delegateId
    ) {
        StudySiteService.SiteFilter siteFilter = new StudySiteService.SiteFilter(
            new StudySiteService.SiteFilterData()
        );
        siteFilter.sortType = StudySiteService.SS_SORT_TYPE_DISTANCE;
        siteFilter.onlyAcceptedSites = false;
        List<StudySiteService.StudySiteDistanceWrapper> studySites = StudySiteService.getStudySitesWithDistanceForHCPByTrialId(
            siteFilter,
            null,
            true,
            delegateId
        );
        Set<Id> trialsWithActiveEnrollments = new Set<Id>();
        Map<Id, List<StudySiteService.StudySiteDistanceWrapper>> trialStudyMap = new Map<Id, List<StudySiteService.StudySiteDistanceWrapper>>();
        for (StudySiteService.StudySiteDistanceWrapper siteWrapper : studySites) {
            if (!trialStudyMap.containsKey(siteWrapper.site.Clinical_Trial_Profile__c)) {
                trialStudyMap.put(
                    siteWrapper.site.Clinical_Trial_Profile__c,
                    new List<StudySiteService.StudySiteDistanceWrapper>()
                );
            }
            trialStudyMap.get(siteWrapper.site.Clinical_Trial_Profile__c).add(siteWrapper);
            if (siteWrapper.hasActiveHCPE) {
                trialsWithActiveEnrollments.add(siteWrapper.site.Clinical_Trial_Profile__c);
            }
        }

        // get trials with fields and TC:
        List<Clinical_Trial_Profile__c> trials = StudyTrialService.searchTrials(
            trialStudyMap.keySet(),
            filterData,
            sortData
        );

        Set<Id> trialsWithPatients = new Set<Id>();
        Set<Id> trialIds = new Set<Id>();
        for (Clinical_Trial_Profile__c trial : trials) {
            trialIds.add(trial.Id);
        }
        //        String delegatesFilter = '';
        //        List<Id> delegatedHCPEIds = DelegateService.getDelegatedHCPEnrollmentIds();
        //        if(delegatedHCPEIds.size() > 0) delegatesFilter = '   OR HCP__c IN (\'' + String.join(delegatedHCPEIds, '\',\'') + '\')';
        String contactId = CommunityService.getUserContact().Id;
        if (delegateId != null && delegateId != '') {
            contactId = delegateId;
        }
        List<String> peId = ParticipantEnrollmentService.getHealthcareProviderPE();
        String healthCareProviderfilter = '';
        if (!peId.isEmpty()) {
            healthCareProviderfilter =
                ' OR (' +
                'Id IN (\'' +
                String.join(peId, '\',\'') +
                '\') ' +
                ') ';
        }
        String query =
            'SELECT Id, Clinical_Trial_Profile__c FROM Participant_Enrollment__c WHERE Clinical_Trial_Profile__c IN :trialIds AND ' +
            '(' +
            '   HCP__r.HCP_Contact__c = \'' +
            contactId +
            '\'' +
            healthCareProviderfilter +
            //                delegatesFilter +
            ') ';
        for (Participant_Enrollment__c pe : Database.query(query)) {
            trialsWithPatients.add(pe.Clinical_Trial_Profile__c);
        }

        // prepare list of studies:
        List<StudyDetailItem> pageRecords = new List<StudyDetailItem>();
        for (Clinical_Trial_Profile__c trial : trials) {
            StudyDetailItem studyDetailItem = new StudyDetailItem();
            studyDetailItem.sites = trialStudyMap.get(trial.Id);
            studyDetailItem.maxHCPCreatedDate = getMaxHCPCreatedDate(trialStudyMap.get(trial.Id));
            studyDetailItem.trial = trial;
            studyDetailItem.site = studyDetailItem.sites[0];
            for (StudySiteService.StudySiteDistanceWrapper siteWrapper : studyDetailItem.sites) {
                if (
                    siteWrapper.hcpe.Status__c != HCPEnrollmentService.HCP_S_INVITATION_SENT &&
                    siteWrapper.siteType != StudySiteService.SS_TYPE_VIRTUAL
                ) {
                    studyDetailItem.distance = siteWrapper.formatedDistance;
                    break;
                }
            }
            //studyDetailItem.distance = studyDetailItem.sites[0].formatedDistance;
            studyDetailItem.therapeuticArea = trial.Therapeutic_Area__r.Name;
            studyDetailItem.hasActiveHCPEnrollments = trialsWithActiveEnrollments.contains(
                trial.Id
            );
            studyDetailItem.hasPatients = trialsWithPatients.contains(trial.Id);
            List<StudyActions.Action> availableActions = new List<StudyActions.Action>();
            Boolean isAcceptTCAvail = false;
            for (StudySiteService.StudySiteDistanceWrapper siteWrapper : studyDetailItem.sites) {
                siteWrapper.hasPatients = studyDetailItem.hasPatients;
                StudyActionsHCP currSA = new StudyActionsHCP(siteWrapper.hcpe, delegateId);
                studyDetailItem.actionsMap = currSA.actions;
                List<StudyActions.Action> currActions = currSA.studyListViewItemActions;
                if (!studyDetailItem.hasActiveHCPEnrollments) {
                    StudyActions.Action openStudySite = currSA.actions.get(
                        StudyActions.ACT_HCP_LINK_STUDY_SITES
                    );
                    currActions.add(openStudySite);
                }
                if (studyDetailItem.hasPatients) {
                    StudyActions.Action myPatients = currSA.actions.get(
                        StudyActions.ACT_MY_PATIENTS
                    ); //new StudyActions.Action(StudyActions.ACT_MY_PATIENTS, StudyActions.LABEL_MY_PATIENTS, 'referrals', false);
                    currActions.add(myPatients);
                }
                if (studyDetailItem.trial.Terms_And_Conditions_ID__c != null) {
                    if (!isAcceptTCAvail) {
                        for (StudyActions.Action action : currActions) {
                            if (action.id == StudyActions.ACT_ACCEPT_TC) {
                                isAcceptTCAvail = true;
                                break;
                            }
                        }
                    }

                    StudyActions.Action tcAction = currSA.actions.get(StudyActions.ACT_VIEW_TC);
                    currActions.add(tcAction);
                }
                availableActions.addAll(currActions);
            }

            Map<String, StudyActions.Action> actionIdToAction = new Map<String, StudyActions.Action>();
            for (StudyActions.Action currAction : availableActions) {
                if (!isAcceptTCAvail || currAction.id != StudyActions.ACT_VIEW_TC) {
                    if (actionIdToAction.containsKey(currAction.id)) {
                        StudyActions.Action existAction = actionIdToAction.get(currAction.id);
                        if (existAction.disabled && !currAction.disabled) {
                            actionIdToAction.put(currAction.id, currAction);
                        }
                    } else {
                        actionIdToAction.put(currAction.id, currAction);
                    }
                }
            }

            studyDetailItem.studyActions = actionIdToAction.values();

            studyDetailItem.trialRecruitmentStatusLabel = TranslateHelper.getPickListLabel(
                Clinical_Trial_Profile__c.Override_Recruitment_Status__c,
                trial.Override_Recruitment_Status__c
            );
            pageRecords.add(studyDetailItem);
        }

        if (sortData.sortType != null) {
            StudyDetailItem.sortType = sortData.sortType;
            pageRecords.sort();
        }

        paginationData.setRecordsCount(pageRecords.size());
        List<StudyDetailItem> trialsOnPage = new List<StudyDetailItem>();
        Integer leftRecord = (paginationData.currentPage - 1) * paginationData.pageRecordsCount;
        Integer rightRecord = Math.min(
            leftRecord + paginationData.pageRecordsCount,
            pageRecords.size()
        );
        for (Integer i = leftRecord; i < rightRecord; i++) {
            trialsOnPage.add(pageRecords[i]);
        }

        return trialsOnPage;
    }

    private static Datetime getMaxHCPCreatedDate(
        List<StudySiteService.StudySiteDistanceWrapper> studySites
    ) {
        Datetime res = null;
        if (studySites != null) {
            for (StudySiteService.StudySiteDistanceWrapper studySite : studySites) {
                if (
                    studySite.hcpCreatedDate != null &&
                    (res == null ||
                    res < studySite.hcpCreatedDate)
                ) {
                    res = studySite.hcpCreatedDate;
                }
            }
        }

        return res;
    }

    public static List<Clinical_Trial_Profile__c> getTrials(Set<Id> trialsId) {
        return [
            SELECT
                Id,
                Name,
                Study_Sponsor__c,
                Detailed_Description__c,
                Brief_Summary__c,
                Override_Recruitment_Status__c,
                Terms_And_Conditions_ID__c,
                Link_to_Medical_Record_Review__c,
                Link_to_Pre_screening__c,
                Study_Title__c,
                Study_Code_Name__c,
                Official_Title__c,
                Sponsor_Pays_for_Referral_Activity__c,
                NCT_Number__c,
                Share_URL__c
            FROM Clinical_Trial_Profile__c
            WHERE Id IN :trialsId
            ORDER BY Study_Code_Name__c
        ];
    }

    public static void setTherapeuticAreaFilterOptions(
        List<Clinical_Trial_Profile__c> trials,
        String selectedOption
    ) {
        Set<String> options = new Set<String>();
        for (Clinical_Trial_Profile__c currTrial : trials) {
            if (
                currTrial.Therapeutic_Area__r != null &&
                currTrial.Therapeutic_Area__r.Name != null
            ) {
                options.add(currTrial.Therapeutic_Area__r.Name);
            }
        }
        if (String.isNotBlank(selectedOption)) {
            options.add(selectedOption);
        }
        List<String> sortedOptions = new List<String>(options);
        sortedOptions.sort();
        therapeuticAreaFilterOptions = new List<LabelValueItem>();
        therapeuticAreaFilterOptions.add(
            new LabelValueItem(Label.PG_SFS_L_All_Therapeutic_Areas, null)
        );
        for (String currOption : sortedOptions) {
            therapeuticAreaFilterOptions.add(new LabelValueItem(currOption, currOption));
        }
    }

    public static List<Clinical_Trial_Profile__c> searchTrials(
        Set<Id> trialsId,
        StudyFilterData filterData,
        StudySortData sortData
    ) {
        String trialQuery =
            'SELECT ' +
            String.join(TRIAL_FIELDS, ', ') +
            ' FROM Clinical_Trial_Profile__c WHERE (Id IN :trialsId) ';
        List<Clinical_Trial_Profile__c> trials = Database.query(trialQuery);

        List<Clinical_Trial_Profile__c> records = new List<Clinical_Trial_Profile__c>();
        List<Clinical_Trial_Profile__c> recordsFilteredByEnrollmentStatus = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c currTrial : trials) {
            Boolean isMatchTerm = true;
            if (String.isNotBlank(filterData.searchText)) {
                Boolean matchSearchText = false;
                for (String field : TRIAL_SEARCH_FIELDS) {
                    String fieldValue = (String) currTrial.get(field);
                    if (
                        fieldValue != null &&
                        fieldValue.indexOfIgnoreCase(filterData.searchText) != -1
                    ) {
                        matchSearchText = true;
                        break;
                    }
                }

                if (!matchSearchText) {
                    isMatchTerm = false;
                }
            }

            Boolean isMatchEnrollmentFilter = true;
            if (currTrial.Override_Recruitment_Status__c != filterData.enrollmentStatus) {
                isMatchEnrollmentFilter = false;
            }

            Boolean isMatchTherapeuticAreaFilter = true;
            if (
                String.isNotBlank(filterData.therapeuticArea) &&
                currTrial.Therapeutic_Area__r.Name != filterData.therapeuticArea
            ) {
                isMatchTherapeuticAreaFilter = false;
            }

            if (isMatchTerm && isMatchEnrollmentFilter && isMatchTherapeuticAreaFilter) {
                records.add(currTrial);
            }
            if (isMatchEnrollmentFilter) {
                recordsFilteredByEnrollmentStatus.add(currTrial);
            }
        }
        setTherapeuticAreaFilterOptions(
            recordsFilteredByEnrollmentStatus,
            filterData.therapeuticArea
        );

        return records;
    }

    public static List<Clinical_Trial_Profile__c> getFullTrials(Set<Id> trialsId) {
        return [
            SELECT
                Id,
                Orientation_Required__c,
                Name,
                Terms_And_Conditions_ID__c,
                Study_Sponsor__c,
                Study_Type__c,
                Detailed_Description__c,
                Override_Recruitment_Status__c,
                Brief_Summary__c,
                Override_Description__c,
                Override_Inclusion_Criteria__c,
                Override_Exclusion_Criteria__c,
                Condition_s_Therapeutic_Area__c,
                Sponsor_Pays_for_Referral_Activity__c,
                Study_Phase__c,
                NCT_Number__c,
                Protocol_ID__c,
                Enrollment_Start_Date__c,
                Enrolled_End_Date__c,
                Link_to_Medical_Record_Review__c,
                Link_to_Pre_screening__c,
                Study_Title__c,
                Study_Code_Name__c,
                Official_Title__c,
                Interventions__c,
                Participant_Workflow_Final_Step__c,
                Initial_Visit_Required__c,
                Final_Consent_Required__c,
                Patient_Portal_Enabled__c
            FROM Clinical_Trial_Profile__c
            WHERE Id IN :trialsId
        ];
    }

    public static Clinical_Trial_Profile__c getFullTrial(Id trialId) {
        List<Clinical_Trial_Profile__c> trials = getFullTrials(new Set<Id>{ trialId });
        if (trials.size() > 0)
            return trials[0];
        return null;
    }
}
