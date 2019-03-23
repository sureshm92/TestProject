/**
 * Created by Leonid Bartenev
 */

public without sharing class PSEService {
    
    public static final String PSE_STATUS_ENROLLED = 'Enrolled';
    public static final String PSE_STATUS_TREATMENT_PERIOD_STARTED = 'Treatment Period Started';
    public static final String PSE_STATUS_FOLLOW_UP_PERIOD_STARTED = 'Follow-Up Period Started';
    public static final String PSE_STATUS_PARTICIPATION_COMPLETE = 'Participation Complete';
    public static final String PSE_STATUS_TRIAL_COMPLETE = 'Trial Complete';
    
    public static final List<String> PSE_STATUS_GROUP_ALL = new List<String>{
            PSE_STATUS_ENROLLED,
            PSE_STATUS_TREATMENT_PERIOD_STARTED,
            PSE_STATUS_FOLLOW_UP_PERIOD_STARTED,
            PSE_STATUS_PARTICIPATION_COMPLETE,
            PSE_STATUS_TRIAL_COMPLETE
    };
    
    public static final List<String> PSE_STATUS_GROUP_COMPLETE = new List<String>{
            PSE_STATUS_PARTICIPATION_COMPLETE,
            PSE_STATUS_TRIAL_COMPLETE
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
            'Study_Site__r.Site__r.Name'
    };
    
    public static List<Participant_Study_Enrollment__c> getPSECommon(String userMode, String filter){
        return getPSECustomFields(userMode, PSE_DEFAULT_FIELDS_LIST, filter);
    }
    
    public static List<Participant_Study_Enrollment__c> getPSECustomFields(String userMode, List<String> customFields, String filter){
        String query =
                'SELECT ' + String.join(customFields, ',') +
                ' FROM Participant_Study_Enrollment__c ' +
                ' WHERE Study_Site__c != NULL AND ' + getUserModeFilter(userMode);
        if(filter != null) query += ' ' + filter;
        System.debug('EXECUTE QUERY: ' + query);
        List<Participant_Study_Enrollment__c> pseList = Database.query(query);
        TranslateHelper.translate(pseList);
        return pseList;
    }
    
    public static List<Participant_Study_Enrollment__c> getPSEListForParticipant(){
        return getPSECommon(CommunityService.USER_MODE_PARTICIPANT, null);
    }
    
    private static String getUserModeFilter(String userMode){
        String delegatesFilter = '';
        if (userMode == CommunityService.USER_MODE_PI) {
            List<Id> delegatedSSIds = DelegateService.getDelegatedStudySiteIds();
            if(delegatedSSIds.size() > 0) delegatesFilter = ' OR Study_Site__c IN (\'' + String.join(delegatedSSIds, '\',\'') + '\')' ;
            return '( ' +
                    '   Study_Site__r.Principal_Investigator__c = \'' + CommunityService.getUserContact().Id + '\' ' +
                    delegatesFilter +
                    ') ';
        } else if(userMode == CommunityService.USER_MODE_HCP) {
            List<Id> delegatedHCPEIds = DelegateService.getDelegatedHCPEnrollmentIds();
            if(delegatedHCPEIds.size() > 0) delegatesFilter = '   OR HCP__c IN (\'' + String.join(delegatedHCPEIds, '\',\'') + '\')';
            return '(' +
                    '   HCP__r.HCP_Contact__c = \'' + CommunityService.getUserContact().Id + '\'' +
                    delegatesFilter +
                    ') ';
        } else{
            List<Id> delegatedParticipantIds = PatientDelegateService.getDelegatedParticipantIds();
            delegatesFilter = ' OR Participant__c IN (\'' + String.join(delegatedParticipantIds, '\',\'') + '\')';
            return '( ' +
                    '   Participant__r.Contact__c = \'' + CommunityService.getUserContact().Id + '\' ' +
                    delegatesFilter +
                    ')';
        }
    }


}