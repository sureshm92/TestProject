/**
 * Created by Leonid Bartenev
 */

public class DelegateService {
    
    public static String OWNER_LEVEL = 'All';
    public static String DELEGATE_LEVEL_1 = 'Level 1';
    public static String DELEGATE_LEVEL_2 = 'Level 2';
    public static String DELEGATE_LEVEL_3 = 'Level 3';

    public static final List<String> DELEGATE_LEVEL_1_AND_LOW = new List<String>{
            DELEGATE_LEVEL_1,
            DELEGATE_LEVEL_2,
            DELEGATE_LEVEL_3
    };
    public static final List<String> DELEGATE_LEVEL_2_AND_LOW = new List<String>{
            DELEGATE_LEVEL_2,
            DELEGATE_LEVEL_3
    };


    private static Map<Id, String> piStudySitesAccessLevelMap;
    private static Map<Id, String> hcpEnrollmentsAccessLevelMap;
    private static Map<Id, String> piStudiesAccessLevel;
    private static Map<Id, String> hcpStudiesAccessLevel;
    private static Map<Id, Id> studyPIContactsMap;
    private static Map<Id, Id> studyHCPContactsMap;
    private static Map<Id, Map<Id,Site_Staff__c>> piTeamStaffTrialMap;
    private static Map<Id, Map<Id,Referring_HCP_Staff__c>> hcpTeamStaffTrialMap;
    
    public static final String ACCESS_LEVEL_ALL = 'All';
    
    public static Map<Id, String> getPIStudySitesAccessLevelMap(){
        if(piStudySitesAccessLevelMap == null) init();
        return piStudySitesAccessLevelMap;
    }
    
    public static Map<Id, String> getHCPEnrollmentAccessLevelMap(){
        if(hcpEnrollmentsAccessLevelMap == null) init();
        return hcpEnrollmentsAccessLevelMap;
    }
    
    public static List<Id> getDelegatedHCPEnrollmentIds(){
        return new List<Id>(getHCPEnrollmentAccessLevelMap().keySet());
    }
    
    public static List<Id> getDelegatedStudySiteIds(){
        return new List<Id>(getPIStudySitesAccessLevelMap().keySet());
    }
    
    public static Map<Id, Id> getStudyPIContactsMap(){
        if(studyPIContactsMap == null) init();
        return studyPIContactsMap;
    }
    
    public static Map<Id, Id> getStudyHCPContactsMap(){
        if(studyHCPContactsMap == null) init();
        return studyHCPContactsMap;
    }

    public static Map<Id, Map<Id,Site_Staff__c>> getPITeamStaffTrialMap(){
        if(piTeamStaffTrialMap == null) init();
        return piTeamStaffTrialMap;
    }

    public static Map<Id, Map<Id,Referring_HCP_Staff__c>> getHCPTeamStaffTrialMap(){
        if(hcpTeamStaffTrialMap == null) init();
        return hcpTeamStaffTrialMap;
    }
    
    public static Id getContactId(Id studyId, String userMode){
        Id contactId;
        if(userMode == CommunityService.USER_MODE_PI){
            contactId = getStudyPIContactsMap().get(studyId);
        }else if(userMode == CommunityService.USER_MODE_HCP){
            contactId = getStudyHCPContactsMap().get(studyId);
        }
        if(contactId != null) return contactId;
        return CommunityService.getUserContact().Id;
    }
    
    public static Map<Id, String> getStudiesAccessLevelMap(String userMode){
        if(userMode == CommunityService.USER_MODE_PI){
            if(piStudiesAccessLevel == null) init();
            return piStudiesAccessLevel;
        }else{
            if(hcpStudiesAccessLevel == null) init();
            return hcpStudiesAccessLevel;
        }
    }
    
    public static String getStudyAccessLevel(Id studyId, String userMode){
        String accessLevel = getStudiesAccessLevelMap(userMode).get(studyId);
        if(accessLevel != null) return accessLevel;
        return ACCESS_LEVEL_ALL;
    }
    
