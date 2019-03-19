/**
 * Created by Leonid Bartenev
 */

public without sharing class PSEService {
    
    public static final List<String> PSE_DEFAULT_FIELDS_LIST = new List<String>{
            'Name',
            'Clinical_Trial_Profile__c',
            'Participant__c',
            'Participant_Enrollment__c',
            'Status__c',
            'Study_Site__c'
    };
    
    public static List<Participant_Study_Enrollment__c> getPSECommon(String userMode, String filter){
        return getPSECustomFields(userMode, PSE_DEFAULT_FIELDS_LIST, filter);
    }
    
    public static List<Participant_Study_Enrollment__c> getPSECustomFields(String userMode, List<String> customFields, String filter){
        String query = 'SELECT ' + String.join(customFields, ',') +
                ' FROM Participant_Enrollment__c ' +
                ' WHERE Study_Site__c != NULL AND ' + getUserModeFilter(userMode);
        if(filter != null) query += ' ' + filter;
        System.debug('EXECUTE QUERY: ' + query);
        List<Participant_Study_Enrollment__c> pseList = Database.query(query);
        TranslateHelper.translate(pseList);
        return pseList;
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
            return 'Participant__r.Contact__c = \'' + CommunityService.getUserContact().Id + '\' ';
        }
    }


}