public without sharing class PreferenceManagementController {
    public class Study {
        public string study_name { get; set; }
        public string study_id { get; set; }
        public string sponsor_id { get; set; }
        public boolean phone { get; set; }
        public boolean email { get; set; }
        public boolean sms { get; set; }
        public boolean dmail { get; set; }
        public boolean all { get; set; }
    }
    public class Outreach {
        public string name { get; set; }
        public string iqvia_id { get; set; }
        public boolean phone { get; set; }
        public boolean email { get; set; }
        public boolean sms { get; set; }
        public boolean dmail { get; set; }
        public boolean all { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static String getStudiesConsent() {
        List<Study> studies = new List<Study>();

        Study study = new Study();
        study.study_name = 'Test Study Name';
        study.study_id = 'bldjaf173683a';
        study.sponsor_id = '2';
        study.phone = false;
        study.email = false;
        study.sms = true;
        study.dmail = false;
        study.all = false;

        Study study1 = new Study();
        study1.study_name = 'Janson Study';
        study1.study_id = 'a03809438025b';
        study1.sponsor_id = '2';
        study1.phone = true;
        study1.email = false;
        study1.sms = false;
        study1.dmail = true;
        study1.all = false;

        Study study2 = new Study();
        study2.study_name = 'GSK Study';
        study2.study_id = 'a0380943sdf8025c';
        study2.sponsor_id = '3';
        study2.phone = true;
        study2.email = false;
        study2.sms = false;
        study2.dmail = false;
        study2.all = false;

        studies.add(study);
        studies.add(study1);
        studies.add(study2);

        String studyData = JSON.serialize(studies);

        Integer start = System.Now().millisecond();
        while (System.Now().millisecond() < start + 3000) {
            return studyData;
        }
        return '';
    }

    @AuraEnabled(cacheable=true)
    public static String getOutreachConsent() {
        List<Outreach> outreach = new List<Outreach>();

        Outreach outreachObj = new Outreach();
        outreachObj.name = 'General Communication';
        outreachObj.iqvia_id = 'bldgsdfjaf173683A';
        outreachObj.phone = true;
        outreachObj.email = true;
        outreachObj.sms = true;
        outreachObj.dmail = true;
        outreachObj.all = true;

        outreach.add(outreachObj);
        String outreachData = JSON.serialize(outreach);
        return outreachData;
    }

    @AuraEnabled
    //public static void saveConsent(Object studyData, Object outReachData) {
    public static void saveConsent(String studyDataJSON, Object outReachData) {
        System.debug('Study Data: ' + studyDataJSON);
        System.debug(outReachData);
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
                processSMSOptOutForDelegate(consentData.perId, consentData.ParticipantContId);
            }
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

            //Backend field population logic.
            //TODO: if RH implemented trigger then remove this.
            if (per.Permit_Voice_Text_contact_for_this_study__c) {
                per.Study_Assisted_Dialing_Consent__c = true;
                per.Study_Artificial_Voice_Consent__c = true;
                per.Study_Pre_recorded_Voice_Consent__c = true;
            } else {
                per.Study_Assisted_Dialing_Consent__c = false;
                per.Study_Artificial_Voice_Consent__c = false;
                per.Study_Pre_recorded_Voice_Consent__c = false;
            }
            //IF SMS opt out, revert the welcome message flag at PER.
            if (!per.Permit_SMS_Text_for_this_study__c) {
                per.Welcome_Message_Sent__c = false;
                per.Welcome_Message_Delivered__c = false;
            }
            return per;
        }
    }
    /**
     * @description: This Method will set the consent Preference data to the static variables.
     * @author: Krishna Mahto
     * @param: perList
     * @return:
     **/
    @AuraEnabled
    public static Void processSMSOptOutForDelegate(Id perId, Id ParticipantContId) {
        Set<Id> delContactIdSet = new Set<Id>();
        List<Id> perIdList = new List<Id>{ perId };
        //Get Patient Delegate for the logged in Participant.
        List<Patient_Delegate__c> pdLest = PatientDelegateService.getPDelegates(ParticipantContId);
        for (Patient_Delegate__c pd : pdLest) {
            delContactIdSet.Add(pd.Contact__c);
        }

        //Get list of ParticipantEnrollmentPatientDelJunction records
        List<ParticipantEnrollmentPatientDelJunction__c> perDelJunctionRecList = Action_SendSMS.getPERPatientDelJunctionRecords(
            perIdList,
            delContactIdSet
        );
        for (ParticipantEnrollmentPatientDelJunction__c pdJunObj : perDelJunctionRecList) {
            pdJunObj.Welcome_Message_Sent__c = false;
            pdJunObj.Welcome_Message_Delivered__c = false;
        }

        if (perDelJunctionRecList != null && !perDelJunctionRecList.isEmpty()) {
            update perDelJunctionRecList;
        }
    }
}
