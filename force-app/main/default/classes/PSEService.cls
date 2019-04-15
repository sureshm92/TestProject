/**
 * Created by Leonid Bartenev
 */

public without sharing class PSEService {
    
    public static final String PSE_STATUS_ENROLLED = 'Enrolled';
    public static final String PSE_STATUS_TREATMENT_PERIOD_STARTED = 'Treatment Period Started';
    public static final String PSE_STATUS_FOLLOW_UP_PERIOD_STARTED = 'Follow-Up Period Started';
    public static final String PSE_STATUS_PARTICIPATION_COMPLETE = 'Participation Complete';
    public static final String PSE_STATUS_TRIAL_COMPLETE = 'Trial Complete';
    public static final String PSE_STATUS_DROP_OUT = 'Drop Out';
    public static final String PSE_STATUS_DECEASED = 'Deceased';

    public static final List<String> PSE_STATUS_GROUP_ALL = new List<String>{
            PSE_STATUS_ENROLLED,
            PSE_STATUS_TREATMENT_PERIOD_STARTED,
            PSE_STATUS_FOLLOW_UP_PERIOD_STARTED,
            PSE_STATUS_PARTICIPATION_COMPLETE,
            PSE_STATUS_TRIAL_COMPLETE
    };

    public static final List<String> PSE_STATUS_GROUP_COMPLETE = new List<String>{
            PSE_STATUS_PARTICIPATION_COMPLETE,
            PSE_STATUS_TRIAL_COMPLETE,
            PSE_STATUS_DROP_OUT,
            PSE_STATUS_DECEASED
    };
    
    public static final List<String> PSE_DEFAULT_FIELDS_LIST = new List<String>{
            'Name',
            'Clinical_Trial_Profile__c',
            'Clinical_Trial_Profile__r.Profile_Picture__c',
            'Clinical_Trial_Profile__r.Study_Title__c',
            'Clinical_Trial_Profile__r.Study_Code_Name__c',
            'Clinical_Trial_Profile__r.Study_Sponsor__c',
            'Clinical_Trial_Profile__r.Detailed_Description__c',
            'Clinical_Trial_Profile__r.Official_Title__c',
            'Clinical_Trial_Profile__r.Orientation_Required__c',
            'Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
            'Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
            'Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
            'Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
            'Clinical_Trial_Profile__r.Baseline_Survey_URL__c',
            'Clinical_Trial_Profile__r.Visit_Plan__c',
            'Participant__c',
            'Participant__r.First_Name__c',
            'Participant__r.Last_Name__c',
            'Participant__r.Full_Name__c',
            'Participant__r.Email__c',
            'Participant__r.Phone__c',
            'Participant__r.Mailing_State__c',
            'Participant__r.Mailing_State_Code__c',
            'Participant__r.Mailing_Country__c',
            'Participant__r.Mailing_Country_Code__c',
            'Participant__r.Mailing_Zip_Postal_Code__c',
            'Participant__r.Contact__c',
            'Participant_Enrollment__c',
            'Status__c',
            'Study_Site__c',
            'Study_Site__r.Name',
            'Study_Site__r.Override_PI_Referral_Status__c',
            'Study_Site__r.Site__r.Name',
            'Motivational_Message_Id__c'
    };
    
    private static PSEService instance;
    
    public static PSEService getInstance(){
        if(instance == null) instance = new PSEService();
        return instance;
    }
    
    public static void setMock(StubProvider stubProvider){
        instance = (PSEService) Test.createStub(PSEService.class, stubProvider);
    }
    
    public List<Participant_Study_Enrollment__c> getPSEListCommon(String userMode, String filter){
        return getPSEListWithCustomFields(userMode, PSE_DEFAULT_FIELDS_LIST, filter);
    }
    
    public List<Participant_Study_Enrollment__c> getPSEListWithCustomFields(String userMode, List<String> customFields, String filter){
        String defaultFilter = 'Study_Site__c != NULL AND ' + getUserModeFilter(userMode);
        if(filter != null) defaultFilter += ' ' + filter;
        List<Participant_Study_Enrollment__c> pseList = DatabaseService.query(
                customFields,
                Participant_Study_Enrollment__c.getSObjectType(),
                defaultFilter
        );
        TranslateHelper.translate(pseList);
        return pseList;
    }
    
    public List<Participant_Study_Enrollment__c> getPSEListForCurrentParticipant(){
        return getPSEListCommon(CommunityService.USER_MODE_PARTICIPANT, null);
    }
    
    //Static facade: ------------------------------------------------------------------------------------------------
    
    public static List<Participant_Study_Enrollment__c> getPSECommon(String userMode, String filter){
        return getInstance().getPSEListCommon(userMode, filter);
    }
    
    public static List<Participant_Study_Enrollment__c> getPSECustomFields(String userMode, List<String> customFields, String filter){
        return getInstance().getPSEListWithCustomFields(userMode, customFields, filter);
    }
    
    public static List<Participant_Study_Enrollment__c> getPSEListForParticipant(){
        return getInstance().getPSEListForCurrentParticipant();
    }
    
    @TestVisible
    private static String getUserModeFilter(String userMode){
        String delegatesFilter = '';
        if (userMode == CommunityService.USER_MODE_PI) {
            List<Id> delegatedSSIds = DelegateService.getDelegatedStudySiteIds();
            if(delegatedSSIds.size() > 0) delegatesFilter = ' OR Study_Site__c IN (\'' + String.join(delegatedSSIds, '\',\'') + '\')' ;
            return '( ' +
                    '   Study_Site__r.Principal_Investigator__c = \'' + CommunityService.getInstance().getCurrentContactId() + '\' ' +
                    delegatesFilter +
                    ') ';
        } else if(userMode == CommunityService.USER_MODE_HCP) {
            List<Id> delegatedHCPEIds = DelegateService.getDelegatedHCPEnrollmentIds();
            if(delegatedHCPEIds.size() > 0) delegatesFilter = '   OR HCP__c IN (\'' + String.join(delegatedHCPEIds, '\',\'') + '\')';
            return '(' +
                    '   HCP__r.HCP_Contact__c = \'' + CommunityService.getInstance().getCurrentContactId() + '\'' +
                    delegatesFilter +
                    ') ';
        } else{
            if(PatientDelegateService.getInstance().isDelegate()){
                delegatesFilter = ' OR Participant__c = \'' + PatientDelegateService.getInstance().getParticipant().Id + '\' ';
            }
            return '( ' +
                    '   Participant__r.Contact__c = \'' + CommunityService.getInstance().getCurrentContactId() + '\' ' +
                    delegatesFilter +
                    ')';
        }
    }


}