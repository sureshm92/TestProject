/**
 * Created by RAMukhamadeev on 2019-04-16.
 */

public without sharing class StudyDetailItem implements Comparable {
    public static String sortType;

    public Clinical_Trial_Profile__c trial;
    public List<StudyActions.Action> studyActions;
    public List<StudyActions.Action> studySitePiActions;
    public Map<String, StudyActions.Action> actionsMap;
    public String studyStatus;
    public Study_Site__c ss;
    public List<StudySiteService.StudySiteDistanceWrapper> sites = new List<StudySiteService.StudySiteDistanceWrapper>();
    public StudySiteService.StudySiteDistanceWrapper site;
    public List<StudyTrialService.EnrollmentWrapper> hcpEnrollments = new List<StudyTrialService.EnrollmentWrapper>();
    public HCP_Enrollment__c hcpe;
    public List<StudyTotalPassed> statistics = new List<StudyTotalPassed>();
    public String trialRecruitmentStatusLabel;
    public Boolean hasHCPEnrollments;
    public Boolean hasActiveHCPEnrollments;
    public String distance;
    public String therapeuticArea;
    public Datetime maxHCPCreatedDate;
    public Boolean hasPatients;
    public List<StudyDetailItem.StudySiteWithActions> ssList = new List<StudyDetailItem.StudySiteWithActions>();

    public String primaryContactName;

    public Integer compareTo(Object compareTo) {
        StudyDetailItem compareItem = (StudyDetailItem) compareTo;
        if (sortType == 'Distance ASC') {
            if (this.sites.isEmpty()) {
                if (compareItem.sites.isEmpty()) {
                    return 0;
                } else {
                    return 1;
                }
            } else if (compareItem.sites.isEmpty()) {
                return -1;
            } else if (this.sites[0].siteType == StudySiteService.SS_TYPE_VIRTUAL) {
                return -1;
            } else if (compareItem.sites[0].siteType == StudySiteService.SS_TYPE_VIRTUAL) {
                return 1;
            } else if (this.sites[0].distance == null) {
                return 1;
            } else if (compareItem.sites[0].distance == null) {
                return -1;
            } else if (this.sites[0].distance > compareItem.sites[0].distance) {
                return 1;
            } else if (this.sites[0].distance < compareItem.sites[0].distance) {
                return -1;
            } else {
                return 0;
            }
        }
        if (sortType == 'CreatedDate DESC') {
            if (
                compareItem.maxHCPCreatedDate > this.maxHCPCreatedDate ||
                this.maxHCPCreatedDate == null
            ) {
                return 1;
            } else if (
                this.maxHCPCreatedDate > compareItem.maxHCPCreatedDate ||
                compareItem.maxHCPCreatedDate == null
            ) {
                return -1;
            } else {
                return 0;
            }
        }
        if (sortType == 'Name') {
            if (
                trial.Study_Code_Name__c.toLowerCase() > this.trial.Study_Code_Name__c.toLowerCase()
            ) {
                return 1;
            } else if (
                trial.Study_Code_Name__c.toLowerCase() < this.trial.Study_Code_Name__c.toLowerCase()
            ) {
                return -1;
            } else {
                return 0;
            }
        }
        return 0;
    }

    public class StudySiteWithActions {
        public Study_Site__c studySite;
        public List<StudyActions.Action> actions;
        public List<Account> accounts;
        public String PIName = '';
        public List<LabelValueItem> delegatePicklist = new List<LabelValueItem>();

        public studySiteWithActions() {
        }

        public studySiteWithActions(
            Study_Site__c studySite,
            List<StudyActions.Action> actions,
            List<Account> accounts,
            Participant__c piParticipantDetail
        ) {
            this.studySite = studySite;
            this.actions = actions;
            this.accounts = accounts;
            if (studySite.Principal_Investigator__c != CommunityService.getUserContact().Id) {
                if(piParticipantDetail!=null){
                    PIName =
                        (piParticipantDetail.Salutation__c == null
                         ? ''
                         : piParticipantDetail.Salutation__c + ' ') +
                        piParticipantDetail.First_Name__c +
                        ' ' +
                        piParticipantDetail.Last_Name__c +
                        (piParticipantDetail.Suffix__c == null
                         ? ''
                         : ' ' + piParticipantDetail.Suffix__c);                    
                }else{
                    PIName =
                        (studySite.Principal_Investigator__r.Salutation == null
                         ? ''
                         : studySite.Principal_Investigator__r.Salutation + ' ') +
                        studySite.Principal_Investigator__r.FirstName +
                        ' ' +
                        studySite.Principal_Investigator__r.LastName +
                        (studySite.Principal_Investigator__r.Suffix == null
                         ? ''
                         : ' ' + studySite.Principal_Investigator__r.Suffix);
                }
            }
        }
    }
}