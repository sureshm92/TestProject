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
        public PreScreener_Survey__c preScreenerSurvey;
        public PreScreener_Survey__c mrrSurvey;
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
        Boolean patientDoesNotExist,
        String userMode,
        String delegateId,
        String language
    ) {
        //try{
        InitData initData = new InitData();
        initData.trial = TrialService.getInstance().getTrialImpl(trialId);
        getScreenerSurvey(trialId, initData);
        //ContentDocumentLink
        initData.contentDoc = getContentDocumentLink(trialId, language);

        //localize pes
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
        } else if (initData.mrrSurvey == null) {
            initData.participantEnrollment = ParticipantEnrollmentService.createParticipantEnrollment(
                initData.trial,
                initData.hcpEnrollment,
                null
            );
        }
        if (initData.mrrSurvey != null) {
            List<String> customFields = new List<String>{
            'Id',
        'isAuthorized__c',
        'HCP__r.Status__c',
        'HCP__r.HCP_Contact__r.FirstName',
        'HCP__r.HCP_Contact__r.LastName',
        'Patient_ID__c',
        'Participant__r.First_Name__c',
        'Participant__r.Last_Name__c',
        'Participant__r.Email__c',
        'Participant__r.Phone__c',
        'Participant__r.Phone_Type__c',
        'Participant__r.Date_of_Birth__c',
        'Participant__r.Birth_Year__c',
        'Participant__r.Mailing_Country_Code__c',
        'Primary_Delegate_First_Name__c',
        'Primary_Delegate_Last_Name__c',
        'Primary_Delegate_Email__c',
        'Primary_Delegate_Phone_Number__c',
        'Primary_Delegate_Phone_Type__c',
        'Primary_Delegate_YOB__c',
        'Is_Delegate_Certify__c',
        'Birth_Month__c',
        'YOB__c'
            };
            if(patientDoesNotExist != true){
            initData.pendingPEnrollments = ParticipantEnrollmentService.getPendingParticipantEnrollments(
                trialId,
                null,
                delegateId,
                customFields
            );
            }
            if(initData.pendingPEnrollments != null && !initData.pendingPEnrollments.isEmpty()) {
                Map<Id, List<Participant_PrescreenerResponse__c>> peIdResponseMap = new Map<Id, List<Participant_PrescreenerResponse__c>>();
                for(Participant_PrescreenerResponse__c response : [
                    SELECT Id, Participant_enrollment__c, Status__c, MRR__c, Prescreener__c
                    FROM Participant_PrescreenerResponse__c 
                    WHERE Participant_enrollment__c IN :initData.pendingPEnrollments
                ]) {
                    if(!peIdResponseMap.containsKey(response.Participant_enrollment__c)) {
                        peIdResponseMap.put(response.Participant_enrollment__c, new List<Participant_PrescreenerResponse__c>());
                    }
                    peIdResponseMap.get(response.Participant_enrollment__c).add(response);
                }
                for(Participant_enrollment__c peRecord : initData.pendingPEnrollments) {
                    if(peIdResponseMap.containsKey(peRecord.Id)){
                        for(Participant_PrescreenerResponse__c response : peIdResponseMap.get(peRecord.Id)) {
                            if(response.MRR__c) {
                                peRecord.Medical_Record_Review_Status__c = response.Status__c;
                            } else if(response.Prescreener__c){
                                peRecord.Pre_screening_Status__c = response.Status__c;
                            }
                        }
                    } 
                }
            }
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

    public static void getScreenerSurvey(Id trialId, InitData initData){
        
        for(PreScreener_Survey__c survey : [
            SELECT Id, Link_to_Pre_screening__c, MRR__c, Prescreener__c
            FROM PreScreener_Survey__c  
            WHERE Study__c = :trialId  
                AND (MRR__c = true OR Prescreener__c = true)
        ]) {
            if(String.isNotBlank(survey.Link_to_Pre_screening__c)) {
                survey.Link_to_Pre_screening__c = CommunityFacadeRemote.getLocalizedURL(survey.Link_to_Pre_screening__c);
                if(survey.MRR__c == true) {
                    initData.mrrSurvey = survey;
                } else if(survey.Prescreener__c == true) {
                    initData.preScreenerSurvey = survey;
                }
            }
        }
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
        String preScreenerResponseJSON,
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
            if (delegateDuplicateInfo != null && delegateDuplicateInfo.participantId != null) {
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
            enrollment.Created_Date_RPtoPI__c = Datetime.now(); //created this field for RH-9902
            enrollment.Consulted__c = true;
            enrollment.Consulted_Date__c = System.today();
            enrollment.Have_you_Documented_the_Discussion__c = true;
            enrollment.Discussion_Documented_Date__c = System.today();
            enrollment.Referral_Completed_by__c = CommunityService.getInstance()
                .getCurrentContactId();
            //enrollment.Permit_Mail_Email_contact_for_this_study__c = true;
            enrollment.Permit_IQVIA_to_contact_about_study__c = true;
            enrollment.Study_Artificial_Voice_Consent__c = enrollment.Permit_Voice_Text_contact_for_this_study__c;
            enrollment.Study_Assisted_Dialing_Consent__c = enrollment.Permit_Voice_Text_contact_for_this_study__c;
            enrollment.Study_Pre_recorded_Voice_Consent__c = enrollment.Permit_Voice_Text_contact_for_this_study__c;
            enrollment.Study_Direct_Mail_Consent__c = enrollment.Permit_Mail_Email_contact_for_this_study__c;
            //IQVIA Outreach Consent
            enrollment.IQVIA_Contact_info_storage_consent__c = (enrollment.Participant_Phone_Opt_In_Permit_Phone__c || enrollment.Participant_Opt_In_Status_Emails__c
                                                                || enrollment.Participant_Opt_In_Status_SMS__c || enrollment.IQVIA_Direct_Mail_Consent__c);
            enrollment.IQVIA_Assisted_Dialing_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
            enrollment.IQVIA_Artificial_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
            enrollment.IQVIA_Pre_recorded_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
            
            //setConsentChange(enrollment);
            List<String> HCPE_FIELDS = HCPEnrollmentService.HCPE_COMMON_FIELDS;
            HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c');
            HCPE_FIELDS.add('Study_Site__r.Suppress_Participant_Emails__c');
            HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c');
            HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.IQVIA_Outreach__c');
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getInstance()
                .getHCPEnrollmentByIdImpl(
                    hcpeId,
                    CommunityService.USER_MODE_HCP,
                    delegateId,
                    HCPE_FIELDS
                );
            Boolean filterCriteria =
                hcpEnrollment.Study_Site__r.Study_Site_Type__c != 'Virtual' &&
                hcpEnrollment.Study_Site__r.Study_Site_Type__c != 'Hybrid' &&
                hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__c != null &&
                !hcpEnrollment.Study_Site__r.Suppress_Participant_Emails__c &&
                !hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c;
            enrollment.HCP__c = hcpEnrollment.Id;
            enrollment.Study_Site__c = hcpEnrollment.Study_Site__c;
            enrollment.PI_Contact__c = hcpEnrollment.Study_Site__r.Principal_Investigator__c;
            enrollment.Referral_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
            enrollment.Show_Referring_Provider__c = true;
            enrollment.Non_Referral_Reason__c = '';
            //enrollment.Invited_To_Patient_Portal__c = filterCriteria;
            if (
                filterCriteria &&
                participant.Adult__c &&
                String.isNotBlank(participant.Email__c) //adult added for RH-5266
            ) {
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
                participant.Alternative_Phone_Number__c = enrollment.Participant_Alternative_Phone__c;
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

            if(String.isNotBlank(preScreenerResponseJSON)) {
                Participant_PrescreenerResponse__c screenerResponse = (Participant_PrescreenerResponse__c) JSON.deserialize(
                    preScreenerResponseJSON,
                    Participant_PrescreenerResponse__c.class
                );
                if(screenerResponse != null) {
                    insert new Participant_PrescreenerResponse__c(
                        Completed_by__c =  CommunityService.getUserContact().Id,
                        Completed_Date__c = Datetime.now(),
                        Participant_enrollment__c = enrollment.Id,
                        PreScreener_Survey__c = screenerResponse.PreScreener_Survey__c,
                        Screener_Response__c = screenerResponse.Screener_Response__c,
                        Status__c = ParticipantEnrollmentService.PES_STATUS_PASS,
                        Prescreener__c = true
                    );
                }
            }
            
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
                    //Added by Raviteja
                    if(enrollment.Clinical_Trial_Profile__r.IQVIA_Outreach__c ||
                    (hcpEnrollment!=null && hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.IQVIA_Outreach__c)){
                        participantCon.Participant_Opt_In_Status_Emails__c =enrollment.Participant_Opt_In_Status_Emails__c;
                        participantCon.Participant_Opt_In_Status_SMS__c = enrollment.Participant_Opt_In_Status_SMS__c;
                        participantCon.IQVIA_Direct_Mail_Consent__c = enrollment.IQVIA_Direct_Mail_Consent__c;
                        participantCon.Participant_Phone_Opt_In_Permit_Phone__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                        participantCon.IQVIA_Assisted_Dialing_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                        participantCon.IQVIA_Artificial_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                        participantCon.IQVIA_Pre_recorded_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                        
                    }
                    //End
                     //update participantCon; updating on future method
                    String objJSONStr = Json.serialize(participantCon);
                    updateParticipantContact(objJSONStr);    
                   
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
                List<Patient_Delegate__c> checkPDel;
                if (participantId != null && newContact.Id != null) {
                    checkPDel = [
                        SELECT Id,Primary_Delegate__c,Participant__r.Email__c
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
                            (communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT ||
                            communityTemplateName == CommunityTemplateService.TEMPLATE_PP)
                        ) {
                            TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                            );
                        }

                        insert ptDelegateRef;
                    }
                }                
                if(enrollment != null && (enrollment.Clinical_Trial_Profile__r.IQVIA_Outreach__c || (hcpEnrollment!=null && hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.IQVIA_Outreach__c) )   
                   && ((checkPDel.isEmpty() && (participant.Email__c == null || participant.Email__c == '' || participant.Email__c.trim() == '')) || 
                   (checkPDel != null && !checkPDel.isEmpty() && checkPDel[0].Primary_Delegate__c && checkPDel[0].Participant__r.Email__c == null) )
                   ){
                           contact con = new contact();
                           con.id = newContact.Id;
                           con.Participant_Opt_In_Status_Emails__c =enrollment.Participant_Opt_In_Status_Emails__c;
                           con.Participant_Opt_In_Status_SMS__c = enrollment.Participant_Opt_In_Status_SMS__c;
                           con.Participant_Phone_Opt_In_Permit_Phone__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                           con.IQVIA_Artificial_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                           con.IQVIA_Assisted_Dialing_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                           con.IQVIA_Pre_recorded_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c; 
                           con.IQVIA_Direct_Mail_Consent__c = enrollment.IQVIA_Direct_Mail_Consent__c;

                             //update con; moved to future method
                             String objJSONStr = Json.serialize(con);
                             updateParticipantContact(objJSONStr);
                   }
                //}
                if (createDelegateuser) {
                    createParticipantUsers(
                        new Map<Id, Id>{ newContact.Id => null },
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
            } else if (participantDelegate == null) {
                //REF-3566
                List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
                for (Patient_Delegate__c pd : [
                    SELECT Id, Primary_Delegate__c
                    FROM Patient_Delegate__c
                    WHERE Participant__c = :participantId
                ]) {
                    if (pd.Primary_Delegate__c == true) {
                        pd.Primary_Delegate__c = false;
                        pdList.add(pd);
                    }
                }
               //update pdList; moved to future method
               String objJSONStr = Json.serialize(pdList);
               updatePatientDelegate(objJSONStr);
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
    public static void updateParticipantContact(String objJson){
             Contact participantCont = (Contact) JSON.deserialize(
            objJson,
            Contact.class
        );
        TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.createNotificationsHandler.class
            );
            
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.CreateUserForDelegateContactHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SetShowTourDefaultHandler.class);
            TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PopulateOverrideFields.class);
            TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateUserForCCContactHandler.class);
            TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateParticipantDetailsHandler.class);
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class
            );
        update participantCont;
    }
    
    @Future
    public static void updatePatientDelegate(String objJson){
             Patient_Delegate__c  patientDelegate = (Patient_Delegate__c) JSON.deserialize(
            objJson,
            Patient_Delegate__c.class
        );
        update patientDelegate;
    }

    @Future
    public static void createParticipantUsers(
        Map<Id, Id> usersToCreate,
        Map<Id, String> invitationsVisibleTemp
    ) {
        if (usersToCreate != null && !usersToCreate.isEmpty())
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createParticipantUsers(usersToCreate);
        //Recalling createSurveyTasks method to create survey task for Patient Delegates
        TaskService.invitationsVisibleTemp = invitationsVisibleTemp;
        if (
            TaskService.invitationsVisibleTemp != null &&
            !TaskService.invitationsVisibleTemp.isEmpty()
        ) {
            TaskService.createSurveyTasksforDelegate(TaskService.invitationsVisibleTemp, true);
        }
    }

    @AuraEnabled
    public static void setfailedReferral(String peJSON, String preScreenerResponseJSON, String reason) {
        try {
            Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
                peJSON,
                Participant_Enrollment__c.class
            );
            pe.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL;
            pe.Non_Referral_Reason__c = reason;
            upsert pe;

            if(String.isNotBlank(preScreenerResponseJSON)) {

                Participant_PrescreenerResponse__c screenerResponse = (Participant_PrescreenerResponse__c) JSON.deserialize(
                    preScreenerResponseJSON,
                    Participant_PrescreenerResponse__c.class
                );
                if (screenerResponse.Status__c != ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED)
                    screenerResponse.Status__c = ParticipantEnrollmentService.PES_STATUS_FAIL;
                if (reason == ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING) {
                    screenerResponse.Status__c = ParticipantEnrollmentService.PES_STATUS_FAIL;
                }
                insert new Participant_PrescreenerResponse__c(
                    Completed_by__c =  CommunityService.getUserContact().Id,
                    Completed_Date__c = Datetime.now(),
                    Participant_enrollment__c = pe.Id,
                    PreScreener_Survey__c = screenerResponse.PreScreener_Survey__c,
                    Screener_Response__c = screenerResponse.Screener_Response__c,
                    Status__c = screenerResponse.Status__c,
                    Prescreener__c = true
                );
            }
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
    public static void saveUpdatedPER(String peID) {
        try {
            Participant_Enrollment__c per = new Participant_Enrollment__c(
                Id = peId,
                Contacted__c = true,
                Contacted_Date__c = System.today(),
                Consulted__c = true,
                Consulted_Date__c = System.today(),
                Have_you_Documented_the_Discussion__c = true,
                Discussion_Documented_Date__c = System.today()
            );
            update per;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
    //SOQL 101 fix : split participant and pe creation to 2 methods saveParticipantV2 and saveParticipantEnrollment
    @AuraEnabled
    public static list<string> saveParticipantV2( 
        Id hcpeId,
        String pEnrollmentJSON,
        String participantJSON,
        String participantDelegateJSON,
        String delegateId,
        String ddInfo,
        String contentDocId
    ) {
        try {
             //Bypaass old methods from Patient Delegate Trigger       
             TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
                            );
             TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                            );  
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
            if (delegateDuplicateInfo != null && delegateDuplicateInfo.participantId != null) {
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
            enrollment.Created_Date_RPtoPI__c = Datetime.now(); //created this field for RH-9902
            enrollment.Consulted__c = true;
            enrollment.Consulted_Date__c = System.today();
            enrollment.Have_you_Documented_the_Discussion__c = true;
            enrollment.Discussion_Documented_Date__c = System.today();
            enrollment.Referral_Completed_by__c = CommunityService.getInstance()
                .getCurrentContactId();
            //enrollment.Permit_Mail_Email_contact_for_this_study__c = true;
            enrollment.Permit_IQVIA_to_contact_about_study__c = true;
            enrollment.Permit_Mail_Email_contact_for_this_study__c=true;
            enrollment.Permit_Voice_Text_contact_for_this_study__c=true;
            if(participant.Mailing_Country_Code__c=='US'){
                enrollment.Permit_SMS_Text_for_this_study__c=true;
            }
            else{
                if (enrollment.Delegate_SMS_Consent__c || enrollment.Permit_SMS_Text_for_this_study__c){
                    enrollment.Permit_SMS_Text_for_this_study__c=true;
                }
            }
            enrollment.Study_Artificial_Voice_Consent__c = enrollment.Permit_Voice_Text_contact_for_this_study__c;
            enrollment.Study_Assisted_Dialing_Consent__c = enrollment.Permit_Voice_Text_contact_for_this_study__c;
            enrollment.Study_Pre_recorded_Voice_Consent__c = enrollment.Permit_Voice_Text_contact_for_this_study__c;
            enrollment.Study_Direct_Mail_Consent__c = enrollment.Permit_Mail_Email_contact_for_this_study__c;
            //IQVIA Outreach Consent
            enrollment.IQVIA_Contact_info_storage_consent__c = (enrollment.Participant_Phone_Opt_In_Permit_Phone__c || enrollment.Participant_Opt_In_Status_Emails__c
                                                                || enrollment.Participant_Opt_In_Status_SMS__c || enrollment.IQVIA_Direct_Mail_Consent__c);
            enrollment.IQVIA_Assisted_Dialing_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
            enrollment.IQVIA_Artificial_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
            enrollment.IQVIA_Pre_recorded_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
            
            //setConsentChange(enrollment);
            List<String> HCPE_FIELDS = HCPEnrollmentService.HCPE_COMMON_FIELDS;
            HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c');
            HCPE_FIELDS.add('Study_Site__r.Suppress_Participant_Emails__c');
            HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c');
            HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.IQVIA_Outreach__c');
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getInstance()
                .getHCPEnrollmentByIdImpl(
                    hcpeId,
                    CommunityService.USER_MODE_HCP,
                    delegateId,
                    HCPE_FIELDS
                );
            Boolean filterCriteria =
                hcpEnrollment.Study_Site__r.Study_Site_Type__c != 'Virtual' &&
                hcpEnrollment.Study_Site__r.Study_Site_Type__c != 'Hybrid' &&
                hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__c != null &&
                !hcpEnrollment.Study_Site__r.Suppress_Participant_Emails__c &&
                !hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c;
            enrollment.HCP__c = hcpEnrollment.Id;
            enrollment.Study_Site__c = hcpEnrollment.Study_Site__c;
            enrollment.PI_Contact__c = hcpEnrollment.Study_Site__r.Principal_Investigator__c;
            enrollment.Referral_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
            enrollment.Show_Referring_Provider__c = true;
            enrollment.Non_Referral_Reason__c = '';
            //enrollment.Invited_To_Patient_Portal__c = filterCriteria;
            if (
                filterCriteria &&
                participant.Adult__c &&
                String.isNotBlank(participant.Email__c) //adult added for RH-5266
            ) {
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
                participant.Alternative_Phone_Number__c = enrollment.Participant_Alternative_Phone__c;
                participant.Alternative_Phone_Type__c = enrollment.Participant_Alt_Phone_Type__c;
                if (participantDelegate != null)
                    participantDelegate.Site__c = sSite[0].Site__c;
            }
            participant.Date_of_Birth__c = null;
            return ParticipantService.createParticipantAndUpdatePES(
                participant,
                participantDelegate,
                enrollment,
                language
            );
        }
        catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
    @AuraEnabled
    public static void updateParticipant(String participantJSON) {
        AddPatientByPIRemote.updateParticipant(participantJSON);
    }
    //PE insertion
    @AuraEnabled
    public static string saveParticipantEnrollment(
        Id hcpeId,
        String pEnrollmentJSON,
        String participantJSON,
        String participantDelegateJSON,
        String preScreenerResponseJSON,
        String delegateId,
        String ddInfo,
        String contentDocId
    ) {
        try {
             //Bypaass old methods from Patient Delegate Trigger       
             TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
                            );
             TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                            );  
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
            if (delegateDuplicateInfo != null && delegateDuplicateInfo.participantId != null) {
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
            enrollment.Created_Date_RPtoPI__c = Datetime.now(); //created this field for RH-9902
            enrollment.Consulted__c = true;
            enrollment.Consulted_Date__c = System.today();
            enrollment.Have_you_Documented_the_Discussion__c = true;
            enrollment.Discussion_Documented_Date__c = System.today();
            enrollment.Referral_Completed_by__c = CommunityService.getInstance()
                .getCurrentContactId();
            //enrollment.Permit_Mail_Email_contact_for_this_study__c = true;
            enrollment.Permit_IQVIA_to_contact_about_study__c = true;
            enrollment.Permit_Mail_Email_contact_for_this_study__c=true;
            enrollment.Permit_Voice_Text_contact_for_this_study__c=true;
            if(participant.Mailing_Country_Code__c=='US'){
                enrollment.Permit_SMS_Text_for_this_study__c=true;
            }
            else{
                if (enrollment.Delegate_SMS_Consent__c || enrollment.Permit_SMS_Text_for_this_study__c){
                enrollment.Permit_SMS_Text_for_this_study__c=true;
                }
            }
            enrollment.Study_Artificial_Voice_Consent__c = enrollment.Permit_Voice_Text_contact_for_this_study__c;
            enrollment.Study_Assisted_Dialing_Consent__c = enrollment.Permit_Voice_Text_contact_for_this_study__c;
            enrollment.Study_Pre_recorded_Voice_Consent__c = enrollment.Permit_Voice_Text_contact_for_this_study__c;
            enrollment.Study_Direct_Mail_Consent__c = enrollment.Permit_Mail_Email_contact_for_this_study__c;
            //IQVIA Outreach Consent
            enrollment.IQVIA_Contact_info_storage_consent__c = (enrollment.Participant_Phone_Opt_In_Permit_Phone__c || enrollment.Participant_Opt_In_Status_Emails__c
                                                                || enrollment.Participant_Opt_In_Status_SMS__c || enrollment.IQVIA_Direct_Mail_Consent__c);
            enrollment.IQVIA_Assisted_Dialing_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
            enrollment.IQVIA_Artificial_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
            enrollment.IQVIA_Pre_recorded_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
            
            //setConsentChange(enrollment);
            List<String> HCPE_FIELDS = HCPEnrollmentService.HCPE_COMMON_FIELDS;
            HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c');
            HCPE_FIELDS.add('Study_Site__r.Suppress_Participant_Emails__c');
            HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c');
            HCPE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.IQVIA_Outreach__c');
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getInstance()
                .getHCPEnrollmentByIdImpl(
                    hcpeId,
                    CommunityService.USER_MODE_HCP,
                    delegateId,
                    HCPE_FIELDS
                );
            Boolean filterCriteria =
                hcpEnrollment.Study_Site__r.Study_Site_Type__c != 'Virtual' &&
                hcpEnrollment.Study_Site__r.Study_Site_Type__c != 'Hybrid' &&
                hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__c != null &&
                !hcpEnrollment.Study_Site__r.Suppress_Participant_Emails__c &&
                !hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c;
            enrollment.HCP__c = hcpEnrollment.Id;
            enrollment.Study_Site__c = hcpEnrollment.Study_Site__c;
            enrollment.PI_Contact__c = hcpEnrollment.Study_Site__r.Principal_Investigator__c;
            enrollment.Referral_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
            enrollment.Show_Referring_Provider__c = true;
            enrollment.Non_Referral_Reason__c = '';
            //enrollment.Invited_To_Patient_Portal__c = filterCriteria;
            if (
                filterCriteria &&
                participant.Adult__c &&
                String.isNotBlank(participant.Email__c) //adult added for RH-5266
            ) {
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
                participant.Alternative_Phone_Number__c = enrollment.Participant_Alternative_Phone__c;
                participant.Alternative_Phone_Type__c = enrollment.Participant_Alt_Phone_Type__c;
                if (participantDelegate != null)
                    participantDelegate.Site__c = sSite[0].Site__c;
            }
            
            /*ParticipantService.createParticipantAndUpdatePE(
participant,
participantDelegate,
enrollment,
language
);*/
            if (enrollment != null) {
                enrollment.Participant__c = participant.Id;
                if (enrollment.Participant_Name__c == null)
                    enrollment.Participant_Name__c = participant.First_Name__c;
                if (enrollment.Participant_Surname__c == null)
                    enrollment.Participant_Surname__c = participant.Last_Name__c;
                try {
                    system.debug('>>BeforeUpsertPE>' + limits.getQueries());
                    DatabaseService.getInstance().upsertToDB(enrollment);
                    system.debug('>>aFTERUpsertPE>' + limits.getQueries());
                } catch (Exception e) {
                    String errorMsg = e.getMessage();
                    if (errorMsg.contains('DUPLICATE')) {
                        errorMsg = Label.Error_Message_Participant_Duplicate;
                        return errorMsg;
                    }
                    System.debug('ERROR: ' + errorMsg);
                    throw new ParticipantService.ParticipantServiceException(errorMsg);
                    
                }
            }
            
            if(String.isNotBlank(preScreenerResponseJSON)) {
                Participant_PrescreenerResponse__c screenerResponse = (Participant_PrescreenerResponse__c) JSON.deserialize(
                    preScreenerResponseJSON,
                    Participant_PrescreenerResponse__c.class
                );
                if(screenerResponse != null) {
                    insert new Participant_PrescreenerResponse__c(
                        Completed_by__c =  CommunityService.getUserContact().Id,
                        Completed_Date__c = Datetime.now(),
                        Participant_enrollment__c = enrollment.Id,
                        PreScreener_Survey__c = screenerResponse.PreScreener_Survey__c,
                        Screener_Response__c = screenerResponse.Screener_Response__c,
                        Status__c = ParticipantEnrollmentService.PES_STATUS_PASS,
                        Prescreener__c = true
                    );
                }
            }
            
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
                    //Added by Raviteja
                    if(enrollment.Clinical_Trial_Profile__r.IQVIA_Outreach__c ||
                       (hcpEnrollment!=null && hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.IQVIA_Outreach__c)){
                           participantCon.Participant_Opt_In_Status_Emails__c =enrollment.Participant_Opt_In_Status_Emails__c;
                           participantCon.Participant_Opt_In_Status_SMS__c = enrollment.Participant_Opt_In_Status_SMS__c;
                           participantCon.IQVIA_Direct_Mail_Consent__c = enrollment.IQVIA_Direct_Mail_Consent__c;
                           participantCon.Participant_Phone_Opt_In_Permit_Phone__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                           participantCon.IQVIA_Assisted_Dialing_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                           participantCon.IQVIA_Artificial_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                           participantCon.IQVIA_Pre_recorded_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                           
                       }
                    //End
                    //update participantCon; updating on future method
                    String objJSONStr = Json.serialize(participantCon);
                    updateParticipantContact(objJSONStr);    
                    
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
                        MailingCountry,
                        IQVIA_Contact_info_storage_consent__c,
                        Participant_Phone_Opt_In_Permit_Phone__c,
                        IQVIA_Assisted_Dialing_Consent__c,
                        IQVIA_Pre_recorded_Voice_Consent__c,
                        Participant_Opt_In_Status_SMS__c,
                        IQVIA_Pre_recorded_Calls_Consent_Time__c,
                        IQVIA_PI_Storage_Consent_Time__c,
                        IQVIA_Phone_Consent_Time__c,
                        IQVIA_Email_Consent_Time__c,
                        IQVIA_Assisted_Dialing_Consent_Time__c,
                        IQVIA_Artificial_Voice_Consent_Time__c,
                        IQVIA_SMS_Consent_Time__c
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
                List<Patient_Delegate__c> checkPDel;
                List<Patient_Delegate_Enrollment__c> lstPatientDelEnrollForDup= new List<Patient_Delegate_Enrollment__c> ();
                List<Id> lstPrimaryDelegate = new List<Id> ();
                List<Id> lstNonPrimaryDelegtae = new list<Id> ();
                if (participantId != null && newContact.Id != null) {
                    checkPDel=new List<Patient_Delegate__c>();
                    List<Patient_Delegate__c> allPDelList = [
                        SELECT Id,Primary_Delegate__c,Participant__r.Email__c,Contact__c
                        FROM Patient_Delegate__c
                        WHERE Participant__c = :participantId 
                        //AND Contact__c = :newContact.Id
                    ];
                    for(Patient_Delegate__c pDel:allPDelList){
                        if(pDel.Contact__c==newContact.Id){
                            pDel.Primary_Delegate__c = True;
                            checkPDel.add(pDel);  
                            lstPrimaryDelegate.add(pDel.Id); 
                            Patient_Delegate_Enrollment__c objPDPER = new Patient_Delegate_Enrollment__c ();
                        objPDPER.Participant_Enrollment__c = enrollment.Id;
                        objPDPER.Patient_Delegate__c = pDel.Id;
                        if(participant.Mailing_Country_Code__c=='US'){
                            objPDPER.Study_SMS_Consent__c=true;
                        }
                        else{
                            if (enrollment.Delegate_SMS_Consent__c || enrollment.Permit_SMS_Text_for_this_study__c){
                                objPDPER.Study_SMS_Consent__c=true;
                            }
                        }
                        objPDPER.Study_Phone_Consent__c = true;
                        objPDPER.Study_info_storage_consent__c = true;
                        objPDPER.Study_Email_Consent__c = true;
                        objPDPER.Status__c = 'Disconnected';
                        objPDPER.Primary_Delegate__c = true;
                        lstPatientDelEnrollForDup.add(objPDPER);
                           }else {
                            pDel.Primary_Delegate__c = false;
                            lstNonPrimaryDelegtae.add(pDel.Id);
                           }
                     }
                     if(!lstPrimaryDelegate.isEmpty()  || !lstNonPrimaryDelegtae.isEmpty())
                        updatePatientDelegateExisting(lstPrimaryDelegate,lstNonPrimaryDelegtae);
                     //update allPDelList;
                     if(!lstPatientDelEnrollForDup.isEmpty())
                        insert lstPatientDelEnrollForDup;

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
                            (communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT ||
                             communityTemplateName == CommunityTemplateService.TEMPLATE_PP)
                        ) {
                            TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                            );
                        }
                        
                        insert ptDelegateRef;

                        Patient_Delegate_Enrollment__c objPDPER = new Patient_Delegate_Enrollment__c ();
                        objPDPER.Participant_Enrollment__c = enrollment.Id;
                        objPDPER.Patient_Delegate__c = ptDelegateRef.Id;
                        if(participant.Mailing_Country_Code__c=='US'){
                            objPDPER.Study_SMS_Consent__c=true;
                        }
                        else{
                            if (enrollment.Delegate_SMS_Consent__c || enrollment.Permit_SMS_Text_for_this_study__c){
                                objPDPER.Study_SMS_Consent__c=true;
                            }
                        }
                        objPDPER.Study_Phone_Consent__c = true;
                        objPDPER.Study_info_storage_consent__c = true;
                        objPDPER.Study_Email_Consent__c = true;
                        objPDPER.Status__c = 'Disconnected';
                        objPDPER.Primary_Delegate__c = true;

                        insert objPDPER;
                    }
                }                
                if(enrollment != null && (enrollment.Clinical_Trial_Profile__r.IQVIA_Outreach__c || (hcpEnrollment!=null && hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.IQVIA_Outreach__c) )   
                   && ((checkPDel.isEmpty() && (participant.Email__c == null || participant.Email__c == '' || participant.Email__c.trim() == '')) || 
                       (checkPDel != null && !checkPDel.isEmpty() && checkPDel[0].Primary_Delegate__c && checkPDel[0].Participant__r.Email__c == null) )
                  ){
                      contact con = new contact();
                      con.id = newContact.Id;
                      Contact getCon=[Select id, Participant_Opt_In_Status_Emails__c, Participant_Opt_In_Status_SMS__c,
                                        Participant_Phone_Opt_In_Permit_Phone__c,IQVIA_Artificial_Voice_Consent__c,
                                        IQVIA_Pre_recorded_Voice_Consent__c, IQVIA_Assisted_Dialing_Consent__c from Contact where id=:con.id];

                        con.Participant_Opt_In_Status_Emails__c =enrollment.Participant_Opt_In_Status_Emails__c;
                             
                      con.Participant_Phone_Opt_In_Permit_Phone__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                      con.IQVIA_Artificial_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                      con.IQVIA_Assisted_Dialing_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c;
                      con.IQVIA_Pre_recorded_Voice_Consent__c = enrollment.Participant_Phone_Opt_In_Permit_Phone__c; 
                      con.Participant_Opt_In_Status_SMS__c = enrollment.Participant_Opt_In_Status_SMS__c;
                      con.IQVIA_Direct_Mail_Consent__c = enrollment.IQVIA_Direct_Mail_Consent__c;
                      
                      //update con; moved to future method
                      String objJSONStr = Json.serialize(con);
                      updateParticipantContact(objJSONStr);
                  }
                if (createDelegateuser) {
                    createParticipantUsers(
                        new Map<Id, Id>{ newContact.Id => null },
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
            if (participantDelegate == null) {
                //REF-3566
                List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
                List<Id> lstPatientDelegateId = new List<Id> ();
                for (Patient_Delegate__c pd : [
                    SELECT Id, Primary_Delegate__c
                    FROM Patient_Delegate__c
                    WHERE Participant__c = :participantId
                ]) {
                    if (pd.Primary_Delegate__c == true) {
                        pd.Primary_Delegate__c = false;
                        pdList.add(pd);
                        lstPatientDelegateId.add(pd.id);
                    }
                }
                //update pdList; moved to future method
                if(!pdList.isEmpty()) {
                String objJSONStr = Json.serialize(pdList);
                updatePatientDelegateNew(lstPatientDelegateId);
                }
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
        return null;
    }

    @Future
    public static void updatePatientDelegateNew(List<Id> lstPatientDelegtaeId){
             //Bypaass old methods from Patient Delegate Trigger       
             TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
                            );
             TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                            );  
            List<Patient_Delegate__c> lstPTUpdate = new List<Patient_Delegate__c> ();
             for(Patient_Delegate__c objPT : [ SELECT Id, Primary_Delegate__c FROM Patient_Delegate__c 
                                                Where ID IN:lstPatientDelegtaeId and Primary_Delegate__c = True])
            {
                objPT.Primary_Delegate__c = false;
                lstPTUpdate.add(objPT);
            }
        update lstPTUpdate;
    }

    @Future
    public static void updatePatientDelegateExisting(List<Id> lstPrimaryDelegate, List<Id> lstNonPrimaryDelegtae){
            //Bypaass old methods from Patient Delegate Trigger       
             TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
                            );
             TriggerHandlerExecutor.bypassHandler(
                                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                            );               
            
            List<Patient_Delegate__c> lstPTUpdate = new List<Patient_Delegate__c> ();

            for(ID lstprimaryId : lstPrimaryDelegate)
            {
                Patient_Delegate__c objPD = new Patient_Delegate__c(Id = lstprimaryId,Primary_Delegate__c = true);
                lstPTUpdate.add(objPD);
            }
            for(ID lstprimaryId : lstNonPrimaryDelegtae)
            {
                Patient_Delegate__c objPD = new Patient_Delegate__c(Id = lstprimaryId,Primary_Delegate__c = false);
                lstPTUpdate.add(objPD);

            }
            
        update lstPTUpdate;
    }
}