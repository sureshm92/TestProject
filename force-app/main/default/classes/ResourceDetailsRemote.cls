/**
 * Created by Slav on 24.12.2019.
 */

public with sharing class ResourceDetailsRemote {
    private static String RECORD_TYPE_STUDY_DOCUMENT    = 'Study_Document';
    private static String ERROR_FIELD_REQUIRED          = 'Value required in field ';
    
    private static Map<Id, RecordType> getRecordTypes () {
        Map<Id, RecordType> recTypes= new Map<Id, RecordType>();
        for (RecordType recType : [SELECT DeveloperName, Name FROM RecordType WHERE SobjectType = 'Resource__c']) {
            recTypes.put(recType.Id, recType);
        }
        return recTypes;
    }
    
    private static List<String> getDocTypes () {
        List<String> docTypes= new List<String>();
        for (Schema.PicklistEntry pickListVal : Resource__c.document_type__c.getDescribe().getPicklistValues()) {
            docTypes.add(pickListVal.getValue());
        }
        return docTypes;
    }

    
    private static List<String> getLanguages () {
        List<String> languages= new List<String>();
        for (Schema.PicklistEntry pickListVal : Resource__c.Language__c.getDescribe().getPicklistValues()) {
            languages.add(pickListVal.getValue());
        }
        return languages;
    }
    
    @AuraEnabled
    public static Map<String, Object> getResource (String recordId, String recordTypeId) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('resource', new Resource__c(Language__c='en_US', document_type__c='Document'));
        
        // select Resource by Id if available
        if (String.isNotBlank(recordId)) {
            List<Resource__c> resources = [SELECT Id, Title__c, Description__c, Language__c, Content_Type__c, Video__c, Version_Date__c FROM Resource__c WHERE Id = :recordId];
            if (!resources.isEmpty()) {
                response.put('resource', resources[0]);
            }
        }
    
        // retrieve Document Types
        response.put('docTypes', getDocTypes());

        // retrieve Languages picklist
        response.put('languages', getLanguages());
        
        // help text for the Video__c field
        response.put('videoHelpText', Resource__c.Video__c.getDescribe().getInlineHelpText());
    
        Map<Id, RecordType> recTypes = getRecordTypes();
        response.put('developerName', recTypes.get(recordTypeId).Name);
    
        Id studyDocTypeId;
        for (String id : recTypes.keySet()) {
            if (recTypes.get(id).DeveloperName == RECORD_TYPE_STUDY_DOCUMENT) {
                studyDocTypeId = id;
                break;
            }
        }
        if (recordTypeId != studyDocTypeId) {
            response.put('message', 'Resource creation for RecordType [' + recTypes.get(recordTypeId).Name + '] currently not supported');
            response.put('redirect', '/lightning/o/Resource__c/new?nooverride=1&recordTypeId=' + recordTypeId);
        }
        
        return response;
    }
    
    @AuraEnabled
    public static Map<String, Object> saveResource (String recordId, Resource__c resource) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('isError', false);
        
        try {
            if (String.isNotBlank(recordId)) {
                Resource__c updateResource  = resource;
                resource                    = [SELECT Name FROM Resource__c WHERE Id = :recordId];
                resource.Title__c           = updateResource.Title__c;
                resource.document_type__c   = updateResource.document_type__c;
                resource.Description__c     = updateResource.Description__c;
                resource.Video__c           = updateResource.Video__c;
                resource.Language__c        = updateResource.Language__c;
                resource.Version_Date__c    = updateResource.Version_Date__c;
                if (validate(resource, response)) {
                    update resource;
                    response.put('recordId', resource.Id);
                    response.put('message', 'Resource successfully updated: [' + resource.Name + ']');
                }
            } else if (resource != null) {
                resource.Content_Type__c = RECORD_TYPE_STUDY_DOCUMENT;
                if (validate(resource, response)) {
                    insert resource;
                    resource = [SELECT Name FROM Resource__c WHERE Id = :resource.Id];
                    response.put('recordId', resource.Id);
                    response.put('message', 'New Resource successfully created: [' + resource.Name + ']. You can now upload files which will be attached to this Resource.');
                }
            }
        } catch (Exception e) {
            response.put('isError', true);
            response.put('message', e.getMessage() + ' ' + e.getStackTraceString());
        }
        return response;
    }
    
    private static Boolean validate (Resource__c resource, Map<String, Object> response) {
        if (String.isBlank(resource.Title__c)) {
            response.put('isError', true);
            response.put('message', ERROR_FIELD_REQUIRED + '[Title]');
            return false;
        } else if (String.isBlank(resource.document_type__c)) {
            response.put('isError', true);
            response.put('message', ERROR_FIELD_REQUIRED + '[Document type]');
            return false;
        } else if (String.isBlank(resource.Description__c)) {
            response.put('isError', true);
            response.put('message', ERROR_FIELD_REQUIRED + '[Description]');
            return false;
        } else if (String.isBlank(resource.Language__c)) {
            response.put('isError', true);
            response.put('message', ERROR_FIELD_REQUIRED + '[Language]');
            return false;
        } else if (resource.Version_Date__c == null) {
            response.put('isError', true);
            response.put('message', ERROR_FIELD_REQUIRED + '[Version Date]');
            return false;
        }
        return true;
    }
}