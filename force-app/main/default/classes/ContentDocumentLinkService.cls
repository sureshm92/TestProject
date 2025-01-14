public with sharing class ContentDocumentLinkService {
    public static final Set<String> AVAILABLE_IMAGE_TYPES = new Set<String>{
        'jpeg',
        'png',
        'jpg',
        'gif',
        'JPEG',
        'PNG',
        'JPG',
        'GIF'
    };

 //REF-2654    
 public static final Set<String> PARTICIPANT_FILE_TYPES = new Set<String>{
    'jpeg',
    'png',
    'jpg',
    'gif',
    'JPEG',
    'PNG',
    'JPG',
    'GIF',
    'PDF',
    'pdf'   
};    

    public class TranslatedContentItem {
        @AuraEnabled
        public Id contentId;
        @AuraEnabled
        public String languageCode;
        @AuraEnabled
        public String languageLabel;

        public TranslatedContentItem(Id contentId, String languageCode) {
            this.contentId = contentId;
            this.languageCode = languageCode;
            this.languageLabel = TranslateHelper.getPickListLabel(
                Contact.Language__c,
                languageCode
            );
        }
    }

    public static ContentDocumentLinkService getInstance() {
        return (ContentDocumentLinkService) ClassFactory.newInstance(
            ContentDocumentLinkService.class
        );
    }

    public List<ContentDocumentLink> getContentDocumentLinksByResourcesIds(
        Set<String> resourcesIdsSet
    ) {
        if (resourcesIdsSet.isEmpty()) {
            return new List<ContentDocumentLink>();
        }
        List<String> resourcesIds = new List<String>();
        for (String resourceId : resourcesIdsSet) {
            resourcesIds.add('\'' + resourceId + '\'');
        }
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String documentLinksQuery =
            'SELECT ContentDocument.LatestPublishedVersion.Title, ' +
            'ContentDocument.LatestPublishedVersion.VersionData ' +
            'FROM ContentDocumentLink ' +
            'WHERE LinkedEntityId IN (' +
            String.join(resourcesIds, ', ') +
            ') ' +
            'ORDER BY ContentDocument.CreatedDate DESC';
        return (List<ContentDocumentLink>) databaseProxy.query(documentLinksQuery);
    }

    public Map<Id, List<TranslatedContentItem>> getTranslatedItemsForResources(
        List<Id> resourceIds
    ) {
        List<Resource__c> resources = [
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        ContentDocument.LatestPublishedVersion.Title,
                        ContentDocument.LatestPublishedVersion.LanguageCode__c,
                        ContentDocument.LatestPublishedVersionId
                    FROM ContentDocumentLinks
                )
            FROM Resource__c
            WHERE Id IN :resourceIds
        ];
        Map<Id, List<TranslatedContentItem>> resourceTranslationContentsMap = new Map<Id, List<ContentDocumentLinkService.TranslatedContentItem>>();
        List<String> availableLanguageCodes = new List<String>();
        for (LabelValueItem item : SObjectHelper.getPicklistLabelValueList(Contact.Language__c))
            availableLanguageCodes.add(item.value);
        for (Resource__c resource : resources) {
            List<TranslatedContentItem> items = resourceTranslationContentsMap.get(resource.Id);
            if (items == null)
                items = new List<ContentDocumentLinkService.TranslatedContentItem>();
            for (ContentDocumentLink cdl : resource.ContentDocumentLinks) {
                if (
                    (availableLanguageCodes.contains(
                        cdl.ContentDocument.LatestPublishedVersion.Title
                    )) ||
                    (availableLanguageCodes.contains(
                        cdl.ContentDocument.LatestPublishedVersion.LanguageCode__c
                    ))
                ) {
                    if (
                        availableLanguageCodes.contains(
                            cdl.ContentDocument.LatestPublishedVersion.Title
                        )
                    ) {
                        items.add(
                            new TranslatedContentItem(
                                cdl.ContentDocument.LatestPublishedVersionId,
                                cdl.ContentDocument.LatestPublishedVersion.Title
                            )
                        );
                    }
                    if (
                        availableLanguageCodes.contains(
                            cdl.ContentDocument.LatestPublishedVersion.LanguageCode__c
                        )
                    ) {
                        items.add(
                            new TranslatedContentItem(
                                cdl.ContentDocument.LatestPublishedVersionId,
                                cdl.ContentDocument.LatestPublishedVersion.LanguageCode__c
                            )
                        );
                    }
                }
            }
            resourceTranslationContentsMap.put(resource.Id, items);
        }
        return resourceTranslationContentsMap;
    }

    public ContentDocumentLink getCDLForResource(Id resourceId, String languageCode) {
        List<ContentDocumentLink> cdlList = [
            SELECT
                ContentDocument.LatestPublishedVersion.Title,
                ContentDocument.LatestPublishedVersion.VersionData,
                ContentDocument.LatestPublishedVersion.LanguageCode__c
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :resourceId
        ];
        for (ContentDocumentLink cdl : cdlList) {
            if (
                cdl.ContentDocument.LatestPublishedVersion.LanguageCode__c != '' &&
                cdl.ContentDocument.LatestPublishedVersion.LanguageCode__c != null
            ) {
                if (cdl.ContentDocument.LatestPublishedVersion.LanguageCode__c == languageCode)
                    return cdl;
            } else {
                if (cdl.ContentDocument.LatestPublishedVersion.Title == languageCode)
                    return cdl;
            }
        }
        if (cdlList.size() > 0)
            return cdlList[0];
        return null;
    }

    public void extendSharingToAllUsers(List<ContentDocumentLink> links) {
        for (ContentDocumentLink singleLink : links) {
            if (singleLink.LinkedEntityId.getSobjectType() == Resource__c.getSObjectType()) {
                singleLink.ShareType = 'I';
                singleLink.Visibility = 'AllUsers';
            }
        }
    }

    public void createURLsForImagesOnResources(List<ContentDocumentLink> links) {
        List<Resource__c> resourcesToUpdate = new List<Resource__c>();
        Set<Id> linksIds = new Map<Id, ContentDocumentLink>(links).keySet();
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>(
            [
                SELECT
                    Id,
                    ContentDocument.LatestPublishedVersionId,
                    ContentDocument.FileType,
                    LinkedEntityId
                FROM ContentDocumentLink
                WHERE Id IN :linksIds
            ]
        );
        if (!documentLinks.isEmpty()) {
            Map<Id, Resource__c> resourcesByIds = new Map<Id, Resource__c>(
                this.getResourcesFromContentDocumentLinks(documentLinks)
            );
            if (!resourcesByIds.isEmpty()) {
                for (ContentDocumentLink singleLink : documentLinks) {
                    if (
                        resourcesByIds.get(singleLink.LinkedEntityId) != null &&
                        ContentDocumentLinkService.AVAILABLE_IMAGE_TYPES.contains(
                            singleLink.ContentDocument.FileType
                        )
                    ) {
                        Resource__c singleResource = resourcesByIds.get(singleLink.LinkedEntityId);
                        singleResource.Image__c =
                            '/sfc/servlet.shepherd/version/download/' +
                            singleLink.ContentDocument.LatestPublishedVersionId;
                        resourcesToUpdate.add(singleResource);
                    }
                }
                update resourcesToUpdate;
            }
        }
    }

    public void removeURLsFromImagesOnResources(List<ContentDocument> documents) {
        Set<Id> documentsIds = new Map<Id, ContentDocument>(documents).keySet();
        List<ContentDocumentLink> links = [
            SELECT Id, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :documentsIds
        ];
        Map<Id, Resource__c> resourcesByIds = new Map<Id, Resource__c>(
            this.getResourcesFromContentDocumentLinks(links)
        );
        List<Resource__c> resourcesToUpdate = new List<Resource__c>();
        for (ContentDocumentLink singleLink : links) {
            Resource__c singleResource = resourcesByIds.get(singleLink.LinkedEntityId);
            if (singleResource != null) {
                singleResource.Image__c = null;
                resourcesToUpdate.add(singleResource);
            }
        }
        update resourcesToUpdate;
    }

    public void validateImageTypes(List<ContentDocumentLink> links) {
        List<ContentDocumentLink> linksToValidate = new List<ContentDocumentLink>();

        Set<Id> resourcesIds = new Set<Id>();
        Set<Id> documentsIds = new Set<Id>();
        for (ContentDocumentLink singleLink : links) {
            if (singleLink.LinkedEntityId.getSobjectType() == Resource__c.getSObjectType()) {
                linksToValidate.add(singleLink);
                resourcesIds.add(singleLink.LinkedEntityId);
                documentsIds.add(singleLink.ContentDocumentId);
            }
        }
        if (!linksToValidate.isEmpty() && !resourcesIds.isEmpty() && !documentsIds.isEmpty()) {
            Map<Id, ContentDocument> documentsByIds = new Map<Id, ContentDocument>(
                [
                    SELECT Id, FileType
                    FROM ContentDocument
                    WHERE
                        Id IN :documentsIds
                        AND FileType IN :ContentDocumentLinkService.AVAILABLE_IMAGE_TYPES
                ]
            );
            Map<Id, Resource__c> resourcesByIds = new Map<Id, Resource__c>(
                this.getResourcesByIds(resourcesIds)
            );
            for (ContentDocumentLink singleLink : linksToValidate) {
                if (
                    resourcesByIds.get(singleLink.LinkedEntityId) != null &&
                    documentsByIds.get(singleLink.ContentDocumentId) == null
                ) {
                    singleLink.addError(Label.Resources_Incompatible_Image_Or_Resource_Type);
                }
            }
        }
    }

    private List<Resource__c> getResourcesFromContentDocumentLinks(
        List<ContentDocumentLink> links
    ) {
        Set<Id> resourcesIds = new Set<Id>();
        for (ContentDocumentLink singleLink : links) {
            if (singleLink.LinkedEntityId.getSobjectType() == Resource__c.getSObjectType()) {
                resourcesIds.add(singleLink.LinkedEntityId);
            }
        }
        return this.getResourcesByIds(resourcesIds);
    }

    private List<Resource__c> getResourcesByIds(Set<Id> resourcesIds) {
        return [
            SELECT Id, Image__c
            FROM Resource__c
            WHERE
                Id IN :resourcesIds
                AND RecordType.DeveloperName IN (
                    :ResourceService.RESOURCE_TYPE_ARTICLE,
                    :ResourceService.RESOURCE_TYPE_VIDEO
                )
                AND Content_Class__c IN (
                    :ResourceService.RESOURCE_SOURCE_PLATFORM,
                    :ResourceService.RESOURCE_SOURCE_STUDY
                )
        ];
    }
    //REF-2654    

    String strObjPrefix;
    Schema.DescribeSObjectResult participant = Participant__c.sObjectType.getDescribe();
    String keyPrefix = participant.getKeyPrefix();
    public void shareParticipantReportsWithCommunityUsers(List<ContentDocumentLink> links) {
        //Schema.DescribeSObjectResult participant = Participant__c.sObjectType.getDescribe();
   		//String keyPrefix = participant.getKeyPrefix();
        
        for (ContentDocumentLink singleLink : links) {
             if((String.valueOf(singleLink.LinkedEntityId)).startsWith(keyPrefix)){
                 singleLink.ShareType = 'I';
                 singleLink.Visibility = 'AllUsers';
            } 
        }
    } 
	
    public void restrictFiles(List<ContentDocumentLink> lstCntLinks)
    {
        Set<Id> setCntDocIds = new set<Id>();
        set<Id> setParentIds = new set<Id>();
        map<Id, Participant__c> mapParent;
        
        try{
            for(ContentDocumentLink clIterator : lstCntLinks) {
                strObjPrefix = String.valueOf(clIterator.LinkedEntityId).substring(0, 3);  
                if(strObjPrefix == Participant__c.sObjectType.getDescribe().getKeyPrefix()) {
                    setCntDocIds.add(clIterator.ContentDocumentId);
                }
            }
            
            map<Id, ContentDocument> mapContentDocuments = new map<Id, ContentDocument>([SELECT Id, ContentSize, Title, FileExtension FROM ContentDocument WHERE Id IN :setCntDocIds]);
            
            list<ContentDocument> lstCntDocsToUpdate = new list<ContentDocument>();        
            for(ContentDocumentLink cdlIterator : lstCntLinks) {
                ContentDocument objCntDoc = mapContentDocuments.get(cdlIterator.ContentDocumentId);
                if(!PARTICIPANT_FILE_TYPES.contains(objCntDoc.FileExtension)){
                    cdlIterator.addError('File Not Supported (Use format-jpg,pdf,jpeg,gif,png)');   
                }  
                                                    
                if(objCntDoc.ContentSize > 26215000){
                    cdlIterator.addError('please choose a file that is 25MB or less');   
                }                      
            }  
    	}
    	catch (Exception ex){
            system.debug('Exception in ContentDocumentLink_Handler class :' + ex.getMessage());
        }
    }
	//End
	//
	
    //START REF-3232
    public void addFileNamesAndCalculateSize(List<ContentDocumentLink> lstCntLinks)
    {  
        map<Id, List<String>> mapContentDocument = new map<Id, List<String>>(); 
        map<Id, List<Integer>> mapContentDocumentSize = new map<Id, List<Integer>>();
        list<Participant__c> plist = new list<Participant__c>();
        set<Id> linkedEntityIdSet = new set<Id>();

        try{
            for(ContentDocumentLink clIterator : lstCntLinks){
                linkedEntityIdSet.add(clIterator.LinkedEntityId);
            }
            
            for(ContentDocumentLink clIterator : [Select Id, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileExtension, LinkedEntityId FROM ContentDocumentLink Where LinkedEntityId IN : linkedEntityIdSet]){
                strObjPrefix = String.valueOf(clIterator.LinkedEntityId).substring(0, 3);  
                if(strObjPrefix == Participant__c.sObjectType.getDescribe().getKeyPrefix()) {
                    if(mapContentDocument.containsKey(clIterator.LinkedEntityId))
                    {
                        List<String> participantDocs = mapContentDocument.get(clIterator.LinkedEntityId);   
                        List<Integer> docSize = mapContentDocumentSize.get(clIterator.LinkedEntityId);  
                        participantDocs.add(clIterator.ContentDocument.title + '.' + clIterator.ContentDocument.FileExtension);
                        docSize.add(clIterator.ContentDocument.ContentSize);
                        mapContentDocument.put(clIterator.LinkedEntityId, participantDocs);
                        mapContentDocumentSize.put(clIterator.LinkedEntityId, docSize);
                    }else{                    
                        List<String> participantDocs = new List<String>();
                        List<Integer> docSize = new List<Integer>();
                        participantDocs.add(clIterator.ContentDocument.Title + '.'+ clIterator.ContentDocument.FileExtension);
                        mapContentDocument.put(clIterator.LinkedEntityId, participantDocs);
                        docSize.add(clIterator.ContentDocument.ContentSize);
                        mapContentDocumentSize.put(clIterator.LinkedEntityId, docSize);
                    }															
                }
            }
            
            for(Participant__c participant : [Select Id, Participant_File_Names__c, Participant_Files_Size__c FROM Participant__c where Id IN : mapContentDocument.keySet()])
            {
                String filenamesStr;
                Decimal totalsize = 0;
                List<String> filenames = mapContentDocument.get(participant.Id);
                List<Integer> totalFileSize = mapContentDocumentSize.get(participant.Id);
                filenamesStr = String.join(filenames, ';');
                
                for(Integer tfs : totalFileSize){
                    totalsize += tfs;
                }
                totalsize = totalsize.divide((1024*1024),2);
                participant.Participant_Files_Size__c = totalsize;              
                participant.Participant_File_Names__c = filenamesStr;
                plist.add(participant);
            }
            update plist;
        }catch(Exception ex){
            system.debug('Exception in ContentDocumentLink_Handler class- addFileNamesAndCalculateSize method :' + ex.getMessage());
        }
    }
    
    public void deleteFileNamesAndCalculateSize(List<ContentDocument> documents) {
        map<Id, List<String>> mapContentDocument = new map<Id, List<String>>(); 
        map<Id, List<Integer>> mapContentDocumentSize = new map<Id, List<Integer>>();
        list<Participant__c> plist = new list<Participant__c>();
        set<Id> linkedEntityIdSet = new set<Id>();
        Set<Id> documentsIds = new Map<Id, ContentDocument>(documents).keySet();
        String filenamesStr = '';
        Decimal totalsize = 0;
        
        try{		
            List<ContentDocumentLink> links = [
                SELECT Id, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :documentsIds
            ];
            
            for(ContentDocumentLink clIterator : links){
                linkedEntityIdSet.add(clIterator.LinkedEntityId);
            }
            
            List<ContentDocumentLink> clIteratorlist= [Select Id, ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileExtension, LinkedEntityId FROM ContentDocumentLink Where LinkedEntityId IN :linkedEntityIdSet AND ContentDocumentId NOT IN :documentsIds];
            
            if(!clIteratorlist.isEmpty()){
                for(ContentDocumentLink clIterator : clIteratorlist){
                    strObjPrefix = String.valueOf(clIterator.LinkedEntityId).substring(0, 3);  
                    if(strObjPrefix == Participant__c.sObjectType.getDescribe().getKeyPrefix()) {
                        if(mapContentDocument.containsKey(clIterator.LinkedEntityId))
                        {
                            List<String> participantDocs = mapContentDocument.get(clIterator.LinkedEntityId);   
                            List<Integer> docSize = mapContentDocumentSize.get(clIterator.LinkedEntityId);  
                            participantDocs.add(clIterator.ContentDocument.title + '.' + clIterator.ContentDocument.FileExtension);
                            docSize.add(clIterator.ContentDocument.ContentSize);
                            if(!participantDocs.isEmpty()){
                                mapContentDocument.put(clIterator.LinkedEntityId, participantDocs);
                            }
                            if(!docSize.isEmpty()){
                                mapContentDocumentSize.put(clIterator.LinkedEntityId, docSize);
                            }
                        }else{                    
                            List<String> participantDocs = new List<String>();
                            List<Integer> docSize = new List<Integer>();
                            participantDocs.add(clIterator.ContentDocument.Title + '.'+ clIterator.ContentDocument.FileExtension);
                            mapContentDocument.put(clIterator.LinkedEntityId, participantDocs);
                            docSize.add(clIterator.ContentDocument.ContentSize);
                            mapContentDocumentSize.put(clIterator.LinkedEntityId, docSize);
                        }															
                    }
                }
            }
            
            if(!clIteratorlist.isEmpty() && !mapContentDocument.keySet().isEmpty()){
            for(Participant__c participant : [Select Id, Participant_File_Names__c, Participant_Files_Size__c FROM Participant__c where Id IN : mapContentDocument.keySet()])
            { 
                List<String> filenames = mapContentDocument.get(participant.Id);
                List<Integer> totalFileSize = mapContentDocumentSize.get(participant.Id);
                filenamesStr = String.join(filenames, ';');
                
                for(Integer tfs : totalFileSize){
                    totalsize += tfs;
                }
                totalsize = totalsize.divide((1024*1024),2);
                participant.Participant_Files_Size__c = totalsize;     
                participant.Participant_File_Names__c = filenamesStr;
                plist.add(participant);
            }
            update plist;
            }
            
            else{
                for(Participant__c participant : [Select Id, Participant_File_Names__c, Participant_Files_Size__c FROM Participant__c where Id IN : linkedEntityIdSet])
                {
                    participant.Participant_Files_Size__c = totalsize;     
                    participant.Participant_File_Names__c = filenamesStr;
                    plist.add(participant);
            	}
            	update plist;
            }
        }catch(Exception ex){
            system.debug('Exception in ContentDocumentLink_Handler class- deleteFileNamesAndCalculateSize method :' + ex.getMessage());
        }	
	}
    //END
}