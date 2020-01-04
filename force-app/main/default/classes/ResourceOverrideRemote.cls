/**
 * Created by Slav on 24.12.2019.
 */

public with sharing class ResourceOverrideRemote {
    private class Wrapper {
        private String  fieldName;
        private String  fieldLabel;
        private Integer onArticle;      // usage on Article page (0-absent, 1-present, 2-required)
        private Integer onDocument;     // usage on Document page (0-absent, 1-present, 2-required)
        private Integer onVideo;        // usage on Video page (0-absent, 1-present, 2-required)
        public Wrapper (String fieldName, String fieldLabel, Integer onArticle, Integer onDocument, Integer onVideo) {
            this.fieldName  = fieldName;
            this.fieldLabel = fieldLabel;
            this.onArticle  = onArticle;
            this.onDocument = onDocument;
            this.onVideo    = onVideo;
        }
    }
    
    private static final String     SOBJECT_NAME                  = 'Resource__c';
    private static final String     RECORD_TYPE_ARTICLE           = 'Article';
    private static final String     RECORD_TYPE_STUDY_DOCUMENT    = 'Study_Document';
    private static final String     RECORD_TYPE_VIDEO             = 'Video';
    private static final String     ERROR_FIELD_REQUIRED          = 'Value required in field ';
    
    private static List<String>     recTypeIds;
    private static List<String>     recTypeNames;
    private static List<String>     recTypeDevNames;
    private static List<String>     docTypes;
    private static List<String>     languageNames;
    private static List<String>     languageLabels;
    private static List<String>     contentClasses;
    private static List<String>     thirdPartySources;
    private static List<Wrapper>    fieldWrappers;
    private static String           currentRecType;
    
    static {
        // -------- obtain RecordTypes --------
        recTypeIds      = new List<String>();
        recTypeNames    = new List<String>();
        recTypeDevNames = new List<String>();
        for (RecordType recType : [SELECT DeveloperName, Name FROM RecordType WHERE SobjectType = :SOBJECT_NAME]) {
            recTypeIds.add(recType.Id);
            recTypeNames.add(recType.Name);
            recTypeDevNames.add(recType.DeveloperName);
        }
    
        // -------- obtain Document types --------
        docTypes = new List<String>();
        for (Schema.PicklistEntry pickListVal : Resource__c.document_type__c.getDescribe().getPicklistValues()) {
            docTypes.add(pickListVal.getValue());
        }
    
        // -------- obtain Language names/values --------
        languageNames  = new List<String>();
        languageLabels = new List<String>();
        for (Schema.PicklistEntry pickListVal : Resource__c.Language__c.getDescribe().getPicklistValues()) {
            languageNames.add(pickListVal.getValue());
            languageLabels.add(pickListVal.getLabel());
        }
    
        // -------- obtain Content classes --------
        contentClasses = new List<String>();
        for (Schema.PicklistEntry pickListVal : Resource__c.Content_Class__c.getDescribe().getPicklistValues()) {
            contentClasses.add(pickListVal.getValue());
        }
    
        // -------- obtain 3rd party sources --------
        thirdPartySources = new List<String>();
        for (Schema.PicklistEntry pickListVal : Resource__c.X3rd_Party_Source__c.getDescribe().getPicklistValues()) {
            thirdPartySources.add(pickListVal.getValue());
        }

        fieldWrappers = new List<Wrapper>();
        // -------- Study Document --------
        fieldWrappers.add(new Wrapper('Title__c',                'Title',                2, 2, 2));
        fieldWrappers.add(new Wrapper('document_type__c',        'Document type',        0, 2, 0));
        fieldWrappers.add(new Wrapper('Description__c',          'Description',          1, 2, 1));
        fieldWrappers.add(new Wrapper('Video__c',                'Video Link',           0, 1, 2));
        fieldWrappers.add(new Wrapper('Language__c',             'Language',             2, 2, 2));
        fieldWrappers.add(new Wrapper('Version_Date__c',         'Version Date',         0, 2, 0));
        // -------- Article --------
        fieldWrappers.add(new Wrapper('Subtitle__c',             'Subtitle',             1, 0, 1));
        fieldWrappers.add(new Wrapper('Image__c',                'Image Link',           1, 0, 1));
        fieldWrappers.add(new Wrapper('Image_Title__c',          'Image Title',          1, 0, 1));
        fieldWrappers.add(new Wrapper('Content_Class__c',        'Content Class',        2, 0, 2));
        fieldWrappers.add(new Wrapper('Posting_Date__c',         'Posting Date',         2, 0, 2));
        fieldWrappers.add(new Wrapper('Expiration_Date__c',      'Expiration Date',      1, 0, 1));
        fieldWrappers.add(new Wrapper('Updated_Date__c',         'Updated Date',         1, 0, 1));
        fieldWrappers.add(new Wrapper('Body__c',                 'Body',                 2, 0, 1));
        fieldWrappers.add(new Wrapper('Author_s_Name__c',        'Author\'s Name',       1, 0, 1));
        fieldWrappers.add(new Wrapper('Source__c',               'Source',               1, 0, 1));
        fieldWrappers.add(new Wrapper('Copyright__c',            'Copyright',            1, 0, 1));
        fieldWrappers.add(new Wrapper('X3rd_Party_Source__c',    '3rd Party Source',     1, 0, 1));
        fieldWrappers.add(new Wrapper('Therapeutic_Areas__c',    'SiteCore Conditions',  1, 0, 1));
        fieldWrappers.add(new Wrapper('Image_Subtitle__c',       'Image Subtitle',       1, 0, 1));
        fieldWrappers.add(new Wrapper('Byline__c',               'Byline',               1, 0, 1));
        fieldWrappers.add(new Wrapper('URL_Part__c',             'URL Part',             1, 0, 1));
        fieldWrappers.add(new Wrapper('article_external_link__c','Article External Link',1, 0, 1));
        fieldWrappers.add(new Wrapper('Remove_sharing__c',       'Remove sharing',       1, 0, 1));
    }

    /**
     * getRecordTypeName()
     *
     * @param recordTypeId
     *
     * @return
     */
    private static String getRecordTypeName (String recordTypeId) {
        Integer index = 0;
        for (String id : recTypeIds) {
            if (id == recordTypeId) return recTypeNames[index];
            index++;
        }
        return null;
    }

    /**
     * getRecordTypeDevName()
     *
     * @param recordTypeId
     *
     * @return
     */
    private static String getRecordTypeDevName (String recordTypeId) {
        Integer index = 0;
        for (String id : recTypeIds) {
            if (id == recordTypeId) return recTypeDevNames[index];
            index++;
        }
        return null;
    }

    /**
     * getLanguageName()
     *
     * @param languageLabel
     *
     * @return
     */
    private static String getLanguageName (String languageLabel) {
        Integer index = 0;
        for (String label : languageLabels) {
            if (label == languageLabel) return languageNames[index];
            index++;
        }
        return languageLabel;
    }

    /**
     * getLanguageLabel()
     *
     * @param languageName
     *
     * @return
     */
    private static String getLanguageLabel (String languageName) {
        Integer index = 0;
        for (String name : languageNames) {
            if (name == languageName) return languageLabels[index];
            index++;
        }
        return languageName;
    }
    
    /**
     * buildQuery()
     *
     * @param recordId
     *
     * @return
     */
    private static String buildQuery (String recordId) {
        String queryString = 'SELECT Name,';
        for (Wrapper wrapper : fieldWrappers) {
            queryString += ' ' + wrapper.fieldName + ',';
        }
        queryString = queryString.removeEnd(',');
        queryString += ' FROM Resource__c WHERE Id = \'' + recordId + '\'';
        return queryString;
    }

    /**
     * getMetadata()
     *
     * @param recordTypeId
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> getMetadata (String recordTypeId) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('docTypes',            docTypes);
        response.put('languageNames',       languageNames);
        response.put('languageLabels',      languageLabels);
        response.put('contentClasses',      contentClasses);
        response.put('thirdPartySources',   thirdPartySources);
        response.put('defaultLanguage',     'English');
        response.put('defaultDocType',      'Document');
        response.put('recTypeId',           recordTypeId);
        response.put('recTypeName',         getRecordTypeName(recordTypeId));
        response.put('recTypeDevName',      getRecordTypeDevName(recordTypeId));
        response.put('videoLinkHelp',       Resource__c.Video__c.getDescribe().getInlineHelpText());
        response.put('imageLinkHelp',       Resource__c.Image__c.getDescribe().getInlineHelpText());
        return response;
    }

    /**
     * saveResource()
     *
     * @param recordTypeId
     * @param recordId
     * @param resource
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> saveResource (String recordTypeId, String recordId, Resource__c resource) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('isError', false);
        try {
            currentRecType = getRecordTypeDevName(recordTypeId);
            
            if (String.isNotBlank(recordId)) {
                Resource__c updateResource  = resource;
                resource = Database.query(buildQuery(recordId));
                for (Wrapper wrapper : fieldWrappers) {
                    if (isRelevant(wrapper)) {
                        // update only those fields related to current layout
                        resource.put(wrapper.fieldName, updateResource.get(wrapper.fieldName));
                    }
                }
                if (validate(resource, response)) {
                    resource.Language__c = getLanguageName(resource.Language__c);   // replaces language label with name
                    update resource;
                    response.put('recordId', resource.Id);
                    response.put('availableLanguages', getAvailableLanguages(resource.Id));
                    response.put('message', 'Resource successfully updated: [' + resource.Name + ']');
                }
            } else if (resource != null) {
                resource.RecordTypeId = recordTypeId;
                resource.Content_Type__c = currentRecType;
                if (validate(resource, response)) {
                    resource.Language__c = getLanguageName(resource.Language__c);   // replaces language label with name
                    insert resource;
                    resource = [SELECT Name FROM Resource__c WHERE Id = :resource.Id];
                    response.put('recordId', resource.Id);
                    response.put('resourceName', resource.Name);
                    response.put('availableLanguages', getAvailableLanguages(resource.Id));
                    response.put('message', 'New Resource successfully created: [' + resource.Name + ']. You can now upload files which will be attached to this Resource.');
                }
            }
        } catch (Exception e) {
            response.put('isError', true);
            response.put('message', e.getMessage() + ' ' + e.getStackTraceString());
        }
        return response;
    }

    /**
     * updateContentDocument()
     *
     * @param documentId
     * @param fileName
     * @param language
     *
     * @return
     */
    @AuraEnabled
    public static  Map<String, Object> updateContentDocument (String documentId, String fileName, String recordId, String language) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('isError', false);
        try {
            ContentDocument document = [
                    SELECT  Id
                    FROM    ContentDocument
                    WHERE   Id =: documentId
            ];
            Resource__c resource = [
                    SELECT Name, Language__c
                    FROM   Resource__c
                    WHERE  Id = :recordId
            ];
            document.Title = getLanguageName(language);
            update document;
            response.put('availableLanguages', getAvailableLanguages(recordId));
            response.put('message', 'File [' + fileName + '] -> [' + language + '] successfully uploaded and attached to Resource [' + resource.Name + ']');
        } catch (Exception e) {
            response.put('isError', true);
            response.put('message', e.getMessage() + ' ' + e.getStackTraceString());
        }
        return response;
    }

    /**
     * getAvailableLanguages()
     *
     * @param recordId
     *
     * @return
     */
    private static  List<String> getAvailableLanguages (String recordId) {
        List<String> uploadedLanguages = new List<String>();
        List<String> availableLanguages = new List<String>();

        if (String.isNotBlank(recordId)) {
            List<ContentDocumentLink> uploadedFiles = [
                    SELECT ContentDocument.Title
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :recordId
            ];
    
            for (ContentDocumentLink docLink : uploadedFiles) {
                uploadedLanguages.add(docLink.ContentDocument.Title);
            }
    
            for (String languageName : languageNames) {
                if (!uploadedLanguages.contains(languageName)) {
                    availableLanguages.add(getLanguageLabel(languageName));
                }
            }
        }

        return availableLanguages;
    }
    
    /**
     * isRelevant()
     *
     * @param wrapper
     *
     * @return
     */
    private static Boolean isRelevant (Wrapper wrapper) {
        if (currentRecType == RECORD_TYPE_ARTICLE) {
            if (wrapper.onArticle > 0) return true;
        } else if (currentRecType == RECORD_TYPE_STUDY_DOCUMENT) {
            if (wrapper.onDocument > 0) return true;
        } else if (currentRecType == RECORD_TYPE_VIDEO) {
            if (wrapper.onVideo > 0) return true;
        }
        return false;
    }

    /**
     * validate()
     *
     * @param resource
     * @param response
     *
     * @return
     */
    private static Boolean validate (Resource__c resource, Map<String, Object> response) {
        for (Wrapper wrapper : fieldWrappers) {
            if (resource.get(wrapper.fieldName) == null || String.isBlank('' + resource.get(wrapper.fieldName))) {
                if (currentRecType == RECORD_TYPE_ARTICLE) {
                    if (wrapper.onArticle == 2) {
                        response.put('isError', true);
                        response.put('message', ERROR_FIELD_REQUIRED + '[' + wrapper.fieldLabel + ']');
                        return false;
                    }
                } else if (currentRecType == RECORD_TYPE_STUDY_DOCUMENT) {
                    if (wrapper.onDocument == 2) {
                        response.put('isError', true);
                        response.put('message', ERROR_FIELD_REQUIRED + '[' + wrapper.fieldLabel + ']');
                        return false;
                    }
                } else if (currentRecType == RECORD_TYPE_VIDEO) {
                    if (wrapper.onVideo == 2) {
                        response.put('isError', true);
                        response.put('message', ERROR_FIELD_REQUIRED + '[' + wrapper.fieldLabel + ']');
                        return false;
                    }
                }
            }
        }
        return true;
    }
}
