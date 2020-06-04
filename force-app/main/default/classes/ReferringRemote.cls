/**
 * Created by Leonid Bartenev
 */

public without sharing class ReferringRemote {


    public class InitData{
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
        public Map<String, List<LabelValueItem>> statesByCountryMap;
        public String delegateAccessLevel;
    }

    public class AccountWrapper{
        public Account clinic;
        public String name;
        public String addrStreet;
        public String addrCity;
        public String siteType;
        public Account ssAccount;
    }

    @AuraEnabled
    public static String getInitData(Id trialId, Id peId, Id hcpeId, String userMode, String delegateId){
        //try{
        InitData initData = new InitData();
        initData.trial = TrialService.getInstance().getTrialImpl(trialId);
        //localize pes
        if(initData.trial.Link_to_Pre_screening__c != null){
            initData.trial.Link_to_Pre_screening__c = CommunityFacadeRemote.getLocalizedURL(initData.trial.Link_to_Pre_screening__c);
        }
        if(hcpeId != null){
            initData.hcpEnrollment = HCPEnrollmentService.getInstance().getHCPEnrollmentByIdImpl(hcpeId,userMode,delegateId);//getHCPEnrollmentForHCPByTrial(trialId);
        }
        //new StudyActionsHCP(initData.hcpEnrollment).checkAction(StudyActions.ACT_REFER_TO_THIS_STUDY);

        //initData.actions = new StudyActionsHCP(initData.trial, initData.hcpEnrollment!=null?initData.hcpEnrollment.Study_Site__r:null,  initData.hcpEnrollment).actions;
        if(peId != null) {
            initData.participantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(peId, userMode, delegateId);
        }else if (initData.trial.Link_to_Medical_Record_Review__c == null){
            initData.participantEnrollment = ParticipantEnrollmentService.createParticipantEnrollment(initData.trial, initData.hcpEnrollment, null);
        }
        if(initData.trial.Link_to_Medical_Record_Review__c != null) {
            initData.pendingPEnrollments = ParticipantEnrollmentService.getPendingParticipantEnrollments(trialId, null, delegateId);
        }
        StudySiteService.SiteFilterData siteFilterData = StudySiteService.getInstance().getSiteFilterDataImpl(trialId, 'HCP');

        StudySiteService.SiteFilter siteFilter = new StudySiteService.SiteFilter(siteFilterData);
        List<StudySiteService.StudySiteDistanceWrapper> studiesTemp = StudySiteService.getInstance().getStudySitesWithDistanceForHCPByTrialIdImpl(siteFilter, null, true,delegateId);
        initData.markers = new List<ReferringRemote.AccountWrapper>();
        initData.studies = new List<StudySiteService.StudySiteDistanceWrapper>();
        initData.studiesPending = new List<StudySiteService.StudySiteDistanceWrapper>();
        for(StudySiteService.StudySiteDistanceWrapper siteWrapper : studiesTemp){
            if(HCPEnrollmentService.STATUS_GROUP_ACTIVATED.contains(siteWrapper.hcpe.Status__c) ||
                    HCPEnrollmentService.STATUS_GROUP_PENDING.contains(siteWrapper.hcpe.Status__c)){
                if(HCPEnrollmentService.STATUS_GROUP_ACTIVATED.contains(siteWrapper.hcpe.Status__c)){
                    initData.studies.add(siteWrapper);
                }
                else {
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
        initData.statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
        initData.delegateAccessLevel = CommunityService.getInstance().getUserAccessLevel(delegateId);
        return JSON.serialize(initData);
        /*}catch (Exception e){
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }*/
    }

    @AuraEnabled
    public static String checkNeedsGuardian(String participantJSON) {
        Boolean needsGuardian = false;
        Participant__c participant = (Participant__c) JSON.deserialize(participantJSON, Participant__c.class);
        if (!String.isEmpty(participant.Date_of_Birth__c)) {
            List<Age_of_Majority__mdt> ageOfMajorities = [SELECT DeveloperName,
                                                                 Country_Code__c,
                                                                 State_Code__c,
                                                                 Age__c
                                                          FROM Age_of_Majority__mdt];
            Map<String, Integer> ageByCountryCode = new Map<String, Integer>();
            for (Age_of_Majority__mdt ageOfMajority : ageOfMajorities) {
                if (ageOfMajority.Age__c != null) {
                    ageByCountryCode.put(ageOfMajority.DeveloperName, ageOfMajority.Age__c.intValue());
                }
            }

            Date birthDate = Date.valueOf(participant.Date_of_Birth__c);
            Integer participantAge =
                    Date.newInstance(2000, birthDate.month(), birthDate.day()) <=
                            Date.newInstance(2000, Date.today().month(), Date.today().day()) ?
                            Date.today().year() - birthDate.year() : Date.today().year() - birthDate.year() - 1;

            if (ageByCountryCode.get(participant.Mailing_Country_Code__c + '_' + participant.Mailing_State_Code__c) != null) {
                needsGuardian = participantAge < ageByCountryCode.get(participant.Mailing_Country_Code__c + '_' + participant.Mailing_State_Code__c);
            } else if (ageByCountryCode.get(participant.Mailing_Country_Code__c) != null) {
                needsGuardian = participantAge < ageByCountryCode.get(participant.Mailing_Country_Code__c);
            } else {
                needsGuardian = participantAge < 18;
            }
        }

        return '' + needsGuardian;
    }

    @AuraEnabled
    public static void saveParticipant(Id hcpeId, String pEnrollmentJSON, String participantJSON, String participantDelegateJSON, String delegateId, String ddInfo) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(participantJSON, Participant__c.class);
            participant.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
            Participant__c participantDelegate;
            ReferHealthcareProviderRemote.HealthcareProvider delegateDuplicateInfo;
            if(ddInfo != null) delegateDuplicateInfo = (ReferHealthcareProviderRemote.HealthcareProvider) JSON.deserialize(ddInfo, ReferHealthcareProviderRemote.HealthcareProvider.class);
            if (!String.isBlank(participantDelegateJSON)) {
                participantDelegate = (Participant__c) JSON.deserialize(participantDelegateJSON, Participant__c.class);
                if (participantDelegate != null) {
                    participantDelegate.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
                }
            }

            Participant_Enrollment__c enrollment = (Participant_Enrollment__c)
                    JSON.deserialize(pEnrollmentJSON, Participant_Enrollment__c.class);
            enrollment.Participant_Status__c = PEStatusState.PE_STATUS_RECEIVED;
            enrollment.Referral_Completed_by__c = CommunityService.getInstance().getCurrentContactId();
            if (enrollment.Pre_screening_Status__c == ParticipantEnrollmentService.PES_STATUS_PENDING) {
                enrollment.Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_PASS;
            }

            HCP_Enrollment__c hcpEnrollment =
                    HCPEnrollmentService.getInstance().getHCPEnrollmentByIdImpl(hcpeId, CommunityService.USER_MODE_HCP, delegateId);
            enrollment.HCP__c = hcpEnrollment.Id;
            enrollment.Study_Site__c = hcpEnrollment.Study_Site__c;
            enrollment.PI_Contact__c = hcpEnrollment.Study_Site__r.Principal_Investigator__c;
            enrollment.Referral_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
            enrollment.Show_Referring_Provider__c = true;
            String language = UserInfo.getLanguage();

            ParticipantService.getInstance().createParticipantAndUpdatePEImpl(participant, enrollment, language);

            if (participantDelegate != null && !String.isEmpty(participantDelegate.Last_Name__c) &&
                    !String.isEmpty(participantDelegate.Email__c)) {
                Contact newContact;
                if(delegateDuplicateInfo == null || delegateDuplicateInfo.contactId == null) {
                    newContact = new Contact();
                    newContact.FirstName = participantDelegate.First_Name__c;
                    newContact.LastName = participantDelegate.Last_Name__c;
                    newContact.Email = participantDelegate.Email__c;
                    newContact.AccountId = [
                            SELECT Id
                            FROM Account
                            WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
                            LIMIT 1
                            FOR UPDATE
                    ].Id;
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
                    if ('Home' == participantDelegate.Phone_Type__c) {
                        newContact.HomePhone = participantDelegate.Phone__c;
                    } if ('Mobile' == participantDelegate.Phone_Type__c) {
                        newContact.MobilePhone = participantDelegate.Phone__c;
                    } else {
                        newContact.Phone = participantDelegate.Phone__c;
                    }
                    insert newContact;
                }
                if(delegateDuplicateInfo == null || delegateDuplicateInfo.participantId == null) {
                    participantDelegate.Contact__c = newContact == null ? newContact.Id : delegateDuplicateInfo.contactId;
                    if (String.isBlank(participantDelegate.Phone__c) && !String.isBlank(participant.Phone__c)) {
                        participantDelegate.Phone__c = participant.Phone__c;
                        participantDelegate.Phone_Type__c = participant.Phone_Type__c;
                    }
                    insert participantDelegate;
                }

                Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
                ptDelegateRef.Participant__c = participant.Id;
                ptDelegateRef.Contact__c = newContact == null ? newContact.Id : delegateDuplicateInfo.contactId;
                insert ptDelegateRef;
                if(newContact != null) {
                    createParticipantUsers(new Map<Id, Id>{
                            newContact.Id => null
                    });
                }
            } else if (!String.isBlank(hcpEnrollment.Study_Site__c) && !String.isBlank(participant.Id)) {
                Participant__c newParticipant = [SELECT Id, Contact__c FROM Participant__c WHERE Id = :participant.Id];
                if (newParticipant != null && !String.isBlank(newParticipant.Contact__c)) {
                    Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
                    Study_Site__c ss = StudySiteService.getStudySiteForHCPById(hcpEnrollment.Study_Site__c);
                    String permissionSetName = CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet;
                    actionAssignContactPermissions.addPermission(newParticipant.Contact__c, permissionSetName);
                    if (!actionAssignContactPermissions.isEmpty()) {
                        ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                    }
                }
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @Future
    public static void createParticipantUsers(Map<Id, Id> usersToCreate) {
        if (usersToCreate != null && !usersToCreate.isEmpty()) ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(usersToCreate);
    }

    @AuraEnabled
    public static void setfailedReferral(String peJSON, String reason){
        try {
            Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            pe.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL;
            if(pe.Pre_screening_Status__c != ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED)
                pe.Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_FAIL;
            pe.Non_Referral_Reason__c = reason;
            if(reason == ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING){
                pe.Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_FAIL;
            }
            upsert pe;
        }catch (Exception e){
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
    public static ReferHealthcareProviderRemote.HealthcareProvider checkDuplicateDelegate(String email, String firstName, String lastName){
        return ReferHealthcareProviderRemote.checkDuplicate(null,email, firstName, lastName, null);
    }


}
