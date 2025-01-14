/**
 * Created by Leonid Bartenev
 */

public without sharing class ReferringRemote {
    public class InitData {
        public Clinical_Trial_Profile__c trial;
        public HCP_Enrollment__c hcpEnrollment;
        public Participant_Enrollment__c participantEnrollment;
        public List<Participant_Enrollment__c> pendingPEnrollments;
        public List<StudySiteService.StudySiteDistanceWrapper> studies;
        public List<StudySiteService.StudySiteDistanceWrapper> studiesPending;
        public List<AccountWrapper> markers;
        public Map<String, StudyActions.Action> actions;
        public List<LabelValueItem> countries;
        public List<LabelValueItem> genders;
        public List<LabelValueItem> phoneTypes;
        public List<LabelValueItem> yearOfBirth; //added by sumit
        public Map<String, List<LabelValueItem>> statesByCountryMap;
        public String delegateAccessLevel;
        public String contentDoc;
    }

    public class AccountWrapper {
        public Account clinic;
        public String name;
        public String addrStreet;
        public String addrCity;
        public String siteType;
        public Account ssAccount;
    }

    @AuraEnabled
    public static String getInitData(
        Id trialId,
        Id peId,
        Id hcpeId,
        String userMode,
        String delegateId,
        String language
    ) {
        //try{
        InitData initData = new InitData();
        initData.trial = TrialService.getInstance().getTrialImpl(trialId);

        //ContentDocumentLink
        initData.contentDoc = getContentDocumentLink(trialId, language);

        //localize pes
        if (initData.trial.Link_to_Pre_screening__c != null) {
            initData.trial.Link_to_Pre_screening__c = CommunityFacadeRemote.getLocalizedURL(
                initData.trial.Link_to_Pre_screening__c
            );
        }
        if (hcpeId != null) {
            initData.hcpEnrollment = HCPEnrollmentService.getInstance()
                .getHCPEnrollmentByIdImpl(hcpeId, userMode, delegateId); //getHCPEnrollmentForHCPByTrial(trialId);
        }
        //new StudyActionsHCP(initData.hcpEnrollment).checkAction(StudyActions.ACT_REFER_TO_THIS_STUDY);

        //initData.actions = new StudyActionsHCP(initData.trial, initData.hcpEnrollment!=null?initData.hcpEnrollment.Study_Site__r:null,  initData.hcpEnrollment).actions;
        if (peId != null) {
            initData.participantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(
                peId,
                userMode,
                delegateId
            );
        } else if (initData.trial.Link_to_Medical_Record_Review__c == null) {
            initData.participantEnrollment = ParticipantEnrollmentService.createParticipantEnrollment(
                initData.trial,
                initData.hcpEnrollment,
                null
            );
        }
        if (initData.trial.Link_to_Medical_Record_Review__c != null) {
            initData.pendingPEnrollments = ParticipantEnrollmentService.getPendingParticipantEnrollments(
                trialId,
                null,
                delegateId
            );
        }
        StudySiteService.SiteFilterData siteFilterData = StudySiteService.getInstance()
            .getSiteFilterDataImpl(trialId, 'HCP');

        StudySiteService.SiteFilter siteFilter = new StudySiteService.SiteFilter(siteFilterData);
        List<StudySiteService.StudySiteDistanceWrapper> studiesTemp = StudySiteService.getInstance()
            .getStudySitesWithDistanceForHCPByTrialIdImpl(siteFilter, null, true, delegateId);
        initData.markers = new List<ReferringRemote.AccountWrapper>();
        initData.studies = new List<StudySiteService.StudySiteDistanceWrapper>();
        initData.studiesPending = new List<StudySiteService.StudySiteDistanceWrapper>();
        for (StudySiteService.StudySiteDistanceWrapper siteWrapper : studiesTemp) {
            if (
                HCPEnrollmentService.STATUS_GROUP_ACTIVATED.contains(siteWrapper.hcpe.Status__c) ||
                HCPEnrollmentService.STATUS_GROUP_PENDING.contains(siteWrapper.hcpe.Status__c)
            ) {
                if (
                    HCPEnrollmentService.STATUS_GROUP_ACTIVATED.contains(siteWrapper.hcpe.Status__c)
                ) {
                    initData.studies.add(siteWrapper);
                } else {
                    initData.studiesPending.add(siteWrapper);
                }
                AccountWrapper aw = new AccountWrapper();
                aw.clinic = siteWrapper.site.Principal_Investigator__r.Account;
                aw.ssAccount = siteWrapper.site.Site__r;
                aw.name = siteWrapper.site.Name;
                aw.siteType = siteWrapper.siteType;
                initData.markers.add(aw);
            }
        }
        //            Account site = [
        //                    SELECT Id, Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, Phone,
        //                            BillingLongitude, BillingLatitude
        //                    FROM Account
        //                    WHERE Id =: initData.hcpEnrollment.Study_Site__r.Site__c
        //            ];
        //            AccountWrapper aw = new AccountWrapper();
        //            aw.name = initData.hcpEnrollment.Study_Site__r.Name;
        //            aw.addrStreet = site.BillingStreet;
        //            aw.addrCity = getCityString(site);
        //            aw.clinic = site;
        //            initData.studies.add(aw);
        initData.countries = CountryStateUtil.getCountries();
        initData.genders = ParticipantService.getGenderLVList();
        initData.phoneTypes = ParticipantService.getPhoneTypeLVList();
        initData.yearOfBirth = ParticipantService.getYearofBirthList(); //added by sumit
        initData.statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
        initData.delegateAccessLevel = CommunityService.getInstance()
            .getUserAccessLevel(delegateId);
        return JSON.serialize(initData);
        /*}catch (Exception e){
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }*/
    }

    @AuraEnabled
    public static String checkNeedsGuardian(String participantJSON) {
        Boolean needsGuardian = false;
        Participant__c participant = (Participant__c) JSON.deserialize(
            participantJSON,
            Participant__c.class
        );
        if (!String.isEmpty(participant.Date_of_Birth__c)) {
            List<Age_of_Majority__mdt> ageOfMajorities = [
                SELECT DeveloperName, Country_Code__c, State_Code__c, Age__c
                FROM Age_of_Majority__mdt
            ];
            Map<String, Integer> ageByCountryCode = new Map<String, Integer>();
            for (Age_of_Majority__mdt ageOfMajority : ageOfMajorities) {
                if (ageOfMajority.Age__c != null) {
                    ageByCountryCode.put(
                        ageOfMajority.DeveloperName,
                        ageOfMajority.Age__c.intValue()
                    );
                }
            }

            Date birthDate = Date.valueOf(participant.Date_of_Birth__c);
            Integer participantAge = Date.newInstance(2000, birthDate.month(), birthDate.day()) <=
                Date.newInstance(2000, Date.today().month(), Date.today().day())
                ? Date.today().year() - birthDate.year()
                : Date.today().year() - birthDate.year() - 1;

            if (
                ageByCountryCode.get(
                    participant.Mailing_Country_Code__c +
                    '_' +
                    participant.Mailing_State_Code__c
                ) != null
            ) {
                needsGuardian =
                    participantAge <
                    ageByCountryCode.get(
                        participant.Mailing_Country_Code__c +
                        '_' +
                        participant.Mailing_State_Code__c
                    );
            } else if (ageByCountryCode.get(participant.Mailing_Country_Code__c) != null) {
                needsGuardian =
                    participantAge < ageByCountryCode.get(participant.Mailing_Country_Code__c);
            } else {
                needsGuardian = participantAge < 18;
            }
        }

        return '' + needsGuardian;
    }

    @AuraEnabled
    public static String checkDelegateAge(String participantJSON, String delegateParticipantJSON) {
        Boolean isAdult = false;

        Participant__c participant = (Participant__c) JSON.deserialize(
            participantJSON,
            Participant__c.class
        );

        Participant__c delegateparticipant = (Participant__c) JSON.deserialize(
            delegateParticipantJSON,
            Participant__c.class
        );

        if (!String.isEmpty(delegateparticipant.Birth_Year__c)) {
            List<Age_of_Majority__mdt> ageOfMajorities = [
                SELECT DeveloperName, Country_Code__c, State_Code__c, Age__c
                FROM Age_of_Majority__mdt
            ];
            Map<String, Integer> ageByCountryCode = new Map<String, Integer>();
            for (Age_of_Majority__mdt ageOfMajority : ageOfMajorities) {
                if (ageOfMajority.Age__c != null) {
                    ageByCountryCode.put(
                        ageOfMajority.DeveloperName,
                        ageOfMajority.Age__c.intValue()
                    );
                }
            }

            Integer delegateAge =
                (Date.Today().Year()) - (Integer.valueof(delegateparticipant.Birth_Year__c));

            if (
                ageByCountryCode.get(
                    participant.Mailing_Country_Code__c +
                    '_' +
                    participant.Mailing_State_Code__c
                ) != null
            ) {
                isAdult =
                    delegateAge >=
                    ageByCountryCode.get(
                        participant.Mailing_Country_Code__c +
                        '_' +
                        participant.Mailing_State_Code__c
                    );
            } else if (ageByCountryCode.get(participant.Mailing_Country_Code__c) != null) {
                isAdult = delegateAge >= ageByCountryCode.get(participant.Mailing_Country_Code__c);
            } else {
                isAdult = delegateAge >= 18;
            }
        }

        return '' + isAdult;
    }

    public static String getContentDocumentLink(Id trialId, String language) {
        system.debug('language' + language);
        List<Res_study__c> st = [
            SELECT Id, Resource__r.Id, Resource__r.Language__c
            FROM Res_study__c
            WHERE
                Clinical_Trial_Profile__c = :trialId
                AND Clinical_Trial_Profile__r.Patient_Auth_Upload_Required__c = TRUE
                AND Resource__r.Resource_Type__c = 'Patient Authorization Template'
                AND Visible_To_RP__c = TRUE
                AND (Resource__r.Language__c = :language
                OR Resource__r.Language__c = 'en_US')
            ORDER BY CreatedDate DESC
        ];
        Id resId;

        if (st.size() > 0) {
            for (Res_study__c sr : st) {
                if (sr.Resource__r.Language__c == language) {
                    resId = sr.Resource__r.Id;
                    break;
                } else if (sr.Resource__r.Language__c == 'en_US') {
                    resId = sr.Resource__r.Id;
                }
            }
        }

        List<ContentDocument> entries = new List<ContentDocument>();

        if (resId != null) {
            List<ContentDocumentLink> cdls = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :resId
            ];

            Set<Id> documentIds = new Set<Id>();
            for (ContentDocumentLink cdl : cdls) {
                documentIds.add(cdl.ContentDocumentId);
            }
            List<ContentDocument> documents = [
                SELECT Id, Title, ContentSize, CreatedDate, FileExtension, ContentModifiedDate
                FROM ContentDocument
                WHERE Id IN :documentIds
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            String basefileUrl = URL.getSalesforceBaseUrl().toExternalForm();
            return JSON.serialize(new resourceWrapper(st[0], documents, basefileUrl));
        } else
            return null;
    }

    public class resourceWrapper {
        @AuraEnabled
        public Res_study__c st;
        @AuraEnabled
        public List<ContentDocument> attachments;
        @AuraEnabled
        public String baseURL;

        public resourceWrapper(Res_study__c st, List<ContentDocument> attachments, String baseURL) {
            this.st = st;
            this.attachments = attachments;
            this.baseURL = baseURL;
        }
    }

    @AuraEnabled
    public static void deleteFile(String contentDocId) {
        System.debug('contentDocId--' + contentDocId);
        try {
            if (!String.isBlank(contentDocId)) {
                ContentDocument objCon = [SELECT Id FROM ContentDocument WHERE Id = :contentDocId];
                delete objCon;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void saveParticipant(
        Id hcpeId,
        String pEnrollmentJSON,
        String participantJSON,
        String participantDelegateJSON,
        String delegateId,
        String ddInfo,
        String contentDocId
    ) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantJSON,
                Participant__c.class
            );
            participant.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
            Participant__c participantDelegate = new Participant__c();
            ReferHealthcareProviderRemote.HealthcareProvider delegateDuplicateInfo;
            if (ddInfo != null)
                delegateDuplicateInfo = (ReferHealthcareProviderRemote.HealthcareProvider) JSON.deserialize(
                    ddInfo,
                    ReferHealthcareProviderRemote.HealthcareProvider.class
                );
            if (!String.isBlank(participantDelegateJSON)) {
                participantDelegate = (Participant__c) JSON.deserialize(
                    participantDelegateJSON,
                    Participant__c.class
                );
                if (participantDelegate != null) {
                    participantDelegate.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
                }
            }
            if(delegateDuplicateInfo != null && delegateDuplicateInfo.participantId != null){
                participantDelegate.Id = delegateDuplicateInfo.participantId;
                try {
                    upsert participantDelegate;
                } catch (Exception exp) {
                    system.debug('No delegate was provided');
                }
            }
            Participant_Enrollment__c enrollment = (Participant_Enrollment__c) JSON.deserialize(
                pEnrollmentJSON,
                Participant_Enrollment__c.class
            );
            enrollment.Participant_Status__c = PEStatusState.PE_STATUS_RECEIVED;
            enrollment.Contacted__c = true;
            enrollment.Contacted_Date__c = System.today();
            enrollment.Consulted__c = true;
            enrollment.Consulted_Date__c = System.today();
            enrollment.Have_you_Documented_the_Discussion__c = true;
            enrollment.Discussion_Documented_Date__c = System.today();
            enrollment.Referral_Completed_by__c = CommunityService.getInstance()
                .getCurrentContactId();
            //enrollment.Permit_Mail_Email_contact_for_this_study__c = true;
            enrollment.Permit_IQVIA_to_contact_about_study__c = true;
            if (
                enrollment.Pre_screening_Status__c ==
                ParticipantEnrollmentService.PES_STATUS_PENDING
            ) {
                enrollment.Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_PASS;
            }
        List<String> HCPE_FIELDS = HCPEnrollmentService.HCPE_COMMON_FIELDS;
        HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c');
        HCPE_FIELDS.add('Study_Site__r.Suppress_Participant_Emails__c');
        HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c');
        HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getInstance()
            .getHCPEnrollmentByIdImpl(hcpeId, CommunityService.USER_MODE_HCP, delegateId, HCPE_FIELDS);
        Boolean filterCriteria =
        hcpEnrollment.Study_Site__r.Study_Site_Type__c!='Virtual'&& hcpEnrollment.Study_Site__r.Study_Site_Type__c!='Hybrid' &&
        hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__c != null &&
        !hcpEnrollment.Study_Site__r.Suppress_Participant_Emails__c &&
        !hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
        hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c;
        enrollment.HCP__c = hcpEnrollment.Id;
        enrollment.Study_Site__c = hcpEnrollment.Study_Site__c;
        enrollment.PI_Contact__c = hcpEnrollment.Study_Site__r.Principal_Investigator__c;
        enrollment.Referral_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
        enrollment.Show_Referring_Provider__c = true;
        enrollment.Non_Referral_Reason__c='';
        //enrollment.Invited_To_Patient_Portal__c = filterCriteria;
        if(filterCriteria){
            enrollment.Invited_To_PP_Date__c = DateTime.now();
        }
        system.debug('');
        String language = UserInfo.getLanguage();
            List<Study_Site__c> sSite = new List<Study_Site__c>();
            if (enrollment.Study_Site__c != null) {
                sSite = [
                    SELECT Id, Site__c
                    FROM Study_Site__c
                    WHERE Id = :enrollment.Study_Site__c
                ];
            }
            if (sSite[0].Site__c != null) {
                participant.Site__c = sSite[0].Site__c;
                participant.Alternative_Phone_Number__c =  enrollment.Participant_Alternative_Phone__c;
                participant.Alternative_Phone_Type__c = enrollment.Participant_Alt_Phone_Type__c;
                if (participantDelegate != null)
                    participantDelegate.Site__c = sSite[0].Site__c;
            }

            ParticipantService.createParticipantAndUpdatePE(
                participant,
                participantDelegate,
                enrollment,
                language
            );
            String participantId = !String.isBlank(participant.Id)
                ? participant.Id
                : enrollment.Participant__c;
            if (participantId != null) {
                Participant__c newpartcipant = [
                    SELECT Id, Contact__c, Phone__c, Site__c
                    FROM Participant__c
                    WHERE Id = :participantId
                ];
                if (newpartcipant.Contact__c != null) {
                    Contact participantCon = new Contact(Id = newpartcipant.Contact__c);

                    if (participant.Phone_Type__c == 'Home') {
                        participantCon.HomePhone = participant.Phone__c;
                    }
                    if (participant.Phone_Type__c == 'Mobile') {
                        participantCon.MobilePhone = participant.Phone__c;
                    } else {
                        participantCon.Phone = participant.Phone__c;
                    }
                    update participantCon;
                }
            }

            Boolean createDelegateuser = true;
            // Added this lines for REF-2592 bug fixing, to stop sending email to the Virtual/Hybrid study
            if (
                hcpEnrollment != null &&
                (hcpEnrollment.Study_Site__r.Study_Site_Type__c == 'Virtual' ||
                hcpEnrollment.Study_Site__r.Study_Site_Type__c == 'Hybrid')
            ) {
                createDelegateuser = false;
            }
            /////
            if (
                participantDelegate != null &&
                !String.isEmpty(participantDelegate.Last_Name__c) &&
                !String.isEmpty(participantDelegate.Email__c)
            ) {
                Contact newContact;
                if (delegateDuplicateInfo == null || delegateDuplicateInfo.contactId == null) {
                    newContact = new Contact();
                    newContact.FirstName = participantDelegate.First_Name__c;
                    newContact.LastName = participantDelegate.Last_Name__c;
                    newContact.Email = participantDelegate.Email__c;
                    /*newContact.AccountId = [
                            SELECT Id
                            FROM Account
                            WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
                            LIMIT 1
                            FOR UPDATE
                    ].Id;*/
                    newContact.AccountId = participantDelegate.Site__c;
                    newContact.Language__c = UserInfo.getLanguage();
                    newContact.Second_Choice_Language__c = '';
                    newContact.Third_Choice_Language__c = '';
                    newContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                    newContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                    newContact.userCommunityIsDelegate__c = true;
                    newContact.MailingCountryCode = participant.Mailing_Country_Code__c;
                    newContact.MailingStateCode = participant.Mailing_State_Code__c;
                    newContact.MailingCountry = participant.Mailing_Country__c;
                    newContact.MailingState = participant.Mailing_State__c;
                    newContact.MailingPostalCode = participant.Mailing_Zip_Postal_Code__c;
                    if ('Home' == participantDelegate.Phone_Type__c) {
                        newContact.HomePhone = participantDelegate.Phone__c;
                    }
                    if ('Mobile' == participantDelegate.Phone_Type__c) {
                        newContact.MobilePhone = participantDelegate.Phone__c;
                    } else {
                        newContact.Phone = participantDelegate.Phone__c;
                    }
                    insert newContact;
                } else {
                    newContact = [
                        SELECT
                            Id,
                            FirstName,
                            LastName,
                            Email,
                            MailingCity,
                            MailingCountryCode,
                            MailingStateCode,
                            MailingState,
                            MailingPostalCode,
                            MailingCountry
                        FROM Contact
                        WHERE Id = :delegateDuplicateInfo.contactId
                    ];
                    createDelegateuser = false;
                }
                if (delegateDuplicateInfo == null || delegateDuplicateInfo.participantId == null) {
                    participantDelegate.Contact__c = newContact.Id;
                    participantDelegate.Adult__c = true;
                    participantDelegate.Mailing_Country__c = newContact.MailingCountry;
                    participantDelegate.Mailing_Country_Code__c = newContact.MailingCountryCode;
                    participantDelegate.Mailing_State__c = newContact.MailingState;
                    participantDelegate.Mailing_State_Code__c = newContact.MailingStateCode;
                    participantDelegate.Mailing_Zip_Postal_Code__c = newContact.MailingPostalCode;
                    if (
                        String.isBlank(participantDelegate.Phone__c) &&
                        !String.isBlank(participant.Phone__c)
                    ) {
                        participantDelegate.Phone__c = participant.Phone__c;
                        participantDelegate.Phone_Type__c = participant.Phone_Type__c;
                    }
                    if (String.isNotBlank(participantDelegate.Birth_Year__c)) {
                        participantDelegate.Attestation__c = true;
                        participantDelegate.Attestation_TimeStamp__c = ParticipantService.getFormattedTime();
                        participantDelegate.Attested_by__c = CommunityService.getInstance()
                            .getCurrentContactId();
                    }
                    insert participantDelegate;
                }
                //if(delegateDuplicateInfo == null || !delegateDuplicateInfo.isDuplicateDelegate) {

                if (participantId != null && newContact.Id != null) {
                    List<Patient_Delegate__c> checkPDel = [
                        SELECT Id
                        FROM Patient_Delegate__c
                        WHERE Participant__c = :participantId AND Contact__c = :newContact.Id
                    ];
                    List<Participant_Enrollment__c> particpantEnrollList = [
                        SELECT
                            Id,
                            Study_Site__r.Study_Site_Type__c,
                            Study_Site__r.Suppress_Participant_Emails__c,
                            Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c
                        FROM Participant_Enrollment__c
                        WHERE Participant__c = :participantId
                    ];
                    if (checkPDel.isEmpty()) {
                        Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
                        ptDelegateRef.Participant__c = participantId;
                        ptDelegateRef.Contact__c = newContact.Id;
                        ptDelegateRef.Primary_Delegate__c = true;
                        ptDelegateRef.Status__c = 'Disconnected';
                        /*  if(delegateDuplicateInfo == null || delegateDuplicateInfo.participantId == null){
                            ptDelegateRef.Attestation__c = true;
                            ptDelegateRef.Attestation_TimeStamp__c = Date.today();
                            ptDelegateRef.Attested_by__c = CommunityService.getInstance().getCurrentContactId();
                        }   */
                        String communityTemplateName = UserContext.getCurrentCommunityTemplate()
                            .templateName;
                        if (
                            particpantEnrollList.size() > 0 &&
                            particpantEnrollList[0].Study_Site__r.Study_Site_Type__c ==
                            StudySiteService.SS_TYPE_TRADITIONAL &&
                            (particpantEnrollList[0].Study_Site__r.Suppress_Participant_Emails__c ||
                            particpantEnrollList[0]
                                .Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c) &&
                            communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT
                        ) {
                            TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                            );
                        }

                        insert ptDelegateRef;
                    }
                }

                //}
                if (createDelegateuser) {
                    createParticipantUsers(new Map<Id, Id>{ newContact.Id => null },
                    TaskService.invitationsVisibleTemp //Added to hold the value of this parameter in future Method
                    );
                }
            } else if (
                !String.isBlank(hcpEnrollment.Study_Site__c) && !String.isBlank(participant.Id)
            ) {
                Participant__c newParticipant = [
                    SELECT Id, Contact__c
                    FROM Participant__c
                    WHERE Id = :participant.Id
                ];
                if (newParticipant != null && !String.isBlank(newParticipant.Contact__c)) {
                    Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
                    Study_Site__c ss = StudySiteService.getStudySiteForHCPById(
                        hcpEnrollment.Study_Site__c
                    );
                    String permissionSetName = CommunityTemplateService.getTemplate(
                            ss.Clinical_Trial_Profile__r.CommunityTemplate__c
                        )
                        .permissionSet;
                    actionAssignContactPermissions.addPermission(
                        newParticipant.Contact__c,
                        permissionSetName
                    );
                    if (!actionAssignContactPermissions.isEmpty()) {
                        ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                    }
                }
            }

            //REF-3566
            else if(participantDelegate == null){
                List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
                For(Patient_Delegate__c pd:[SELECT Id,
                                            Primary_Delegate__c
                                            FROM Patient_Delegate__c
                                            WHERE Participant__c =: participantId 
                                           ]) {
                                               if(pd.Primary_Delegate__c == True){
                                                   pd.Primary_Delegate__c = False;
                                                   pdList.add(pd);
                                               }
                                           }
                update pdList;
                
            }

            System.debug('contentDocId--' + contentDocId);
            if (!String.isBlank(contentDocId)) {
                List<Participant_Enrollment__c> particpantEnrollList = [
                    SELECT
                        Id,
                        Study_Site__r.Study_Site_Type__c,
                        Study_Site__r.Suppress_Participant_Emails__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Protocol_ID__c
                    FROM Participant_Enrollment__c
                    WHERE Participant__c = :participantId
                ];
                ContentVersion objConVersion = [
                    SELECT Id
                    FROM ContentVersion
                    WHERE ContentDocumentId = :contentDocId
                ];
                //objConVersion.Form_Type__c=ParticipantEnrollmentService.CONTENTVERSION_AUTHORIZATION;
                /*if(particpantEnrollList.size() > 0){
                            objConVersion.Study_Protocol_Id__c= particpantEnrollList[0].Study_Site__r.Clinical_Trial_Profile__r.Protocol_ID__c;
                        }
                        System.debug('objConVersion-'+objConVersion);
                        update objConVersion;*/
                ContentDocumentLink objConDocLink = new ContentDocumentLink(
                    ContentDocumentId = contentDocId,
                    LinkedEntityId = particpantEnrollList[0].Id,
                    ShareType = 'V'
                );
                //System.debug('participantId--'+participantId);
                insert objConDocLink;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @Future
    public static void createParticipantUsers(Map<Id, Id> usersToCreate,
                                              Map<Id,String> invitationsVisibleTemp
                                             ) {
        if (usersToCreate != null && !usersToCreate.isEmpty())
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createParticipantUsers(usersToCreate);
                //Recalling createSurveyTasks method to create survey task for Patient Delegates
                TaskService.invitationsVisibleTemp = invitationsVisibleTemp; 
                if (TaskService.invitationsVisibleTemp != null && !TaskService.invitationsVisibleTemp.isEmpty()){
                    TaskService.createSurveyTasksforDelegate(TaskService.invitationsVisibleTemp,true);
                }
    }

    @AuraEnabled
    public static void setfailedReferral(String peJSON, String reason) {
        try {
            Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
                peJSON,
                Participant_Enrollment__c.class
            );
            pe.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL;
            if (pe.Pre_screening_Status__c != ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED)
                pe.Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_FAIL;
            pe.Non_Referral_Reason__c = reason;
            if (reason == ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING) {
                pe.Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_FAIL;
            }
            upsert pe;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    /*private static String getCityString(Account acc){
        List<String> addressList = new List<String>();
        if(acc.BillingCity != null) addressList.add(acc.BillingCity);
        if(acc.BillingState != null) addressList.add(acc.BillingState);
        if(acc.BillingPostalCode != null) addressList.add(acc.BillingPostalCode);
        return String.join(addressList, ', ');
    }*/

    public static final Map<String, List<String>> STATES_MAP = FieldDescribeUtil.getDependentOptionsImpl(
        User.CountryCode,
        User.StateCode
    );

    @AuraEnabled
    public static ReferHealthcareProviderRemote.HealthcareProvider checkDuplicateDelegate(
        String email,
        String firstName,
        String lastName
    ) {
        return ReferHealthcareProviderRemote.checkDuplicate(null, email, firstName, lastName, null);
    }

    @AuraEnabled
    public static void saveUpdatedPER(String peID){
        try{
            Participant_Enrollment__c per = new Participant_Enrollment__c(
                Id = peId,
                Contacted__c = true,
                Contacted_Date__c = System.today(),
                Consulted__c = true,
                Consulted_Date__c = System.today(),
                Have_you_Documented_the_Discussion__c = true,
                Discussion_Documented_Date__c = System.today());
            update per;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        
    }
}
