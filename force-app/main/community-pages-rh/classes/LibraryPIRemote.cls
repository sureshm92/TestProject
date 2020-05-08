/**
 * Created by Nikita Abrazhevitch on 06-May-20.
 */

public with sharing class LibraryPIRemote {

    public static final String EXCLUDED_RESOURCE_TYPE = 'Article';
    public static final String NOT_STUDY_SPECIFIC_SECTION = 'Not Study-Specific';

    public class ResourceWrapper {
        @AuraEnabled public String structureName;
        @AuraEnabled public List<PIResources> resources;

        public ResourceWrapper(String structureName, List<PIResources> resources) {
            this.structureName = structureName;
            this.resources = resources;
        }
    }

    public class PIResources {
        @AuraEnabled public Id resourceId;
        @AuraEnabled public String recordTypeDevName;
       @AuraEnabled public String name;
        @AuraEnabled public String language;
        @AuraEnabled public String type;
        @AuraEnabled public String format;
        @AuraEnabled public Date versionDate;
        @AuraEnabled public String link;
        @AuraEnabled public String videoLink;

        public PIResources(Id resourceId, String recordTypeDevName, String name, String language, String type, String format, Date versionDate, String link, String videoLink) {
            this.recordTypeDevName = recordTypeDevName;
            this.resourceId = resourceId;
            this.name = name;
            this.language = language;
            this.type = type;
            this.format = format;
            this.versionDate = versionDate;
            this.link = link;
            this.videoLink = videoLink;
        }
    }

    @AuraEnabled
    public static List<ResourceWrapper> getInitData() {
        Map<String, List<PIResources>> initDataMap = new Map<String, List<PIResources>>{
                NOT_STUDY_SPECIFIC_SECTION => new List<PIResources>()
        };
        List<ResourceWrapper> initData = new List<ResourceWrapper>();
        Set<Id> ctpIds = new Set<Id>();
        for (Study_Site__c ss : [
                SELECT Clinical_Trial_Profile__c,
                        Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Study_Site__c
                WHERE Principal_Investigator__c = :CommunityService.getUserContact().Id
        ]) {
            ctpIds.add(ss.Clinical_Trial_Profile__c);
            if (!initDataMap.containsKey(ss.Clinical_Trial_Profile__r.Study_Code_Name__c)) {
                initDataMap.put(ss.Clinical_Trial_Profile__r.Study_Code_Name__c, new List<PIResources>());
            }
        }
        for (Resource__c res : [
                SELECT Id,
                        RecordType.Name,
                        RecordType.DeveloperName,
                        Title__c,
                        Language__c,
                        Resource_Type__c,
                        Version_Date__c,
                        Video__c,
                        URL__c
                FROM Resource__c
                WHERE Resource_Visibility__c INCLUDES ('PI')
        ]) {
            res.Language__c = getResourceLanguage(res.Language__c);
            initDataMap.get(NOT_STUDY_SPECIFIC_SECTION).add(new PIResources(res.Id,
                                                                            res.RecordType.DeveloperName,
                                                                            res.Title__c,
                                                                            res.Language__c,
                                                                            res.Resource_Type__c,
                                                                            res.RecordType.Name,
                                                                            res.Version_Date__c,
                                                                            res.URL__c,
                                                                            res.Video__c));
        }
        for (Res_study__c rs : [
                SELECT Id,
                        Resource__c,
                        Resource__r.RecordType.Name,
                        Resource__r.RecordType.DeveloperName,
                        Resource__r.Title__c,
                        Resource__r.Language__c,
                        Resource__r.Resource_Type__c,
                        Resource__r.Version_Date__c,
                        Resource__r.Video__c,
                        Resource__r.URL__c,
                        Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Res_study__c
                WHERE (Clinical_Trial_Profile__c IN :ctpIds)
                AND Resource__r.RecordType.Name != :EXCLUDED_RESOURCE_TYPE
        ]) {
            rs.Resource__r.Language__c = getResourceLanguage(rs.Resource__r.Language__c);
            initDataMap.get(rs.Clinical_Trial_Profile__r.Study_Code_Name__c).add(new PIResources(rs.Resource__c,
                                                                                                rs.Resource__r.RecordType.DeveloperName,
                                                                                                rs.Resource__r.Title__c,
                                                                                                rs.Resource__r.Language__c,
                                                                                                rs.Resource__r.Resource_Type__c,
                                                                                                rs.Resource__r.RecordType.Name,
                                                                                                rs.Resource__r.Version_Date__c,
                                                                                                rs.Resource__r.URL__c,
                                                                                                rs.Resource__r.Video__c));
        }
        for (String key : initDataMap.keySet()) {
            initData.add(new ResourceWrapper(key, initDataMap.get(key)));
        }
        return initData;
    }

    private static String getResourceLanguage(String languageCode) {
        if (languageCode != null) {
            Schema.DescribeFieldResult describedField = User.LanguageLocaleKey.getDescribe();
            for (Schema.Picklistentry entry : describedField.getPicklistValues()) {
                if (entry.getValue() == languageCode) {
                    return entry.getLabel();
                }
            }
        }
        return null;
    }

}