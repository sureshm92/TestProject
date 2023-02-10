/**
 * Created by Nikita Abrazhevitch on 05-Sep-19.
 */

public without sharing class ParticipantInformationRemote {
    @AuraEnabled
    public static AddPatientByPIRemote.FormData getInitData() {
        try {
            AddPatientByPIRemote.FormData formData = AddPatientByPIRemote.getInitData(null);
            return formData;
        } catch (Exception e) {
            return (AddPatientByPIRemote.FormData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getSteps(String peId, String userMode, String delegateId) {
        try {
            String steps = ReferralProfileRemote.getReferralProfileDetail(
                peId,
                userMode,
                delegateId
            );
            return steps;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getPrintInformation(String peId, String userMode, String delegateId) {
        List<String> PE_COMMON_FIELDS_PRINT = new List<String>();
        PE_COMMON_FIELDS_PRINT.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
        PE_COMMON_FIELDS_PRINT.add(
            '(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)'
        );
        PE_COMMON_FIELDS_PRINT.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
        PE_COMMON_FIELDS_PRINT.add('Study_Hub_Log__c');
        PE_COMMON_FIELDS_PRINT.add('Study_Hub_Log__r.Response_Status_Code__c');
        List<String> PE_COMMON_DOB_FIELDS = new List<String>{'Participant__r.Age__c','Participant__r.Birth_Day__c','Participant__r.Birth_Month__c'};
        PE_COMMON_FIELDS_PRINT.addAll(PE_COMMON_DOB_FIELDS);
        try {
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                peId,
                userMode,
                delegateId,
                PE_COMMON_FIELDS_PRINT
            );
            ParticipantItem pi = new ParticipantItem(pe);
            ParticipantWorkflowService.populatePatientItemsWithPathWrappers(
                new List<ParticipantItem>{ pi }
            );
            pi.pe.Participant_Status__c = TranslateHelper.getPickListLabel(
                Participant_Enrollment__c.Participant_Status__c,
                pi.pe.Participant_Status__c
            );
            pi.currentPageList = ViewPatientsRemote.convertToPEWrapperList(
                new List<Participant_Enrollment__c>{ pe },
                userMode,
                delegateId
            );
            Id participantid = pi.pe.Participant__c;
            Integer count= database.countQuery('Select count() from ContentDocumentLink where LinkedEntityId = :participantId');
            if(count > 0){
                pi.containsFile = true;
            }else{
                pi.containsFile = false;
            }
            pi.screenerResponse = getMrrScreenerResponse(peId);
            
         List<Participant_Enrollment_Status_History__c> pehistory = new List<Participant_Enrollment_Status_History__c>();
         pehistory = [
         SELECT
          Id,
          Date__c,Name,
          Status_Order__c,
          toLabel(Status__c),
          toLabel(Non_Enrollment_Reason__c),
          Notes__c,
          CreatedBy.Name,
          Additional_Notes__c,
          CreatedBy.IsPortalEnabled,
          CreatedBy.contact.userCommunityMode__c,
          Status_Label__c
        FROM Participant_Enrollment_Status_History__c
        WHERE
          ParticipantEnrollment__c = :peId
          AND Status_Order__c = 2
        ORDER BY Name DESC Limit 1
      ];
     // peBubbleChartInfo bubblechart = new peBubbleChartInfo();
      if(pehistory.size() > 0){
          system.debug('history');
           if(pehistory[0].Status_Label__c == 'Participant_No_Show'){
                pi.isPNS= true;
                pi.dateOccured=pehistory[0].Date__c.date().format();
                pi.occuredDate=pehistory[0].Date__c.date();
                pi.isContact=false;
                
                String title = '';
                  title =TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,pehistory[0].Status__c);
                  if (pehistory[0].Notes__c != null) {
                    title = title + ', ' + pehistory[0].Notes__c;
                  }
                   pi.historyTitle = title;
                   pi.detailDate = pehistory[0].Date__c.format('YYYY-MM-dd hh:mm:ss a');
                  pi.createdBy = ParticipantInformationRemote.getMasked(
                    pehistory[0].CreatedBy.IsPortalEnabled,
                    pehistory[0].CreatedBy.contact.userCommunityMode__c,
                    pehistory[0].CreatedBy.Name
                  );
                  String createdName =   pi.createdBy;
                  pi.detail =  ' ' +
                    TranslateHelper.getLabelValue('PE_Status_History_On_Date') +
                    ' ' +
                    pehistory[0].Date__c.format() +
                    ' ' +
                    TranslateHelper.getLabelValue('PG_IMI_L_by_user') +
                    ' ' +
                    createdName;
           }
           
          else if(pehistory[0].Status_Label__c == 'Successfully_Contacted' || pehistory[0].Status_Label__c == 'Successfully_Re_Engaged'){
              
                pi.dateOccured=pehistory[0].Date__c.date().format();
                pi.occuredDate=pehistory[0].Date__c.date();
                pi.reason=pehistory[0].Non_Enrollment_Reason__c;
                pi.isPNS= false;  
                  String title = '';
                  if(pehistory[0].Status__c == 'Successfully re-engaged'){
                      String sc = 'Successfully Re-Engaged';
                      title =TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,sc);
                       pi.isContact=false;
                  }else{
                     pi.isContact=false;
                  }
                  if (pehistory[0].Non_Enrollment_Reason__c != null) {
                    //title = title + ' - ' + pesh.Non_Enrollment_Reason__c;
                    title = title + ' - ' + TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c,pehistory[0].Non_Enrollment_Reason__c.trim());
                  }
                  if (pehistory[0].Notes__c != null) { 
                    title = title + ', ' + pehistory[0].Notes__c;
                  }
                   pi.historyTitle = title;
                     pi.detailDate = pehistory[0].Date__c.format('YYYY-MM-dd hh:mm:ss a');
                  pi.createdBy = ParticipantInformationRemote.getMasked(
                    pehistory[0].CreatedBy.IsPortalEnabled,
                    pehistory[0].CreatedBy.contact.userCommunityMode__c,
                    pehistory[0].CreatedBy.Name
                  );
                  String createdName =   pi.createdBy;
                  pi.detail =  ' ' +
                    TranslateHelper.getLabelValue('PE_Status_History_On_Date') +
                    ' ' +
                    pehistory[0].Date__c.format() +
                    ' ' +
                    TranslateHelper.getLabelValue('PG_IMI_L_by_user') +
                    ' ' +
                    createdName;
           }

           
      }
      
      else{
           pi.isPNS= false;
             pi.isContact= false; 
      }
       
            return JSON.serialize(pi);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    public static List<Participant_PrescreenerResponse__c> getMrrScreenerResponse(Id peId) {

        if (peId != null) {
           
            return [
                SELECT Id, Screener_Response__c, Completed_Date__c, PreScreener_Survey__c, MRR_EPR__c, MRR__c,
                    PreScreener_Survey__r.Survey_Name__c, Participant_enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Participant_PrescreenerResponse__c 
                WHERE Participant_enrollment__c = :peid 
                    AND (MRR_EPR__c = true OR MRR__c = true)
                ORDER BY Completed_Date__c DESC
            ];
        }
        return null;
    }

    @AuraEnabled
    public static Participant__c getDelegates(String participantId) {
        List<Participant__c> delegates = [
            SELECT Id, First_Name__c, Last_Name__c, Phone__c
            FROM Participant__c
            WHERE
                Contact__c IN (
                    SELECT Contact__c
                    FROM Patient_Delegate__c
                    WHERE
                        Participant__c = :participantId
                        AND Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                )
        ];
        if (!delegates.isEmpty()) {
            return delegates[0];
        } else {
            return null;
        }
    }

    /**
     * This method is created to accomodate the requirements of REF-1192
     * It calls getSteps(String, String, String) and
     * getPrintInformation(String, String, String) returns the combined
     * return value of these methods
     * @param peId Participant_Enrollment__c.Id
     * @param userMode in String
     * @param delegateId in String
     * @return ParticipantItemWithSteps in JSON String format.
     * @exception AuraHandledException to community UI
     * @see AuraHandledException
     */
    @AuraEnabled
    public static String getPrintInfoWithSteps(String peId, String userMode, String delegateId) {
        try {
            ParticipantItemWithSteps itemSteps = new ParticipantItemWithSteps();

            itemSteps.participantItem = getPrintInformation(peId, userMode, delegateId);
            itemSteps.initData = getSteps(peId, userMode, delegateId);

            return JSON.serialize(itemSteps);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static PIDelegateLevelInfo checkPILevelI(String studySiteId) {
        PIDelegateLevelInfo levelInfo = new PIDelegateLevelInfo();
        levelInfo.isDisabled = DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(
            DelegateService.getPIStudySitesAccessLevelMap().get(studySiteId)
        );

        return levelInfo;
    }

    @AuraEnabled
    public static void updatePatientInfo(String participantJSON, String peJSON) {
        AddPatientByPIRemote.updatePatientInfo(participantJSON, peJSON);
    }

    @AuraEnabled
    public static DelegateInfo updatePatientInfoWithDelegate(
        String participantJSON,
        String peJSON,
        String delegateJSON,
        String userInfoJSON,
        String contactInfoJSON
    ) {
        Participant_Enrollment__c pe = AddPatientByPIRemote.updatePatientInfo(
            participantJSON,
            peJSON
        );
        Participant__c part = [
            SELECT Id, Adult__c, Emancipation_in_progress__c
            FROM Participant__c
            WHERE Id = :pe.Participant__c
        ];
        if(!Test.isRunningTest()){
        pe.Participant__r.Adult__c = part.Adult__c;
        pe.Participant__r.Emancipation_in_progress__c = part.Emancipation_in_progress__c;
        }
        Participant__c participantObj = (Participant__c) JSON.deserialize(
            participantJSON,
            Participant__c.class
        );
        DelegateInfo objDelegateInfo = new DelegateInfo();
        objDelegateInfo.particpantEnrollment = pe;

        if (!String.isBlank(delegateJSON)) {
            Participant__c delegateParticipant = (Participant__c) JSON.deserialize(
                delegateJSON,
                Participant__c.class
            );
            String strFirstName = delegateParticipant.First_Name__c;
            String strLastName = delegateParticipant.Last_Name__c;
            String strDelegateEmail = delegateParticipant.Email__c;

            Boolean delFound =
                String.isBlank(delegateParticipant.First_Name__c) &&
                String.isBlank(delegateParticipant.Last_Name__c) &&
                String.isBlank(delegateParticipant.Email__c) &&
                String.isBlank(delegateParticipant.Phone__c);

            if (
                (String.isBlank(delegateParticipant.Id) && !delFound) ||
                (!String.isBlank(delegateParticipant.Id) && delFound) ||
                (!String.isBlank(delegateParticipant.Id) && !delFound)
            ) {
                ID perAccountId = [
                    SELECT ID, Study_Site__c, Study_Site__r.Site__c
                    FROM Participant_Enrollment__c
                    WHERE ID = :pe.Id
                ]
                .Study_Site__r.Site__c;
                Contact objcon;
                if (String.isBlank(delegateParticipant.Id)) {
                    List<Contact> lstContact = [
                        SELECT
                            FirstName,
                            LastName,
                            Email,
                            MailingCity,
                            MailingCountryCode,
                            MailingState,
                            MailingCountry,
                            MailingStateCode,
                            MailingPostalCode,
                            userCommunytyType__c,
                            userCommunityMode__c
                        FROM Contact
                        WHERE
                            (FirstName = :strFirstName
                            OR FirstName = :strFirstName.toLowerCase())
                            AND (LastName = :strLastName
                            OR LastName = :strLastName.toLowerCase())
                            AND (Email = :strDelegateEmail
                            OR Email = :strDelegateEmail.toLowerCase())
                            AND userCommunityMode__c != 'CC'
                    ];
                    if (lstContact.isEmpty()) {
                        objcon = new Contact(
                            FirstName = delegateParticipant.First_Name__c,
                            LastName = delegateParticipant.Last_Name__c,
                            Email = delegateParticipant.Email__c,
                            Phone = delegateParticipant.Phone__c,
                            AccountId = perAccountId,
                            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
                            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
                            Language__c = UserInfo.getLanguage(),
                            Second_Choice_Language__c = '',
                            Third_Choice_Language__c = '',
                            userCommunityIsDelegate__c = true,
                            MailingCountryCode = participantObj.Mailing_Country_Code__c,
                            MailingStateCode = participantObj.Mailing_State_Code__c,
                            MailingCountry = participantObj.Mailing_Country__c,
                            MailingState = participantObj.Mailing_State__c,
                            MailingPostalCode = participantObj.Mailing_Zip_Postal_Code__c
                        );
                    } else {
                        objcon = lstContact[0];
                        String strCommunityType = objcon.userCommunytyType__c;
                        strCommunityType = String.isBlank(strCommunityType)
                            ? CommunityService.USER_MODE_PARTICIPANT
                            : strCommunityType + ';' + CommunityService.USER_MODE_PARTICIPANT;
                        objcon.userCommunytyType__c = strCommunityType;
                    }
                    upsert objcon;
                    delegateParticipant.Contact__c = objcon.id;
                    delegateParticipant.Mailing_Country_Code__c = participantObj.Mailing_Country_Code__c;
                    delegateParticipant.Mailing_State_Code__c = participantObj.Mailing_State_Code__c;
                    delegateParticipant.Mailing_Zip_Postal_Code__c = participantObj.Mailing_Zip_Postal_Code__c;
                    if (String.isNotBlank(delegateParticipant.Birth_Year__c)) {
                        delegateParticipant.Attestation__c = true;
                        delegateParticipant.Attestation_TimeStamp__c = ParticipantService.getFormattedTime();
                        delegateParticipant.Attested_by__c = CommunityService.getInstance()
                            .getCurrentContactId();
                    }
                }
                if (delegateParticipant != null) {
                    try {
                        if (
                            String.isNotBlank(delegateParticipant.First_Name__c) &&
                            String.isNotBlank(delegateParticipant.Last_Name__c) &&
                            String.isNotBlank(delegateParticipant.Email__c)
                        )
                            upsert delegateParticipant;
                    } catch (Exception exp) {
                        system.debug('No delegate was provided');
                    }
                    Id participantConId = [
                        SELECT Contact__c, id
                        FROM Participant__c
                        WHERE id = :delegateParticipant.id
                    ]
                    .contact__c;
                    Map<Id, Patient_Delegate__c> mapParticipantIdToPatientDelegate = new Map<Id, Patient_Delegate__c>();
                    for (Patient_Delegate__c objPateintDel : [
                        SELECT ID, Participant__c, Contact__c, Primary_Delegate__c
                        FROM Patient_Delegate__c
                        WHERE Participant__c = :pe.Participant__c
                    ]) {
                        if (objPateintDel.Contact__c == participantConId) {
                            if (
                                String.isBlank(delegateParticipant.First_Name__c) &&
                                String.isBlank(delegateParticipant.Last_Name__c) &&
                                String.isBlank(delegateParticipant.Email__c)
                            ) {
                                objPateintDel.Primary_Delegate__c = false;
                            } else {
                                objPateintDel.Primary_Delegate__c = true;
                            }
                        } else {
                            objPateintDel.Primary_Delegate__c = false;
                        }
                        mapParticipantIdToPatientDelegate.put(
                            objPateintDel.Contact__c,
                            objPateintDel
                        );
                    }
                    if (!mapParticipantIdToPatientDelegate.containsKey(participantConId)) {
                        mapParticipantIdToPatientDelegate.put(
                            participantConId,
                            new Patient_Delegate__c(
                                Contact__c = participantConId,
                                Primary_Delegate__c = true,
                                Participant__c = pe.Participant__c,
                                Status__c = 'Disconnected'
                            )
                        );
                    }
                    system.debug(
                        '>>>mapParticipantIdToPatientDelegate>>' +
                        mapParticipantIdToPatientDelegate.values()
                    );
                    //  system.debug('<>>exception>>>'+0/0);
                    if (!mapParticipantIdToPatientDelegate.isEmpty())
                        upsert mapParticipantIdToPatientDelegate.values();

                    List<Participant__c> Primarydelegates = [
                        SELECT Id, First_Name__c, Last_Name__c, Phone__c, Email__c, Contact__c
                        FROM Participant__c
                        WHERE
                            Contact__c IN (
                                SELECT Contact__c
                                FROM Patient_Delegate__c
                                WHERE
                                    Participant__c = :pe.Participant__c
                                    // AND Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                                    AND Primary_Delegate__c = TRUE
                            )
                    ];
                    if (!Primarydelegates.isEmpty())
                        objDelegateInfo.DelegateParticipant = Primarydelegates[0];
                    else {
                        objDelegateInfo.DelegateParticipant = new Participant__c(
                            First_Name__c = '',
                            Last_Name__c = '',
                            Phone__c = '',
                            Email__c = ''
                        );
                    }

                    /*  if (delegateParticipant != null && !String.isBlank(delegateParticipant.Id)) {
                try {
                    update delegateParticipant;
                } catch (Exception exp) {
                    system.debug('No delegate was provided');
                }
            } */
                }
            }
        }

        //If user is available then updated user language else update contact language
        if (userInfoJSON != null) {
            updateUserLanguage(userInfoJSON);
        } else {
            updateParticipantContactLanguage(contactInfoJSON);
        }
        return objDelegateInfo;
    }

    @AuraEnabled
    public static List<User> createUserForPatientProtal(String peJSON, Boolean sendEmails) {
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );
        if (sendEmails && !pe.Participant_Contact__r.Is_Patient_User_Created__c) {
            update new Contact(
                Id = pe.Participant_Contact__c,
                Consent_To_Inform_About_Study__c = true,
                Is_Patient_User_Created__c = true
            );
        }
        try {
            List<User> returnUsers = new List<User>();
            if(!pe.Participant_Contact__r.Is_Patient_User_Created__c){
                if (pe.HCP_Contact__c == null) {
                    returnUsers = ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                        .createParticipantUsers(
                            new Map<Id, Id>{ pe.Participant_Contact__c => pe.PI_Contact__c }
                        );
                } else {
                    returnUsers = ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                        .createParticipantUsers(
                            new Map<Id, Id>{ pe.Participant_Contact__c => pe.HCP_Contact__c }
                        );
                }
            }
                pe.Invited_To_PP_Date__c = DateTime.now();
                update pe;

            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            String permissionSetName = CommunityTemplateService.getTemplate(
                    pe.Clinical_Trial_Profile__r.CommunityTemplate__c
                )
                .permissionSet;
            actionAssignContactPermissions.addPermission(
                pe.Participant_Contact__c,
                permissionSetName
            );
            if (!actionAssignContactPermissions.isEmpty()) {
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }
            return returnUsers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static ReferHealthcareProviderRemote.HealthcareProvider checkDelegateDuplicate(
        String email,
        String firstName,
        String lastName,
        String participantId,
        String perId
    ) {
         return ReferHealthcareProviderRemote.checkDuplicateNew(
            perId,
            email,
            firstName,
            lastName,
            participantId
        );
    }

    @AuraEnabled
    public static DelegateConnectedInfo connectDelegateToPatient(
        String participantS,
        String delegateS,
        String studySiteId,
        Boolean isConnected,
        String duplicateDelegateInfo,
        Boolean NoInvite,
        Id perId
    ) {
        DelegateConnectedInfo isConnectedRes = new DelegateConnectedInfo();
        isConnectedRes.isConnected = isConnected;

        try {
            ReferHealthcareProviderRemote.HealthcareProvider ddi = (ReferHealthcareProviderRemote.HealthcareProvider) JSON.deserialize(
                duplicateDelegateInfo,
                ReferHealthcareProviderRemote.HealthcareProvider.class
            );
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantS,
                Participant__c.class
            );
            Participant__c delegateParticipant = (Participant__c) JSON.deserialize(
                delegateS,
                Participant__c.class
            );
            isConnectedRes.contactId = delegateParticipant.Contact__c;
            Map<Id, Id> toCreateUser = new Map<Id, Id>();
            List<Patient_Delegate__c> patientDelegatesToInsert = new List<Patient_Delegate__c>();
            Contact delegateContact;
            Boolean userNotExists = false;

            if (String.isBlank(delegateParticipant.Contact__c) && String.isBlank(ddi.contactId)) {
                /*ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(new List<Participant__c>{
                        delegateParticipant
                });*/

                delegateContact = new Contact(
                    AccountId = [SELECT Site__c, Id FROM Study_Site__c WHERE Id = :studySiteId]
                    .Site__c,
                    MailingState = delegateParticipant.Mailing_State__c,
                    MailingCountry = delegateParticipant.Mailing_Country__c,
                    MailingStateCode = delegateParticipant.Mailing_State_Code__c,
                    MailingCountryCode = delegateParticipant.Mailing_Country_Code__c,
                    MailingPostalCode = delegateParticipant.Mailing_Zip_Postal_Code__c,
                    FirstName = delegateParticipant.First_Name__c,
                    LastName = delegateParticipant.Last_Name__c,
                    Email = delegateParticipant.Email__c,
                    Language__c = UserInfo.getLanguage(),
                    Second_Choice_Language__c = '',
                    Third_Choice_Language__c = '',
                    userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
                    userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
                    userCommunityIsDelegate__c = true
                    
                );
                insert delegateContact;
            } else {
                delegateContact = new Contact(Id = ddi.contactId,
                    IQVIA_Contact_info_storage_consent__c =true,
                    Participant_Opt_In_Status_Emails__c =true,
                    IQVIA_PI_Storage_Consent_Time__c =Datetime.now(),
                    IQVIA_Email_Consent_Time__c =Datetime.now()
                    );
                    //update delegateContact;
            }

            List<Patient_Delegate__c> patientDelegatesEver = [
                SELECT Id, Participant__c, Contact__c, Status__c
                FROM Patient_Delegate__c
                WHERE Participant__c = :participant.Id AND Contact__c = :delegateContact.Id
            ];
            userNotExists = patientDelegatesEver.isEmpty();

            if (patientDelegatesEver.isEmpty() && !isConnected) {
                patientDelegatesToInsert.add(
                    new Patient_Delegate__c(
                        Participant__c = participant.Id,
                        Contact__c = delegateContact.Id,
                        Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                    )
                );
                toCreateUser.put(delegateContact.Id, null);
                isConnectedRes.isConnected = true;
            } else {
                for (Patient_Delegate__c ptDelegate : patientDelegatesEver) {
                    if (!String.isBlank(ptDelegate.Id)) {
                        ptDelegate.Status__c = isConnected
                            ? PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS
                            : PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS;
                        patientDelegatesToInsert.add(ptDelegate);
                        isConnectedRes.isConnected = !isConnected;
                    }
                }
            }

            if (String.isBlank(delegateParticipant.Contact__c)) {
                delegateParticipant.Contact__c = delegateContact.Id;
                isConnectedRes.contactId = delegateContact.Id;
            }
            if (String.isBlank(delegateParticipant.Phone__c)) {
                delegateParticipant.Phone__c = participant.Phone__c;
                delegateParticipant.Phone_Type__c = participant.Phone_Type__c;
            }
            if (!String.isBlank(ddi.participantId)) {
                delegateParticipant.Id = ddi.participantId;
            }else{
                if (String.isNotBlank(delegateParticipant.Birth_Year__c)) {
                    delegateParticipant.Attestation__c = true;
                    delegateParticipant.Attestation_TimeStamp__c = ParticipantService.getFormattedTime();
                    delegateParticipant.Attested_by__c = CommunityService.getInstance()
                        .getCurrentContactId();
                }
            }
            upsert delegateParticipant;
            isConnectedRes.participantId = delegateParticipant.Id;

            if (!patientDelegatesToInsert.isEmpty()) {
                upsert patientDelegatesToInsert;
                isConnectedRes.delegateId = patientDelegatesToInsert!=null && patientDelegatesToInsert.size()>0?patientDelegatesToInsert[0].Id:null;
                if(patientDelegatesToInsert!=null && patientDelegatesToInsert.size()>0){
                    
                    List<Patient_Delegate_Enrollment__c> pder = new List<Patient_Delegate_Enrollment__c>();
                    pder = [Select Id,Participant_Enrollment__c,Patient_Delegate__c,Status__c,Study_Email_Consent__c,Study_Email_Consent_Time__c from Patient_Delegate_Enrollment__c where Patient_Delegate__c=:patientDelegatesToInsert[0].Id and Participant_Enrollment__c=: perId limit 1];
                    if(!pder.isEmpty()){
                    if(pder[0].Status__c == 'Withdrawn'){
                         pder[0].Study_Email_Consent__c = true;
                         pder[0].Status__c ='Active';
                         pder[0].Study_Email_Consent_Time__c = Datetime.now();
                    }else{
                         pder[0].Status__c ='Active';
                    }
                    update pder;
                    }else{
                    Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
                    pde.Participant_Enrollment__c = perId;
                    pde.Patient_Delegate__c = patientDelegatesToInsert[0].Id;
                    pde.Status__c =  'Active';
                    pde.Study_Email_Consent__c = true;
                    pde.Study_info_storage_consent__c = true;
                    Insert pde;
                    }              
                }
            }
            if (String.isBlank(ddi.contactId) && NoInvite == false) {
                createCommunityUser(toCreateUser, userNotExists);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

        return isConnectedRes;
    }

    @AuraEnabled
    public static String disconnectDelegateToPatient(
        String delegateId, String perId
    ) {
        try {
            Patient_Delegate__c pd = new Patient_Delegate__c();
            pd.Id = delegateId;
            pd.Status__c = 'Disconnected';
            update pd;
            List<Patient_Delegate_Enrollment__c> pde = new List<Patient_Delegate_Enrollment__c>();
            pde = [Select Id,Participant_Enrollment__c,Patient_Delegate__c,Status__c  from Patient_Delegate_Enrollment__c where Patient_Delegate__c=:delegateId and Participant_Enrollment__c=:perId];
            pde[0].Status__c ='Disconnected';
            update pde;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

        return delegateId;
    }

    @Future
    private static void createCommunityUser(Map<Id, Id> toCreateUser, Boolean userNotExists) {
        if (!toCreateUser.isEmpty() && userNotExists)
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createParticipantUsers(toCreateUser);
    }

    @AuraEnabled
    public static void updateParticipantAndDelegates(
        String peId,
        String participantS,
        String participantContactS,
        String delegatesS,
        List<String> doNotContinueIds,
        Boolean needsInvite,
        String studySiteId,
        String delegateConsentItems
    ) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantS,
                Participant__c.class
            );
            Contact participantContact = (Contact) JSON.deserialize(
                participantContactS,
                Contact.class
            );
            List<Participant__c> delegates = (List<Participant__c>) JSON.deserialize(
                delegatesS,
                List<Participant__c>.class
            );
             List<ConsentDetailsWrapper> consentDetails = (List<ConsentDetailsWrapper>) JSON.deserialize(
                delegateConsentItems,
                List<ConsentDetailsWrapper>.class
            );
            List<id> delContact= new List<id> ();
            Study_Site__c studySite = StudySiteService.getStudySiteForPIById(studySiteId);
            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            String permissionSetName = CommunityTemplateService.getTemplate(
                    studySite.Clinical_Trial_Profile__r.CommunityTemplate__c
                )
                .permissionSet;


            update participant;
            if (participantContact.Id != null) {
                participantContact.Email = participant.Email__c;
                if (participant.Phone_Type__c == 'Home') {
                    participantContact.HomePhone = participant.Phone__c;
                }
                if (participant.Phone_Type__c == 'Mobile') {
                    participantContact.MobilePhone = participant.Phone__c;
                } else {
                    participantContact.Phone = participant.Phone__c;
                }
                update participantContact;
            }

            Map<Id, Id> toCreateUser = new Map<Id, Id>();
                system.debug('needsInvite: ' + needsInvite);
            if (needsInvite) {
                toCreateUser.put(participant.Contact__c, null);
                actionAssignContactPermissions.addPermission(
                    participant.Contact__c,
                    permissionSetName
                );
            }

            Set<String> idsToCheck = new Set<String>(doNotContinueIds);
            List<Patient_Delegate__c> patientDelegates = [
                SELECT Id, Participant__c, Contact__c, Status__c, Contact__r.IQVIA_Contact_info_storage_consent__c,
                contact__r.IQVIA_PI_Storage_Consent_Time__c
                FROM Patient_Delegate__c
                WHERE
                    Participant__c = :participant.Id
                    AND Status__c != :PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS
            ];
            Map<Id, Patient_Delegate__c> patientDelegateByDelegate = new Map<Id, Patient_Delegate__c>();
            List<Patient_Delegate__c> delegatesToUpdate = new List<Patient_Delegate__c>();
            if (!patientDelegates.isEmpty()) {
                system.debug('patientDelegates: ' + patientDelegates);
                for (Patient_Delegate__c patientDelegate : patientDelegates) {
                    if (
                        idsToCheck.contains(patientDelegate.Contact__c) &&
                        PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS !=
                        patientDelegate.Status__c
                    ) {
                        patientDelegate.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS;
                        delegatesToUpdate.add(patientDelegate);
                    }
                    patientDelegateByDelegate.put(patientDelegate.Contact__c, patientDelegate);
                }
            }
            Map<id,Boolean> mapContactIdToSMS=new Map<id,Boolean>();
            for (Participant__c delegateParticipant : delegates) {
                if(!idsToCheck.contains(delegateParticipant.Contact__c)){
                    delContact.add(delegateParticipant.Contact__c);
                    mapContactIdToSMS.put(delegateParticipant.Contact__c,delegateParticipant.Delegate_Consent_SMS__c);
                }
                if (
                    !String.isBlank(delegateParticipant.Contact__c) &&
                    !idsToCheck.contains(delegateParticipant.Contact__c) &&
                    patientDelegateByDelegate.containsKey(delegateParticipant.Contact__c)
                ) {
                    delegatesToUpdate.add(
                        new Patient_Delegate__c(
                            Id = patientDelegateByDelegate.get(delegateParticipant.Contact__c).Id,
                            Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                        )
                    );
                }
            }
           if(!consentDetails.isEmpty()){
               List<Patient_Delegate_Enrollment__c> pder = new List<Patient_Delegate_Enrollment__c>();
               List<Patient_Delegate_Enrollment__c> updPDER = new List<Patient_Delegate_Enrollment__c>();
               pder =[Select Id,Study_Email_Consent__c,Study_info_storage_consent__c,Study_Phone_Consent__c,Study_SMS_Consent__c,Participant_Enrollment__c,
                        Patient_Delegate__c,Patient_Delegate__r.Participant__c,Patient_Delegate__r.Contact__c,Patient_Delegate__r.Participant_Delegate__c,Status__c from Patient_Delegate_Enrollment__c where Patient_Delegate__r.Participant__c=:participant.Id and Status__c!='Withdrawn' ];
            Set<Id> duplicates = new Set<Id>();
            Set<Id> nonDuplicates = new Set<Id>();
            for(Patient_Delegate_Enrollment__c pd:pder){
                if(nonDuplicates.contains(pd.Patient_Delegate__c)){
                    duplicates.add(pd.Patient_Delegate__c);
                }else{
                    nonDuplicates.add(pd.Patient_Delegate__c);
                }
             }
               for(Patient_Delegate_Enrollment__c pde:pder){
                    if(!duplicates.contains(pde.Patient_Delegate__c)){
                       Patient_Delegate_Enrollment__c pdes = new Patient_Delegate_Enrollment__c();
                       pdes.Id = pde.Id;
                       for(ConsentDetailsWrapper cdw:consentDetails){
                           if(cdw.delgParticipantId == pde.Patient_Delegate__r.Participant_Delegate__c){
                                   pdes.Study_Email_Consent__c = cdw.Study_Email_Consent;
                                   pdes.Study_info_storage_consent__c= cdw.Study_info_storage_consent;
                                   pdes.Study_Phone_Consent__c= cdw.Study_Phone_Consent;
                                   pdes.Study_SMS_Consent__c= cdw.Study_SMS_Consent;
                                   if (
                                    idsToCheck.contains(pde.Patient_Delegate__r.Contact__c) &&
                                    PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS !=
                                    pde.Status__c
                                    ){
                                    pdes.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS;
                                    }
                                    
                                    if (
                                    !idsToCheck.contains(pde.Patient_Delegate__r.Contact__c) &&
                                    PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS ==
                                    pde.Status__c
                                    ){
                                      pdes.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS;
                                    }
                           }
                       }
                        updPDER.add(pdes);
                    }else{
                        
                           Patient_Delegate_Enrollment__c pdes = new Patient_Delegate_Enrollment__c();
                           pdes.Id = pde.Id;
                           for(ConsentDetailsWrapper cdw:consentDetails){
                               if(cdw.delgParticipantId == pde.Patient_Delegate__r.Participant_Delegate__c){
                                       if(pde.Participant_Enrollment__c == peId){
                                           pdes.Study_Email_Consent__c = cdw.Study_Email_Consent;
                                           pdes.Study_info_storage_consent__c= cdw.Study_info_storage_consent;
                                           pdes.Study_Phone_Consent__c= cdw.Study_Phone_Consent;
                                           pdes.Study_SMS_Consent__c= cdw.Study_SMS_Consent;
                                       }
                                       if (
                                        idsToCheck.contains(pde.Patient_Delegate__r.Contact__c) &&
                                        PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS !=
                                        pde.Status__c
                                        ){
                                        pdes.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS;
                                        }
                                        
                                        if (
                                        !idsToCheck.contains(pde.Patient_Delegate__r.Contact__c) &&
                                        PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS ==
                                        pde.Status__c
                                        ){
                                          pdes.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS;
                                        }
                               }
                           }
                            updPDER.add(pdes);
                           
                    }
               }
                  update updPDER;      
           }
            if (!delegates.isEmpty() && needsInvite == true) {
                update delegates;
            }
            if (!delegatesToUpdate.isEmpty() && needsInvite == true) {
                update delegatesToUpdate;
            }
            if (!delegates.isEmpty() && needsInvite == false) {
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.CreateReactivatedNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                );
                update delegates;
            }
            if (!delegatesToUpdate.isEmpty() && needsInvite == false) {
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.CreateReactivatedNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                );
                update delegatesToUpdate;
            }
            if(needsInvite == true){
                Participant_Enrollment__c pe = new Participant_Enrollment__c(Id= peId, Invited_To_PP_Date__c =DateTime.now());//,Invited_To_Patient_Portal__c = true);
                update pe;
            }else{
                Participant_Enrollment__c pe = new Participant_Enrollment__c(Id= peId);
                update pe;
            }
            system.debug('toCreateUser: ' + toCreateUser);
            if (!toCreateUser.isEmpty() && needsInvite == true) {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createParticipantUsers(toCreateUser);
            }
            if (!toCreateUser.isEmpty() && needsInvite == false) {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createParticipantUsers(new Map<Id, Id>{ participantContact.Id => null });
            }
            if (!actionAssignContactPermissions.isEmpty() && needsInvite == true) {
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }
            /*if (!actionAssignContactPermissions.isEmpty() && needsInvite == false) {
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.CreateReactivatedNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                );
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }*/
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }
    public static void updateDelContact(List<id> delContact, Boolean countryUS, Map<id,Boolean> mapContactIdToSMS){
        try{
        List<Patient_Delegate__c> updateDelCon=new List<Patient_Delegate__c> ();
        list<contact> contoUpdate=new list<contact>();
        Boolean getSMSValue;
        for(Integer i=0;i<delContact.size();i++){
            contact con = new Contact();
                  con.id =delContact[i];
                  getSMSValue=con.Participant_Opt_In_Status_SMS__c;
                  if(countryUS){
                    con.IQVIA_Contact_info_storage_consent__c =true;
                    con.Participant_Phone_Opt_In_Permit_Phone__c =true;
                    con.IQVIA_Assisted_Dialing_Consent__c =true;
                    con.Participant_Opt_In_Status_Emails__c =true;
                    con.IQVIA_Artificial_Voice_Consent__c =true;
                    con.IQVIA_Pre_recorded_Voice_Consent__c =true;
                    con.Participant_Opt_In_Status_SMS__c=true;
                    con.IQVIA_Pre_recorded_Calls_Consent_Time__c = Datetime.now();
                    con.IQVIA_PI_Storage_Consent_Time__c = Datetime.now();
                    con.IQVIA_Phone_Consent_Time__c = Datetime.now();
                    con.IQVIA_Email_Consent_Time__c = Datetime.now();
                    con.IQVIA_Assisted_Dialing_Consent_Time__c = Datetime.now();
                    con.IQVIA_Artificial_Voice_Consent_Time__c = Datetime.now();
                    con.IQVIA_SMS_Consent_Time__c = Datetime.now();
                  }
                  else{
                      
                    con.IQVIA_Contact_info_storage_consent__c =true;
                    con.Participant_Phone_Opt_In_Permit_Phone__c =true;
                    con.IQVIA_Assisted_Dialing_Consent__c =true;
                    con.Participant_Opt_In_Status_Emails__c =true;
                    con.IQVIA_Artificial_Voice_Consent__c =true;
                    con.IQVIA_Pre_recorded_Voice_Consent__c =true;
                    con.Participant_Opt_In_Status_SMS__c=mapContactIdToSMS.get(con.id)!=null? mapContactIdToSMS.get(con.id): false;
                    con.IQVIA_Pre_recorded_Calls_Consent_Time__c = Datetime.now();
                    con.IQVIA_PI_Storage_Consent_Time__c = Datetime.now();
                    con.IQVIA_Phone_Consent_Time__c = Datetime.now();
                    con.IQVIA_Email_Consent_Time__c = Datetime.now();
                    con.IQVIA_Assisted_Dialing_Consent_Time__c = Datetime.now();
                    con.IQVIA_Artificial_Voice_Consent_Time__c = Datetime.now();
                    if(mapContactIdToSMS.get(con.id)!=null &&  mapContactIdToSMS.get(con.id)==true){
                        con.IQVIA_SMS_Consent_Time__c=Datetime.now();
                    }
                    else if(getSMSValue!=mapContactIdToSMS.get(con.id)){
                        con.IQVIA_SMS_Consent_Time__c = Datetime.now();
                        }
                  }
                  
                contoUpdate.add(con);
        }
        
        update contoUpdate;
    }
    catch (Exception exp) {
        throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
    }
        
 
    }
    @AuraEnabled
    public static List<Participant__c> getParticipantDelegates(String participantId) {
        try {
            List<Participant__c> participants = [
                SELECT
                    Id,
                    Contact__c,
                    First_Name__c,
                    Middle_Name__c,
                    Last_Name__c,
                    Mailing_Zip_Postal_Code__c,
                    Mailing_State_Code__c,
                    Mailing_State__c,
                    Mailing_Country_Code__c,
                    Mailing_Country__c,
                    Email__c,
                    Phone__c,
                    Phone_Type__c,
                    Delegate_Consent_SMS__c
                FROM Participant__c
                WHERE
                    Contact__c IN (
                        SELECT Contact__c
                        FROM Patient_Delegate__c
                        WHERE
                        Participant__c = :participantId
                        AND Status__c != 'Withdrawn' //as per REF-2998(fix for REF-4222),delegate will come with status Disconnected, 
                       /* AND (Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                        OR Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS) */
                    )
            ];
            return participants;
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }
    public class ConsentDetailsWrapper {
    @AuraEnabled
    public Boolean Study_Email_Consent { get; set; }
    @AuraEnabled
    public Boolean Study_info_storage_consent { get; set; }
    @AuraEnabled
    public Boolean Study_Phone_Consent { get; set; }
    @AuraEnabled
    public Boolean Study_SMS_Consent { get; set; }
    @AuraEnabled
    public String delgParticipantId { get; set; }
    @AuraEnabled
    public String partEnrollId { get; set; }
  }
  public class ParticipantConsentWrapper {
    @AuraEnabled
    public List<Participant__c> ParticipantList { get; set; }
    @AuraEnabled
    Public List<ConsentDetailsWrapper> ParticipantConsent { get; set; }
  }
     @AuraEnabled
    public static ParticipantConsentWrapper getParticipantPDER(String participantId,String perId) {
        try {
            List<Patient_Delegate_Enrollment__c> pder = new List<Patient_Delegate_Enrollment__c>();
            pder  = [Select Id,Participant_Enrollment__c,Patient_Delegate__c,Patient_Delegate__r.Participant__c,Patient_Delegate__r.Participant_Delegate__c,Study_Email_Consent__c,
            Study_info_storage_consent__c,Study_Phone_Consent__c,Study_SMS_Consent__c,Status__c from Patient_Delegate_Enrollment__c where Patient_Delegate__r.Participant__c=:participantId and Status__c!='Withdrawn'];
            List<Id> partId = new List<Id>();
            List<ConsentDetailsWrapper> cdw = new List<ConsentDetailsWrapper>();
            ParticipantConsentWrapper pcw = new ParticipantConsentWrapper();
            Set<Id> duplicates = new Set<Id>();
            Set<Id> nonDuplicates = new Set<Id>();
            for(Patient_Delegate_Enrollment__c pd:pder){
                if(nonDuplicates.contains(pd.Patient_Delegate__c)){
                    duplicates.add(pd.Patient_Delegate__c);
                }else{
                    nonDuplicates.add(pd.Patient_Delegate__c);
                }
             }
            for(Patient_Delegate_Enrollment__c pd:pder){
                if(!duplicates.contains(pd.Patient_Delegate__c)){
                partId.add(pd.Patient_Delegate__r.Participant_Delegate__c);
                
                ConsentDetailsWrapper cd= new ConsentDetailsWrapper();
                cd.Study_Email_Consent = pd.Study_Email_Consent__c;
                cd.Study_info_storage_consent = pd.Study_info_storage_consent__c;
                cd.Study_Phone_Consent  = pd.Study_Phone_Consent__c;
                cd.Study_SMS_Consent = pd.Study_SMS_Consent__c;
                cd.delgParticipantId  = pd.Patient_Delegate__r.Participant_Delegate__c;
                cd.partEnrollId = pd.Participant_Enrollment__c;
                cdw.add(cd);
                }else{
                if(pd.Participant_Enrollment__c == perId){
                    partId.add(pd.Patient_Delegate__r.Participant_Delegate__c);
                    
                    ConsentDetailsWrapper cd= new ConsentDetailsWrapper();
                    cd.Study_Email_Consent = pd.Study_Email_Consent__c;
                    cd.Study_info_storage_consent = pd.Study_info_storage_consent__c;
                    cd.Study_Phone_Consent  = pd.Study_Phone_Consent__c;
                    cd.Study_SMS_Consent = pd.Study_SMS_Consent__c;
                    cd.delgParticipantId  = pd.Patient_Delegate__r.Participant_Delegate__c;
                    cd.partEnrollId = pd.Participant_Enrollment__c;
                    cdw.add(cd);
                 }
                }
               
            }
            List<Participant__c> participants = [
                SELECT
                    Id,
                    Contact__c,
                    First_Name__c,
                    Middle_Name__c,
                    Last_Name__c,
                    Mailing_Zip_Postal_Code__c,
                    Mailing_State_Code__c,
                    Mailing_State__c,
                    Mailing_Country_Code__c,
                    Mailing_Country__c,
                    Email__c,
                    Phone__c,
                    Phone_Type__c,
                    Delegate_Consent_SMS__c
                FROM Participant__c
                WHERE
                    Id IN:partId
            ];
            pcw.ParticipantList = participants;
            pcw.ParticipantConsent = cdw;
            return pcw;
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String updatePatientStatus(
        String pathWrapperJSON,
        String peId,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome,
        Boolean sitepreference,
        Boolean PartcipantNoShow
    ) {
        Participant_Enrollment__c pe = new Participant_Enrollment__c(Id = peId);
        return updatePatientStatus(pathWrapperJSON, pe, historyToUpdate, notesToBeAdded, outcome,sitepreference,PartcipantNoShow);
    }

    @AuraEnabled
    public static String updatePatientStatusCC(
        String pathWrapperJSON,
        String peId,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome,
        Boolean sitepreference,
        Boolean PartcipantNoShow
    ) {
        Participant_Enrollment__c pe = new Participant_Enrollment__c(Id = peId);
        return updatePatientStatusCC(pathWrapperJSON, pe, historyToUpdate, notesToBeAdded, outcome,sitepreference,PartcipantNoShow);
    }

    public static String updatePatientStatus(
        String pathWrapperJSON,
        Participant_Enrollment__c pe,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome,
        Boolean sitepreference,
        Boolean PartcipantNoShow
    ) {
        try {
            ParticipantWorkflowService.ParticipantWorkflowWrapper pathWrapper = (ParticipantWorkflowService.ParticipantWorkflowWrapper) JSON.deserialize(
                pathWrapperJSON,
                ParticipantWorkflowService.ParticipantWorkflowWrapper.class
            );
            //Participant_Enrollment__c oldParticipantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityModeService.USER_MODE_PI, null);
            Participant_Enrollment__c oldParticipantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_PI,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            Clinical_Trial_Profile__c ctp = StudyTrialService.getFullTrial(
                oldParticipantEnrollment.Clinical_Trial_Profile__c
            );
            ParticipantWorkflowService.populatePEFromWorkflowWrapper(
                pathWrapper,
                pe,
                ctp,
                oldParticipantEnrollment
            );
            pe.Site_Communication_Preference__c=sitepreference;
            pe.ParticipantNoShow__c = PartcipantNoShow;
            update pe;
            if (
                (oldParticipantEnrollment.Initial_visit_scheduled_date__c == null ||
                oldParticipantEnrollment.Initial_visit_scheduled_time__c == null) &&
                (pe.Initial_visit_scheduled_date__c != null &&
                pe.Initial_visit_scheduled_time__c != null)
            ) {
                IncentiveProgramService.completeIncentiveTaskCurrentContact(
                    IncentiveTaskCatalog.INCENTIVE_TASK_ENTERED_INITIAL_VISIT_SCHEDULED_TIME,
                    oldParticipantEnrollment.Study_Site__c,
                    oldParticipantEnrollment.Name
                );
            }
            //pe = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityService.USER_MODE_PI);
            pe = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_PI,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            Participant_Enrollment_Status_History__c pesh = ParticipantWorkflowService.createPESHFromPathWrapper(
                pathWrapper,
                pe,
                ctp,
                oldParticipantEnrollment,
                PartcipantNoShow
            );
            if (pesh != null && historyToUpdate) {
                if (
                    oldParticipantEnrollment.Participant_Status__c ==
                    PEStatusState.PE_STATUS_RECEIVED &&
                    (pesh.Status__c == PEStatusState.PE_STATUS_CONTACT_ATTEMPTED ||
                    pesh.Status__c == PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED ||
                    pesh.Status__c == PEStatusState.PE_STATUS_CONTACTED_NOT_SUITABLE ||
                    pesh.Status__c == PEStatusState.PE_STATUS_UNABLE_TO_REACH) &&
                    oldParticipantEnrollment.Participant_Status_Last_Changed_Date__c.date()
                        .daysBetween(Date.today()) <= 1
                ) {
                    IncentiveProgramService.completeIncentiveTaskCurrentContact(
                        IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY,
                        oldParticipantEnrollment.Study_Site__c,
                        oldParticipantEnrollment.Name
                    );
                }
                insert pesh;
            } else if (notesToBeAdded && pe != null && pe.Id != null) {
                Boolean isCCUser = false;
                updateNotes(pathWrapper, pe, outcome, isCCUser);
            } else if (pe != null && pe.Id != null) {
                updateWithDividerWithNotes(pathWrapper, pe, outcome);
            }
            //pe = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityService.USER_MODE_PI);
            pe = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_PI,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            if (pe == null)
                throw new CommunityServiceException('Participant enrollment not found');
            return JSON.serialize(
                new UpdateResponse(
                    pe,
                    ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe)
                )
            );
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    @testVisible
    private static void updateNotes(
        ParticipantWorkflowService.ParticipantWorkflowWrapper pathWrapper,
        Participant_Enrollment__c pe,
        String outcome,
        Boolean isCCUser
    ) {
        Participant_Enrollment_Status_History__c peshnotes;
        List<Participant_Enrollment_Status_History__c> peshnotesList = new List<Participant_Enrollment_Status_History__c>();
        Boolean isBetweenStep = false;
        if (outcome != null) {
            peshnotesList = [
                SELECT Id, Additional_Notes__c, Notes__c, Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c = :pe.Id AND Status__c = :outcome
                ORDER BY Date__c DESC
                LIMIT 1
            ];
        } else {
            peshnotesList = [
                SELECT Id, Additional_Notes__c, Notes__c, Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c = :pe.Id
                ORDER BY Date__c DESC
                LIMIT 1
            ];
        }
        if (peshnotesList.size() > 0) {
            peshnotes = peshnotesList[0];
        }
        if (peshnotes != null) {
            Map<String, Participant_Workflow_Step__mdt> stepsWithName = new Map<String, Participant_Workflow_Step__mdt>();
            for (Participant_Workflow_Step__mdt s : [
                SELECT
                    Id,
                    MasterLabel,
                    DeveloperName,
                    Additional_Notes_For_Statuses__c,
                    In_Progress_Condition__c,
                    Success_Condition__c
                FROM Participant_Workflow_Step__mdt
            ]) {
                stepsWithName.put(s.MasterLabel, s);
            }
            //Mask Created by Name for  Portal user whose User Community Mode is 'CC'
            String createdbyName = '';

            if (isCCUser) {
                createdbyName = UserInfo.getName() + '(' + System.Label.RH_Masked_IQVIA_User + ')';
            } else {
                createdbyName = UserInfo.getName();
            }

            for (Integer i = 0; i < pathWrapper.steps.size(); i = i + 1) {
                ParticipantWorkflowService.ParticipantWorkflowStepWrapper step = pathWrapper.steps[
                    i
                ];
                if (step.isCurrentStep == true && step.isCurrentStepValid == true) {
                    String note = step.notes;
                    if (step.reason != null && step.reason != '') {
                        note = peshnotes.Status__c + ' - ' + step.reason + ', ' + step.notes;
                    }
                    if (i + 1 < pathWrapper.steps.size()) {
                        Boolean nextStepStateNew = isStepSuccessfulOrInProgress(
                            stepsWithName.get(pathWrapper.steps[i + 1].title),
                            pe,
                            peshnotes.Status__c
                        );
                        String nextStepStateOld = pathWrapper.steps[i + 1].state;
                        if (
                            nextStepStateNew &&
                            !(nextStepStateOld == PEStatusState.STATUS_STATE_SUCCESS ||
                            nextStepStateOld == PEStatusState.STATUS_STATE_IN_PROGRESS ||
                            nextStepStateOld == PEStatusState.STATUS_STATE_FAILURE)
                        ) {
                            isBetweenStep = true;
                            if (peshnotes.Additional_Notes__c == null) {
                                peshnotes.Additional_Notes__c =
                                    '####' +
                                    note +
                                    ' ' +
                                    Label.PE_Status_History_On_Date +
                                    ' ' +
                                    DateTime.now().format('MMM dd yyyy, hh:mm a') +
                                    ' ' +
                                    Label.PG_IMI_L_by_user +
                                    ' ' +
                                    createdbyName +
                                    '#';
                                break;
                            } else if (
                                peshnotes.Additional_Notes__c != null &&
                                !peshnotes.Additional_Notes__c.contains('####')
                            ) {
                                peshnotes.Additional_Notes__c =
                                    '####' +
                                    note +
                                    ' ' +
                                    Label.PE_Status_History_On_Date +
                                    ' ' +
                                    DateTime.now().format('MMM dd yyyy, hh:mm a') +
                                    ' ' +
                                    Label.PG_IMI_L_by_user +
                                    ' ' +
                                    createdbyName +
                                    '#' +
                                    peshnotes.Additional_Notes__c;
                                break;
                            }
                        }
                    }
                    if (peshnotes.Additional_Notes__c == null) {
                        peshnotes.Additional_Notes__c =
                            ' ' +
                            note +
                            ' ' +
                            Label.PE_Status_History_On_Date +
                            ' ' +
                            DateTime.now().format('MMM dd yyyy, hh:mm a') +
                            ' ' +
                            Label.PG_IMI_L_by_user +
                            ' ' +
                            createdbyName +
                            '#';
                        break;
                    } else {
                        peshnotes.Additional_Notes__c =
                            note +
                            ' ' +
                            Label.PE_Status_History_On_Date +
                            ' ' +
                            DateTime.now().format('MMM dd yyyy, hh:mm a') +
                            ' ' +
                            Label.PG_IMI_L_by_user +
                            ' ' +
                            createdbyName +
                            '#' +
                            peshnotes.Additional_Notes__c;
                        break;
                    }
                }
            }
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
            );
            List<Participant_Enrollment_Status_History__c> peshNotesToUpdate = new List<Participant_Enrollment_Status_History__c>();
            peshNotesToUpdate.add(peshnotes);
            if (isBetweenStep && peshnotes != null) {
                for (Participant_Enrollment_Status_History__c peshstep : [
                    SELECT Id, Additional_Notes__c
                    FROM Participant_Enrollment_Status_History__c
                    WHERE
                        Id != :peshnotes.Id
                        AND Status__c = :peshnotes.Status__c
                        AND ParticipantEnrollment__c = :pe.Id
                ]) {
                    if (
                        peshstep.Additional_Notes__c != null &&
                        peshstep.Additional_Notes__c != '' &&
                        !peshstep.Additional_Notes__c.contains('####')
                    ) {
                        peshstep.Additional_Notes__c = '####' + peshstep.Additional_Notes__c;
                        peshNotesToUpdate.add(peshstep);
                    }
                }
            }
            update peshNotesToUpdate;
        }
    }

    @testVisible
    private static void updateWithDividerWithNotes(
        ParticipantWorkflowService.ParticipantWorkflowWrapper pathWrapper,
        Participant_Enrollment__c pe,
        String outcome
    ) {
        Participant_Enrollment_Status_History__c peshnotes;
        List<Participant_Enrollment_Status_History__c> peshnotesList = new List<Participant_Enrollment_Status_History__c>();
        Boolean isBetweenStep = false;
        if (outcome != null) {
            peshnotesList = [
                SELECT Id, Additional_Notes__c, Notes__c, Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c = :pe.Id AND Status__c = :outcome
                ORDER BY Date__c DESC
                LIMIT 1
            ];
        } else {
            peshnotesList = [
                SELECT Id, Additional_Notes__c, Notes__c, Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c = :pe.Id
                ORDER BY Date__c DESC
                LIMIT 1
            ];
        }
        if (peshnotesList.size() > 0) {
            peshnotes = peshnotesList[0];
        }
        if (peshnotes != null) {
            Map<String, Participant_Workflow_Step__mdt> stepsWithName = new Map<String, Participant_Workflow_Step__mdt>();
            for (Participant_Workflow_Step__mdt s : [
                SELECT
                    Id,
                    MasterLabel,
                    DeveloperName,
                    Additional_Notes_For_Statuses__c,
                    In_Progress_Condition__c,
                    Success_Condition__c
                FROM Participant_Workflow_Step__mdt
            ]) {
                stepsWithName.put(s.MasterLabel, s);
            }
            if (pathWrapper != null) {
                for (Integer i = 0; i < pathWrapper.steps.size(); i = i + 1) {
                    ParticipantWorkflowService.ParticipantWorkflowStepWrapper step = pathWrapper.steps[
                        i
                    ];
                    if (step.isCurrentStep == true && step.isCurrentStepValid == true) {
                        if (i + 1 < pathWrapper.steps.size()) {
                            Boolean nextStepStateNew = isStepSuccessfulOrInProgress(
                                stepsWithName.get(pathWrapper.steps[i + 1].title),
                                pe,
                                peshnotes.Status__c
                            );
                            String nextStepStateOld = pathWrapper.steps[i + 1].state;
                            if (
                                nextStepStateNew &&
                                !(nextStepStateOld == PEStatusState.STATUS_STATE_SUCCESS ||
                                nextStepStateOld == PEStatusState.STATUS_STATE_IN_PROGRESS ||
                                nextStepStateOld == PEStatusState.STATUS_STATE_FAILURE)
                            ) {
                                isBetweenStep = true;
                                if (
                                    peshnotes.Additional_Notes__c != null &&
                                    !peshnotes.Additional_Notes__c.contains('####')
                                ) {
                                    peshnotes.Additional_Notes__c =
                                        '####' + peshnotes.Additional_Notes__c;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
            );
            List<Participant_Enrollment_Status_History__c> peshNotesToUpdate = new List<Participant_Enrollment_Status_History__c>();
            peshNotesToUpdate.add(peshnotes);
            if (isBetweenStep && peshnotes != null) {
                for (Participant_Enrollment_Status_History__c peshstep : [
                    SELECT Id, Additional_Notes__c
                    FROM Participant_Enrollment_Status_History__c
                    WHERE
                        Id != :peshnotes.Id
                        AND Status__c = :peshnotes.Status__c
                        AND ParticipantEnrollment__c = :pe.Id
                ]) {
                    if (
                        peshstep.Additional_Notes__c != null &&
                        peshstep.Additional_Notes__c != '' &&
                        !peshstep.Additional_Notes__c.contains('####')
                    ) {
                        peshstep.Additional_Notes__c = '####' + peshstep.Additional_Notes__c;
                        peshNotesToUpdate.add(peshstep);
                    }
                }
            }
            update peshNotesToUpdate;
        }
    }

    private static Boolean isStepSuccessfulOrInProgress(
        Participant_Workflow_Step__mdt step,
        Participant_Enrollment__c pe,
        String Status
    ) {
        Boolean stepSuccessful = false;
        Boolean stepInProgress = false;
        Boolean statusPresent = false;

        if (step != null) {
            stepSuccessful =
                String.isNotBlank(step.Success_Condition__c) &&
                ConditionCheckerService.checkConditionForObject(step.Success_Condition__c, pe);
            stepInProgress =
                String.isBlank(step.In_Progress_Condition__c) ||
                ConditionCheckerService.checkConditionForObject(step.In_Progress_Condition__c, pe);
            statusPresent =
                step.Additional_Notes_For_Statuses__c != null &&
                step.Additional_Notes_For_Statuses__c.contains(';' + Status + ';');
        }
        Boolean res = (statusPresent && (stepSuccessful || stepInProgress));
        return res;
    }

    //CC
    @AuraEnabled
    public static String updatePatientStatusCC(
        String pathWrapperJSON,
        Participant_Enrollment__c pe,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome,
        Boolean sitepreference,
        Boolean PartcipantNoShow
    ) {
        try {
            ParticipantWorkflowService.ParticipantWorkflowWrapper pathWrapper = (ParticipantWorkflowService.ParticipantWorkflowWrapper) JSON.deserialize(
                pathWrapperJSON,
                ParticipantWorkflowService.ParticipantWorkflowWrapper.class
            );

            //Participant_Enrollment__c oldParticipantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityModeService.USER_MODE_CC, null);
            Participant_Enrollment__c oldParticipantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_CC,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            Clinical_Trial_Profile__c ctp = StudyTrialService.getFullTrial(
                oldParticipantEnrollment.Clinical_Trial_Profile__c
            );
            ParticipantWorkflowService.populatePEFromWorkflowWrapper(
                pathWrapper,
                pe,
                ctp,
                oldParticipantEnrollment
            );
            pe.ParticipantNoShow__c = PartcipantNoShow;
            update pe;
            if (
                (oldParticipantEnrollment.Initial_visit_scheduled_date__c == null ||
                oldParticipantEnrollment.Initial_visit_scheduled_time__c == null) &&
                (pe.Initial_visit_scheduled_date__c != null &&
                pe.Initial_visit_scheduled_time__c != null)
            ) {
                IncentiveProgramService.completeIncentiveTaskCurrentContact(
                    IncentiveTaskCatalog.INCENTIVE_TASK_ENTERED_INITIAL_VISIT_SCHEDULED_TIME,
                    oldParticipantEnrollment.Study_Site__c,
                    oldParticipantEnrollment.Name
                );
            }
            //pe = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityService.USER_MODE_CC);
            pe = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_CC,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            Participant_Enrollment_Status_History__c pesh = ParticipantWorkflowService.createPESHFromPathWrapper(
                pathWrapper,
                pe,
                ctp,
                oldParticipantEnrollment,
                PartcipantNoShow
            );
            if (pesh != null && historyToUpdate) {
                if (
                    oldParticipantEnrollment.Participant_Status__c ==
                    PEStatusState.PE_STATUS_RECEIVED &&
                    (pesh.Status__c == PEStatusState.PE_STATUS_CONTACT_ATTEMPTED ||
                    pesh.Status__c == PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED) &&
                    oldParticipantEnrollment.Participant_Status_Last_Changed_Date__c.date()
                        .daysBetween(Date.today()) <= 1
                ) {
                    IncentiveProgramService.completeIncentiveTaskCurrentContact(
                        IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY,
                        oldParticipantEnrollment.Study_Site__c,
                        oldParticipantEnrollment.Name
                    );
                }
                insert pesh;
            } else if (notesToBeAdded && pe != null && pe.Id != null) {
                Boolean isCCUser = true;
                updateNotes(pathWrapper, pe, outcome, isCCUser);
            } else if (pe != null && pe.Id != null) {
                updateWithDividerWithNotes(pathWrapper, pe, outcome);
            }
            //pe = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityService.USER_MODE_CC);
            pe = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_CC,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            if (pe == null)
                throw new CommunityServiceException('Participant enrollment not found');
            return JSON.serialize(
                new UpdateResponse(
                    pe,
                    ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe)
                )
            );
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String updatePatientInfoAndStatus(
        String participantJSON,
        String peJSON,
        String pathWrapperJSON,
        String peId
    ) {
        Participant__c participant = (Participant__c) JSON.deserialize(
            participantJSON,
            Participant__c.class
        );
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );
        update participant;
        return updatePatientStatus(pathWrapperJSON, pe, false, false, null,false,false);
    }

    @AuraEnabled
    public static void updatePatientInfoAndStatusWithDelegate(
        String participantJSON,
        String peJSON,
        String pathWrapperJSON,
        String peId,
        String delegateJSON,
        String userInfoJSON,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome,
        String contactInfoJSON
    ) {
        Participant__c participantObj;
        try {
            participantObj = (Participant__c) JSON.deserialize(
                participantJSON,
                Participant__c.class
            );
            update participantObj;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );

        if (!String.isBlank(delegateJSON)) {
            Participant__c delegateParticipant = (Participant__c) JSON.deserialize(
                delegateJSON,
                Participant__c.class
            );
            String strFirstName = delegateParticipant.First_Name__c;
            String strLastName = delegateParticipant.Last_Name__c;
            String strDelegateEmail = delegateParticipant.Email__c;

            Boolean delFound =
                String.isBlank(delegateParticipant.First_Name__c) &&
                String.isBlank(delegateParticipant.Last_Name__c) &&
                String.isBlank(delegateParticipant.Email__c) &&
                String.isBlank(delegateParticipant.Phone__c);

            if (
                (String.isBlank(delegateParticipant.Id) && !delFound) ||
                (!String.isBlank(delegateParticipant.Id) && delFound) ||
                (!String.isBlank(delegateParticipant.Id) && !delFound)
            ) {
                ID perAccountId = [
                    SELECT ID, Study_Site__c, Study_Site__r.Site__c
                    FROM Participant_Enrollment__c
                    WHERE ID = :pe.Id
                ]
                .Study_Site__r.Site__c;
                Contact objcon;
                if (String.isBlank(delegateParticipant.Id)) {
                    List<Contact> lstContact = [
                        SELECT
                            FirstName,
                            LastName,
                            Email,
                            MailingCity,
                            MailingCountryCode,
                            MailingState,
                            MailingCountry,
                            MailingStateCode,
                            MailingPostalCode,
                            userCommunytyType__c,
                            userCommunityMode__c
                        FROM Contact
                        WHERE
                            (FirstName = :strFirstName
                            OR FirstName = :strFirstName.toLowerCase())
                            AND (LastName = :strLastName
                            OR LastName = :strLastName.toLowerCase())
                            AND (Email = :strDelegateEmail
                            OR Email = :strDelegateEmail.toLowerCase())
                            AND userCommunityMode__c != 'CC'
                    ];
                    if (lstContact.isEmpty()) {
                        objcon = new Contact(
                            FirstName = delegateParticipant.First_Name__c,
                            LastName = delegateParticipant.Last_Name__c,
                            Email = delegateParticipant.Email__c,
                            Phone = delegateParticipant.Phone__c,
                            AccountId = perAccountId,
                            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
                            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
                            Language__c = UserInfo.getLanguage(),
                            Second_Choice_Language__c = '',
                            Third_Choice_Language__c = '',
                            userCommunityIsDelegate__c = true,
                            MailingCountryCode = participantObj.Mailing_Country_Code__c,
                            MailingStateCode = participantObj.Mailing_State_Code__c,
                            MailingCountry = participantObj.Mailing_Country__c,
                            MailingState = participantObj.Mailing_State__c,
                            MailingPostalCode = participantObj.Mailing_Zip_Postal_Code__c
                        );
                    } else {
                        objcon = lstContact[0];
                        String strCommunityType = objcon.userCommunytyType__c;
                        strCommunityType = String.isBlank(strCommunityType)
                            ? CommunityService.USER_MODE_PARTICIPANT
                            : strCommunityType + ';' + CommunityService.USER_MODE_PARTICIPANT;
                        objcon.userCommunytyType__c = strCommunityType;
                    }
                    upsert objcon;
                    delegateParticipant.Contact__c = objcon.id;
                    // delegateParticipant.Site__c = perAccountId;
                    delegateParticipant.Mailing_Country_Code__c = participantObj.Mailing_Country_Code__c;
                    delegateParticipant.Mailing_State_Code__c = participantObj.Mailing_State_Code__c;
                    delegateParticipant.Mailing_Zip_Postal_Code__c = participantObj.Mailing_Zip_Postal_Code__c;
                    if (String.isNotBlank(delegateParticipant.Birth_Year__c)) {
                        delegateParticipant.Attestation__c = true;
                        delegateParticipant.Attestation_TimeStamp__c = ParticipantService.getFormattedTime();
                        delegateParticipant.Attested_by__c = CommunityService.getInstance()
                            .getCurrentContactId();
                    }
                }
                system.debug('>>delegateParticipant11>>>' + delegateParticipant.id);

                if (delegateParticipant != null) {
                    try {
                        if (
                            String.isNotBlank(delegateParticipant.First_Name__c) &&
                            String.isNotBlank(delegateParticipant.Last_Name__c) &&
                            String.isNotBlank(delegateParticipant.Email__c)
                        )
                            upsert delegateParticipant;
                    } catch (Exception exp) {
                        system.debug('No delegate was provided');
                    }
                    system.debug('>>delegateParticipant>>' + delegateParticipant);
                    Id participantConId = [
                        SELECT Contact__c, id
                        FROM Participant__c
                        WHERE id = :delegateParticipant.id
                    ]
                    .contact__c;

                    Map<Id, Patient_Delegate__c> mapParticipantIdToPatientDelegate = new Map<Id, Patient_Delegate__c>();
                    for (Patient_Delegate__c objPateintDel : [
                        SELECT ID, Participant__c, Contact__c, Primary_Delegate__c
                        FROM Patient_Delegate__c
                        WHERE Participant__c = :pe.Participant__c
                    ]) {
                        if (objPateintDel.Contact__c == participantConId) {
                            if (
                                String.isBlank(delegateParticipant.First_Name__c) &&
                                String.isBlank(delegateParticipant.Last_Name__c) &&
                                String.isBlank(delegateParticipant.Email__c)
                            ) {
                                objPateintDel.Primary_Delegate__c = false;
                            } else {
                                objPateintDel.Primary_Delegate__c = true;
                            }
                        } else {
                            objPateintDel.Primary_Delegate__c = false;
                        }
                        mapParticipantIdToPatientDelegate.put(
                            objPateintDel.Contact__c,
                            objPateintDel
                        );
                    }
                    if (!mapParticipantIdToPatientDelegate.containsKey(participantConId)) {
                        mapParticipantIdToPatientDelegate.put(
                            participantConId,
                            new Patient_Delegate__c(
                                Contact__c = participantConId,
                                Primary_Delegate__c = true,
                                Participant__c = pe.Participant__c,
                                Status__c = 'Disconnected'
                            )
                        );
                    }
                    if (!mapParticipantIdToPatientDelegate.isEmpty())
                        upsert mapParticipantIdToPatientDelegate.values();

                    /*  if (delegateParticipant != null && !String.isBlank(delegateParticipant.Id)) {
                try {
                    update delegateParticipant;
                } catch (Exception exp) {
                    system.debug('No delegate was provided');
                }
            } */
                }
            }
        }
        //If user is available then updated user language else update contact language
        if (userInfoJSON != null) {
            updateUserLanguage(userInfoJSON);
        } else {
            updateParticipantContactLanguage(contactInfoJSON);
        }
    }

    @AuraEnabled
    public static String updatePatientStatusHelper(
        String peJSON,
        String pathWrapperJSON,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome,
        Boolean sitepreference,
        Boolean PartcipantNoShow
        
    ) {
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );
        return updatePatientStatus(pathWrapperJSON, pe, historyToUpdate, notesToBeAdded, outcome,sitepreference,PartcipantNoShow);
    }

    @AuraEnabled
    public static DelegateInfo checkExisitingParticipant(
        String strFirstName,
        String strLastName,
        String strDelegateEmail,
        Id participantId
    ) {
        List<Participant__c> lstdelegateParticipants = [
            SELECT
                Id,
                First_Name__c,
                Email__c,
                Last_Name__c,
                Phone__c,
                Phone_Type__c,
                Contact__c,
                Birth_Year__c,
                Attestation__c
            FROM Participant__c
            WHERE
                (First_Name__c = :strFirstName
                OR First_Name__c = :strFirstName.toLowerCase())
                AND (Last_Name__c = :strLastName
                OR Last_Name__c = :strLastName.toLowerCase())
                AND (Email__c = :strDelegateEmail
                OR Email__c = :strDelegateEmail.toLowerCase())
        ];
        if (!lstdelegateParticipants.isEmpty()) {
            Participant__c objTempParticipant = lstdelegateParticipants[0];
            DelegateInfo objDelegate = new DelegateInfo();
            objDelegate.PartcipantId = objTempParticipant.Id;
            objDelegate.email = objTempParticipant.Email__c;
            objDelegate.firstName = objTempParticipant.First_Name__c;
            objDelegate.lastName = objTempParticipant.Last_Name__c;
            objDelegate.isDuplicateDelegate = false;
            objDelegate.participantPhoneNumber = String.isBlank(objTempParticipant.Phone__c)
                ? ''
                : objTempParticipant.Phone__c;
            objDelegate.DelegateParticipant = objTempParticipant;
            List<Patient_Delegate__c> duplicateDelegates = checkDuplicatePDelegates(
                participantId,
                String.escapeSingleQuotes(strDelegateEmail),
                String.escapeSingleQuotes(strFirstName),
                String.escapeSingleQuotes(strLastName)
            );
            objDelegate.isBulkImport = objTempParticipant.Attestation__c == true &&
                String.isBlank(objTempParticipant.Birth_Year__c)
                ? true
                : false;
            if (!duplicateDelegates.isEmpty()) {
                objDelegate.isDuplicate = true;
            } else {
                objDelegate.isDuplicate = false;
            }

            return objDelegate;
        } else {
            List<Contact> lstContact = [
                SELECT Id, FirstName, LastName, Name, Email, Phone, userCommunytyType__c
                FROM Contact
                WHERE
                    userCommunityMode__c != 'CC'
                    AND (FirstName = :strFirstName
                    OR FirstName = :strFirstName.toLowerCase())
                    AND (LastName = :strLastName
                    OR LastName = :strLastName.toLowerCase())
                    AND (Email = :strDelegateEmail
                    OR Email = :strDelegateEmail.toLowerCase())
            ];
            if (!lstContact.isEmpty()) {
                Participant__c objTempParticipant = new Participant__c(Birth_Year__c = '',Attestation__c=false);
                Contact objTempCon = lstContact[0]; 
                DelegateInfo objDelegate = new DelegateInfo();
                objDelegate.PartcipantId = null;
                objDelegate.email = objTempCon.Email;
                objDelegate.firstName = objTempCon.FirstName;
                objDelegate.lastName = objTempCon.LastName;
                objDelegate.contactId = objTempCon.Id;
                objDelegate.isDuplicateDelegate = false;
                objDelegate.participantPhoneNumber = String.isBlank(objTempCon.Phone)
                    ? ''
                    : objTempCon.Phone;
                objDelegate.DelegateParticipant = objTempParticipant;
                objDelegate.isDuplicate = false;
                objDelegate.isBulkImport = false;

                return objDelegate;
            } else
                return null;
        }
    }

    public static List<Patient_Delegate__c> checkDuplicatePDelegates(
        String participantId,
        String email,
        String firstName,
        String lastName
    ) {
        String duplicateDelegatesQuery =
            'SELECT Id FROM Patient_Delegate__c WHERE Participant__c = \'' +
            participantId +
            '\' AND Contact__r.Email = \'' +
            email +
            '\'';
        if (firstName != null)
            duplicateDelegatesQuery +=
                ' AND (Contact__r.FirstName = \'' +
                firstName +
                '\' OR Contact__r.FirstName = \'' +
                firstName.toLowerCase() +
                '\')';
        if (lastName != null)
            duplicateDelegatesQuery +=
                ' AND (Contact__r.LastName = \'' +
                lastName +
                '\' OR Contact__r.LastName = \'' +
                lastName.toLowerCase() +
                '\')';
        duplicateDelegatesQuery += ' AND Primary_Delegate__c = True';
        system.debug('>>>duplicateDelegates>>' + duplicateDelegatesQuery);
        return Database.query(duplicateDelegatesQuery);
    }
    //CC
    @AuraEnabled
    public static void updatePatientInfoAndStatusWithDelegateCC(
        String participantJSON,
        String peJSON,
        String pathWrapperJSON,
        String peId,
        String delegateJSON,
        String userInfoJSON,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome,
        String contactInfoJSON
    ) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantJSON,
                Participant__c.class
            );
            update participant;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );

        if (!String.isBlank(delegateJSON)) {
            Participant__c delegateParticipant = (Participant__c) JSON.deserialize(
                delegateJSON,
                Participant__c.class
            );
            if (delegateParticipant != null && !String.isBlank(delegateParticipant.Id)) {
                try {
                    update delegateParticipant;
                } catch (Exception exp) {
                    system.debug('No delegate was provided');
                }
            }
        }
        //If user is available then updated user language else update contact language
        if (userInfoJSON != null) {
            updateUserLanguage(userInfoJSON);
        } else {
            updateParticipantContactLanguage(contactInfoJSON);
        }
    }
    //Added as per REF-3248
    @AuraEnabled
    public static String checkDelegateAge(String participantJSON, String delegateParticipantJSON) {
        return ReferringRemote.checkDelegateAge(participantJSON, delegateParticipantJSON);
    }

    @AuraEnabled
    public static String updatePatientStatusCCHelper(
        String peJSON,
        String pathWrapperJSON,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome,
        Boolean PartcipantNoShow
    ) {
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );
        return updatePatientStatusCC(pathWrapperJSON, pe, historyToUpdate, notesToBeAdded, outcome,false,PartcipantNoShow);
    }

    public static void updateUserLanguage(String userJSON) {
        if (!String.isBlank(userJSON)) {
            try {
                User userL = (User) JSON.deserialize(userJSON, User.class);
                if (userL != null) {
                    update userL;
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
            }
        }
    }
    //Update Participant Contact language for not invited Participants
    public static void updateParticipantContactLanguage(String contactJSON) {
        if (!String.isBlank(contactJSON)) {
            try {
                Contact ContactL = (Contact) JSON.deserialize(contactJSON, Contact.class);
                if (ContactL != null) {
                    update ContactL;
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
            }
        }
    }

    public class UpdateResponse {
        @AuraEnabled
        public Participant_Enrollment__c pe;
        @AuraEnabled
        public ParticipantWorkflowService.ParticipantWorkflowWrapper participantPath;

        public UpdateResponse(
            Participant_Enrollment__c pe,
            ParticipantWorkflowService.ParticipantWorkflowWrapper participantPath
        ) {
            this.pe = pe;
            this.participantPath = participantPath;
        }
    }

    //REF-2826
    @AuraEnabled
    public static String getMedicalHistory(Id peId) {
        Participant_Enrollment__c pe = [
            SELECT Id, Participant__c
            FROM Participant_Enrollment__c
            WHERE Id = :peId
        ];

        List<ContentDocument> entries = new List<ContentDocument>();

        List<ContentDocumentLink> cdls = [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :pe.Participant__c
        ];

        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink cdl : cdls) {
            documentIds.add(cdl.ContentDocumentId);
        }
        List<ContentDocument> documents = [
            SELECT Id, Title, CreatedDate, FileExtension, ContentModifiedDate
            FROM ContentDocument
            WHERE Id IN :documentIds
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        String basefileUrl = URL.getSalesforceBaseUrl().toExternalForm();
        return JSON.serialize(new MedicalHistoryWrapper(pe, documents, basefileUrl));
    }

    public class MedicalHistoryWrapper {
        @AuraEnabled
        public Participant_Enrollment__c pe;
        @AuraEnabled
        public List<ContentDocument> attachments;
        @AuraEnabled
        public String baseURL;
        @AuraEnabled
        public ContentDocument content;

        public MedicalHistoryWrapper(
            Participant_Enrollment__c pe,
            List<ContentDocument> attachments,
            String baseURL
        ) {
            this.pe = pe;
            this.attachments = attachments;
            this.baseURL = baseURL;
            this.content = content;
        }
    }
    //REF-2826 End

    @AuraEnabled
    public static String updateParticipantData(Id peId) {
        List<Participant_Enrollment__c> PEUpdateList = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : [
            SELECT Id, Participant_Status__c, High_Priority__c, Initial_visit_scheduled_date__c
            FROM Participant_Enrollment__c
            WHERE Id = :peId
        ]) {
            if (pe.Initial_visit_scheduled_date__c != null) {
                pe.High_Priority__c = true;
            } else {
                pe.High_Priority__c = false;
            }

            pe.Participant_Status__c = 'Eligibility Passed';
            pe.Participant_Status_Last_Changed_Date__c = DateTime.now();
            PEUpdateList.add(pe);
        }
        if (PEUpdateList != null && !PEUpdateList.isEmpty()) {
            update PEUpdateList;
        }
        Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
            peId,
            CommunityModeService.USER_MODE_CC,
            null,
            ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
        );
        Clinical_Trial_Profile__c ctp = StudyTrialService.getFullTrial(
            pe.Clinical_Trial_Profile__c
        );
        return JSON.serialize(
            new UpdateResponse(pe, ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe))
        );
    }

    @AuraEnabled
    public static String getPESHrecord(Id peId) {
        List<Participant_Enrollment__c> pe = [
            SELECT
                Id,
                Participant_Status__c,
                Study_Hub_Log__r.Response_Status_Code__c,
                (
                    SELECT Date__c
                    FROM Participant_Enrollment_Status_History__r
                    WHERE Status__c = 'Eligibility Passed'
                    ORDER BY Date__c DESC
                    LIMIT 1
                )
            FROM Participant_Enrollment__c
            WHERE Id = :peId
        ];
        peStudyHubInfo peshinfo = new peStudyHubInfo();
        peshinfo.currentStatus = pe.isEmpty() ? null : pe[0].Participant_Status__c;
        if (
            !pe.isEmpty() &&
            pe[0].Participant_Enrollment_Status_History__r != null &&
            !pe[0].Participant_Enrollment_Status_History__r.isEmpty()
        ) {
            peshinfo.dateOfSH = Date.valueOf(
                pe[0].Participant_Enrollment_Status_History__r[0].Date__c
            );
        }
        peshinfo.shLogStatus = pe.isEmpty() ? null : pe[0].Study_Hub_Log__r.Response_Status_Code__c;
        return JSON.serialize(peshinfo);
    }

    @AuraEnabled
    public static string getUser(Id contactId) {
        List<user> lstUser = [
            SELECT id, CreatedDate, ContactId
            FROM user
            WHERE ContactId = :contactid
        ];
        return String.ValueOf(Date.valueOf(lstUser[0].CreatedDate));
    }
    
    @AuraEnabled
    public static String checkNeedsGuardian(String participantJSON) {
        return ReferringRemote.checkNeedsGuardian(participantJSON);
    }
    
    
    public static String getMasked(
    Boolean IsPortalEnabled,
    String userCommunityMode,
    String Name
  ) {
    if (IsPortalEnabled == true) {
      if (userCommunityMode == 'CC') {
        return System.Label.RH_Masked_IQVIA_User;
      } else {
        return Name;
      }
    } else {
      return System.Label.RH_Masked_IQVIA_User;
    }
  }

    /**
     * This wapper class is created to accomodate the requirements of REF-1192
     * It intends to combine the return value of getSteps(String, String, String)
     * and getPrintInformation(String, String, String)
     * @param args Unused.
     * @return Nothing.
     * @exception IOException On input error.
     * @see IOException
     */
    public class ParticipantItemWithSteps{
        @AuraEnabled
        public String participantItem;
        @AuraEnabled
        public String initData;
        ParticipantItemWithSteps() {
            this.participantItem = '';
            this.initData = '';
        }
    }
    public class DelegateInfo {
        @AuraEnabled
        public String email { get; set; }
        @AuraEnabled
        public String firstName { get; set; }
        @AuraEnabled
        public String lastName { get; set; }
        @AuraEnabled
        public Boolean isDuplicateDelegate { get; set; }
        @AuraEnabled
        public Boolean isDuplicate { get; set; }
        @AuraEnabled
        public String contactId { get; set; }
        @AuraEnabled
        public String PartcipantId { get; set; }
        @AuraEnabled
        public String participantPhoneNumber { get; set; }
        @AuraEnabled
        public Participant__c DelegateParticipant { get; set; }
        @AuraEnabled
        public Participant_Enrollment__c particpantEnrollment { get; set; }
        @AuraEnabled
        public Boolean isBulkImport { get; set; }
    }

    public class DelegateConnectedInfo {
        @AuraEnabled
        public Boolean isConnected { get; set; }
        @AuraEnabled
        public Id participantId { get; set; }
        @AuraEnabled
        public Id contactId { get; set; }
        @AuraEnabled
        public Id delegateId {get; set; }
    }

    public class PIDelegateLevelInfo {
        @AuraEnabled
        public Boolean isDisabled { get; set; }
    }

    public class peStudyHubInfo {
        @AuraEnabled
        public String currentStatus { get; set; }
        @AuraEnabled
        public Date dateOfSH { get; set; }
        @AuraEnabled
        public Decimal shLogStatus { get; set; }
    }
    
}