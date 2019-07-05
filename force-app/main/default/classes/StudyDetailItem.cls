/**
 * Created by RAMukhamadeev on 2019-04-16.
 */

public class StudyDetailItem implements Comparable {
    public static String sortType;

    public Clinical_Trial_Profile__c trial;
    public List<StudyActions.Action> studyActions;
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
    public List<Study_Site__c> ssList;
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
            if (compareItem.maxHCPCreatedDate > this.maxHCPCreatedDate || this.maxHCPCreatedDate == null) {
                return 1;
            } else if (this.maxHCPCreatedDate > compareItem.maxHCPCreatedDate || compareItem.maxHCPCreatedDate == null) {
                return -1;
            } else {
                return 0;
            }
        }

        return 0;
    }
}
