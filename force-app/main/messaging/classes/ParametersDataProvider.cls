/**
 * Created by Leonid Bartenev
 *
 * Email Template Parameters Data Provider
 *
 */

public without sharing class ParametersDataProvider {

    public static final String DEFAULT_LANGUAGE = 'en_US';

    public Map<String, String> parameters;
    public String userMode;
    public Boolean isDelegate = false;
    public Boolean multiplePIMessage = false;
    public List<DelegateLevelWrapper> delegateLevelsPI = new List<DelegateLevelWrapper>();
    public List<DelegateLevelWrapper> delegateLevelsHCP = new List<DelegateLevelWrapper>();
    public String recipientName;
    public String recipientFirstName;
    public Id recipientId;
    public Id recipientUserId;
    public Id recipientContactId;
    public String recipientLanguage;
    public String parametersProviderName;
    public String communityTemplateName;

    public ParametersDataProvider(Id sourceId, String recipientName, Id recipientId, String recipientLanguage, String parametersProviderName, String userType, String outputMode, Boolean multiplePIMessage,
            String communityTemplateName) {
        this.userMode = userType;
        this.recipientName = recipientName;
        this.recipientId = recipientId;
        this.multiplePIMessage = multiplePIMessage;
        this.recipientLanguage = recipientLanguage;
        this.parametersProviderName = parametersProviderName;
        this.communityTemplateName = communityTemplateName;
        parameters = new Map<String, String>();
        updateRecipientName();
        if (sourceId != null) {
            if (parametersProviderName == null) {
                if (sourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                    initParamsFromPE(sourceId);
                } else if (sourceId.getSobjectType() == HCP_Enrollment__c.getSObjectType()) {
                    initParamsFromHCPE(sourceId);
                } else if (sourceId.getSobjectType() == Study_Site__c.getSObjectType()) {
                    initParamsFromSS(sourceId);
                } else if (sourceId.getSobjectType() == Contact.getSObjectType()) {
                    initParamsFromContact(sourceId);
                } else if (sourceId.getSobjectType() == User.getSObjectType()) {
                    initParamsFromUser(sourceId);
                } else if (sourceId.getSobjectType() == Task.getSObjectType()) {
                    initParamsFromTask(sourceId);
                }
            } else {
                Parameters_Provider__mdt pp = CatalogParametersHelper.getParametersProviderMetadata(parametersProviderName);
                parameters = CatalogParametersHelper.getParamsValueMap(sourceId, pp, recipientLanguage);
            }
        } else {
            initDummyParams();
        }

        String clinicalResearchCommunityURL = 'IQVIA Clinical Research Community at https://www.clinicalresearch.com';
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId, '');
        String clinicalResearchCommunityForgotPasswordURL = 'IQVIA Clinical Research Community Forgot password at' + authConfig.getForgotPasswordUrl();
        if (outputMode == 'HTML') {
            clinicalResearchCommunityURL = '<a href="https://www.clinicalresearch.com" target="_blank">IQVIA Clinical Research Community</a>';
            clinicalResearchCommunityForgotPasswordURL = authConfig.getForgotPasswordUrl();
        }
        parameters.put('CRCommunityURL', clinicalResearchCommunityURL);
        parameters.put('RecipientName', getUserName());
        parameters.put('RecipientFirstName', recipientFirstName);
        parameters.put('ForgotPasswordURL', clinicalResearchCommunityForgotPasswordURL);

        if (isDelegate && userMode == CommunityService.USER_MODE_PARTICIPANT) {
            parameters.put('UserName', getCommunityUserName(recipientContactId));

            List<Id> conIds = new List<Id>{recipientContactId};
            List<String> templates = new List<String>{communityTemplateName};
            if(communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT) templates.add(null);
            Map<Id, List<Id>> delegatedParticipantIdsMap = PatientDelegateService.getDelegatedParticipantIdsMap(conIds);
            List<Participant_Enrollment__c> listPe = new List<Participant_Enrollment__c>();
            List<Id> partIds = delegatedParticipantIdsMap.get(recipientContactId);

            Participant__c participant;
            listPe = [
                    SELECT Id, Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                            Participant__r.Full_Name__c,
                            Participant__r.First_Name__c,
                            Participant__r.Contact__c
                    FROM Participant_Enrollment__c
                    WHERE Participant__c IN: partIds
                    AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c IN: templates
            ];
            if(!listPe.isEmpty()) {
                participant = listPe.get(0).Participant__r;
            } else {
                participant = [SELECT First_Name__c FROM Participant__c WHERE Id =: partIds];
            }

            if(participant != null) parameters.put('ParticipantFirstName', participant.First_Name__c);
        }
        System.debug('Parameters: ' + JSON.serializePretty(parameters));
    }

    private void initParamsFromPE(Id sourceId) {
        Participant_Enrollment__c pe = [
                SELECT Id, Name,
                        Referral_Source__c,
                        HCP__r.HCP_Contact__c,
                        HCP__r.HCP_Contact__r.Name,
                        HCP__r.HCP_Contact__r.FirstName,
                        HCP__r.HCP_Contact__r.LastName,
                        HCP__r.HCP_Contact__r.Salutation,
                        HCP__r.HCP_Contact__r.Language__c,
                        HCP__r.HCP_Contact__r.Title,
                        Participant__r.Contact__c,
                        Participant__r.Contact__r.Name,
                        Participant__r.Contact__r.FirstName,
                        Participant__r.Contact__r.LastName,
                        Participant__r.Contact__r.Salutation,
                        Participant__r.Contact__r.Language__c,
                        Participant__r.Language_Preference_Code__c,
                        Participant__r.First_Name__c,
                        Participant__r.Last_Name__c,
                        Participant_Contact__r.FirstName,
                        Study_Site__r.Name,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Principal_Investigator__r.FirstName,
                        Study_Site__r.Principal_Investigator__r.LastName,
                        Study_Site__r.Principal_Investigator__r.Salutation,
                        Study_Site__r.Principal_Investigator__r.Language__c,
                        Study_Site__r.Principal_Investigator__r.Title,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c,
                        Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Study_Site__r.Study_Site_Phone__c,
                        Study_Site__r.Site__r.BillingStreet,
                        Study_Site__r.Site__r.BillingCity,
                        Study_Site__r.Site__r.BillingPostalCode,
                        Is_Virtual_Study_Site__c,
                        IsSubjectIDverifiedInSDH__c,
                        Motivational_Message_Id__c,
                        HCP__c
                FROM Participant_Enrollment__c
                WHERE (Id = :sourceId OR Participant__r.Contact__c = :sourceId)
                AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = :communityTemplateName
                LIMIT 1
        ];

        if (pe.Is_Virtual_Study_Site__c) recipientFirstName = pe.Participant__r.First_Name__c;

        parameters = new Map<String, String>{
                'PIName' => getFullContactName(pe.Study_Site__r.Principal_Investigator__r),
                'PITitle' => pe.Study_Site__r.Principal_Investigator__r.Title,
                'PILanguage' => pe.Study_Site__r.Principal_Investigator__r.Language__c,
                'ParticipantName' => getFullParticipantName(pe.Participant__r),
                'ParticipantContactFirstName' => pe.Participant_Contact__r.FirstName,
                'ParticipantLanguage' => getParticipantLanguage(pe.Participant__r),
                'IsVirtual' => pe.Is_Virtual_Study_Site__c + '',
                'PEProfileName' => pe.Name,
                'SSName' => pe.Study_Site__r.Name,
                'StudyCodeName' => pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                'SSAddress' => pe.Study_Site__r.Site__r.BillingStreet != null ? pe.Study_Site__r.Site__r.BillingStreet : '',
                'SSCity' => pe.Study_Site__r.Site__r.BillingCity != null ? pe.Study_Site__r.Site__r.BillingCity + ',' : '',
                'SSPostalCode' => pe.Study_Site__r.Site__r.BillingPostalCode != null ? pe.Study_Site__r.Site__r.BillingPostalCode : '',
                'SSPhone' => pe.Study_Site__r.Study_Site_Phone__c != null ? pe.Study_Site__r.Study_Site_Phone__c : ''
        };

        if (pe.HCP__c != null) {
            parameters.putAll(new Map<String, String>{
                    'HCPName' => getFullContactName(pe.HCP__r.HCP_Contact__r),
                    'HCPLanguage' => pe.HCP__r.HCP_Contact__r.Language__c,
                    'HCPTitle' => pe.HCP__r.HCP_Contact__r.Title
            });
        }

        TranslateHelper.translate(pe, getUserLanguage());

        parameters.putAll(new Map<String, String>{
                'PEName' => pe.Name,
                'StudyName' => pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                'StudyTitle' => pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                'StudySiteName' => pe.Study_Site__r.Name,
                'SitePhoneNumber' => pe.Study_Site__r.Study_Site_Phone__c,
                'ReferralSource' => pe.Referral_Source__c
        });
    }

    private void initParamsFromHCPE(Id hcpeId) {
        HCP_Enrollment__c hcpe;
        String piNames = '';
        hcpe = [
                SELECT Id,
                        Name,
                        HCP_Contact__r.Name,
                        HCP_Contact__r.FirstName,
                        HCP_Contact__r.LastName,
                        HCP_Contact__r.Salutation,
                        HCP_Contact__r.Language__c,
                        Study_Site__r.Name,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Principal_Investigator__r.Language__c,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Principal_Investigator__r.FirstName,
                        Study_Site__r.Principal_Investigator__r.LastName,
                        Study_Site__r.Principal_Investigator__r.Salutation,
                        Study_Site__r.Study_Site_Phone__c,
                        HCP_Contact__c
                FROM HCP_Enrollment__c
                WHERE Id = :hcpeId
        ];
        if (multiplePIMessage) {
            Map<Id, HCP_Enrollment__c> hcpeMap = new Map<Id, HCP_Enrollment__c>([
                    SELECT Id,
                            Name,
                            HCP_Contact__r.Name,
                            HCP_Contact__r.FirstName,
                            HCP_Contact__r.LastName,
                            HCP_Contact__r.Salutation,
                            HCP_Contact__r.Language__c,
                            Study_Site__r.Name,
                            Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                            Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                            Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c,
                            Study_Site__r.Principal_Investigator__c,
                            Study_Site__r.Principal_Investigator__r.Language__c,
                            Study_Site__r.Principal_Investigator__r.Name,
                            Study_Site__r.Principal_Investigator__r.FirstName,
                            Study_Site__r.Principal_Investigator__r.LastName,
                            Study_Site__r.Principal_Investigator__r.Salutation,
                            Study_Site__r.Study_Site_Phone__c,
                            HCP_Contact__c
                    FROM HCP_Enrollment__c
                    WHERE HCP_Contact__c = :hcpe.HCP_Contact__c
            ]);
            Map<Id, Contact> piMap = new Map<Id, Contact>();
            for (HCP_Enrollment__c hcpEnrollment : hcpeMap.values()) {
                piMap.put(hcpEnrollment.Study_Site__r.Principal_Investigator__c, hcpEnrollment.Study_Site__r.Principal_Investigator__r);
            }
            for (Contact c : piMap.values()) {
                piNames += getFullContactName(c) + ', ';
            }
            if (piNames != null) {
                piNames = piNames.removeEnd(', ');
            }
        }
        parameters = new Map<String, String>{
                'GuestName' => TranslateHelper.getLabelValue('Email_Guest_User_Name'),
                'GuestLanguage' => hcpe.HCP_Contact__r.Language__c,
                'PIName' => multiplePIMessage ? piNames : getFullContactName(hcpe.Study_Site__r.Principal_Investigator__r),
                'HCPName' => getFullContactName(hcpe.HCP_Contact__r),
                'PILanguage' => hcpe.Study_Site__r.Principal_Investigator__r.Language__c,
                'HCPLanguage' => hcpe.HCP_Contact__r.Language__c
        };
        TranslateHelper.translate(hcpe, getUserLanguage());
        parameters.putAll(new Map<String, String>{
                'StudySiteName' => hcpe.Study_Site__r.Name,
                'StudyName' => hcpe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                'StudyTitle' => hcpe.Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                'SitePhoneNumber' => hcpe.Study_Site__r.Study_Site_Phone__c
        });


    }

    private void initParamsFromSS(Id ssId) {
        Study_Site__c ss = [
                SELECT Id, Name,
                        Principal_Investigator__r.Name,
                        Principal_Investigator__r.FirstName,
                        Principal_Investigator__r.LastName,
                        Principal_Investigator__r.Salutation,
                        Principal_Investigator__r.Language__c,
                        Principal_Investigator__c,
                        Clinical_Trial_Profile__r.Study_Title__c,
                        Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site_Phone__c,
                        ReferralNetworkId__r.Name
                FROM Study_Site__c
                WHERE Id = :ssId
        ];

        parameters = new Map<String, String>{
                'PIName' => getFullContactName(ss.Principal_Investigator__r),
                'PILanguage' => ss.Principal_Investigator__r.Language__c,
                'ReferralNetworkName' => ss.ReferralNetworkId__r.Name
        };

        TranslateHelper.translate(ss, getUserLanguage());

        parameters.putAll(new Map<String, String>{
                'StudySiteName' => ss.Name,
                'StudyName' => ss.Clinical_Trial_Profile__r.Study_Code_Name__c,
                'StudyTitle' => ss.Clinical_Trial_Profile__r.Study_Title__c,
                'SitePhoneNumber' => ss.Study_Site_Phone__c
        });

    }

    private void initParamsFromTask(Id taskId) {
        Task task = [
                SELECT
                        Id,
                        Subject,
                        ActivityDate,
                        OwnerId,
                        Task_Code__c
                FROM Task
                WHERE Id = :taskId
        ];

        User emailOwner = [
                SELECT Id,
                        LanguageLocaleKey,
                        ContactId
                FROM User
                WHERE Id = :task.OwnerId
        ];
        //TaskTriggerHandler.processDefaultFieldValues(new List<Task> {task}, emailOwner.LanguageLocaleKey);

        parameters = new Map<String, String>{
                'TaskName' => task.Subject,
                'CompleteByDate' => UserService.formatDate(task.ActivityDate, emailOwner.LanguageLocaleKey)
        };

    }

    private void initParamsFromContact(Id contactId) {
        Contact cnt = [
                SELECT Id,
                        Name,
                        FirstName,
                        LastName,
                        Salutation,
                        RP_Invited_By_PI__c,
                        Language__c,
                        userCommunityMode__c,
                        UserCommunityIsDelegate__c,
                        OwnerId,
                        Owner.ContactId
                FROM Contact
                WHERE Id = :contactId
        ];
        initDelegates(cnt);
        isDelegate = cnt.UserCommunityIsDelegate__c;
        userMode = cnt.userCommunityMode__c;
        parameters = new Map<String, String>();
        parameters.put('FullName', getFullContactName(cnt));
        if (userMode == CommunityService.USER_MODE_PI) {
            parameters.put('PIName', getFullContactName(cnt));
            parameters.put('PILanguage', cnt.Language__c);
        } else if (userMode == CommunityService.USER_MODE_HCP) {
            List<HCP_Enrollment__c> hcpe = [
                    SELECT Id, Name,
                            HCP_Contact__r.Name,
                            HCP_Contact__r.FirstName,
                            HCP_Contact__r.LastName,
                            HCP_Contact__r.Salutation,
                            HCP_Contact__r.Language__c,
                            Study_Site__r.Name,
                            Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                            Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                            Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c,
                            Study_Site__r.Principal_Investigator__c,
                            Study_Site__r.Principal_Investigator__r.Language__c,
                            Study_Site__r.Principal_Investigator__r.Name,
                            Study_Site__r.Principal_Investigator__r.FirstName,
                            Study_Site__r.Principal_Investigator__r.LastName,
                            Study_Site__r.Principal_Investigator__r.Salutation,
                            Study_Site__r.Study_Site_Phone__c,
                            HCP_Contact__c
                    FROM HCP_Enrollment__c
                    WHERE HCP_Contact__c = :cnt.Id AND
                    (Status__c = :HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O OR Status__c = :HCPEnrollmentService.HCP_S_ACTIVATED OR Status__c = :HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION)
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];
            if (!hcpe.isEmpty()) {
                initParamsFromHCPE(hcpe[0].Id);
            }
            parameters.put('HCPName', getFullContactName(cnt));
            parameters.put('HCPLanguage', cnt.Language__c);
        } else if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            parameters.put('ParticipantLanguage', cnt.Language__c);

            if (isDelegate) {
                List<Id> conIds = new List<Id>{cnt.Id};
                Map<Id, List<Id>> delegatedParticipantIdsMap = PatientDelegateService.getDelegatedParticipantIdsMap(conIds);
                List<Participant_Enrollment__c> listPe = new List<Participant_Enrollment__c>();
                List<String> templates = new List<String>{communityTemplateName};
                if(communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT) templates.add(null);
                List<Id> partIds = delegatedParticipantIdsMap.get(cnt.Id);
                listPe = [
                        SELECT Id, Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                                Participant__r.Full_Name__c,
                                Participant__r.First_Name__c,
                                Participant__r.Contact__c
                        FROM Participant_Enrollment__c
                        WHERE Participant__c IN: partIds
                        AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c IN: templates
                ];
                Participant_Enrollment__c pe;
                if(listPe.size() > 0) pe = listPe[0];
                if (pe != null) {
                    parameters.put('ParticipantName', pe.Participant__r.Full_Name__c);
                    parameters.put('ParticipantFirstName', pe.Participant__r.First_Name__c);
                }
                parameters.put('UserName', getCommunityUserName(contactId));
            } else {
                initParamsFromPE(contactId);
            }
        }
    }

    private void initParamsFromUser(Id userId) {
        User user = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        initParamsFromContact(user.ContactId);
    }

    public String getUserName() {
        if (recipientName != null) return recipientName;
        String userNameParam;
        if (isDelegate) {
            userNameParam = 'FullName';
        } else {
            userNameParam = userMode + 'Name';
        }
        String name = parameters.get(userNameParam);
        if (name == null) {
            name = parameters.get('ParticipantContactFirstName');
        }

        return name;
    }

    public String getCommunityUserName(String contactId) {
        List<User> userList = [SELECT Username FROM User WHERE ContactId = :contactId];
        return !userList.isEmpty() ? userList.get(0).Username : '';
    }

    public String getUserLanguage() {
        if (recipientLanguage != null) return recipientLanguage;
        String langParam = userMode + 'Language';
        String language = parameters.get(langParam);
        if (language != null) return language;
        return DEFAULT_LANGUAGE;
    }

    private void initDummyParams() {
        List<Email_Dummy_Parameter__mdt> mparams = [SELECT Id, Label, Value__c FROM Email_Dummy_Parameter__mdt];
        parameters = new Map<String, String>();
        for (Email_Dummy_Parameter__mdt mparam : mparams) parameters.put(mparam.Label, mparam.Value__c);
    }

    private void initDelegates(Contact cnt) {
        //delegated by PI
        List<Site_Staff__c> siteStaffs = [
                SELECT toLabel(Delegate_Level__c),
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c,
                        Study_Site__r.Principal_Investigator__r.Full_Name__c,
                        Study_Site__r.Name
                FROM Site_Staff__c
                WHERE Site_Contact__c = :cnt.Id
        ];
        TranslateHelper.translate(siteStaffs, cnt.Language__c);
        for (Site_Staff__c PIDelegate : siteStaffs) {
            DelegateLevelWrapper dlw = new DelegateLevelWrapper();
            dlw.level = PIDelegate.Delegate_Level__c;
            dlw.studyName = PIDelegate.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c +
                    ' (' + PIDelegate.Study_Site__r.Name + ')';
            delegateLevelsPI.add(dlw);
        }
        delegateLevelsPI.sort();

        //delegated by HCP
        List<RP_Delegate_Relationship__c> rpDelegates = [
                SELECT toLabel(Delegate_Access_Level__c),
                        Referring_Provider__r.Full_Name__c
                FROM RP_Delegate_Relationship__c
                WHERE Delegate__c = :cnt.Id
        ];
        TranslateHelper.translate(rpDelegates, cnt.Language__c);
        for (RP_Delegate_Relationship__c delegate : rpDelegates) {
            DelegateLevelWrapper dlw = new DelegateLevelWrapper();
            dlw.level = delegate.Delegate_Access_Level__c;
            dlw.studyName = delegate.Referring_Provider__r.Full_Name__c;
            delegateLevelsHCP.add(dlw);
        }
        delegateLevelsHCP.sort();
    }

    private String getFullContactName(Contact c) {
        String fullName = c.Name;
        if (c.Salutation != null) fullName = c.Salutation + ' ' + fullName;
        return fullName;
    }

    private String getFullParticipantName(Participant__c participant) {
        List<String> nameParts = new List<String>();
        if (participant.First_Name__c != null) nameParts.add(participant.First_Name__c);
        if (participant.Last_Name__c != null) nameParts.add(participant.Last_Name__c);
        return String.join(nameParts, ' ');
    }

    private String getParticipantLanguage(Participant__c participant) {
        String participantLanguage = participant.Contact__r.Language__c;
        if (participant.Contact__c == null) participantLanguage = participant.Language_Preference_Code__c;
        return participantLanguage;
    }

    private void updateRecipientName() {
        if (recipientId == null) return ;
        if (recipientId.getSobjectType() == User.getSObjectType()) {
            User recipientUser = [
                    SELECT Id,
                            ContactId,
                            Contact.Name, Contact.FirstName, Contact.LastName, Contact.Salutation,
                            Contact.UserCommunityIsDelegate__c,
                            Contact.userCommunityMode__c,
                            LanguageLocaleKey
                    FROM User
                    WHERE Id = :recipientId
            ];
            recipientUserId = recipientUser.Id;
            recipientContactId = recipientUser.ContactId;
            recipientName = (recipientUser.Contact.Salutation == null ? '' : recipientUser.Contact.Salutation + ' ')
                    + recipientUser.Contact.Name;
            recipientFirstName = recipientUser.Contact.FirstName;
            recipientLanguage = recipientUser.LanguageLocaleKey;
            isDelegate = recipientUser.Contact.UserCommunityIsDelegate__c;
            userMode = recipientUser.Contact.userCommunityMode__c;

        } else {
            Contact cnt = [
                    SELECT Id,
                            Name, FirstName, LastName, Salutation,
                            Language__c,
                            UserCommunityIsDelegate__c,
                            userCommunityMode__c
                    FROM Contact
                    WHERE Id = :recipientId
            ];
            recipientContactId = recipientId;
            recipientName = (cnt.Salutation == null ? '' : cnt.Salutation + ' ') +
                    cnt.Name;
            recipientFirstName = cnt.FirstName;
            recipientLanguage = cnt.Language__c;
            isDelegate = cnt.UserCommunityIsDelegate__c;
            userMode = cnt.userCommunityMode__c;
        }

        if (recipientContactId != null) {
            List<Participant__c> participants = [
                    SELECT First_Name__c, Last_Name__c FROM Participant__c WHERE Contact__c = :recipientContactId
            ];
            if (participants.size() > 0) {
                recipientName = getFullParticipantName(participants[0]);
                recipientFirstName = participants[0].First_Name__c;
            }
        }

    }
}