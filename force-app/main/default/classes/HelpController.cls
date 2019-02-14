/**Created by D.Yasinskyi on 23.05.2018*/
public without sharing class HelpController {

    @AuraEnabled
    public static void createCase(String description, String type, String files) {

        Savepoint sp = Database.setSavepoint();
        List<AssignmentRule> ars = getCaseAssignmentRule();
        if(ars.isEmpty()) throw new AuraHandledException('No case assigenment rule found!');

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.assignmentRuleHeader.AssignmentRuleId = ars[0].Id;

        Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.Description = description;
        newCase.Type = type;
        newCase.setOptions(dmlOptions);

        try {
            insert newCase;
            if(String.isNotEmpty(files)){
                List<HelpController.FileContainer> fileContainers = (List<HelpController.FileContainer>) JSON.deserialize(files, List<HelpController.FileContainer>.class);
                addFiles(newCase.Id, fileContainers);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
            throw new AuraHandledException('Can`t create case! [' + e.getMessage() + ']');
        }
    }

    private static List<AssignmentRule> getCaseAssignmentRule() {

        return [
                SELECT Id
                FROM AssignmentRule
                WHERE SobjectType = 'Case'
                AND Active = true
                LIMIT 1
        ];
    }

    /*private static void addAttachments(Id parentId, List<HelpController.FileContainer> filecontainers) {

        List<Attachment> attachments = new List<Attachment>();

        for(HelpController.FileContainer file : filecontainers){

            String base64Data = EncodingUtil.urlDecode(file.base64Data, 'UTF-8');

            Attachment attachment = new Attachment();
            attachment.parentId = parentId;
            attachment.Body = EncodingUtil.base64Decode(base64Data);
            attachment.Name = file.fileName;
            attachment.ContentType = file.contentType;
            attachments.add(attachment);
        }
        try {
            insert attachments;
        } catch (Exception e) {
            throw new AuraHandledException('Can`t attach file(s) to case!');
        }
    }*/

    private static void addFiles(Id parentId, List<HelpController.FileContainer> fileContainers) {

        List<ContentVersion> files = new List<ContentVersion>();

        for(HelpController.FileContainer file : fileContainers){

            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
            conVer.PathOnClient = file.fileName; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = file.fileName; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(file.base64Data); // converting your binary string to Blog
            files.add(conVer);
        }

        insert files;
        createContentDocumentLink(parentId, files);
    }
    
    private static void createContentDocumentLink(Id parentId, List<ContentVersion> files) {

        Set<Id> contentDocumentIds = new Set<Id>();
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for(ContentVersion file : files){
            contentDocumentIds.add(file.Id);
        }

        List<ContentVersion> contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentDocumentIds];

        for(ContentVersion file : contentVersions){
            //Create ContentDocumentLink
            ContentDocumentLink cdl= new ContentDocumentLink();
            cdl.ContentDocumentId = file.ContentDocumentId;
            cdl.LinkedEntityId = parentId; // you can use objectId,GroupId etc
            cdl.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
            links.add(cdl);
        }

        insert links;
    }

    public class FileContainer {
        public String tmpId;
        public String fileName;
        public String base64Data;
        public String contentType;
        public String size;
    }
}