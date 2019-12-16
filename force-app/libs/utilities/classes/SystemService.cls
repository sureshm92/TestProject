/**
 * Created by Leonid Bartenev
 */

public without sharing class SystemService {
    
    public static final String ORG_TYPE_SETTING = 'OrgType';
    public static final String ORG_TYPE_SCRATCH = 'ScratchOrg';
    public static final String ORG_TYPE_NON_SCRATCH = 'NonScratchOrg';
    
    private static String orgType;
    
    public static void markAsScratchOrg(){
        SettingStoreService.save(ORG_TYPE_SETTING, ORG_TYPE_SCRATCH, String.class);
    }
    
    public static Boolean isScratchOrg(){
        if(orgType == null) orgType = (String) SettingStoreService.get(ORG_TYPE_SETTING);
        if(orgType == null) orgType = ORG_TYPE_NON_SCRATCH;
        return orgType == ORG_TYPE_SCRATCH;
    }

}