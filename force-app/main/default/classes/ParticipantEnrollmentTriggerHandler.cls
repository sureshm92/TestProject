/**
 * Created by D.Yasinskyi on 26.04.2018
 * Refactored by L.Bartenev
 */

public without sharing class ParticipantEnrollmentTriggerHandler {
    
    private Map<Id, Participant_Enrollment__c> oldMap;
    private Map<Id, Participant_Enrollment__c> newMap;
    private List<Participant_Enrollment__c> oldList;
    private List<Participant_Enrollment__c> newList;
    
    private Map<Id, Study_Site__c> ssMap;
    private Map<Id, HCP_Enrollment__c> hcpeMap;
    private Map<Id, Participant__c> participantMap;
    
    public ParticipantEnrollmentTriggerHandler(){
        oldList = (List<Participant_Enrollment__c>)Trigger.old;
        newList= (List<Participant_Enrollment__c>)Trigger.new;
    
        List<Id> ssIds = new List<Id>();
        List<Id> hcpeIds = new List<Id>();
        List<Id> participantIds = new List<Id>();
        for(Participant_Enrollment__c pe : newList){
            if(pe.Study_Site__c != null) ssIds.add(pe.Study_Site__c);
            if(pe.HCP__c != null) hcpeIds.add(pe.HCP__c);
            if(pe.Participant__c != null) participantIds.add(pe.Participant__c);
        }
        ssMap = new Map<Id, Study_Site__c>([
                SELECT Id, Principal_Investigator__c,
                        Suppress_Participant_Emails__c,
                        Clinical_Trial_Profile__c,
                        Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Clinical_Trial_Profile__r.NCT_Number__c
                FROM Study_Site__c
                WHERE Id IN: ssIds
        ]);
        hcpeMap = new Map<Id, HCP_Enrollment__c>([
                SELECT Id, HCP_Contact__c
                FROM HCP_Enrollment__c
                WHERE Id IN: hcpeIds
        ]);
        participantMap = new Map<Id, Participant__c>([
                SELECT Id, Contact__c, Name,
                        IsCountry_NOT_Eligible_for_Emails__c
                FROM Participant__c
                WHERE Id IN: participantIds
        ]);
    
        if(Trigger.isUpdate){
            oldMap = new Map<Id, Participant_Enrollment__c>(oldList);
            newMap = new Map<Id, Participant_Enrollment__c>(newList);
        }
    }
    
    public void handle(){
        if(Trigger.isUpdate || Trigger.isInsert){
            if(Trigger.isBefore){
                prepareAdditionalFields();
            }
            if(Trigger.isAfter){
                createUsersOrSendNotifications();
            }
        }
    }
    
    private void prepareAdditionalFields(){
        for(Participant_Enrollment__c pe : newList){
            String nctNumber;
            String participantName;
            if(pe.Study_Site__c != null){
                Study_Site__c ss = ssMap.get(pe.Study_Site__c);
                if(ss != null) {
                    pe.PI_Contact__c = ss.Principal_Investigator__c;
                    pe.Clinical_Trial_Profile__c = ss.Clinical_Trial_Profile__c;
                    nctNumber = ss.Clinical_Trial_Profile__r.NCT_Number__c;
                }
            }
            if(pe.HCP__c != null){
                HCP_Enrollment__c hcpe = hcpeMap.get(pe.HCP__c);
                if(hcpe != null) pe.HCP_Contact_HCPEnroll__c = hcpe.HCP_Contact__c;
            }
            if(pe.Participant__c != null){
                Participant__c participant = participantMap.get(pe.Participant__c);
                if(participant != null) {
                    pe.Participant_Contact__c = participant.Contact__c;
                    participantName = participant.Name;
                }
            }
            //populate Participant Code
            if(nctNumber != null && participantName != null){
                pe.Participant_Key__c = participantName + ' ' + nctNumber;
            }
            //populate referred date
            if(pe.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI){
                if(Trigger.isInsert || (Trigger.isUpdate && oldMap.get(pe.Id).Participant_Status__c != pe.Participant_Status__c)){
                    pe.Referred_Date__c = Date.today();
                }
            }
        }
    }
    
    private void createUsersOrSendNotifications() {
        Map<Id, Id> toCreateUser = new Map<Id, Id>();
        Map<Id, String> notificationMap = new Map<Id, String>();
        Map<Id, String> notificationMapEmptyHCP = new Map<Id, String>();
        Map<Id, String> toSendNotificationMap = new Map<Id, String>();
        List<Contact> contactsForChangeMode = new List<Contact>();
        
        //get users if exist
        Map<Id, User> usersByContactId = new Map<Id, User>();
        Set<Id> participantContactIds = new Set<Id>();
        for(Participant_Enrollment__c pe : newList) {
            Participant__c participant = participantMap.get(pe.Participant__c);
            if(participant != null && participant.Contact__c != null) participantContactIds.add(participant.Contact__c);
        }
        for (User usr : CommunityService.getCommunityUsersByContactIds(participantContactIds)) usersByContactId.put(usr.ContactId, usr);
        
        //process PE items:
        for(Participant_Enrollment__c newPE : newList){
            Study_Site__c ss = ssMap.get(newPE.Study_Site__c);
            HCP_Enrollment__c hcpe = hcpeMap.get(newPE.HCP__c);
            Participant__c participant = participantMap.get(newPE.Participant__c);
            User participantUser;
            if(participant != null && participant.Contact__c != null) participantUser = usersByContactId.get(participant.Contact__c);
            Boolean updateCriteria = true;
            if(oldMap != null){
                Participant_Enrollment__c oldPE = oldMap.get(newPE.Id);
                updateCriteria = oldPE.Participant_Status__c != newPE.Participant_Status__c ||
                        oldPE.Participant__c != newPE.Participant__c || participantUser == null;
                System.debug('OLD STATUS: ' +  oldPE.Participant_Status__c);
                System.debug('NEW STATUS: ' +  newPE.Participant_Status__c);
                System.debug('OLD PART ID: ' +  oldPE.Participant__c);
                System.debug('NEW PART ID: ' +  newPE.Participant__c);
                System.debug('PART USER: ' +  participantUser);
            }
            System.debug('UPDATE CRITERIA: ' + updateCriteria);
            if(!updateCriteria) continue;
            Boolean filterCriteria =
                            newPE.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI &&
                            newPE.Participant__c != null &&
                            !newPE.Is_Virtual_Study_Site__c &&
                            ss != null &&
                            ss.Clinical_Trial_Profile__c != null &&
                            !ss.Suppress_Participant_Emails__c &&
                            !ss.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                            participant != null &&
                            !participant.IsCountry_NOT_Eligible_for_Emails__c &&
                            participant.Contact__c != null;
            System.debug('FILTER CRITERIA: ' + filterCriteria);
            if(filterCriteria){
                if(participantUser == null){
                    System.debug('CREATE USER');
                    Id hcpContact;
                    if(hcpe != null) hcpContact = hcpe.HCP_Contact__c;
                    toCreateUser.put(participant.Contact__c, hcpContact);
                }else{
                    System.debug('NOTIFY USER');
                    if(hcpe != null){
                        notificationMap.put(newPE.Id, participant.Contact__c);
                    }else{
                        notificationMapEmptyHCP.put(newPE.Id, participant.Contact__c);
                    }
                }
                contactsForChangeMode.add(new Contact(
                        Id = participant.Contact__c,
                        userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT
                ));
            }
        }
    
        if(toCreateUser.size() > 0) CommunityService.createParticipantUsers(toCreateUser);
        if(notificationMap.size() > 0) SendEmailTemplate.sendEmailNotification(SendEmailTemplate.EMAIL_TEMPLATE_PATIENT1_NEW, notificationMap);
        if(notificationMapEmptyHCP.size() > 0) SendEmailTemplate.sendEmailNotification(SendEmailTemplate.EMAIL_TEMPLATE_PATIENT2_NEW, notificationMapEmptyHCP);
        update contactsForChangeMode;
    }
    
}