/**
 * Created by AlexKetch on 5/17/2019.
 */

public with sharing class TrialDetail {
    public Clinical_Trial_Profile__c trial;
    public List<ClinicWrapper> accountEnrollmentsList;
    public Boolean isTCAccepted;
    public Boolean isSSAccepted;
    public Boolean showVisits;
    public Study_Site__c studySite; //for PI mode
    public HCP_Enrollment__c hcpe; //for HCP mode
    public Participant_Enrollment__c pe; //for Participant;
    public string participantstate;
    public List<StudyActions.Action> studyBottomBarActions;
    public Map<String, StudyActions.Action> actions;
    public List<StudyTab> tabs;
    public List<ResourceService.ResourceWrapper> resources;
    public String communityName;
    public Boolean showTravelCardInPreEnrollment;
    public TrialDetail.TabPermission tabvisiblity;
    public List<StudyActions.Action> shareActions = new List<StudyActions.Action>{
        new StudyActions.Action(
            StudyActions.ACT_SHARE_EMAIL,
            StudyActions.LABEL_SHARE,
            'icon-mail',
            false
        ),
        new StudyActions.Action(
            StudyActions.ACT_SHARE_FACEBOOK,
            StudyActions.LABEL_SHARE,
            'facebook',
            false
        ),
        new StudyActions.Action(
            StudyActions.ACT_SHARE_LINKEDIN,
            StudyActions.LABEL_SHARE,
            'linked-in',
            false
        ),
        new StudyActions.Action(
            StudyActions.ACT_SHARE_TWITTER,
            StudyActions.LABEL_SHARE,
            'twitter',
            false
        )
    };

    public class TabPermission{
        public Boolean isFileTabVisiblity;
        public Boolean isPastStudyVisible;
    }

    public class ClinicWrapper implements Comparable {
        public Account clinic; //If there is no completed BillingAddress, the clinic is not displayed on RRGoogleMap
        public String name;
        public String addrStreet;
        public String addrCity;
        public String hcpStatus;
        public String hcpStatusLabel;
        public String studySiteId;
        public String drivingDirection;
        public String otherGuidance;

        public Integer compareTo(Object compareTo) {
            ClinicWrapper compareToCW = (ClinicWrapper) compareTo;
            if (this.hcpStatus != null && compareToCW.hcpStatus == null)
                return -1;
            if (this.hcpStatus == null && compareToCW.hcpStatus != null)
                return 1;
            return 0;
        }
    }

    public class StudyTab {
        public String id;
        public String iconName;
        public String title;
        public List<StudyActions.Action> studyActions;

        public StudyTab(
            String id,
            String iconName,
            String title,
            List<StudyActions.Action> studyActions
        ) {
            this.id = id;
            this.iconName = iconName;
            this.title = title;
            this.studyActions = studyActions;
        }
    }
}
