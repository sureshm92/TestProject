public without sharing class PPMessagePageRemote {
    public class applicationException extends Exception {}
    public class MSPageData {
        @AuraEnabled
        public String userMode;
        @AuraEnabled
        public List<ConversationWrapper> conversationWrappers;
        @AuraEnabled
        public List<String> messageTemplates;
        @AuraEnabled
        public List<Participant_Enrollment__c> enrollments;
        @AuraEnabled
        public Map<Id, Boolean> statusByPeMap;
        @AuraEnabled
        public Boolean isPageEnabled;
        @AuraEnabled
        public Boolean isRTL;
        @AuraEnabled
        public Map<Id, String> piContactNames;
        @AuraEnabled
        public DateTime partTodayDate;
        @AuraEnabled
        public Map<Id,String> profilePicture;
        @AuraEnabled
        public Boolean isSecondary;
         @AuraEnabled
        public string usrcontid;
       
    }

    public class ConversationWrapper {
        @AuraEnabled
        public Conversation__c conversation;
        @AuraEnabled
        public Boolean isPastStudy = false;
        @AuraEnabled
        public Boolean unread = false;
        @AuraEnabled
        public String fullName;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public DateTime lastUpdate;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String lastMessagePart;
        @AuraEnabled
        public Boolean haveAttachment;
        @AuraEnabled
        public List<MessageWrapper> messages;
        @AuraEnabled
        public String patientDelegates;
        @AuraEnabled
        public Boolean isLastMsgUnRead;
        @AuraEnabled
        public DateTime isLastMsgUnReadDtTime;
        @AuraEnabled
        public Integer peopleCount = 0;
        @AuraEnabled
        public Map<Id,String> nameList;
    }

    public class MessageWrapper {
        @AuraEnabled
        public Message__c message;
        @AuraEnabled
        public AttachmentWrapper attachmentWrapper;
    }

    public class AttachmentWrapper {
        private Map<String, String> iconByExtension = new Map<String, String>{
            'csv' => 'attach-file-csv',
            'doc' => 'attach-file-doc',
            'docx' => 'attach-file-doc',
            'jpg' => 'attach-file-jpg',
            'pdf' => 'attach-file-pdf',
            'png' => 'attach-file-png',
            'xls' => 'attach-file-xls'
        };

        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public String fileIcon;
        @AuraEnabled
        public String downloadLink = '/sfc/servlet.shepherd/document/download/'; //ContentDocumentId
        @AuraEnabled
        public String versionId;
        @AuraEnabled
        public String conDocId;
        @AuraEnabled
        public String siteBaseUrl;
        @AuraEnabled
        public String fileExtension;
        @AuraEnabled
        public String fileTitle;

        public AttachmentWrapper(ContentDocumentLink doc) {
            fileName = doc.ContentDocument.Title;
            fileIcon = iconByExtension.containsKey(doc.ContentDocument.FileExtension)
                ? iconByExtension.get(doc.ContentDocument.FileExtension)
                : 'icon-blank';
            downloadLink= Site.getBaseUrl()  + downloadLink; //Appending base URL
            downloadLink += doc.ContentDocumentId;
            versionId = doc.ContentDocument.LatestPublishedVersionId;
            conDocId = doc.ContentDocumentId;
            siteBaseUrl = Site.getBaseUrl();
            fileExtension = doc.ContentDocument.FileExtension;
            fileTitle = doc.ContentDocument.Title;
        }
    }

    @AuraEnabled
    public static MSPageData getInitData(String formFactor, Boolean isIE, String studyId) {
        try {
            MSPageData pageData = new MSPageData();
            pageData.userMode = UserContext.getCurrentUserMode().userMode;
            pageData.isSecondary = false;
            String communityTemplate = UserContext.getCurrentCommunityTemplate().templateName;
            String piId = UserContext.getUserContactId();
            Map<Id,String> piContactNames = new Map<Id,String>();
            List<Id> pIContactIds = new List<Id>();
            List<Id> delegatedSites = DelegateService.getDelegatedStudySiteIds();
            List<String> communitiesNotInSwitcher = System.Label.MessagecommunitiesforPI.split(',');
            List<Id> lstConversation = new List<Id>();
            List<Study_Site__c> allStudies = new List<Study_Site__c>(
                [
                    SELECT Id
                    FROM Study_Site__c
                    WHERE
                        (Clinical_Trial_Profile__r.CommunityTemplate__c = :communityTemplate OR
                         Clinical_Trial_Profile__r.CommunityTemplate__c = :'PatientPortal' OR  
                         Clinical_Trial_Profile__r.CommunityTemplate__c in :communitiesNotInSwitcher)
                        AND (Id IN :delegatedSites
                        OR Principal_Investigator__c = :piId)
                        AND Messages_Are_Available__c = TRUE
                ]
            );

             pageData.isPageEnabled = pageData.userMode.equals(CommunityService.USER_MODE_PI) &&
                allStudies.size() > 0
                ? true
                : CommunityFacadeRemote.getMessagesVisibility();
            pageData.isRTL = (System.Label.RTL_Languages).contains(UserInfo.getLanguage());
            List<Conversation__c> sharedConversations = new  List<Conversation__c>();
            List<Conversation__c> conversations = new List<Conversation__c>();
            
            Boolean isDelegate = false;
            Set<Id> primayDelegateConvs  = new Set<Id>();
            Set<Id> nonPrimaryConvs = new Set<Id>();
            
            if (pageData.userMode == CommunityService.USER_MODE_PARTICIPANT) {
                //Collect Enrollments
                ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
                    .getState();
                 isDelegate = participantState.isDelegate;    
                List<Participant_Enrollment__c> participantEnrollments = new List<Participant_Enrollment__c>();
                if (participantState.pe != null)
                    participantEnrollments.add(participantState.pe);
                List<Participant_Enrollment__c> pastEnrollments = new List<Participant_Enrollment__c>();
                Map<Id,Patient_Delegate_Enrollment__c> perVspdEnrolls = new Map<Id,Patient_Delegate_Enrollment__c>();
                if(participantState.isDelegate){
                      /*pastEnrollments =  PatientDelegateEnrollmentService.getPEList(
                    ParticipantContext.getCurrentContactId(),
                    UserContext.getUserContactId()
                    ) ; */
                    List<Patient_Delegate_Enrollment__c> pdEnrolls = PatientDelegateEnrollmentService.getPatientDelegateEnrollments(
                                                                    ParticipantContext.getCurrentContactId(),
                                                                    UserContext.getUserContactId());
                    if(!pdEnrolls.isEmpty()){
                        for(Patient_Delegate_Enrollment__c pde : pdEnrolls ){
                            //preparing map with participant enrollment as key and patient delegate enrollment as value
                            perVspdEnrolls.put(pde.Participant_Enrollment__c,pde);
                        }
                        String filter = DatabaseService.fieldInValues('Id', new List<Id>(perVspdEnrolls.keySet())) +'AND' +
                                        DatabaseService.fieldInValues('Participant_Status__c',PEStatusState.PE_STATUS_GROUP_ALUMNI);
                        
                        pastEnrollments = (List<Participant_Enrollment__c>) DatabaseService.query(
                                            ParticipantEnrollmentService.PE_COMMON_FIELDS,
                                            Participant_Enrollment__c.getSObjectType(),
                                            filter);                        
                    }
                }else{
                   pastEnrollments = ContactService.getPastEnrollments(
                        ParticipantContext.getCurrentContactId()
                    );
                }
                
                /*List<Participant_Enrollment__c> pastEnrollments = ContactService.getPastEnrollments(
                    ParticipantContext.getCurrentContactId()
                );*/
                List<Patient_Delegate_Enrollment__c> pdenrollment = new List<Patient_Delegate_Enrollment__c>();
                List<Id> partEnroll = new List<Id>();
                List<Participant_Enrollment__c> lstpdEnrollment = new List<Participant_Enrollment__c>();
                pdenrollment = [Select Id,Participant_Enrollment__c,Status__c,Patient_Delegate__c,Patient_Delegate__r.Contact__c, Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c from Patient_Delegate_Enrollment__c
                                 where Patient_Delegate__r.Contact__c=:piId limit 2999];    
                if(!pdenrollment.isEmpty() && pdenrollment != null){
                    for(Patient_Delegate_Enrollment__c p:pdenrollment){
                            if(p.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c && p.Status__c != 'Active' ){
                                partEnroll.add(p.Participant_Enrollment__c);
                            }
                    } 
                   
                }              
                if(!pastEnrollments.isEmpty()){
                     if(!partEnroll.isEmpty() && partEnroll!=null){
                         for(Participant_Enrollment__c per:pastEnrollments){
                             if(!partEnroll.contains(per.Id)){
                                 participantEnrollments.add(per);
                             }
                         }
                     }else{
                      participantEnrollments.addAll(pastEnrollments);
                     }
                }
                //  PEH-14410 : To display the selected Study in top from past studies page.
                if(studyId != '' && studyId != null && participantEnrollments != null && studyId != participantEnrollments[0].Clinical_Trial_Profile__c){
                    Participant_Enrollment__c enrfirst;
                    List<Participant_Enrollment__c> permnlist = new List<Participant_Enrollment__c>();
                    for(Participant_Enrollment__c pe: participantEnrollments){
                        if(pe.Clinical_Trial_Profile__c != null && pe.Clinical_Trial_Profile__c == studyId){
                            enrfirst = pe;
                        }else{
                            permnlist.add(pe);
                        }
                    }
                    participantEnrollments = new List<Participant_Enrollment__c>();
                    participantEnrollments.add(enrfirst);
                    participantEnrollments.addAll(permnlist);
                }
                //End 
                Set<Id> availablePEIds = new Set<Id>();
                List<Id> peIds = new List<Id>();
                pageData.enrollments = new List<Participant_Enrollment__c>();
                pageData.statusByPeMap = new Map<Id, Boolean>();
                for (Participant_Enrollment__c pe : participantEnrollments) {
                     //Participant Studies where PPEnabled and Invited
                     if (
                        pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c == true &&
                        pe.Invited_To_PP_Date__c != null &&
                        !participantState.isDelegate
                    ) {
                        availablePEIds.add(pe.Id);
                        if (pe.Study_Site__r.Messages_Are_Available__c) {
                            pageData.enrollments.add(pe);
                            peIds.add(pe.Id);
                            pageData.statusByPeMap.put(
                                pe.Id,
                                PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(
                                    pe.Participant_Status__c
                                )
                            );
                        }
                    }
                    //Delegate-Participant View where Studies are PPEnabled
                    else if (
                        participantState.isDelegate &&
                        pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c == true
                    ) {
                        availablePEIds.add(pe.Id);
                        if (pe.Study_Site__r.Messages_Are_Available__c) {
                            pageData.enrollments.add(pe);
                            peIds.add(pe.Id);
                            pageData.statusByPeMap.put(
                                pe.Id,
                                PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(
                                    pe.Participant_Status__c
                                )
                            );
                        }
                    }
                }
                sharedConversations = ConversationService.getSharedConversations(
                  UserInfo.getUserId()
                );

                //Collect Conversations
                 if (sharedConversations != null) {
                 Boolean secondaryDelegate = false;
                    //PEH-14410 : To display the selected Study in top from past studies page.
                    if(studyId != '' && studyId != null && sharedConversations[0].Participant_Enrollment__r.Clinical_Trial_Profile__c != studyId){
                       Conversation__c cnvfirst;
                       List<Conversation__c> convlist = new List<Conversation__c>();
                       for(Conversation__c cn: sharedConversations){
                           if(cn.Participant_Enrollment__r != null && cn.Participant_Enrollment__r.Clinical_Trial_Profile__c == studyId){
                               cnvfirst = cn;
                           }else{
                               convlist.add(cn);
                           }
                       }
                       sharedConversations = new List<Conversation__c>();
                       sharedConversations.add(cnvfirst);
                       sharedConversations.addAll(convlist);
                    }
                    // End
                    for (Conversation__c con : sharedConversations) {
                        if (availablePEIds.contains(con.Participant_Enrollment__c)){
                            //seggregation of conversation based on primary and secondary delegates
                            if(participantState.isDelegate){
                                if(perVspdEnrolls.get(con.Participant_Enrollment__c).Primary_Delegate__c){
                                    primayDelegateConvs.add(con.id);
                                }
                                else{
                                    nonPrimaryConvs.add(con.id);
                                    secondaryDelegate = true;
                                }
                            }
                            conversations.add(con);
                            lstConversation.add(con.Id);
                        }
                    }
                     pageData.isSecondary = secondaryDelegate;
                }

                //Message Variants
                List<Message_Template__mdt> messageTemplates = [
                    SELECT Message_Variant__c
                    FROM Message_Template__mdt
                ];
                if (!messageTemplates.isEmpty()) {
                    pageData.messageTemplates = new List<String>();
                    for (Message_Template__mdt mesTmp : messageTemplates) {
                        pageData.messageTemplates.add(
                            TranslateHelper.getLabelValue(
                                mesTmp.Message_Variant__c,
                                UserInfo.getLanguage()
                            )
                        );
                    }
                }
            } 
            Set<Id> allPeIds = new Set<Id>();
            if(pageData.enrollments!=null){
                for(Participant_Enrollment__c pe : pageData.enrollments){
                    pIContactIds.add(pe.Study_Site__r.Principal_Investigator__c);
                    allPeIds.add(pe.Id);
                }
                pageData.piContactNames = ViewPatientsRemote.getPINames(pIContactIds);
            }
            if (!conversations.isEmpty()) {
                Map<Id, Conversation__c> conversationsByIds = new Map<Id, Conversation__c>();
                for (Conversation__c con : conversations)
                    conversationsByIds.put(con.Id, con);

                 // if running user is delegate then retrive message considering primary or secondary delegates else retrieve message normally
                Map<Id, List<Message__c>> messagesByConversation = (isDelegate) ? getMessageforDelegates(new List<Id>(primayDelegateConvs),new List<Id>(nonPrimaryConvs)) :
                                                  MessageService.getMessagesByConversations(new List<Id>(conversationsByIds.keySet()));
                                                                                  
                //
                //PEH-14410 : To display the selected Study in top from past studies page.
                if(studyId != '' && studyId != null && conversations[0].Id != new List<Id>(messagesByConversation.keySet())[0]){
                    Map<Id, List<Message__c>> mapofselectedstudytop = new Map<Id, List<Message__c>>();
                    for(Conversation__c con : conversations){
                        mapofselectedstudytop.put(con.Id,messagesByConversation.get(con.Id));
                    }
                    messagesByConversation = new  Map<Id, List<Message__c>>();
                    messagesByConversation = mapofselectedstudytop;
                }
                //End
               if(!messagesByConversation.keySet().isEmpty()){
                
                Map<Id, Map<Id, ContentDocumentLink>> documentLinksByMesByCon = MessageService.getAttachmentsByConversation(
                    new List<Id>(conversationsByIds.keySet())
                );
                Map<Id,Map<Id, List<String>>> peDelegateNamesMap = ConversationService.peParticipantDelegateNameMap(allPeIds);

                String firstConId = (String) messagesByConversation.keySet().iterator().next();
              
                Boolean isConfidential = false;
                if(firstConId != null){
                List<Message__c> lastMsg = new List<Message__c>();
                lastMsg = [Select Id,DocId__c,Conversation__c,Is_Confidential__c  FROM Message__c where Conversation__c =:firstConId ORDER BY CreatedDate DESC LIMIT 1];
                if(!lastMsg.isEmpty() && lastMsg != null){
                    if(lastMsg[0].DocId__c != null){
                        isConfidential = lastMsg[0].Is_Confidential__c;
                    }
                 }
                }
                
                List<Id> peId = new List<Id>();
                List<Id> secDelpeIds = new List<Id>();
                List<Conversation__c> lstConversations = new List<Conversation__c>();
                List<Patient_Delegate_Enrollment__c> lstPDERs = new List<Patient_Delegate_Enrollment__c>();
                Map<Id,Message__c> confidentialMsg = new Map<Id,Message__c>();
                lstConversations =[Select Id,Participant_Enrollment__c from Conversation__c where Id IN:messagesByConversation.keySet()];
                for(Conversation__c  c: lstConversations) {
                    peId.add(c.Participant_Enrollment__c);
                }
                lstPDERs = [Select Id,Participant_Enrollment__c,Primary_Delegate__c,Patient_Delegate__c,Patient_Delegate__r.Contact__c from Patient_Delegate_Enrollment__c where Participant_Enrollment__c IN:peId
                             and Primary_Delegate__c=false and Patient_Delegate__r.Contact__c =:piId];
                for(Patient_Delegate_Enrollment__c pd: lstPDERs ) {
                    secDelpeIds.add(pd.Participant_Enrollment__c); //study which current usr is sec delegate
                }
                for(Conversation__c cn:[Select Id,Participant_Enrollment__c,(Select Id,Conversation__c,Is_Confidential__c from Messages__r ORDER BY LastModifiedDate  DESC LIMIT 1)
                                        from Conversation__c where Participant_Enrollment__c IN:secDelpeIds]){
                       for(Message__c m:cn.Messages__r){
                             if(m.Is_Confidential__c){
                                    confidentialMsg.put(cn.Id,cn.Messages__r);
                              }
                       }
                }
                
                pageData.conversationWrappers = new List<ConversationWrapper>();
                for (Id conId : messagesByConversation.keySet()) {
                    Conversation__c conversation = conversationsByIds.get(conId);
                    Boolean lastUnRead = false;
                    DateTime isLastMsgUnReadDtTime;
                    if (formFactor != 'Small' && String.valueOf(conId).equals(firstConId)) {
                        if (
                            pageData.userMode.equals(CommunityService.USER_MODE_PI) &&
                            conversation.haveUnreadForPI__c
                        ) {
                            conversation.haveUnreadForPI__c = false;
                            update conversation;
                        } else if (
                            pageData.userMode.equals(CommunityService.USER_MODE_PARTICIPANT) &&
                            conversation.haveUnreadForParticipant__c
                        ) {
                            if(confidentialMsg.get(conId) == null){
                                conversation.haveUnreadForParticipant__c = false;
                                lastUnRead = true;
                                isLastMsgUnReadDtTime = conversation.FirstUnreadDate__c;
                                update conversation;
                            }
                            
                        }
                    }
                    Map<Id, List<String>> namesMap = peDelegateNamesMap.containsKey(conversation.Participant_Enrollment__c) ? peDelegateNamesMap.get(conversation.Participant_Enrollment__c) : new  Map<Id, List<String>>();
                    pageData.conversationWrappers.add(
                        getConversationWrapperNew(
                            pageData.userMode,
                            conversation,
                            messagesByConversation.get(conversation.Id),
                            documentLinksByMesByCon.get(conversation.Id),
                            isIE,
                            namesMap,
                            pageData.piContactNames,
                            lastUnRead,
                            isLastMsgUnReadDtTime,
                            formFactor,
                            firstConId,
                            confidentialMsg  
                        )
                    );
                }
               }
            }
            pageData.partTodayDate = DateTime.now();
            pageData.usrcontid = piId;
    
            Set<Id> lstUserId = new Set<Id>();
            List<User> lstUser = new List<User>();
            Map<Id,String> usrPic = new Map<Id,String>();
            if (lstConversation != null) {
                 List<Message__c> lstMessage = new List<Message__c>();
                 lstMessage = [Select Id,CreatedById,Conversation__c,Sender_Name__c from Message__c where Conversation__c IN:lstConversation];
                 for(Message__c mes:lstMessage){
                     lstUserId.add(mes.CreatedById);
                 }        
                 lstUserId.add(UserInfo.getUserId()); 
                 lstUser = [Select Id,SmallPhotoUrl,FullPhotoUrl  from User where Id IN:lstUserId];
                 for(User u:lstUser){
                     if(!u.SmallPhotoUrl.contains('profilephoto/005/T')){
                         usrPic.put(u.Id,u.SmallPhotoUrl);
                     }
                 }
                 if(usrPic != null){
                   pageData.profilePicture = usrPic;
                 }
             }else{
                 lstUserId.add(UserInfo.getUserId()); 
                 lstUser = [Select Id,SmallPhotoUrl,FullPhotoUrl from User where Id IN:lstUserId];
                 for(User u:lstUser){
                     if(!u.SmallPhotoUrl.contains('profilephoto/005/T')){
                         usrPic.put(u.Id,u.SmallPhotoUrl);
                     }
                 }
                 if(usrPic != null){
                   pageData.profilePicture = usrPic;
                 }
             }
             
            //if(pageData != null)
            //throw new applicationException('You cant do that here');
            return pageData;
        } catch (Exception e) {
            return (MSPageData) AuraHelper.throwException(e);
        }
    }
    
    private static ConversationWrapper getConversationWrapperNew(
        String userMode,
        Conversation__c conversation,
        List<Message__c> messages,
        Map<Id, ContentDocumentLink> documentLinksMap,
        Boolean ascendingOrder,
        Map<Id, List<String>> delegateNamesByParticipant,
        Map<Id,String> piContactNames,
        Boolean lastUnRead,
        DateTime isLastMsgUnReadDtTime,
        String formFactor,
        String firstConId,
        Map<Id,Message__c> confidentialMsg 
    ) {
        ConversationWrapper conWr = new ConversationWrapper();
        conWr.conversation = conversation;

        String conTitle;    
        String conFullName;
        String conDescription;
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            conWr.unread = conversation.haveUnreadForParticipant__c;
            if(lastUnRead){
             conWr.isLastMsgUnRead = lastUnRead;
             conWr.isLastMsgUnReadDtTime = isLastMsgUnReadDtTime;
            }else{
                if(formFactor != 'Small'){
                     if(String.valueOf(conversation.Id).equals(firstConId)){
                          conWr.isLastMsgUnRead = false;
                          conWr.isLastMsgUnReadDtTime = conversation.FirstUnreadDate__c;
                     }else{
                            if(confidentialMsg.get(conversation.Id) == null){
                                 conWr.isLastMsgUnRead = conversation.haveUnreadForParticipant__c;
                                 conWr.isLastMsgUnReadDtTime = conversation.FirstUnreadDate__c;
                            }else{
                                 conWr.isLastMsgUnRead = false;
                                 conWr.isLastMsgUnReadDtTime = conversation.FirstUnreadDate__c;
                            }  
                     }
                }else{
                     
                           if(confidentialMsg.get(conversation.Id) == null){
                                 conWr.isLastMsgUnRead = conversation.haveUnreadForParticipant__c;
                                 conWr.isLastMsgUnReadDtTime = conversation.FirstUnreadDate__c;
                            }else{
                                 conWr.isLastMsgUnRead = false;
                                 conWr.isLastMsgUnReadDtTime = conversation.FirstUnreadDate__c;
                            }  
                     
                }
             
            }
            Contact piContact = conversation.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__r;
            conTitle = Label.Study_Team;
            if(piContactNames!=null && piContactNames.containsKey(conversation.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__c)){
                conFullName = piContactNames.get(conversation.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__c);
            }else{
                 conFullName = piContact.Name;
            }  

            if (
                PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(
                    conversation.Participant_Enrollment__r.Participant_Status__c
                )
            ) {
                conWr.isPastStudy = true;
                conDescription = conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
            } else {
                conDescription =
                    Label.PI_Colon +
                    ' ' +
                    (String.isNotBlank(piContact.Title) ? piContact.Title + ' ' : '') +
                    conFullName;
            }
        } 
        conWr.title = conTitle;
        conWr.fullName = conFullName;
        conWr.description = conDescription;

        if (!messages.isEmpty()) {
            Message__c lastMessage = messages.get(0);
            conWr.lastUpdate = lastMessage.CreatedDate;
            conWr.lastMessagePart = lastMessage.Message_Content__c;

            if (ascendingOrder)
                CollectionUtil.sortByField(messages, 'CreatedDate', false);
            List<MessageWrapper> messageWrappers = getMessageWrappers(messages, documentLinksMap);
            conWr.haveAttachment = messageWrappers.get(0).attachmentWrapper != null;
            conWr.messages = messageWrappers;
            
            Map<Id,String> nameList = new Map<Id,String>();
            for(Message__c mes:messages){
               if(!nameList.containsKey(mes.CreatedById)){
                    nameList.put(mes.CreatedById,mes.Sender_Name__c);
                }
            }  
            conWr.nameList = nameList;
            conWr.peopleCount = nameList.size();
             
        }
        return conWr;
    }
    
    //Method to fetch messages based on delegate is primary or secondary 
    public static Map<Id,List<Message__c>> getMessageforDelegates(List<Id> primaryCon,List<Id> nonPrimaryCon){
        Map<Id,List<Message__c>> conVsMsg = new Map<Id,List<Message__c>>();
        conVsMsg = MessageService.getMessagesByConversations(primaryCon);
        if(!nonPrimaryCon.isEmpty()){
            conVsMsg = MessageService.getnonConfidentialMessageByConversations(nonPrimaryCon,conVsMsg); 
        }
       
        return conVsMsg;
    }

    @AuraEnabled
    public static ConversationWrapper createConversation(
        Participant_Enrollment__c enrollment,
        String messageText,
        String fileJSON,
        Boolean isIE,
        Map<Id, String> piContactNames
    ) {
        try {
            Conversation__c newConversation = new Conversation__c(
                Participant_Enrollment__c = enrollment.Id
            );
            insert newConversation;

            ConversationService.createConversationSharesForMembers(newConversation.Id, enrollment);
            newConversation.Participant_Enrollment__r = enrollment;
            return sendMessage(newConversation, messageText, fileJSON, isIE, piContactNames);
        } catch (Exception e) {
            return (ConversationWrapper) AuraHelper.throwException(e);
        }
    }

    
    @AuraEnabled
    public static ConversationWrapper sendMessage(
        Conversation__c conversation,
        String messageText,
        String fileJSON,
        Boolean isIE,
        Map<Id,String> piContactNames
    ) {
        try {
            if (isIE == null)
                isIE = false;
            conversation = ConversationService.getConversations(new List<Id>{ conversation.Id })
                .get(0);
            Contact userContact = UserContext.getUserContact();

            String senderName;
            Boolean needUpdate = false;
            if (
                UserContext.getCurrentUserMode().userMode == CommunityService.USER_MODE_PARTICIPANT
            ) {
                List<Participant__c> participant = [
                    SELECT Id, Full_Name__c
                    FROM Participant__c
                    WHERE Contact__c = :userContact.Id
                ];
                if (!participant.isEmpty()) {
                    senderName = participant.get(0).Full_Name__c;
                } else {
                    senderName = userContact.UserCommunityIsDelegate__c
                        ? userContact.Full_Name__c
                        : conversation.Participant_Enrollment__r.Participant__r.Full_Name__c;
                }
                if (!conversation.haveUnreadForPI__c) {
                    conversation.haveUnreadForPI__c = true;
                    needUpdate = true;
                }
            } else if (UserContext.getCurrentUserMode().userMode == CommunityService.USER_MODE_PI) {
                List<Participant__c> participant = [
                    SELECT Id, Full_Name__c
                    FROM Participant__c
                    WHERE Contact__c = :userContact.Id
                ];
                if (!participant.isEmpty()) {
                    senderName = participant.get(0).Full_Name__c;
                } else {
                    senderName = userContact.Full_Name__c;
                }
                if (!conversation.haveUnreadForParticipant__c) {
                    conversation.haveUnreadForParticipant__c = true;
                    needUpdate = true;
                }
            }

            if (needUpdate) {
                conversation.FirstUnreadDate__c = Datetime.now();
                update conversation;
            }

            Message__c message = new Message__c(
                Conversation__c = conversation.Id,
                Message_Content__c = messageText,
                Sender_Name__c = senderName
            );
            if (!String.isEmpty(fileJSON))
                message.DocId__c = attachFile(conversation.Id, fileJSON);
            insert message;

            Map<Id, List<String>> participantsDelegateNames;
            if (
                CommunityService.getUserContact().userCommunityMode__c ==
                CommunityService.USER_MODE_PI
            ) {
                participantsDelegateNames = ConversationService.getYourParticipantsDelegateNames(
                    conversation.Participant_Enrollment__c
                );
            }

            List<Message__c> messages = MessageService.getMessages(conversation.Id);
            List<Id> docIds = new List<Id>();
            for (Message__c mes : messages) {
                if (mes.DocId__c != null)
                    docIds.add(mes.DocId__c);
            }

            return getConversationWrapper(
                CommunityService.getUserContact().userCommunityMode__c,
                conversation,
                messages,
                MessageService.getAttachments(conversation.Id),
                isIE,
                participantsDelegateNames,
                piContactNames,
                false,null
            );
        } catch (Exception e) {
            return (ConversationWrapper) AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static ConversationWrapper createConversations(
        Participant_Enrollment__c enrollment,
        String messageText,
        String deviceSize,
        Boolean isIE,
        Map<Id, String> piContactNames
    ) {
        try {
             // check if conversation is already present for enrollment
            List<Conversation__c> conversation = [select Id,Participant_Enrollment__c,Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c  from Conversation__c where Participant_Enrollment__c =:enrollment.Id];
            Conversation__c newConversation;
            if(conversation.isEmpty()){
                newConversation = new Conversation__c(
                Participant_Enrollment__c = enrollment.Id
                );
                insert newConversation; 
                ConversationService.createConversationSharesForMembers(newConversation.Id, enrollment);
            } 
            else{
                // if conversation is already there then map message to same conversations
                newConversation  = conversation[0];
            }
            
            newConversation.Participant_Enrollment__r = enrollment;
            return sendMessages(newConversation, messageText,deviceSize,isIE,piContactNames);
            
            
        } catch (Exception e) {
            return (ConversationWrapper) AuraHelper.throwException(e);
        }
    }
     @AuraEnabled
    public static ConversationWrapper sendMessages(
        Conversation__c conversation,
        String messageText,
       String deviceSize, Boolean isIE,
        Map<Id,String> piContactNames
    ){ 
        try {
            conversation = ConversationService.getConversations(new List<Id>{ conversation.Id })
                .get(0);
            Contact userContact = UserContext.getUserContact();

            String senderName;
            Boolean needUpdate = false;
            Boolean primaryDelegate = false;
            
            if (
                UserContext.getCurrentUserMode().userMode == CommunityService.USER_MODE_PARTICIPANT
            ) {
                List<Participant__c> participant = [
                    SELECT Id, Full_Name__c
                    FROM Participant__c
                    WHERE Contact__c = :userContact.Id
                ];
                 
                 //checking if logged in user is delegate
                if(userContact.userCommunityDelegateId__c != null){
                    //checking if logged in delegate is primary or secondary
                    List<Patient_Delegate_Enrollment__c> pde= [SELECT Id, Participant_Enrollment__c,Primary_Delegate__c 
                                                       FROM Patient_Delegate_Enrollment__c where 
                                                       Participant_Enrollment__c = :conversation.Participant_Enrollment__c
                                                       and Participant_Enrollment__r.Participant_Contact__c = : userContact.userCommunityDelegateId__c
                                                       AND Patient_Delegate__r.Contact__c = : userContact.id];
                    if(!pde.isEmpty()){
                        primaryDelegate = pde[0].Primary_Delegate__c;
                    }
                }
                
                if (!participant.isEmpty()) {
                    senderName = participant.get(0).Full_Name__c;
                } else {
                    senderName = userContact.UserCommunityIsDelegate__c
                        ? userContact.Full_Name__c
                        : conversation.Participant_Enrollment__r.Participant__r.Full_Name__c;
                }
                if (!conversation.haveUnreadForPI__c) {
                    conversation.haveUnreadForPI__c = true;
                    needUpdate = true;
                }
            } 

            if (needUpdate) {
                conversation.FirstUnreadDate__c = Datetime.now();
                update conversation;
            }

            Message__c message = new Message__c(
                Conversation__c = conversation.Id,
                Message_Content__c = messageText,
                Sender_Name__c = senderName,
                Is_Confidential__c = false
            );
            
            insert message;
            
            //getinitdata;
            Map<Id, List<String>> participantsDelegateNames;
         
             List<Message__c> messages;
            
            if(userContact.userCommunityDelegateId__c != null && !primaryDelegate){
                //eleminating confidential messages to appear if delegate is non primary    
                messages = MessageService.getNonConfidentialMessages(conversation.Id);
             }
            else{
                messages = MessageService.getMessages(conversation.Id);
            }
            
            return getConversationWrapper(
                CommunityService.getUserContact().userCommunityMode__c,
                conversation,
                messages,
                MessageService.getAttachments(conversation.Id),
                isIE,
                participantsDelegateNames,
                piContactNames,
                false,null
            );
         

        } catch (Exception e) {
             return (ConversationWrapper) AuraHelper.throwException(e);
        }
    
    }
    
    @AuraEnabled
    public static void markConversationAsRead(
        String convId
    ) {
        try {
            update new Conversation__c(
                Id = convId,
                haveUnreadForParticipant__c = false,
                haveUnreadForPI__c = false
            );
          
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Integer getUnreadCount() {
        try {
            return ConversationService.getUnreadConversationCount(
                UserInfo.getUserId(),
                UserContext.getCurrentUserMode().userMode
            );
        } catch (Exception e) {
            return (Integer) AuraHelper.throwException(e);
        }
    }
    
    public static Map<Id,String> getPIContactFullNames(List<Id> piContacts){
        Map<Id,String> pIContactFullNames = new Map<Id,String>();
        for(Participant__c piPart : [SELECT Id,Contact__c, Full_Name__c FROM Participant__c WHERE Contact__c IN :piContacts]){
            pIContactFullNames.put(piPart.Contact__c, piPart.Full_Name__c);
        }
        return pIContactFullNames;
    }
    //Wrappers Logic:---------------------------------------------------------------------------------------------------
    private static List<MessageWrapper> getMessageWrappers(
        List<Message__c> messages,
        Map<Id, ContentDocumentLink> documentLinksMap
    ) {
        List<MessageWrapper> messageWrappers = new List<PPMessagePageRemote.MessageWrapper>();
        for (Message__c message : messages) {
            MessageWrapper messageWrapper = new MessageWrapper();
            messageWrapper.message = message;
            if (message.DocId__c != null && documentLinksMap.containsKey(message.DocId__c)) {
                messageWrapper.attachmentWrapper = new AttachmentWrapper(
                    documentLinksMap.get(message.DocId__c)
                );
            }
            messageWrappers.add(messageWrapper);
        }
        return messageWrappers;
    }

    private static ConversationWrapper getConversationWrapper(
        String userMode,
        Conversation__c conversation,
        List<Message__c> messages,
        Map<Id, ContentDocumentLink> documentLinksMap,
        Boolean ascendingOrder,
        Map<Id, List<String>> delegateNamesByParticipant,
        Map<Id,String> piContactNames,
        Boolean lastUnRead,
        DateTime isLastMsgUnReadDtTime
    ) {
        ConversationWrapper conWr = new ConversationWrapper();
        conWr.conversation = conversation;

        String conTitle;    
        String conFullName;
        String conDescription;
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            conWr.unread = conversation.haveUnreadForParticipant__c;
            if(lastUnRead){
             conWr.isLastMsgUnRead = lastUnRead;
             conWr.isLastMsgUnReadDtTime = isLastMsgUnReadDtTime;
            }else{
             conWr.isLastMsgUnRead = false;
             conWr.isLastMsgUnReadDtTime = conversation.FirstUnreadDate__c;
            }
            Contact piContact = conversation.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__r;
            conTitle = Label.Study_Team;
            if(piContactNames!=null && piContactNames.containsKey(conversation.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__c)){
                conFullName = piContactNames.get(conversation.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__c);
            }else{
                 conFullName = piContact.Name;
            }  

            if (
                PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(
                    conversation.Participant_Enrollment__r.Participant_Status__c
                )
            ) {
                conWr.isPastStudy = true;
                conDescription = conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
            } else {
                conDescription =
                    Label.PI_Colon +
                    ' ' +
                    (String.isNotBlank(piContact.Title) ? piContact.Title + ' ' : '') +
                    conFullName;
            }
        } else if (userMode == CommunityService.USER_MODE_PI) {
            conWr.unread = conversation.haveUnreadForPI__c;
            Participant__c participant = conversation.Participant_Enrollment__r.Participant__r;
            conTitle = participant.Full_Name__c;
            if(delegateNamesByParticipant.containsKey(conversation.Participant_Enrollment__c)){
                conWr.patientDelegates = String.join(
                    delegateNamesByParticipant.get(conversation.Participant_Enrollment__c),
                    ', '
                );
                conTitle += ', ' + conWr.patientDelegates;
            }
            else if (delegateNamesByParticipant.containsKey(participant.Id)) {
                conWr.patientDelegates = String.join(
                    delegateNamesByParticipant.get(participant.Id),
                    ', '
                );
                conTitle += ', ' + conWr.patientDelegates;
            }
            conFullName = participant.Full_Name__c;
            conDescription = conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
        }
        conWr.title = conTitle;
        conWr.fullName = conFullName;
        conWr.description = conDescription;

        if (!messages.isEmpty()) {
            Message__c lastMessage = messages.get(0);
            conWr.lastUpdate = lastMessage.CreatedDate;
            conWr.lastMessagePart = lastMessage.Message_Content__c;

            if (ascendingOrder)
                CollectionUtil.sortByField(messages, 'CreatedDate', false);
            List<MessageWrapper> messageWrappers = getMessageWrappers(messages, documentLinksMap);
            conWr.haveAttachment = messageWrappers.get(0).attachmentWrapper != null;
            conWr.messages = messageWrappers;
            
            Map<Id,String> nameList = new Map<Id,String>();
            for(Message__c mes:messages){
               if(!nameList.containsKey(mes.CreatedById)){
                    nameList.put(mes.CreatedById,mes.Sender_Name__c);
                }
            }  
            conWr.nameList = nameList;
            conWr.peopleCount = nameList.size();
             
        }
        return conWr;
    }

    @TestVisible
    private static Id attachFile(Id parentId, String fileString) {
        List<String> fileEntity = (List<String>) JSON.deserialize(fileString, List<String>.class);
        ContentVersion newVersion = new ContentVersion(
            ContentLocation = 'S',
            PathOnClient = fileEntity.get(0),
            Title = fileEntity.get(0),
            VersionData = EncodingUtil.base64Decode(fileEntity.get(1))
        );
        insert newVersion;

        ContentVersion contentVersion = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :newVersion.Id
        ];
        insert new ContentDocumentLink(
            ContentDocumentId = contentVersion.ContentDocumentId,
            LinkedEntityId = parentId,
            ShareType = 'V'
        );

        return contentVersion.ContentDocumentId;
    }
}