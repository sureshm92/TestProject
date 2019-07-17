/**
 * Created by AlexKetch on 7/9/2019.
 */

public with sharing class VisitIconsConfiguration {
    private static final String DEFAULT_PACKAGE_NAME = 'default';
    private Icons_package__c defaultPackage;
    private Visit_Plan__c visitPlan;
    public static List<Icon_details__c> getIconsByVisitPackage(Set<Id> ids) {
        List<Icon_Details__c> icons = [
                SELECT Id
                        ,Name
                        ,description__c
                        ,Icons_package__c
                        ,label__c
                FROM Icon_Details__c
                WHERE Icons_package__c In:ids
        ];
        return icons;
    }
    public static List<Icon_details__c> createDefaultIcons() {
        Icons_package__c packageNew = new Icons_package__c();
        packageNew.Name = DEFAULT_PACKAGE_NAME;
        insert packageNew;
        return getDefaultIcons();
    }
    public static List<Icon_details__c> getDefaultIcons() {
        List<PicklistEntry> picklistEntries = Visit__c.Icons__c.getDescribe().picklistValues;
        List<Icon_details__c> iconDetails = new List<Icon_details__c>();
        for (PicklistEntry entry : picklistEntries) {
            Icon_details__c det = new Icon_details__c();
            det.Name = entry.value;
            iconDetails.add(det);
        }
        /* insert iconDetails;*/
        return iconDetails;

    }
    public static List<Icon_details__c> getPopulateIconDetails(List<Icon_details__c> populatedIcons) {
        List<Icon_details__c> icons = getDefaultIcons();
        List<Icon_details__c> newIcons = new List<Icon_details__c>();
        Set<IconsWrapper> wrappers = new Set<IconsWrapper>();
        Set<IconsWrapper> arranged = new Set<IconsWrapper>();
        for (Icon_details__c p : populatedIcons) {
            IconsWrapper w = new IconsWrapper(p);
            wrappers.add(w);
        }
        for (Icon_details__c i : icons) {
            IconsWrapper w = new IconsWrapper(i);
            wrappers.add(w);
        }
        for (IconsWrapper w : wrappers) {
            newIcons.add(w.detail);
        }
        return newIcons;


    }

    public Class IconsWrapper {
        public Icon_details__c detail;
        public Boolean equals(object obj) {
            if (obj != null && obj instanceof IconsWrapper) {
                IconsWrapper t = (IconsWrapper)obj;
                return this.detail.Name == t.detail.Name;
            } else {
                return false;
            }

        }
        public IconsWrapper(Icon_details__c detail) {
            this.detail = detail;
        }
    }

}