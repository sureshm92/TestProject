global without sharing class Batch_SendBellNotificationBell implements Database.Batchable<sObject>, Database.Stateful {
	global List<String> lstOfStatus = new List<String>{'Received', 'Contact Attempted', 'Pre-review Passed', 'Successfully Contacted', 'Successfully re-engaged'};    
    global Map<String, Set<String>> mapOfSiteVsContact = new Map<String, Set<String>>();
    global Map<String, Set<String>> mapOfCommVsContact = new Map<String, Set<String>>();    
    global Map<String, String> mapOfCommTemp = new Map<String, String>();
    global Map<String, String> mapOfSiteVsStudy = new Map<String, String>();

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Participant_Status__c, High_Priority__c, Clinical_Trial_Profile__c, Study_Site__c, Clinical_Trial_Profile__r.CommunityTemplate__c, Clinical_Trial_Profile__r.Bell_Notification_Reminder__c, '+
                       ' (SELECT Id, Name, Status__c, CreatedDate FROM Participant_Enrollment_Status_History__r ORDER BY Name DESC LIMIT 1) '+
                       ' FROM Participant_Enrollment__c WHERE Participant_Status__c IN (\'Received\',\'Contact Attempted\', \'Pre-review Passed\', \'Successfully Contacted\', \'Successfully re-engaged\')'+
                       ' AND Study_Site__r.Override_PI_Referral_Status__c IN (\'Accepted\', \'Accepted (Admin)\', \'On Hold\') AND Initial_visit_scheduled_flag__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> peList){    
        for(Participant_Enrollment__c eachRec : peList){
            for(Participant_Enrollment_Status_History__c eachStatus : eachRec.Participant_Enrollment_Status_History__r){
                if(lstOfStatus.contains(eachStatus.Status__c) && eachRec.Participant_Status__c == eachStatus.Status__c){
                    Integer noOfDays = eachStatus.createdDate.Date().daysBetween(System.today());
                    if(eachRec.Clinical_Trial_Profile__r.Bell_Notification_Reminder__c != null && noOfDays >= eachRec.Clinical_Trial_Profile__r.Bell_Notification_Reminder__c){                        
                        mapOfCommTemp.put(eachRec.Clinical_Trial_Profile__c, eachRec.Clinical_Trial_Profile__r.CommunityTemplate__c);
                        mapOfSiteVsStudy.put(eachRec.Study_Site__c, eachRec.Clinical_Trial_Profile__c);
                    }
                }
            }
        }    
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('mapOfCommTemp=='+mapOfCommTemp);
        System.debug('mapOfSiteVsStudy=='+mapOfSiteVsStudy);
        List<Notification__c> allNotificationList = new List<Notification__c>();
        mapOfSiteVsContact = BellNotificationsHelper.getContactForSites(mapOfSiteVsStudy.keySet());

        System.debug('mapOfSiteVsContact=='+mapOfSiteVsContact);
        for(String eachRec : mapOfSiteVsContact.keySet()){
            if(mapOfSiteVsStudy.containsKey(eachRec) && mapOfCommTemp.containsKey(mapOfSiteVsStudy.get(eachRec))){
                for(String eachContact : mapOfSiteVsContact.get(eachRec)){
                    if(!mapOfCommVsContact.containsKey(mapOfCommTemp.get(mapOfSiteVsStudy.get(eachRec)))){
                        mapOfCommVsContact.put(mapOfCommTemp.get(mapOfSiteVsStudy.get(eachRec)), new Set<String>{});
                    }
                    mapOfCommVsContact.get(mapOfCommTemp.get(mapOfSiteVsStudy.get(eachRec))).add(eachContact);
                }                
            }
        }

        System.debug('mapOfCommVsContact=='+mapOfCommVsContact);
        for(String eachRec : mapOfCommVsContact.keySet()){
            for(String eachCon : mapOfCommVsContact.get(eachRec)){
                Notification__c notificationRec = BellNotificationsHelper.createNotification('BELL_Message_on_Pending_Action', eachCon, 'PI', eachRec, false);  
                allNotificationList.add(notificationRec);
            }            
        }        

        System.debug('allNotificationList=='+allNotificationList);
        if(allNotificationList.size() > 0 && allNotificationList.size() <= 8000){
            insert allNotificationList;
            Id jobId = System.enqueueJob(new BellNotificationQueueable(allNotificationList));
        }else if(allNotificationList.size() > 0 && allNotificationList.size() > 8000){
            Batch_NotificationInsertion notifyBatch = new Batch_NotificationInsertion(allNotificationList);
            Database.executeBatch(notifyBatch);
        }
    }
}