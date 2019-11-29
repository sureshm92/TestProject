/**Created by D.Yasinskyi on 23.05.2018*/
public without sharing class HelpController {

    /**
     * This is initialize method for current user.
     * @return UserContact
     */
    @AuraEnabled
    public static String getHelpInitData(String userMode) {
        try{
            UserContact userContact = new UserContact();
            userContact.currentContact = CommunityService.getUserContact();
            userContact.isDelegate = PatientDelegateService.getInstance().isDelegate();
            HelpInitData initData = new HelpInitData();
            initData.userContact = userContact;
            initData.helpTopicSettings = new List<HelpController.HelpTopicWrapper>();
            initData.helpTopicOptions = new List<LabelValueItem>();
            String userModefilter = '%' + userMode + '%';
            List<Help_Topic__mdt> helpTopics = [
                    SELECT  CaseType__c, CaseDescription__c,CaseSubject__c,
                            CasePriority__c, CaseReason__c,
                            Display_Name_Label__c, Display_Solution_Label__c,
                            Description_Placeholder_Label__c,
                            Is_Escalated__c,
                            Knowledge_Article_Link__c, Order__c,
                            Submit_Required__c,
                            User_Description_Required__c, User_Types__c
                    FROM Help_Topic__mdt
                    WHERE User_Types__c LIKE :userModefilter
                    AND Is_Active__c = TRUE
                    ORDER BY Order__c
            ];
            TranslateHelper.prepareLabelFields(helpTopics, new Set<String>{
                    'Display_Name_Label__c',
                    'Display_Solution_Label__c',
                    'Description_Placeholder_Label__c'
            });
            for(Help_Topic__mdt topic : helpTopics){
                HelpTopicWrapper tw = new HelpTopicWrapper();
                tw.type = topic.CaseType__c;
                tw.subject = topic.CaseSubject__c;
                tw.description = topic.CaseDescription__c;
                tw.priority = topic.CasePriority__c;
                tw.reason = topic.CaseReason__c;
                tw.userDescriptionRequired = topic.User_Description_Required__c;
                tw.knowledgeArticleLink = topic.Knowledge_Article_Link__c;
                tw.userTypes = topic.User_Types__c;
                tw.order = (Integer)topic.Order__c;
                tw.displayName = topic.Display_Name_Label__c;
                tw.displaySolution = topic.Display_Solution_Label__c;
                tw.descriptionPlaceholder = topic.Description_Placeholder_Label__c;
                tw.submitRequired = topic.Submit_Required__c;
                tw.escalated = topic.Is_Escalated__c;
                initData.helpTopicSettings.add(tw);
            }

            initData.helpTopicSettings.sort();

            for(Integer i=0; i< initData.helpTopicSettings.size(); i++){
                initData.helpTopicOptions.add(new LabelValueItem(initData.helpTopicSettings[i].displayName,String.valueOf(i)));
            }

            return JSON.serialize(initData);
        }catch (Exception e) {
           return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void createCase(String subject, String description, String type, String priority, String reason, String files, Boolean isClosed, Boolean isEscalated) {
        Savepoint sp = Database.setSavepoint();
        List<AssignmentRule> ars = getCaseAssignmentRule();
        if(ars.isEmpty()) throw new AuraHandledException(Label.No_Case_Assign);

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.assignmentRuleHeader.assignmentRuleId = ars[0].Id;

        Case newCase = new Case();
        newCase.Status = (isClosed?'Closed':(isEscalated?'Escalated':'New'));
        newCase.Origin = 'Web';
        newCase.Description = description;
        newCase.Type = type;
        newCase.Subject = subject;
        newCase.OwnerId = UserInfo.getUserId();
        newCase.Priority = priority;
        newCase.Reason = reason;
        newCase.setOptions(dmlOptions);

        try {
            insert newCase;
            if(String.isNotEmpty(files)){
                List<HelpController.FileContainer> fileContainers =
                        (List<HelpController.FileContainer>) JSON.deserialize(files, List<HelpController.FileContainer>.class);
                addFiles(newCase.Id, fileContainers);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            AuraHelper.throwException(e);
        }
    }

    /**
     * Before use need to create Case Assignment Rules
     */
    private static List<AssignmentRule> getCaseAssignmentRule() {
        return [
                SELECT Id
                FROM AssignmentRule
                WHERE SobjectType = 'Case' AND Active = TRUE
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

    public class HelpInitData {
        UserContact userContact;
        List<HelpTopicWrapper> helpTopicSettings;
        List<LabelValueItem> helpTopicOptions;
    }

    public class HelpTopicWrapper implements Comparable{
        Boolean userDescriptionRequired;
        String knowledgeArticleLink;
        String type;
        String subject;
        String priority;
        String reason;
        String description;
        String userTypes;
        Integer order;
        String displayName;
        String displaySolution;
        String descriptionPlaceholder;
        Boolean submitRequired;
        Boolean escalated;

        public Integer compareTo(Object compObject){
            HelpTopicWrapper compareToObj = (HelpTopicWrapper) compObject;
            if(order == compareToObj.order)
                return compareToObj.userTypes.length() - userTypes.length();
            else
                    return order - compareToObj.order;
        }
    }

    public class UserContact {
        Contact currentContact;
        Boolean isDelegate;
    }

    public class FileContainer {
        public String tmpId;
        public String fileName;
        public String base64Data;
        public String contentType;
        public String size;
    }
}