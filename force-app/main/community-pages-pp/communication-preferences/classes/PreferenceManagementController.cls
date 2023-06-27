public without sharing class PreferenceManagementController {
    public static Set<Id> minorOrAdultWithNoEmailParIdSet = new Set<Id>();
    /**
     * @description: This Method will save the Consent data checked/uncheck by participant/Patient delegate..
     * @author: Krishna Mahto
     * @param: studyDataJSON
     * @param: outReachData
     * @param: requestFrom
     * @return:
     **/
    @AuraEnabled
    public static void saveConsent(
        String studyDataJSON,
        String outReachDataJSON,
        String requestFrom
    ) {
        System.debug('***Study Data: ' + studyDataJSON);
        System.debug('****Outreach Data: ' + outReachDataJSON);

        if (requestFrom == 'PER') {
            //Update Study Consent.
            saveStudyConsent(studyDataJSON);
        } else if (requestFrom == 'PDE') {
            //Update Patient Delegate enrollment Consent.
            savePDEConsent(studyDataJSON);
        } else if (requestFrom == 'IQVIA_OUTREACH') {
            //Update IQVIA Outreach Consent.
            saveIQVIAOutreachConsent(outReachDataJSON);
        }
    }

    @AuraEnabled
    public static Boolean createCommPrefEvent() {
        try {
            Communication_Preference_Change__e commPrefEvent = new Communication_Preference_Change__e();
            commPrefEvent.Payload__c = String.valueOf(UserInfo.getUserId());
            EventBus.publish(commPrefEvent);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * @description: This Method will save the Study Consent data checked/uncheck by participant/Patient delegate.
     * @author: Krishna Mahto
     * @param: studyDataJSON
     * @return:
     **/
    public static void saveStudyConsent(String studyDataJSON) {
        try {
            ConsentPreferenceDataWrapper consentData = (ConsentPreferenceDataWrapper) JSON.deserialize(
                studyDataJSON,
                ConsentPreferenceDataWrapper.class
            );
            Participant_Enrollment__c per = consentData.convertToPER();
            system.debug('per: ' + per);
            if (per != null) {
                update per;
            }
            //SMS Opt out for Patient Delegate.
            if (!per.Permit_SMS_Text_for_this_study__c) {
                List<Id> perIdList = new List<Id>{ consentData.perId };
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
    /**
     * @description: This Method will save the PDE Consent data checked/uncheck by Patient delegate.
     * @author: Krishna Mahto
     * @param: studyDataJSON
     * @return:
     **/
    public static void savePDEConsent(String studyDataJSON) {
        try {
            ConsentPreferencePDEDataWrapper consentData = (ConsentPreferencePDEDataWrapper) JSON.deserialize(
                studyDataJSON,
                ConsentPreferencePDEDataWrapper.class
            );
            Patient_Delegate_Enrollment__c pde = consentData.convertToPDE();
            system.debug('pde: ' + pde);
            if (pde != null) {
                update pde;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    /**
     * @description: This Method will save the IQVIA Outreach Consent data checked/uncheck by participant/Patient delegate.
     * @author: Krishna Mahto
     * @param: outReachDataJSON
     * @return:
     **/
    public static void saveIQVIAOutreachConsent(String outReachDataJSON) {
        try {
            ConsentPreferenceContactDataWrapper consentContactData = (ConsentPreferenceContactDataWrapper) JSON.deserialize(
                outReachDataJSON,
                ConsentPreferenceContactDataWrapper.class
            );
            Contact cont = consentContactData.convertToCont();
            system.debug('****cont: ' + cont);
            if (cont != null) {
                update cont;
            }
            /*Not Required as Part of Delegate Redesign 
            //Update consent at Primady Delegate contact also when Participant consents got updated by Participant or Primary Delegate under participant account setting.
            if (
                consentContactData.participantLoogedIn ||
                (!consentContactData.participantLoogedIn && !consentContactData.isDelegateSelfView)
            ) {
                //If Participant is Minor or Adult without email.
                if (
                    !consentContactData.isAdultParticipant ||
                    (consentContactData.isAdultParticipant &&
                    !consentContactData.isEmailAvailabelForParticipant)
                ) {
                    updatePrimaryDelegateCommConsent(cont);
                }
            }
            */
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    /**
     * @description: This Method will save the phone number at Participant record.
     * @author: Krishna Mahto
     * @param: parId
     * @param: mobilePhone
     * @return:
     **/
    @AuraEnabled
    public static void updateParticipantMobileNumber(
        String parId,
        String contId,
        String mobilePhone
    ) {
        try {
            Participant__c participant = new Participant__c();
            participant.Id = parId;
            participant.Alternative_Phone_Number__c = mobilePhone;
            participant.Alternative_Phone_Type__c = 'Mobile';

            update participant;

            Contact cont = new Contact();
            cont.Id = contId;
            cont.MobilePhone = mobilePhone;

            update cont;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Boolean getIsRTL() {
        try {
            return (System.Label.RTL_Languages).contains(UserInfo.getLanguage());
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    public class ConsentPreferenceDataWrapper {
        @AuraEnabled
        public String perId;
        @AuraEnabled
        public String ParticipantContId;
        @AuraEnabled
        public Boolean participantOptInEmail;
        @AuraEnabled
        public Boolean participantOptInSMSText;
        @AuraEnabled
        public Boolean participantOptInPhone;
        @AuraEnabled
        public Boolean participantOptInDirectEmail;

        public Participant_Enrollment__c convertToPER() {
            Participant_Enrollment__c per = new Participant_Enrollment__c();
            per.Id = perId;
            per.Permit_Mail_Email_contact_for_this_study__c = participantOptInEmail;
            per.Permit_SMS_Text_for_this_study__c = participantOptInSMSText;
            per.Permit_Voice_Text_contact_for_this_study__c = participantOptInPhone;
            per.Study_Direct_Mail_Consent__c = participantOptInDirectEmail;

            //IF SMS opt out, revert the welcome message flag at PER.
            if (!per.Permit_SMS_Text_for_this_study__c) {
                per.Welcome_Message_Sent__c = false;
                per.Welcome_Message_Delivered__c = false;
            }
            return per;
        }
    }
    public class ConsentPreferencePDEDataWrapper {
        @AuraEnabled
        public String pdeId;
        @AuraEnabled
        public Boolean delegateOptInEmail;
        @AuraEnabled
        public Boolean delegateOptInSMSText;
        @AuraEnabled
        public Boolean delegateOptInPhone;
        @AuraEnabled
        public Boolean delegateOptInDirectEmail;

        public Patient_Delegate_Enrollment__c convertToPDE() {
            Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
            pde.Id = pdeId;
            pde.Study_Email_Consent__c = delegateOptInEmail;
            pde.Study_SMS_Consent__c = delegateOptInSMSText;
            pde.Study_Phone_Consent__c = delegateOptInPhone;
            pde.Study_Direct_Mail_Consent__c = delegateOptInDirectEmail;

            //IF SMS opt out, revert the welcome message flag at PDE.
            if (!pde.Study_SMS_Consent__c) {
                pde.Welcome_Message_Sent__c = false;
                pde.Welcome_Message_Delivered__c = false;
            }
            return pde;
        }
    }
    public class ConsentPreferenceContactDataWrapper {
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public Boolean contactOptInEmail;
        @AuraEnabled
        public Boolean contactOptInSMSText;
        @AuraEnabled
        public Boolean contactOptInPhone;
        @AuraEnabled
        public Boolean contactOptInDirectEmail;
        @AuraEnabled
        public Boolean participantLoogedIn;
        @AuraEnabled
        public Boolean isAdultParticipant;
        @AuraEnabled
        public Boolean isEmailAvailabelForParticipant;
        @AuraEnabled
        public Boolean isDelegateSelfView;
        @AuraEnabled
        public Boolean contactStorageOptIn;

        public Contact convertToCont() {
            Contact cont = new Contact();
            cont.Id = contactId;
            cont.Participant_Opt_In_Status_Emails__c = contactOptInEmail;
            cont.Participant_Opt_In_Status_SMS__c = contactOptInSMSText;
            cont.Participant_Phone_Opt_In_Permit_Phone__c = contactOptInPhone;
            cont.IQVIA_Direct_Mail_Consent__c = contactOptInDirectEmail;
            if (contactStorageOptIn != null) {
                cont.IQVIA_Contact_info_storage_consent__c = contactStorageOptIn;
            }
            //IF SMS opt out, revert the welcome message flag at contact.
            if (!cont.Participant_Opt_In_Status_SMS__c) {
                cont.Welcome_Message_Sent__c = false;
                cont.Welcome_Message_Delivered__c = false;
            }
            return cont;
        }
    }

     /**
     * @description: This Method will opt out Study/Delegate/Platfrom level SMS if MobilePhone is deleted from PP2.0.
     * @author: Krishna Mahto
     * @param: contactId
     * @return:
     **/
    public static void optOutSMSWhenMobileIsDeletedforPPLite(
        Id contactId
    ) {
        //Get PERList
        list<Participant_Enrollment__c> PERList = [SELECT Id, 
                                                            Permit_SMS_Text_for_this_study__c,
                                                            Welcome_Message_Sent__c,
                                                            Welcome_Message_Delivered__c
        
                                                    FROM Participant_Enrollment__c 
                                                    WHERE Participant_Contact__c = :contactId
                                                    AND Permit_SMS_Text_for_this_study__c = true
                                                    ];
        //Get PDEList
        list<Patient_Delegate_Enrollment__c> PDEList = [SELECT Id, 
                                                                Study_SMS_Consent__c,
                                                                Welcome_Message_Sent__c,
                                                                Welcome_Message_Delivered__c
                                                        FROM Patient_Delegate_Enrollment__c 
                                                        WHERE Patient_Delegate__r.Contact__c = :contactId
                                                        AND Study_SMS_Consent__c =  true
                                                        ];
        optOutSMSWhenMobileIsDeleted(PERList, PDEList, contactId);

    }
    /**
     * @description: This Method will opt out Study/Delegate/Platfrom level SMS if MobilePhone is deleted.
     * @author: Krishna Mahto
     * @param: perIdsSet
     * @param: pdeIdsSet
     * @param: contactId
     * @return:
     **/
    public static void optOutSMSWhenMobileIsDeleted(
        List<Participant_Enrollment__c> perToUpdate,
        List<Patient_Delegate_Enrollment__c> pdeToUpdate,
        Id contactId
    ) {
        //Opt out Platform level SMS and Revert welcome message flags.
        // if (contactToUpdate != null && !contactToUpdate.isEmpty()) {
        if (contactId != null) {
            Contact contactToUpdate = optOutPlatFormLevelSMS(contactId);
            update contactToUpdate;
        }
        //Opt out Study level SMS and Revert welcome message flags.
        if (perToUpdate != null && !perToUpdate.isEmpty()) {
            optOutStudyLevelSMS(perToUpdate);
            update perToUpdate;
        }
        if (pdeToUpdate != null && !pdeToUpdate.isEmpty()) {
            optOutDelegateStudySMS(pdeToUpdate);
            update pdeToUpdate;
        }
    }
    /**
     * @description: This Method will prepare data to opt out Platfrom level SMS.
     * @author: Krishna Mahto
     * @param: perIdsSet
     * @param: contactId
     * @return:
     **/
    public static Contact optOutPlatFormLevelSMS(Id contactId) {
        Contact contToUpdate = new Contact();
        contToUpdate.Id = contactId;
        contToUpdate.Participant_Opt_In_Status_SMS__c = false;
        contToUpdate.Welcome_Message_Sent__c = false;
        contToUpdate.Welcome_Message_Delivered__c = false;

        return contToUpdate;
    }
    /**
     * @description: This Method will prepare data to opt out Study level SMS
     * @author: Krishna Mahto
     * @param: perIdsSet
     * @param: contactId
     * @return:
     **/
    public static List<Participant_Enrollment__c> optOutStudyLevelSMS(
        List<Participant_Enrollment__c> perToUpdate
    ) {
        List<Id> perIdList = new List<Id>();
        for (Participant_Enrollment__c per : perToUpdate) {
            perIdList.Add(per.Id);
            per.Id = per.Id;
            per.Permit_SMS_Text_for_this_study__c = false;
            per.Welcome_Message_Sent__c = false;
            per.Welcome_Message_Delivered__c = false;
        }
        //Revert Study level Welcome message flags for Patient Delegates also.
        return perToUpdate;
    }
    /**
     * @description: This Method will prepare data to opt out Delegate Study SMS
     * @author: Faizaan Baig
     * @param: pdeIdsSet
     * @param: contactId
     * @return:
     **/
    public static List<Patient_Delegate_Enrollment__c> optOutDelegateStudySMS(
        List<Patient_Delegate_Enrollment__c> pdeToUpdate
    ) {
        List<Id> pdeIdList = new List<Id>();
        for (Patient_Delegate_Enrollment__c pde : pdeToUpdate) {
            pdeIdList.Add(pde.Id);
            pde.Id = pde.Id;
            pde.Study_SMS_Consent__c = false;
            pde.Welcome_Message_Sent__c = false;
            pde.Welcome_Message_Delivered__c = false;
        }
        return pdeToUpdate;
    }

    /**
     * @description: This Method will get the contact record of Minor/Adult
     *               without email Participant of Primary Delegate.
     * @author: Krishna Mahto
     * @param: perIdsSet
     * @param: contactId
     * @return:
     **/
    public static List<Contact> getConOfMinorOfAdultWithoutEmailPar(Id contactId) {
        List<Contact> contactToUpdate = new List<Contact>();
        //check if Primary Delegate has any Minor Participant or Adult Participant without email.
        List<Patient_Delegate_Enrollment__c> PDEnrollmentList = PatientDelegateEnrollmentService.getPDForMinorOrAdultWithoutEmailPar(
            contactId
        );
        //Opt out Platfrom level SMS for Participants also.
        for (Patient_Delegate_Enrollment__c pd : PDEnrollmentList) {
            minorOrAdultWithNoEmailParIdSet.add(pd.Participant_Enrollment__r.Participant__c);
            Contact cont = optOutPlatFormLevelSMS(
                pd.Participant_Enrollment__r.Participant__r.Contact__c
            );
            contactToUpdate.Add(cont);
        }
        return contactToUpdate;
    }
}