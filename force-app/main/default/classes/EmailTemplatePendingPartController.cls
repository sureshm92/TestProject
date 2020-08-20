/**
 * Created by Anshuman Mishra on 8/12/2020.
 */

global without sharing class EmailTemplatePendingPartController {

    global Id sourceIdValue { get; set; }
    global 	List<ParticipantInfoWrapper> participants { 
        get{
            List<ParticipantInfoWrapper> delegateStudyNames = new List<ParticipantInfoWrapper>();
            if(sourceIdValue != null && sourceIdValue.getSobjectType() == Contact.getSObjectType()) {
                List<User> user = [SELECT Id,timezonesidkey,Contact.UserCommunityIsDelegate__c FROM User WHERE ContactId=:sourceIdValue];
                
                if(user.size()>0){
                    List<Id> studySites = new List<Id>();
                    if(user[0].Contact.UserCommunityIsDelegate__c){
                    for(Site_Staff__c ss : [SELECT Study_Site__c FROM Site_Staff__c 
                                          WHERE Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1 
                                          AND Site_Contact__c =:sourceIdValue]){
                                              studySites.add(ss.Study_Site__c);
                                          }
                    }
                for(Participant_Enrollment__c pe:[SELECT Name,Clinical_Trial_Profile__r.Study_Code_Name__c,
                                                  Participant_Status_Last_Changed_Date__c FROM Participant_Enrollment__c
                                                  WHERE Participant_Status__c = 'Received' 
                                                  AND (Study_Site__c IN:studySites OR PI_Contact__c =: sourceIdValue)
                                                  AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = false]){                                   
                   delegateStudyNames.add(new ParticipantInfoWrapper(pe.Name,pe.Clinical_Trial_Profile__r.Study_Code_Name__c,pe.Participant_Status_Last_Changed_Date__c,user[0].timezonesidkey));
                   }
                }
            }
            return delegateStudyNames;
        }
        set;
    }
    
    global class ParticipantInfoWrapper implements Comparable {
        
        global String refId {get; set;}
        global String studyName {get; set;}
        global String lastRecievedDate {get; set;}
        
        public ParticipantInfoWrapper() {}
        
        public ParticipantInfoWrapper(String Name, String studyCodeName, DateTime lastRecievedDate, String timezonesidkey) {
            this.refId = Name;
            this.studyName = studyCodeName;
            //this.lastRecievedDate = lastRecievedDate.yearGmt()+'-'+lastRecievedDate.monthGmt()+'-'+lastRecievedDate.dayGmt();//String.valueOfGmt(lastRecievedDate);
            Datetime gmt = Datetime.newInstance(lastRecievedDate.yearGmt(), lastRecievedDate.monthGmt(),
                                                lastRecievedDate.dayGmt(), lastRecievedDate.hourGmt(),
                                                lastRecievedDate.minuteGmt(), lastRecievedDate.secondGmt());
            this.lastRecievedDate = gmt.format('yyyy-MM-dd',timezonesidkey); 
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