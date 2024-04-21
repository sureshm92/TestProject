/**
 * Created by Nikita Abrazhevitch on 06-May-20.
 */

public without sharing class LibraryPIRemote {
    public static final String NOT_STUDY_SPECIFIC_SECTION = system.label.Library_General_Resources;

    public class ResourceInitData {
        @AuraEnabled
        public List<LabelValueItem> languages;
        @AuraEnabled
        public List<ResourceWrapper> resources;
        @AuraEnabled
        public string OrgBaseurl;

        public ResourceInitData(
            List<LabelValueItem> languages,
            List<ResourceWrapper> resources,
            string OrgBaseurl
        ) {
            this.languages = languages;
            this.resources = resources;
            this.OrgBaseurl = OrgBaseurl;
        }
    }

    public class ResourceWrapper {
        @AuraEnabled
        public String structureName;
        @AuraEnabled
        public List<PIResources> resources;

        public ResourceWrapper(String structureName, List<PIResources> resources) {
            this.structureName = structureName;
            this.resources = resources;
        }
    }

    public class PIResources {
        @AuraEnabled
        public Id resourceId;
        @AuraEnabled
        public String recordTypeDevName;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String language;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String format;
        @AuraEnabled
        public Date versionDate;
        @AuraEnabled
        public String link;
        @AuraEnabled
        public String videoLink;
        @AuraEnabled
        public String fileID; //for download

        public PIResources(
            Id resourceId,
            String recordTypeDevName,
            String name,
            String language,
            String type,
            String format,
            Date versionDate,
            String link,
            String videoLink,
            String fileID
        ) {
            this.recordTypeDevName = recordTypeDevName;
            this.resourceId = resourceId;
            this.name = name;
            this.language = language;
            this.type = type;
            this.format = format;
            this.versionDate = versionDate;
            this.link = link;
            this.videoLink = videoLink;
            this.fileID = fileID; //for download
        }
    }

    @AuraEnabled
    public static ResourceInitData getInitData(
        Boolean isDelegate,
        String language,
        String Searchstr,
        String communityTemplate
    ) {
        string searchstring = '%' + Searchstr + '%';

        Set<Id> ssIds = new Set<Id>();
        Set<Id> ctpIds = new Set<Id>();
        Set<Id> resIds = new Set<Id>();
        List<Res_study__c> lstResStudy = new List<Res_study__c> ();
        List<Resource__c> lstResource = new List<Resource__c> ();
        List<Id> lstResourceId_ForContentDoc = new List<Id> ();
        Map<Id,Id> mapResourceIdToContentDocId = new Map<Id,Id> ();
        Map<String, String> resourceLanguageMap = new Map<String, String>();
        List<ResourceWrapper> initData = new List<ResourceWrapper>();
        String communityType = UserContext.getCurrentUserMode().template.templateName;
        List<String> communityTypeList = new List<String>();
          if(communityType == 'Janssen'){
              communityTypeList.add(communityType);
          }else{
              communityTypeList.add('Default');
              communityTypeList.add('GSK');
              communityTypeList.add('PatientPortal');
          }
        Contact currentContact = CommunityService.getContacts(
            new Set<Id>{ CommunityService.getUserContact().Id }
        )[0];
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
                SELECT Study_Site__c, is_Invited__c
                FROM Site_Staff__c
                WHERE
                    Site_Contact__c = :CommunityService.getUserContact().Id
                    AND is_Invited__c = TRUE
            ]) {
                ssIds.add(siteStaff.Study_Site__c);
            }
        }
        for (Study_Site__c ss : [
            SELECT Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.Study_Code_Name__c
            FROM Study_Site__c
            WHERE
                (Principal_Investigator__c = :CommunityService.getUserContact().Id
                OR Id IN :ssIds)
                AND Clinical_Trial_Profile__r.CommunityTemplate__c in :communityTypeList
        ]) {
            ctpIds.add(ss.Clinical_Trial_Profile__c);
            if (!initDataMap.containsKey(ss.Clinical_Trial_Profile__r.Study_Code_Name__c)) {
                initDataMap.put(
                    ss.Clinical_Trial_Profile__r.Study_Code_Name__c,
                    new List<PIResources>()
                );
            }
        }
        if (Searchstr == null) {
            for (Res_study__c rs : [
                SELECT
                    Id,
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
                WHERE Clinical_Trial_Profile__c IN :ctpIds AND Visible_To_PI__c = TRUE
            ]){
                resIds.add(rs.Resource__c);
                lstResStudy.add(rs);
                lstResourceId_ForContentDoc.add(rs.Resource__c);
            }
            for (Resource__c res : [
                SELECT
                    Id,
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
            ]){
                lstResource.add(res);
                lstResourceId_ForContentDoc.add(res.id);
            }
            mapResourceIdToContentDocId = getFileId(lstResourceId_ForContentDoc);

            for (Res_study__c rs : lstResStudy) {
               // resIds.add(rs.Resource__c);
                Set<String> rlLanguages = new Set<String>();
                if (rs.Resource__r.Languages__c != null) {
                    for (String lang : rs.Resource__r.Languages__c.split(';')) {
                        rlLanguages.add(lang);
                        resourceLanguageMap.put(lang, getResourceLanguage(lang));
                    }
                } else {
                    resourceLanguageMap.put(
                        rs.Resource__r.Language__c,
                        getResourceLanguage(rs.Resource__r.Language__c)
                    );
                }
                if (rlLanguages.contains(language) || rs.Resource__r.Language__c == language) {
                    initDataMap.get(rs.Clinical_Trial_Profile__r.Study_Code_Name__c)
                        .add(
                            new PIResources(
                                rs.Resource__c,
                                rs.Resource__r.RecordType.DeveloperName,
                                rs.Resource__r.Title__c,
                                getResourceLanguage(language),
                                TranslateHelper.getPickListLabel(
                                    Resource__c.Resource_Type__c,
                                    rs.Resource__r.Resource_Type__c
                                ),
                                rs.Resource__r.RecordType.Name,
                                rs.Resource__r.Version_Date__c,
                                rs.Resource__r.URL__c,
                                rs.Resource__r.Video__c,
                                mapResourceIdToContentDocId.containsKey(rs.Resource__c) ? mapResourceIdToContentDocId.get(rs.Resource__c) : null
                               // getFileId(rs.Resource__c)
                            )
                        ); //for download
                }
            }
            for (Resource__c res :  lstResource) {
                Set<String> rlLanguages = new Set<String>();
                if (res.Languages__c != null) {
                    for (String lang : res.Languages__c.split(';')) {
                        rlLanguages.add(lang);
                        resourceLanguageMap.put(lang, getResourceLanguage(lang));
                    }
                } else {
                    resourceLanguageMap.put(res.Language__c, getResourceLanguage(res.Language__c));
                }
                if (rlLanguages.contains(language) || res.Language__c == language) {
                    initDataMap.get(NOT_STUDY_SPECIFIC_SECTION)
                        .add(
                            new PIResources(
                                res.Id,
                                res.RecordType.DeveloperName,
                                res.Title__c,
                                getResourceLanguage(language),
                                TranslateHelper.getPickListLabel(
                                    Resource__c.Resource_Type__c,
                                    res.Resource_Type__c
                                ),
                                res.RecordType.Name,
                                res.Version_Date__c,
                                res.URL__c,
                                res.Video__c,
                                mapResourceIdToContentDocId.containsKey(res.Id) ? mapResourceIdToContentDocId.get(res.Id) : null
                                //getFileId(res.Id)
                            )
                        ); //for download
                }
            }
        } else {
            for (Res_study__c rs : [
                SELECT
                    Id,
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
                WHERE
                    Clinical_Trial_Profile__c IN :ctpIds
                    AND Visible_To_PI__c = TRUE
                    AND (Resource__r.Title__c LIKE :searchstring
                    OR Resource__r.RecordType.Name LIKE :searchstring
                    OR Resource__r.Resource_Type__c LIKE :searchstring)
            ]){
                resIds.add(rs.Resource__c);
                lstResStudy.add(rs);
                lstResourceId_ForContentDoc.add(rs.Resource__c);

            }
            for (Resource__c res : [
                SELECT
                    Id,
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
                WHERE
                    Resource_Visibility__c INCLUDES ('PI')
                    AND Id NOT IN :resIds
                    AND (Title__c LIKE :searchstring
                    OR RecordType.Name LIKE :searchstring
                    OR Resource_Type__c LIKE :searchstring)
            ]){
                lstResource.add(res);
                lstResourceId_ForContentDoc.add(res.id);
            }

            mapResourceIdToContentDocId = getFileId(lstResourceId_ForContentDoc);

            for (Res_study__c rs :  lstResStudy) {
              //  resIds.add(rs.Resource__c);
                Set<String> rlLanguages = new Set<String>();
                if (rs.Resource__r.Languages__c != null) {
                    for (String lang : rs.Resource__r.Languages__c.split(';')) {
                        rlLanguages.add(lang);
                        resourceLanguageMap.put(lang, getResourceLanguage(lang));
                    }
                } else {
                    resourceLanguageMap.put(
                        rs.Resource__r.Language__c,
                        getResourceLanguage(rs.Resource__r.Language__c)
                    );
                }
                if (rlLanguages.contains(language) || rs.Resource__r.Language__c == language) {
                    initDataMap.get(rs.Clinical_Trial_Profile__r.Study_Code_Name__c)
                        .add(
                            new PIResources(
                                rs.Resource__c,
                                rs.Resource__r.RecordType.DeveloperName,
                                rs.Resource__r.Title__c,
                                getResourceLanguage(language),
                                TranslateHelper.getPickListLabel(
                                    Resource__c.Resource_Type__c,
                                    rs.Resource__r.Resource_Type__c
                                ),
                                rs.Resource__r.RecordType.Name,
                                rs.Resource__r.Version_Date__c,
                                rs.Resource__r.URL__c,
                                rs.Resource__r.Video__c,
                                mapResourceIdToContentDocId.containsKey(rs.Resource__c) ? mapResourceIdToContentDocId.get(rs.Resource__c) : null
                               // getFileId(rs.Resource__c)
                            )
                        ); //for download
                }
            }
            for (Resource__c res :  lstResource) {
                Set<String> rlLanguages = new Set<String>();
                if (res.Languages__c != null) {
                    for (String lang : res.Languages__c.split(';')) {
                        rlLanguages.add(lang);
                        resourceLanguageMap.put(lang, getResourceLanguage(lang));
                    }
                } else {
                    resourceLanguageMap.put(res.Language__c, getResourceLanguage(res.Language__c));
                }
                if (rlLanguages.contains(language) || res.Language__c == language) {
                    initDataMap.get(NOT_STUDY_SPECIFIC_SECTION)
                        .add(
                            new PIResources(
                                res.Id,
                                res.RecordType.DeveloperName,
                                res.Title__c,
                                getResourceLanguage(language),
                                res.Resource_Type__c,
                                res.RecordType.Name,
                                res.Version_Date__c,
                                res.URL__c,
                                res.Video__c,
                                mapResourceIdToContentDocId.containsKey(res.Id) ? mapResourceIdToContentDocId.get(res.Id) : null
                               // getFileId(res.Id)
                            )
                        ); //for download
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
        String BaseUrl = System.URL.getOrgDomainUrl().tostring();
        return new ResourceInitData(languages, initData, BaseUrl);
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
 //REF-4924
    //This Method will return Map of Resource with content document id
    private static Map<Id,Id> getFileId(List<Id> lstResourceId_ForContentDoc) {
        Map<Id,Id> mapResourceIdToContentDoc = new Map<Id,Id> ();
        if (!lstResourceId_ForContentDoc.isEmpty()) {

            for(ContentDocumentLink objcontentDoc : [SELECT ContentDocumentId, LinkedEntityId
             FROM ContentDocumentLink  
              WHERE LinkedEntityId IN: lstResourceId_ForContentDoc]){
                  if(!mapResourceIdToContentDoc.containsKey(objcontentDoc.LinkedEntityId))
                  mapResourceIdToContentDoc.put(objcontentDoc.LinkedEntityId,objcontentDoc.ContentDocumentId);
              }
              return mapResourceIdToContentDoc;  
        } 
        return null;
    }

	//This method returns the base64 values of the resource document 
    @AuraEnabled
    public static String getBase64Resource( String resourceId,String language)
    {
        ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(
            ContentDocumentLinkService.class
        );
        ContentDocumentLink cdl = contentDocumentLinkService.getCDLForResource(
            resourceId,
            language
        );
        if (cdl != null) {
           
            return EncodingUtil.base64Encode(
                cdl.ContentDocument.LatestPublishedVersion.VersionData
            );
           
        }
        return null;
    }
}