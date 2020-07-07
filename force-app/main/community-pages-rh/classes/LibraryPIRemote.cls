/**
* Created by Nikita Abrazhevitch on 06-May-20.
*/

public without sharing class LibraryPIRemote {
    
    public static final String NOT_STUDY_SPECIFIC_SECTION = system.label.Library_General_Resources;
    
    public class ResourceInitData {
        @AuraEnabled public List<LabelValueItem> languages;
        @AuraEnabled public List<ResourceWrapper> resources;
        
        public ResourceInitData(List<LabelValueItem> languages, List<ResourceWrapper> resources) {
            this.languages = languages;
            this.resources = resources;
        }
    }
    
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
        @AuraEnabled public String fileID;//for download
        
        public PIResources(Id resourceId, String recordTypeDevName, String name, String language, String type, String format, Date versionDate, String link, String videoLink,String fileID) {
            this.recordTypeDevName = recordTypeDevName;
            this.resourceId = resourceId;
            this.name = name;
            this.language = language;
            this.type = type;
            this.format = format;
            this.versionDate = versionDate;
            this.link = link;
            this.videoLink = videoLink;
            this.fileID=fileID;//for download
        }
    }
    
    @AuraEnabled
    public static ResourceInitData getInitData(Boolean isDelegate, String language, String Searchstr) {
        
        string searchstring = '%' + Searchstr + '%';
        
        Set<Id> ssIds = new Set<Id>();
        Set<Id> ctpIds = new Set<Id>();
        Set<Id> resIds = new Set<Id>();
        Map<String, String> resourceLanguageMap = new Map<String, String>();
        List<ResourceWrapper> initData = new List<ResourceWrapper>();
        Contact currentContact = CommunityService.getContacts(new Set<Id>{CommunityService.getUserContact().Id})[0];
        if (language == null) {
            if (currentContact.Library_Primary_Language__c != null) {
                language = currentContact.Library_Primary_Language__c;
            } else {
                language = currentContact.Language__c;
            }
        } else {
            currentContact.Library_Primary_Language__c = language;
            update currentContact;
        }
        Map<String, List<PIResources>> initDataMap = new Map<String, List<PIResources>>{
            NOT_STUDY_SPECIFIC_SECTION => new List<PIResources>()
                };
                    if (isDelegate) {
                        for (Site_Staff__c siteStaff : [
                            SELECT Study_Site__c
                            FROM Site_Staff__c
                            WHERE Site_Contact__c = :CommunityService.getUserContact().Id
                        ]) {
                            ssIds.add(siteStaff.Study_Site__c);
                        }
                    }
        for (Study_Site__c ss : [
            SELECT Clinical_Trial_Profile__c,
            Clinical_Trial_Profile__r.Study_Code_Name__c
            FROM Study_Site__c
            WHERE Principal_Investigator__c = :CommunityService.getUserContact().Id OR Id IN :ssIds
        ]) {
            ctpIds.add(ss.Clinical_Trial_Profile__c);
            if (!initDataMap.containsKey(ss.Clinical_Trial_Profile__r.Study_Code_Name__c)) {
                initDataMap.put(ss.Clinical_Trial_Profile__r.Study_Code_Name__c, new List<PIResources>());
            }
        }
        if (Searchstr == null) {
            for (Res_study__c rs : [
                SELECT Id,
                Resource__c,
                toLabel(Resource__r.RecordType.Name),
                Resource__r.RecordType.DeveloperName,
                Resource__r.Title__c,
                Resource__r.Languages__c,
                Resource__r.Language__c,
                Resource__r.Resource_Type__c,
                Resource__r.Version_Date__c,
                Resource__r.Video__c,
                Resource__r.URL__c,
                Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Res_study__c
                WHERE (Clinical_Trial_Profile__c IN :ctpIds) AND Visible_To_PI__c = true
            ]) {
                resIds.add(rs.Resource__c);
                Set<String> rlLanguages =  new Set<String>();
                if(rs.Resource__r.Languages__c != null) {
                    for (String lang : rs.Resource__r.Languages__c.split(';')) {
                        rlLanguages.add(lang);
                        resourceLanguageMap.put(lang, getResourceLanguage(lang));
                    }
                } else {
                    resourceLanguageMap.put(rs.Resource__r.Language__c, getResourceLanguage(rs.Resource__r.Language__c));
                }
                if (rlLanguages.contains(language) || rs.Resource__r.Language__c == language) {
                    initDataMap.get(rs.Clinical_Trial_Profile__r.Study_Code_Name__c).add(new PIResources(rs.Resource__c,
                                                                                                         rs.Resource__r.RecordType.DeveloperName,
                                                                                                         rs.Resource__r.Title__c,
                                                                                                         getResourceLanguage(language),
                            TranslateHelper.getPickListLabel(Resource__c.Resource_Type__c,rs.Resource__r.Resource_Type__c),
                                                                                                         rs.Resource__r.RecordType.Name,
                                                                                                         rs.Resource__r.Version_Date__c,
                                                                                                         rs.Resource__r.URL__c,
                                                                                                         rs.Resource__r.Video__c,
                                                                                                         getFileId(rs.Resource__c)));//for download
                }
            }
            for (Resource__c res : [
                SELECT Id,
                toLabel(RecordType.Name),
                RecordType.DeveloperName,
                Title__c,
                Languages__c,
                Language__c,
                Resource_Type__c,
                Version_Date__c,
                Video__c,
                URL__c
                FROM Resource__c
                WHERE Resource_Visibility__c INCLUDES ('PI') AND Id NOT IN :resIds
            ]) {
                Set<String> rlLanguages =  new Set<String>();
                if(res.Languages__c != null) {
                    for (String lang : res.Languages__c.split(';')) {
                        rlLanguages.add(lang);
                        resourceLanguageMap.put(lang, getResourceLanguage(lang));
                    }
                } else {
                    resourceLanguageMap.put(res.Language__c, getResourceLanguage(res.Language__c));
                }
                if (rlLanguages.contains(language) || res.Language__c == language) {
                    initDataMap.get(NOT_STUDY_SPECIFIC_SECTION).add(new PIResources(res.Id,
                                                                                    res.RecordType.DeveloperName,
                                                                                    res.Title__c,
                                                                                    getResourceLanguage(language),
                                                                                    res.Resource_Type__c,
                                                                                    res.RecordType.Name,
                                                                                    res.Version_Date__c,
                                                                                    res.URL__c,
                                                                                    res.Video__c,
                                                                                    getFileId(res.Id)));//for download
                }
            }
        }
        else {
            for (Res_study__c rs: [
                SELECT Id,
                Resource__c,
                toLabel(Resource__r.RecordType.Name),
                Resource__r.RecordType.DeveloperName,
                Resource__r.Title__c,
                Resource__r.Languages__c,
                Resource__r.Language__c,
                Resource__r.Resource_Type__c,
                Resource__r.Version_Date__c,
                Resource__r.Video__c,
                Resource__r.URL__c,
                Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Res_study__c
                WHERE(Clinical_Trial_Profile__c IN: ctpIds) AND Visible_To_PI__c = true AND(Resource__r.Title__c Like: searchstring OR Resource__r.RecordType.Name Like: searchstring OR Resource__r.Resource_Type__c Like: searchstring)
            ]) {
                resIds.add(rs.Resource__c);
                Set < String > rlLanguages = new Set < String > ();
                if (rs.Resource__r.Languages__c != null) {
                    for (String lang: rs.Resource__r.Languages__c.split(';')) {
                        rlLanguages.add(lang);
                        resourceLanguageMap.put(lang, getResourceLanguage(lang));
                    }
                } else {
                    resourceLanguageMap.put(rs.Resource__r.Language__c, getResourceLanguage(rs.Resource__r.Language__c));
                }
                if (rlLanguages.contains(language) || rs.Resource__r.Language__c == language) {
                    initDataMap.get(rs.Clinical_Trial_Profile__r.Study_Code_Name__c).add(new PIResources(rs.Resource__c,
                                                                                                         rs.Resource__r.RecordType.DeveloperName,
                                                                                                         rs.Resource__r.Title__c,
                                                                                                         getResourceLanguage(language),
                                                                                                         TranslateHelper.getPickListLabel(Resource__c.Resource_Type__c, rs.Resource__r.Resource_Type__c),
                                                                                                         rs.Resource__r.RecordType.Name,
                                                                                                         rs.Resource__r.Version_Date__c,
                                                                                                         rs.Resource__r.URL__c,
                                                                                                         rs.Resource__r.Video__c,
                                                                                                         getFileId(rs.Resource__c)));//for download
                }
            }
            for (Resource__c res: [
                SELECT Id,
                toLabel(RecordType.Name),
                RecordType.DeveloperName,
                Title__c,
                Languages__c,
                Language__c,
                Resource_Type__c,
                Version_Date__c,
                Video__c,
                URL__c
                FROM Resource__c
                WHERE Resource_Visibility__c INCLUDES('PI') AND Id NOT IN: resIds AND(Title__c Like: searchstring OR RecordType.Name Like: searchstring OR Resource_Type__c Like: searchstring)
            ]) {
                Set < String > rlLanguages = new Set < String > ();
                if (res.Languages__c != null) {
                    for (String lang: res.Languages__c.split(';')) {
                        rlLanguages.add(lang);
                        resourceLanguageMap.put(lang, getResourceLanguage(lang));
                    }
                } else {
                    resourceLanguageMap.put(res.Language__c, getResourceLanguage(res.Language__c));
                }
                if (rlLanguages.contains(language) || res.Language__c == language) {
                    initDataMap.get(NOT_STUDY_SPECIFIC_SECTION).add(new PIResources(res.Id,
                                                                                    res.RecordType.DeveloperName,
                                                                                    res.Title__c,
                                                                                    getResourceLanguage(language),
                                                                                    res.Resource_Type__c,
                                                                                    res.RecordType.Name,
                                                                                    res.Version_Date__c,
                                                                                    res.URL__c,
                                                                                    res.Video__c,
                                                                                    getFileId(res.Id)));//for download
                }
            }
            
        }
        
        List<LabelValueItem> languages = new List<LabelValueItem>();
        for (String lang : resourceLanguageMap.keySet()) {
            languages.add(new LabelValueItem(resourceLanguageMap.get(lang), lang));
        }
        for (String key : initDataMap.keySet()) {
            initData.add(new ResourceWrapper(key, initDataMap.get(key)));
        }
        return new ResourceInitData(languages, initData);
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
    //This method returns the Content document ID attached to the resource
    Private static String getFileId(string resId){
        if(resId!=null && resId!=''){
            list<ContentDocumentLink> cd= [SELECT ContentDocumentId,LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =:resId];
            if(!cd.isEmpty())
            return cd[0].ContentDocumentId;	
        }
        
        return null;
    }
}