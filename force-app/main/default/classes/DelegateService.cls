/**
 * Created by Leonid Bartenev
 */

public without sharing class DelegateService {
    
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
    public static final String ACCESS_LEVEL_ALL = 'All';
    
    private Map<Id, String> piStudySitesAccessLevelMap;
    private Map<Id, String> hcpEnrollmentsAccessLevelMap;
    private Map<Id, String> piStudiesAccessLevel;
    private Map<Id, String> hcpStudiesAccessLevel;
    private Map<Id, Id> studyPIContactsMap;
    private Map<Id, Id> studyHCPContactsMap;
    private Map<Id, Map<Id,Site_Staff__c>> piTeamStaffTrialMap;
    private Map<Id, Map<Id,Referring_HCP_Staff__c>> hcpTeamStaffTrialMap;

    private List<RP_Delegate_Relationship__c> hcpDelegatesList;

    
    private static DelegateService instance;
    
    public DelegateService(){
        Set<Id> siteIds = new Set<Id>();
        for(Site_Staff__c del : [SELECT Id, Study_Site__c FROM Site_Staff__c WHERE Site_Contact__c = : CommunityService.getUserContact().Id]){
            siteIds.add(del.Study_Site__c);
        }
        List<Site_Staff__c> piStaffs = [
                SELECT Id, Study_Site__c,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Clinical_Trial_Profile__c,
                        Delegate_Level__c,
                        Site_Contact__c
                FROM Site_Staff__c
                WHERE Site_Contact__c =: CommunityService.getUserContact().Id
                OR Study_Site__r.Principal_Investigator__c =: CommunityService.getUserContact().Id
                OR Study_Site__c IN :siteIds
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
            if(siteStaff.Study_Site__r.Principal_Investigator__c == CommunityService.getUserContact().Id
                    || siteIds.contains(siteStaff.Study_Site__c)){
                if(!piTeamStaffTrialMap.containsKey(siteStaff.Site_Contact__c)){
                    piTeamStaffTrialMap.put(siteStaff.Site_Contact__c, new Map<Id,Site_Staff__c>());
                }
                piTeamStaffTrialMap.get(siteStaff.Site_Contact__c).put(siteStaff.Study_Site__c,siteStaff);
            }
        
        }
        
        Set<Id> hcpeIds = new Set<Id>();
        for(Referring_HCP_Staff__c del : [SELECT Id, HCP_Enrollment__c FROM Referring_HCP_Staff__c WHERE Contact__c = : CommunityService.getUserContact().Id]){
            hcpeIds.add(del.HCP_Enrollment__c);
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
                OR HCP_Enrollment__c IN : hcpeIds
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
            if(hcpStaff.HCP_Enrollment__r.HCP_Contact__c == CommunityService.getUserContact().Id
                    || hcpeIds.contains(hcpStaff.HCP_Enrollment__c)){
                if(!hcpTeamStaffTrialMap.containsKey(hcpStaff.Contact__c)){
                    hcpTeamStaffTrialMap.put(hcpStaff.Contact__c, new Map<Id,Referring_HCP_Staff__c>());
                }
                hcpTeamStaffTrialMap.get(hcpStaff.Contact__c).put(hcpStaff.HCP_Enrollment__c,hcpStaff);
            }
        }
        hcpDelegatesList = [
                SELECT Id, Referring_Provider__r.Full_Name__c,
                        Referring_Provider__c, Delegate__c,
                        Delegate_Access_Level__c
                FROM RP_Delegate_Relationship__c
                WHERE Delegate__c = :CommunityService.getUserContact().Id
        ];
    }
    
    public static DelegateService getInstance(){
        if(instance == null) instance = new DelegateService();
        return instance;
    }
    
    public static void setMock(StubProvider stubProvider){
        instance = (DelegateService) Test.createStub(DelegateService.class, stubProvider);
    }
    
    
    public Map<Id, String> getPIStudySitesAccessLevelMapImpl(){
        return piStudySitesAccessLevelMap;
    }
    
    public Map<Id, String> getHCPEnrollmentAccessLevelMapImpl(){
        return hcpEnrollmentsAccessLevelMap;
    }
    
    public List<Id> getDelegatedHCPEnrollmentIdsImpl(){
        return new List<Id>(hcpEnrollmentsAccessLevelMap.keySet());
    }
    
    public List<Id> getDelegatedStudySiteIdsImpl(){
        return new List<Id>(piStudySitesAccessLevelMap.keySet());
    }
    
    public Map<Id, Id> getStudyPIContactsMapImpl(){
        return studyPIContactsMap;
    }
    
    public Map<Id, Id> getStudyHCPContactsMapImpl(){
        return studyHCPContactsMap;
    }
    
    public Map<Id, Map<Id,Site_Staff__c>> getPITeamStaffTrialMapImpl(){
        return piTeamStaffTrialMap;
    }
    
    public Map<Id, Map<Id,Referring_HCP_Staff__c>> getHCPTeamStaffTrialMapImpl(){
        return hcpTeamStaffTrialMap;
    }
    
    public Map<Id, String> getStudiesAccessLevelMapImpl(String userMode){
        if(userMode == CommunityService.USER_MODE_PI){
            return piStudiesAccessLevel;
        }else{
            return hcpStudiesAccessLevel;
        }
    }
    
    public String getStudyAccessLevelImpl(Id studyId, String userMode){
        if(userMode == CommunityService.USER_MODE_HCP){
            if(!getStudiesAccessLevelMapImpl(userMode).isEmpty()){
                return getStudiesAccessLevelMapImpl(userMode).values()[0];
            }
        }
        else{
            String accessLevel = getStudiesAccessLevelMapImpl(userMode).get(studyId);
            if(accessLevel != null) return accessLevel;
        }

        return ACCESS_LEVEL_ALL;
    }

    public static  Map<Id, Map<Id, String>> getHCPTeamLevelMapByHCPImpl(Set<Id> hcpIds){
        List<Referring_HCP_Staff__c> hcpStaffs = [
                SELECT Id, Delegate_Level__c,
                        HCP_Enrollment__r.HCP_Contact__c,
                        HCP_Enrollment__c,
                        HCP_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__c,
                        Contact__c
                FROM Referring_HCP_Staff__c
                WHERE HCP_Enrollment__r.HCP_Contact__c IN :hcpIds
        ];
        Map<Id, Map<Id, String>> hcpTeamLevelMapByHCP = new Map<Id, Map<Id, String>>();
        for(Referring_HCP_Staff__c hcpStaff : hcpStaffs) {
            if (hcpStaff.HCP_Enrollment__c != null) {
                if (!hcpTeamLevelMapByHCP.containsKey(hcpStaff.HCP_Enrollment__r.HCP_Contact__c)) {
                    hcpTeamLevelMapByHCP.put(hcpStaff.HCP_Enrollment__r.HCP_Contact__c, new Map<Id, String>());
                }
                hcpTeamLevelMapByHCP.get(hcpStaff.HCP_Enrollment__r.HCP_Contact__c).put(hcpStaff.Contact__c, hcpStaff.Delegate_Level__c);
            }
        }
        return hcpTeamLevelMapByHCP;
    }

    public List<RP_Delegate_Relationship__c> getHCPDelegatesImpl(){
        return hcpDelegatesList;
    }

    
    // Static facade: --------------------------------------------------------------------------------------------------
    
    public static Map<Id, String> getPIStudySitesAccessLevelMap(){
        return getInstance().getPIStudySitesAccessLevelMapImpl();
    }
    
    public static Map<Id, String> getHCPEnrollmentAccessLevelMap(){
        return getInstance().getHCPEnrollmentAccessLevelMapImpl();
    }
    
    public static List<Id> getDelegatedHCPEnrollmentIds(){
        return getInstance().getDelegatedHCPEnrollmentIdsImpl();
    }
    
    public static List<Id> getDelegatedStudySiteIds(){
        return getInstance().getDelegatedStudySiteIdsImpl();
    }
    
    public static Map<Id, Id> getStudyPIContactsMap(){
        return getInstance().getStudyPIContactsMapImpl();
    }
    
    public static Map<Id, Id> getStudyHCPContactsMap(){
        return getInstance().getStudyHCPContactsMapImpl();
    }
    
    public static Map<Id, Map<Id,Site_Staff__c>> getPITeamStaffTrialMap(){
        return getInstance().getPITeamStaffTrialMapImpl();
    }
    
    public static Map<Id, Map<Id,Referring_HCP_Staff__c>> getHCPTeamStaffTrialMap(){
        return getInstance().getHCPTeamStaffTrialMapImpl();
    }
    
    public static Map<Id, String> getStudiesAccessLevelMap(String userMode){
        return getInstance().getStudiesAccessLevelMapImpl(userMode);
    }
    
    public static String getStudyAccessLevel(Id studyId, String userMode){
        return getInstance().getStudyAccessLevelImpl(studyId, userMode);
    }

    public static Map<Id, Map<Id,String>> getHCPTeamLevelMapByHCP(Set<Id> hcpIds){
        return getHCPTeamLevelMapByHCPImpl(hcpIds);
    }

    public static List<RP_Delegate_Relationship__c> getHCPDelegates(){
        return getInstance().getHCPDelegatesImpl();
    }
}