/**
 * Created by Anshuman Mishra on 8/12/2020.
 */

global without sharing class EmailTemplatePendingPartController {
    global Id sourceIdValue { get; set; }
    global List<ParticipantInfoWrapper> participants {
        get {
            List<ParticipantInfoWrapper> delegateStudyNames = new List<ParticipantInfoWrapper>();
             List<ParticipantInfoWrapper> passParticipantDelegate = new List<ParticipantInfoWrapper>();
            if (
                sourceIdValue != null &&
                sourceIdValue.getSobjectType() == Contact.getSObjectType()
            ) {
                List<User> user = [
                    SELECT Id, timezonesidkey, Contact.UserCommunityIsDelegate__c
                    FROM User
                    WHERE ContactId = :sourceIdValue
                ];
                Integer size = 0;
                if (user.size() > 0) {
                    List<Id> studySites = new List<Id>();

                    for (Site_Staff__c ss : [
                        SELECT Study_Site__c, is_Invited__c
                        FROM Site_Staff__c
                        WHERE
                            Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1
                            AND is_Invited__c = TRUE
                            AND Site_Contact__c = :sourceIdValue
                            AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = FALSE
                            AND Study_Site__r.Override_PI_Referral_Status__c IN ('Accepted','Accepted (Admin)')
                    ]) {
                        studySites.add(ss.Study_Site__c);
                    }

                    for (Participant_Enrollment__c pe : [
                        SELECT
                            Name,
                            Clinical_Trial_Profile__r.Study_Code_Name__c,
                            Participant_Status_Last_Changed_Date__c,
                        	High_Priority__c,Re_consent__c
                        FROM Participant_Enrollment__c
                        WHERE
                            (Participant_Status__c = 'Received' OR 
                             (Participant_Status__c IN ('Contact Attempted','Pre-review Passed','Successfully Contacted','Successfully re-engaged')
                              AND High_Priority__c = true) OR Re_consent__c = true
                            )
                            AND (Study_Site__c IN :studySites
                            OR PI_Contact__c = :sourceIdValue)
                            AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = FALSE 
                            AND Study_Site__r.Override_PI_Referral_Status__c IN ('Accepted','Accepted (Admin)')
                            ORDER BY High_Priority__c DESC NULLS LAST
                            LIMIT 10
                    ]) {
                            delegateStudyNames.add(
                                new ParticipantInfoWrapper(
                                    pe.Name,
                                    pe.Clinical_Trial_Profile__r.Study_Code_Name__c,
                                    pe.Participant_Status_Last_Changed_Date__c,
                                    user[0].timezonesidkey,
                                    pe.High_Priority__c,
                                    pe.Re_consent__c
                                )
                            );	
                    }
                }
            }
            return delegateStudyNames;
        }
        set;
    }

    global class ParticipantInfoWrapper implements Comparable {
        global String refId { get; set; }
        global String studyName { get; set; }
        global String lastRecievedDate { get; set; }
        global String yesNoPriority { get; set; }
        global boolean highPriorityReconsent { get; set; }
        global String highPriority { get; set; }
        global String reConsent { get; set; }
        
        public ParticipantInfoWrapper() {
        }

        public ParticipantInfoWrapper(
            String Name,
            String studyCodeName,
            DateTime lastRecievedDate,
            String timezonesidkey,
            boolean highPriorityFlag,
            boolean reConsentRequiredFlag
        ) {
            this.refId = Name;
            this.studyName = studyCodeName;
            Datetime gmt = Datetime.newInstance(
                lastRecievedDate.yearGmt(),
                lastRecievedDate.monthGmt(),
                lastRecievedDate.dayGmt(),
                lastRecievedDate.hourGmt(),
                lastRecievedDate.minuteGmt(),
                lastRecievedDate.secondGmt()
            );
            this.lastRecievedDate = gmt.format('yyyy-MM-dd', timezonesidkey);
			this.yesNoPriority = yesNoPriority;
            this.highPriorityReconsent = false;
            this.highPriority = 'High Priority';   
			if(highPriorityFlag == true && reConsentRequiredFlag == false ){
                this.yesNoPriority = 'High Priority';
            }else if(reConsentRequiredFlag == true && highPriorityFlag == false){
                this.yesNoPriority = 'Consent Required';
            }else if(highPriorityFlag == true && reConsentRequiredFlag == true){
                this.highPriorityReconsent = true;
                this.highPriority = 'High Priority';   
                this.reConsent = 'Consent Required';
            }else{
                this.yesNoPriority = '';
            }
        }
        global Integer compareTo(Object compareTo) {
            if (studyName > ((ParticipantInfoWrapper) compareTo).studyName) {
                return 1;
            } else if (studyName < ((ParticipantInfoWrapper) compareTo).studyName) {
                return -1;
            }
            return 0;
        }
    }
}