    public static void init(){
        List<Site_Staff__c> piStaffs = [
                SELECT Id, Study_Site__c,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Clinical_Trial_Profile__c,
                        Delegate_Level__c,
                        Site_Contact__c
                FROM Site_Staff__c
                WHERE Site_Contact__c =: CommunityService.getUserContact().Id
                OR Study_Site__r.Principal_Investigator__c =: CommunityService.getUserContact().Id
        ];
        piStudySitesAccessLevelMap = new Map<Id, String>();
        piStudiesAccessLevel = new Map<Id, String>();
        studyPIContactsMap = new Map<Id, Id>();
        piTeamStaffTrialMap = new Map<Id, Map<Id,Site_Staff__c>>();
        for(Site_Staff__c siteStaff : piStaffs) {
            if(siteStaff.Site_Contact__c == CommunityService.getUserContact().Id){
                piStudySitesAccessLevelMap.put(siteStaff.Study_Site__c, siteStaff.Delegate_Level__c);
                piStudiesAccessLevel.put(siteStaff.Study_Site__r.Clinical_Trial_Profile__c, siteStaff.Delegate_Level__c);
                studyPIContactsMap.put(siteStaff.Study_Site__r.Clinical_Trial_Profile__c, siteStaff.Study_Site__r.Principal_Investigator__c);
            }
            if(siteStaff.Study_Site__r.Principal_Investigator__c == CommunityService.getUserContact().Id){
                if(!piTeamStaffTrialMap.containsKey(siteStaff.Site_Contact__c)){
                    piTeamStaffTrialMap.put(siteStaff.Site_Contact__c, new Map<Id,Site_Staff__c>());
                }
                piTeamStaffTrialMap.get(siteStaff.Site_Contact__c).put(siteStaff.Study_Site__c,siteStaff);
            }

        }
    
        List<Referring_HCP_Staff__c> hcpStaffs = [
                SELECT Id, Delegate_Level__c,
                        HCP_Enrollment__r.HCP_Contact__c,
                        HCP_Enrollment__c,
                        HCP_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__c,
                        Contact__c
                FROM Referring_HCP_Staff__c
                WHERE Contact__c =: CommunityService.getUserContact().Id
                OR HCP_Enrollment__r.HCP_Contact__c =: CommunityService.getUserContact().Id
        ];
        hcpEnrollmentsAccessLevelMap = new Map<Id, String>();
        hcpStudiesAccessLevel = new Map<Id, String>();
        studyHCPContactsMap = new Map<Id, Id>();
        hcpTeamStaffTrialMap = new Map<Id, Map<Id, Referring_HCP_Staff__c>>();
        for(Referring_HCP_Staff__c hcpStaff : hcpStaffs) {
            if(hcpStaff.Contact__c == CommunityService.getUserContact().Id){
                hcpEnrollmentsAccessLevelMap.put(hcpStaff.HCP_Enrollment__c, hcpStaff.Delegate_Level__c);
                hcpStudiesAccessLevel.put(hcpStaff.HCP_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__c, hcpStaff.Delegate_Level__c);
                studyHCPContactsMap.put(hcpStaff.HCP_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__c,  hcpStaff.HCP_Enrollment__r.HCP_Contact__c);
            }
            if(hcpStaff.HCP_Enrollment__r.HCP_Contact__c == CommunityService.getUserContact().Id){
                if(!hcpTeamStaffTrialMap.containsKey(hcpStaff.Contact__c)){
                    hcpTeamStaffTrialMap.put(hcpStaff.Contact__c, new Map<Id,Referring_HCP_Staff__c>());
                }
                hcpTeamStaffTrialMap.get(hcpStaff.Contact__c).put(hcpStaff.HCP_Enrollment__c,hcpStaff);
            }
        }
    }

}