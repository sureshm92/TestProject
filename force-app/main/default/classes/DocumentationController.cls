/**
 * Created by D.Yasinskyi on 06.04.2018
 */
public without sharing class DocumentationController {
/*
    @AuraEnabled
    public static String getFolderItems(String userMode, String folderId) {


        Id parentFolderId = '07H3D0000008OsdUAE';//todo

        if (folderId != null) {
            try {
                parentFolderId = Id.valueOf(folderId);
            } catch (Exception ex) {
                throw new AuraHandledException('Invalid folderId!');
            }
        }

        return JSON.serialize(getContentFolderItems(parentFolderId));
    }

    @AuraEnabled
    public static String getParentFolderId(String userMode, String folderId) {

        if (String.isEmpty(folderId)) {
            throw new AuraHandledException('Invalid folderId!');
        }
        Id parantId;

        try{
            parantId = [SELECT ParentContentFolderId  FROM ContentFolderItem WHERE Id = :folderId][0].ParentContentFolderId;
        } catch (Exception ex) {
            throw new AuraHandledException('No parent folder');
        }

        return JSON.serialize(parantId);
    }

    private static List<ContentFolderItem> getContentFolderItems(Id parentFolderId) {
        return [
                SELECT Id
                        , FileExtension
                        , IsFolder
                        , ParentContentFolderId
                        , Title
                        , LastModifiedDate
                FROM ContentFolderItem
                WHERE ParentContentFolderId = :parentFolderId
        ];
    }
    
    */
}