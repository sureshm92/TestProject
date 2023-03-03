/**Created by D.Yasinskyi on 23.05.2018
Updated by Sumit Surve on 13.07.2020
*/

public without sharing class HelpController {
    @AuraEnabled
    public static String getHelpText() {
        String communityHelpText = TranslateHelper.getLabelValue(
            UserContext.getTemplateProperty('CommunityHelpAbout')
        );
        String helpLabel = Label.PG_HLP_HI_HCP;
        return helpLabel.replace('##CommunityHelpAbout', communityHelpText);
    }

    @AuraEnabled
    public static string getResourceURL(String resourceName){
        String baseURL='';
        try {
            //return URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Participant_user_guide').getUrl();
            baseURL=baseURL+PageReference.forResource(resourceName).getUrl();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return baseURL;
    }

    /**
     * This is initialize method for current user.
     * @return UserContact
     */
    @AuraEnabled
    public static String getHelpInitData(String userMode,String communityName) {
        try {
            List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
            List<Study_Site__c> ssList = new List<Study_Site__c>();
            UserContact userContact = new UserContact();
            userContact.currentContact = CommunityService.getUserContact();
            userContact.isDelegate = ParticipantContext.isCurrentDelegate();
            peList = getParticipants(userContact.currentContact);
            ssList = getSites(userContact.currentContact,communityName);
            HelpInitData initData = new HelpInitData();
            initData.participantEnrollList = peList;
            initData.siteList = ssList;
            initData.participantEnrollOptions = new List<LabelValueItem>();
            initData.siteOptions = new List<LabelValueItem>();

            initData.userContact = userContact;
            initData.helpTopicSettings = new List<HelpController.HelpTopicWrapper>();
            initData.helpTopicOptions = new List<LabelValueItem>();
            String userModefilter = '%' + userMode + '%';
            String communityTemplateFilter =
                '%' +
                UserContext.getCurrentCommunityTemplate().templateName +
                '%';
            List<Help_Topic__mdt> helpTopics = [
                SELECT
                    CaseType__c,
                    CaseDescription__c,
                    CaseSubject__c,
                    CasePriority__c,
                    CaseReason__c,
                    Display_Name_Label__c,
                    Display_Solution_Label__c,
                    Description_Placeholder_Label__c,
                    Is_Escalated__c,
                    Knowledge_Article_Link__c,
                    Order__c,
                    Submit_Required__c,
                    User_Description_Required__c,
                    User_Types__c
                FROM Help_Topic__mdt
                WHERE
                    User_Types__c LIKE :userModefilter
                    AND User_Communities__c LIKE :communityTemplateFilter
                    AND Is_Active__c = TRUE
                ORDER BY Order__c
            ];
            TranslateHelper.prepareLabelFields(
                helpTopics,
                new Set<String>{
                    'Display_Name_Label__c',
                    'Display_Solution_Label__c',
                    'Description_Placeholder_Label__c'
                }
            );

            Map<String, String> paramMap = new Map<String, String>{
                'CommunityBrandName' => TranslateHelper.getLabelValue(
                    UserContext.getTemplateProperty('CommunityBrandName')
                ),
                'CommunityWelcome' => TranslateHelper.getLabelValue(
                    UserContext.getTemplateProperty('CommunityWelcome')
                )
            };

            for (Help_Topic__mdt topic : helpTopics) {
                HelpTopicWrapper tw = new HelpTopicWrapper();
                tw.type = topic.CaseType__c;
                tw.subject = topic.CaseSubject__c;
                tw.description = topic.CaseDescription__c;
                tw.priority = topic.CasePriority__c;
                tw.reason = topic.CaseReason__c;
                tw.userDescriptionRequired = topic.User_Description_Required__c;
                tw.knowledgeArticleLink = topic.Knowledge_Article_Link__c;
                tw.userTypes = topic.User_Types__c;
                tw.order = (Integer) topic.Order__c;

                tw.displayName = topic.Display_Name_Label__c;
                tw.displayName = TranslateHelper.replaceParams(tw.displayName, '##', paramMap);
                tw.displaySolution = topic.Display_Solution_Label__c;
                tw.displaySolution = TranslateHelper.replaceParams(
                    tw.displaySolution,
                    '##',
                    paramMap
                );

                tw.descriptionPlaceholder = topic.Description_Placeholder_Label__c;
                tw.submitRequired = topic.Submit_Required__c;
                tw.escalated = topic.Is_Escalated__c;
                initData.helpTopicSettings.add(tw);
            }

            initData.helpTopicSettings.sort();

            for (Integer i = 0; i < initData.helpTopicSettings.size(); i++) {
                initData.helpTopicOptions.add(
                    new LabelValueItem(initData.helpTopicSettings[i].displayName, String.valueOf(i))
                );
            }

            if (
                (initData.participantEnrollList.size()) > 0 &&
                (initData.participantEnrollList != null)
            ) {
                for (Participant_Enrollment__c pe : initData.participantEnrollList) {
                    initData.participantEnrollOptions.add(
                        new LabelValueItem(
                            pe.Participant_Name__c +
                            ' ' +
                            pe.Participant_Surname__c +
                            ' ' +
                            pe.Name,
                            String.valueOf(pe.Id)
                        )
                    );
                }
            } else {
                initData.participantEnrollOptions.add(new LabelValueItem('None', null));
            }

            if (initData.siteList.size() > 0 && initData.siteList != null) {
                for (Study_Site__c ss : initData.siteList) {
                    initData.siteOptions.add(new LabelValueItem(ss.Name, ss.Name));
                }
            } else {
                initData.siteOptions.add(new LabelValueItem('None', null));
            }
            return JSON.serialize(initData);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void createCase(
        String subject,
        String description,
        String type,
        String priority,
        String reason,
        String files,
        Boolean isClosed,
        Boolean isEscalated
    ) {
        Savepoint sp = Database.setSavepoint();
        List<AssignmentRule> ars = getCaseAssignmentRule();
        if (ars.isEmpty())
            throw new AuraHandledException(Label.No_Case_Assign);

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.assignmentRuleHeader.assignmentRuleId = ars[0].Id;

        Case newCase = new Case();
        newCase.Status = (isClosed ? 'Closed' : (isEscalated ? 'Escalated' : 'New'));
        newCase.Origin = 'Web';
        newCase.Description = description;
        newCase.Type = type;
        newCase.Subject = subject;
        newCase.OwnerId = UserInfo.getUserId();
        newCase.Priority = priority;
        newCase.Reason = reason;
        Id conId = UserContext.getUserContactId();
        newCase.CommunityName__c = CommunityModeService.getUserCommunityModes(conId)[0]
            .template.communityName;
        newCase.setOptions(dmlOptions);

        try {
            insert newCase;
            if (String.isNotEmpty(files)) {
                List<HelpController.FileContainer> fileContainers = (List<HelpController.FileContainer>) JSON.deserialize(
                    files,
                    List<HelpController.FileContainer>.class
                );
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
        return [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = TRUE LIMIT 1];
    }

    private static List<Participant_Enrollment__c> getParticipants(Contact cnt) {
        List<Participant_Enrollment__c> peList = [
            SELECT
                Id,
                Name,
                Participant_Name__c,
                Participant_Surname__c,
                PI_Contact__c,
                Clinical_Trial_Profile__r.Protocol_ID__c
            FROM Participant_Enrollment__c
            WHERE Clinical_Trial_Profile__r.Protocol_ID__c = 'C19NYBC'
        ];

        return peList;
    }

    private static List<Study_Site__c> getSites(Contact cnt,String communityName) {
        Set<Id> siteIdList = new Set<Id>();
        for (Site_Staff__c sStaff : [
            SELECT Id, Study_Site__c
            FROM Site_Staff__c
            WHERE Site_Contact__c = :cnt.Id
        ]) {
            siteIdList.add(sStaff.Study_Site__c);
        }
        List<String> communityNames = new List<String>(); 
        if(communityName  == CommunityTemplateService.TEMPLATE_DEFAULT){
            communityNames.add(CommunityTemplateService.TEMPLATE_GSK);
            communityNames.add(CommunityTemplateService.TEMPLATE_PP);
        }
        communityNames.add(communityName);
        List<Study_Site__c> ssList = [
            SELECT
                Id,
                Name,
                Study_Site_Number__c,
                Override_PI_Referral_Status__c,
                Clinical_Trial_Profile__r.Protocol_ID__c,
                Principal_Investigator__c
            FROM Study_Site__c
            WHERE
                (Principal_Investigator__c = :cnt.Id
                OR Id IN :siteIdList) AND Clinical_Trial_Profile__r.CommunityTemplate__c IN :communityNames
                AND (Override_PI_Referral_Status__c = 'Accepted'
                OR Override_PI_Referral_Status__c = 'Accepted (Admin)')
        ];

        return ssList;
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

        for (HelpController.FileContainer file : fileContainers) {
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
        for (ContentVersion file : files) {
            contentDocumentIds.add(file.Id);
        }

        List<ContentVersion> contentVersions = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentDocumentIds
        ];

        for (ContentVersion file : contentVersions) {
            //Create ContentDocumentLink
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = file.ContentDocumentId;
            cdl.LinkedEntityId = parentId; // you can use objectId,GroupId etc
            cdl.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
            links.add(cdl);
        }

        insert links;
    }

    public class HelpInitData {
        UserContact userContact;
        List<Participant_Enrollment__c> participantEnrollList;
        List<LabelValueItem> participantEnrollOptions;
        List<Study_Site__c> siteList;
        List<LabelValueItem> siteOptions;
        List<HelpTopicWrapper> helpTopicSettings;
        List<LabelValueItem> helpTopicOptions;
    }

    public class HelpTopicWrapper implements Comparable {
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

        public Integer compareTo(Object compObject) {
            HelpTopicWrapper compareToObj = (HelpTopicWrapper) compObject;
            if (order == compareToObj.order)
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