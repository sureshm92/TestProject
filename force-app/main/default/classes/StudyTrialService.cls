/**
 * Created by D.Yasinskyi on 26.02.2018
 */

public without sharing class StudyTrialService {
    private static List<String> TRIAL_FIELDS = new List<String>{
            'Id',
            'Name',
            'Study_Sponsor__c',
            'Detailed_Description__c',
            'Override_Recruitment_Status__c',
            'Terms_And_Conditions_ID__c',
            'Link_to_Medical_Record_Review__c',
            'Link_to_Pre_screening__c',
            'Study_Title__c',
            'Study_Code_Name__c',
            'Official_Title__c',
            'Sponsor_Pays_for_Referral_Activity__c',
            'Override_Inclusion_Criteria__c',
            'Override_Description__c'
    };

    public class StudyFilterData {
        public String enrollmentStatus;
        public List<LabelValueItem> enrollmentStatuses;
        public String therapeuticArea;
        public List<LabelValueItem> therapeuticAreas;
        public String searchText;
    }

    public class StudySortData {
        public String sortType;
        public List<LabelValueItem> sortVariants;
    }

    public class StudyDetailItem {
        public Clinical_Trial_Profile__c trial;
        public List<StudyActions.Action> studyActions;
        public String studyStatus;
        public Study_Site__c ss;
        public List<HCP_Enrollment__c> hcpEnrollments = new List<HCP_Enrollment__c>();
        public HCP_Enrollment__c hcpe;
        public Integer nearestSiteDistance;
        public List<StudyTotalPassed> statistics = new List<StudyTotalPassed>();
        public String trialRecruitmentStatusLabel;
        public Boolean hasHCPEnrollments;
    }

    public class SearchResults {
        public List<StudyDetailItem> records;
        public PaginationData paginationData;
    }

    public static StudyFilterData getStudyFilterData() {
        StudyFilterData filterData = new StudyFilterData();

        filterData.therapeuticArea = 'All Therapeutic Areas';
        filterData.therapeuticAreas = new List<LabelValueItem>{
                new LabelValueItem('Therapeutic Area 1', 'Therapeutic Area 1'),
                new LabelValueItem('Therapeutic Area 2', 'Therapeutic Area 2'),
                new LabelValueItem('Therapeutic Area 3', 'Therapeutic Area 3')
        };

        filterData.enrollmentStatus = 'Actively Enrolling';
        filterData.enrollmentStatuses = new List<LabelValueItem>{
                new LabelValueItem('Actively Enrolling', 'Actively Enrolling'),
                new LabelValueItem('On Hold', 'On Hold'),
                new LabelValueItem('Enrollment Closed', 'Enrollment Closed'),
                new LabelValueItem('No Longer Enrolling', 'No_Longer_Enrolling')
        };

        return filterData;
    }

    public static StudySortData getStudySortData() {
        StudySortData sortData = new StudySortData();
        sortData.sortType = SortOrder.SORT_TYPES[0].value;
        sortData.sortVariants = SortOrder.SORT_TYPES;

        return sortData;
    }

    public static StudySortData getStudySortDataForHCP() {
        StudySortData sortData = new StudySortData();
        sortData.sortType = SortOrder.STUDIES_HCP_SORT_TYPES[0].value;
        sortData.sortVariants = SortOrder.STUDIES_HCP_SORT_TYPES;

        return sortData;
    }

    public static String getStudiesJSON(String filterDataJSON, String sortDataJSON, String paginationDataJSON, Boolean isSearchResume) {
        StudyFilterData filterData = (StudyFilterData) JSON.deserialize(filterDataJSON, StudyFilterData.class);
        StudySortData sortData = (StudySortData) JSON.deserialize(sortDataJSON, StudySortData.class);
        PaginationData paginationData = (PaginationData) JSON.deserialize(paginationDataJSON, PaginationData.class);

        List<StudyDetailItem> studies = new List<StudyTrialService.StudyDetailItem>();
        if (isSearchResume) {
            studies = searchStudiesGlobal(filterData, sortData, paginationData);
        } else {
            studies = getStudies(filterData, sortData, paginationData);
        }

        SearchResults sr = new SearchResults();
        sr.records = studies;
        sr.paginationData = paginationData;

        return JSON.serialize(sr);
    }

    public static void enrichEnrollmentRecords(List<HCP_Enrollment__c> enrollments) {
        Set<Id> studySiteIds = new Set<Id>();
        for (HCP_Enrollment__c currEnrollment : enrollments) {
            studySiteIds.add(currEnrollment.Study_Site__c);
        }

        Map<Id, Study_Site__c> idToStudySite = new Map<Id, Study_Site__c>([
                SELECT Id,
                        Site__r.Name,
                        Principal_Investigator__r.Name,
                        Principal_Investigator__r.Title,
                        Principal_Investigator__r.Email,
                        Principal_Investigator__r.Phone,
                        Principal_Investigator__r.MailingAddress,
                        Is_Virtual_Study_Site__c
                FROM Study_Site__c
                WHERE Id IN :studySiteIds
        ]);

        for (HCP_Enrollment__c currEnrollment : enrollments) {
            Study_Site__c currStudySite = idToStudySite.get(currEnrollment.Study_Site__c);

            currEnrollment.Study_Site__r.Site__r = currStudySite.Site__r;
            currEnrollment.Study_Site__r.Principal_Investigator__r = currStudySite.Principal_Investigator__r;
            currEnrollment.Study_Site__r.Is_Virtual_Study_Site__c = currStudySite.Is_Virtual_Study_Site__c;
        }
    }

    public static List<StudyDetailItem> searchStudiesGlobal(StudyFilterData filterData, StudySortData sortData, PaginationData paginationData) {
        String query = 'SELECT ' + String.join(TRIAL_FIELDS, ', ') + ' FROM Clinical_Trial_Profile__c WHERE ';
        query += '(Override_Recruitment_Status__c = \'Actively Enrolling\') ';

        if (filterData.searchText != null && filterData.searchText.length() >= 3) {
            query += 'AND (Study_Code_Name__c LIKE \'%' + filterData.searchText + '%\') ';
        }

        if (sortData.sortType == 'CreatedDate DESC') {
            query += 'ORDER BY CreatedDate DESC ';
        }
        if (sortData.sortType == 'Distance ASC') {
            query += 'ORDER BY Study_Code_Name__c ASC ';
        }
        query += 'LIMIT 50';
        List<Clinical_Trial_Profile__c> trials = Database.query(query);

        List<Clinical_Trial_Profile__c> trialsOnPage = new List<Clinical_Trial_Profile__c>();
        Integer leftRecord = (paginationData.currentPage - 1) * paginationData.pageRecordsCount;
        Integer rightRecord = Math.min(leftRecord + paginationData.pageRecordsCount, trials.size());
        for (Integer i = leftRecord; i < rightRecord; i++) {
            trialsOnPage.add(trials[i]);
        }
        paginationData.setRecordsCount(trials.size());

        String contactId = CommunityService.getUserContact().Id;
        List<HCP_Enrollment__c> relatedEnrollments = [
                SELECT Id, Clinical_Trial_Profile__c
                FROM HCP_Enrollment__c
                WHERE HCP_Contact__c = :contactId
                AND Clinical_Trial_Profile__c != NULL
        ];
        Map<Id, List<HCP_Enrollment__c>> trialIdToEnrollments = new Map<Id, List<HCP_Enrollment__c>>();
        for (HCP_Enrollment__c currEnrollment : relatedEnrollments) {
            if (!trialIdToEnrollments.containsKey(currEnrollment.Clinical_Trial_Profile__c)) {
                trialIdToEnrollments.put(currEnrollment.Clinical_Trial_Profile__c, new List<HCP_Enrollment__c>());
            }
            trialIdToEnrollments.get(currEnrollment.Clinical_Trial_Profile__c).add(currEnrollment);
        }

        List<StudyDetailItem> pageRecords = new List<StudyDetailItem>();
        StudyActions.Action openStudySite = new StudyActions.Action('linkToStudySites', 'Find Sites For This Study', 'icon-12', false);
        for (Clinical_Trial_Profile__c trial : trialsOnPage) {
            StudyTrialService.StudyDetailItem studyDetailItem = new StudyTrialService.StudyDetailItem();
            studyDetailItem.trial = trial;
            studyDetailItem.studyActions = new List<StudyActions.Action>{
                    openStudySite
            };
            studyDetailItem.trialRecruitmentStatusLabel = TranslateHelper.getPickListLabel(Clinical_Trial_Profile__c.Override_Recruitment_Status__c, trial.Override_Recruitment_Status__c);
            studyDetailItem.hasHCPEnrollments = trialIdToEnrollments.get(trial.Id) != null && trialIdToEnrollments.get(trial.Id).size() > 0;
            pageRecords.add(studyDetailItem);
        }

        return pageRecords;
    }

    public static List<StudyDetailItem> getStudies(StudyFilterData filterData, StudySortData sortData, PaginationData paginationData) {
        // prepare enrollment records
        List<HCP_Enrollment__c> enrollments = HCPEnrollmentService.getHCPEnrollmentsForHCP();
        enrichEnrollmentRecords(enrollments);

        Map<Id, List<HCP_Enrollment__c>> trialHCPEnrollmentMap = new Map<Id, List<HCP_Enrollment__c>>();
        for (HCP_Enrollment__c enrollment : enrollments) {
            if (!trialHCPEnrollmentMap.containsKey(enrollment.Study_Site__r.Clinical_Trial_Profile__c)) {
                trialHCPEnrollmentMap.put(enrollment.Study_Site__r.Clinical_Trial_Profile__c, new List<HCP_Enrollment__c>());
            }
            trialHCPEnrollmentMap.get(enrollment.Study_Site__r.Clinical_Trial_Profile__c).add(enrollment);
        }


        // get trials with fields and TC:
        List<Clinical_Trial_Profile__c> trials = StudyTrialService.searchTrials(trialHCPEnrollmentMap.keySet(), filterData, sortData, paginationData);

        // prepare list of studies:
        List<StudyDetailItem> pageRecords = new List<StudyDetailItem>();
        for (Clinical_Trial_Profile__c trial : trials) {

            StudyTrialService.StudyDetailItem studyDetailItem = new StudyTrialService.StudyDetailItem();
            studyDetailItem.hcpEnrollments = trialHCPEnrollmentMap.get(trial.Id);
            studyDetailItem.trial = trial;
            studyDetailItem.hcpe = studyDetailItem.hcpEnrollments[0];

            // TODO: STATUS AND ACTIONS??
            studyDetailItem.studyStatus = studyDetailItem.hcpEnrollments[0].Status__c;
            studyDetailItem.studyActions = (new StudyActionsHCP(studyDetailItem.hcpEnrollments[0])).studyListViewItemActions;

            studyDetailItem.trialRecruitmentStatusLabel = TranslateHelper.getPickListLabel(Clinical_Trial_Profile__c.Override_Recruitment_Status__c, trial.Override_Recruitment_Status__c);
            pageRecords.add(studyDetailItem);
        }

        System.debug('in getStudies');
        System.debug(JSON.serializePretty(pageRecords));

        return pageRecords;
    }

    public static List<Clinical_Trial_Profile__c> getTrials(Set<Id> trialsId) {
        return [
                SELECT Id
                        , Name
                        , Study_Sponsor__c
                        , Detailed_Description__c
                        , Override_Recruitment_Status__c
                        , Terms_And_Conditions_ID__c
                        , Link_to_Medical_Record_Review__c
                        , Link_to_Pre_screening__c
                        , Study_Title__c
                        , Study_Code_Name__c
                        , Official_Title__c
                        , Sponsor_Pays_for_Referral_Activity__c

                FROM Clinical_Trial_Profile__c
                WHERE Id IN :trialsId
        ];
    }

    public static List<Clinical_Trial_Profile__c> searchTrials(Set<Id> trialsId, StudyFilterData filterData, StudySortData sortData, PaginationData paginationData) {
        List<String> searchFields = new List<String>{
                'Official_Title__c',
                'Study_Code_Name__c',
                'Study_Sponsor__c',
                'Override_Inclusion_Criteria__c',
                'Override_Description__c'
        };

        String trialQuery = 'SELECT ' + String.join(TRIAL_FIELDS, ', ') + ' FROM Clinical_Trial_Profile__c WHERE (Id IN :trialsId) ';
        if (sortData.sortType == 'Distance ASC') {
            trialQuery += ' ORDER BY Study_Code_Name__c ASC ';
        } else {
            trialQuery += ' ORDER BY ' + sortData.sortType;
        }
        List<Clinical_Trial_Profile__c> trials = Database.query(trialQuery);

        List<Clinical_Trial_Profile__c> trialsOnPage = new List<Clinical_Trial_Profile__c>();
        Integer leftRecord = (paginationData.currentPage - 1) * paginationData.pageRecordsCount;
        Integer rightRecord = Math.min(leftRecord + paginationData.pageRecordsCount, trials.size());
        for (Integer i = leftRecord; i < rightRecord; i++) {
            trialsOnPage.add(trials[i]);
        }
        paginationData.setRecordsCount(trials.size());


        List<Clinical_Trial_Profile__c> records = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c currTrial : trialsOnPage) {

            Boolean isMatchTerm = true;
            if (String.isNotBlank(filterData.searchText)) {
                Boolean matchSearchText = false;
                for (String field : searchFields) {
                    String fieldValue = (String) currTrial.get(field);
                    if (fieldValue.indexOfIgnoreCase(filterData.searchText) != -1) {
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

            if (isMatchTerm && isMatchEnrollmentFilter) {
                records.add(currTrial);
            }
        }

        return records;
    }

    public static List<Clinical_Trial_Profile__c> getFullTrials(Set<Id> trialsId) {
        return [
                SELECT Id
                        , Orientation_Required__c
                        , Name
                        , Terms_And_Conditions_ID__c
                        , Study_Sponsor__c
                        , Study_Type__c
                        , Detailed_Description__c
                        , Override_Recruitment_Status__c
                        , Brief_Summary__c
                        , Override_Description__c
                        , Override_Inclusion_Criteria__c
                        , Override_Exclusion_Criteria__c
                        , Condition_s_Therapeutic_Area__c
                        , Sponsor_Pays_for_Referral_Activity__c
                        , Study_Phase__c
                        , NCT_Number__c
                        , Protocol_ID__c
                        , Enrollment_Start_Date__c
                        , Enrolled_End_Date__c
                        , Link_to_Medical_Record_Review__c
                        , Link_to_Pre_screening__c
                        , Study_Title__c
                        , Study_Code_Name__c
                        , Official_Title__c
                        , Interventions__c
                FROM Clinical_Trial_Profile__c
                WHERE Id IN :trialsId
        ];
    }

    public static Clinical_Trial_Profile__c getFullTrial(Id trialId) {
        List<Clinical_Trial_Profile__c> trials = getFullTrials(new Set<Id>{
                trialId
        });
        if (trials.size() > 0) return trials[0];
        return null;
    }
}