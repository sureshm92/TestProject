/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityModes {
    public static final String MODE_TYPE_PP_ONLY = 'PP_Only';
    public static final String MODE_TYPE_RH_ONLY = 'RH_Only';
    public static final String MODE_TYPE_RH_SINGLE_VIEW = 'RH_Single_View';
    public static final String MODE_TYPE_PP_AND_RH = 'PP_And_RH';
    public static final String MODE_TYPE_CC = 'CC_Only';

    public static final String RH_ITEM_TYPE_PI = 'PI';
    public static final String RH_ITEM_TYPE_RP = 'RP';

    public class RHCommunityModeItem {
        public Boolean isGroup;
        public Boolean isCollapsed; //used only for groups
        public Boolean isSelected;
        public String title; //for group can be 'View as Investigative Site' or 'View as Referring Provider', for non contains user name for RP mode
        public String itemType; //PI/RP
        public String communityName;
        public String mode;
        public Id itemId; //Id of RP for RP delegate mode
        public List<RHCommunityModeItem> subItems; //only for group items

        public RHCommunityModeItem(
            String mode,
            String title,
            String itemType,
            String communityName,
            Id itemId,
            Boolean isGroup,
            Boolean isCollapsed
        ) {
            this.mode = mode;
            this.title = title;
            this.itemType = itemType;
            this.communityName = communityName;
            this.itemId = itemId;
            this.isGroup = isGroup;
            this.isCollapsed = isCollapsed;
            this.subItems = new List<RHCommunityModeItem>();
        }
    }

    public class PPCommunityModeItem {
        public Id peId;
        public Id delegateId;
        public String mode;
        public String title;
        public String subTitle;
        public Boolean isDelegate;
        public Boolean isSelected;
        public Boolean hasBeenActive;
        public Boolean isProgram;
        public List<PPCommunityModeItem> subItems;

        public PPCommunityModeItem(Boolean isDelegate, Boolean hasBeenActive) {
            this.isDelegate = isDelegate;
            this.hasBeenActive = hasBeenActive;
            this.subItems = new List<PPCommunityModeItem>();
        }

        public PPCommunityModeItem(
            String mode,
            String title,
            String subTitle,
            Id peId,
            Id delegateId,
            Boolean isDelegate,
            Boolean isProgram
        ) {
            this.mode = mode;
            this.title = title;
            this.subTitle = subTitle;
            this.peId = peId;
            this.delegateId = delegateId;
            this.isDelegate = isDelegate;
            this.isProgram=isProgram;
            this.subItems = new List<PPCommunityModeItem>();
        }
    }

    public String type; // MODE_TYPE_PP_ONLY/ MODE_TYPE_RH_ONLY/ MODE_TYPE_PP_AND_RH / MODE_TYPE_RH_SINGLE_VIEW
    public List<RHCommunityModeItem> rhModeItems; // rhModeItems.size() = 1 if user has only one RH mode, used only for MODE_TYPE_RH_ONLY or MODE_TYPE_PP_AND_RH modes
    public List<PPCommunityModeItem> ppModeItems;

    public Boolean isPPItemsCollapsed; //only for MODE_TYPE_PP_AND_RH mode
    public Boolean isRHItemsCollapsed; //only for MODE_TYPE_PP_AND_RH mode
    public Boolean isPPItemsSelected;
    public Boolean isRHItemsSelected;
}
