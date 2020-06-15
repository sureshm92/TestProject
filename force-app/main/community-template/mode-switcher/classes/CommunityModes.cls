/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityModes {
    
    public static final String MODE_TYPE_PP_ONLY = 'PP_Only';
    public static final String MODE_TYPE_RH_ONLY = 'RH_Only';
    public static final String MODE_TYPE_PP_AND_RH = 'PP_And_RH';
    
    public static final String RH_ITEM_TYPE_PI = 'PI';
    public static final String RH_ITEM_TYPE_RP = 'RP';
    
    public class RHCommunityModeItem{
        public Boolean isGroup;
        public Boolean isCollapsed; //used only for groups
        public Boolean isSelected;
        public String title; //for group can be 'View as Investigative Site' or 'View as Referring Provider', for non contains user name for RP mode
        public String itemType; //PI/RP
        public String itemId; //Id of RP for RP delegate mode
        public List<RHCommunityModeItem> subItems; //only for group items
    }
    
    public class PPCommunityModeItem{
        public String title;
        public String subTitle;
        public Boolean isDelegate;
        public Boolean isSelected;
        public List<PPCommunityModeItem> subItems;
    }
    
    public String type; // MODE_TYPE_PP_ONLY/ MODE_TYPE_RH_ONLY/ MODE_TYPE_PP_AND_RH
    public List<RHCommunityModeItem> rhModeItems; // rhModeItems.size() = 1 if user has only one RH mode, used only for MODE_TYPE_RH_ONLY or MODE_TYPE_PP_AND_RH modes
    public List<PPCommunityModeItem> ppModeItems;
    
    public Boolean isPPItemsCollapsed; //only for MODE_TYPE_PP_AND_RH mode
    public Boolean isRHItemsCollapsed; //only for MODE_TYPE_PP_AND_RH mode
    

}