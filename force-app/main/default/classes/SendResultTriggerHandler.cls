/**
* Created by Anitha Chavva on 27.04.2022
*/

public without sharing class SendResultTriggerHandler {
    
    // Handlers: -------------------------------------------------------------------------------------------------------
    
    public class updatewelcomeMsgflagsHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            updatewelcomeMsgflags(newList, null); 
        }
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
			updatewelcomeMsgflags(newList, (Map<Id, Send_Result__c>) oldMap); 
        }
    }
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void updatewelcomeMsgflags(
        List<Send_Result__c> newList,
        Map<Id, Send_Result__c> oldMap
    ) {
        Map<Id,Send_Result__c> sendresultmap = new Map<Id,Send_Result__c>();
        Set<Id> perids = new Set<Id>();
        Set<Id> conids = new Set<Id>();
        List<Participant_Enrollment__c> perrecrdslst = new List<Participant_Enrollment__c>();
        List<Contact> conrecrdslst = new List<Contact>(); 
        Map<Id,Notification__c> objidslst = new Map<Id,Notification__c>();
        for (Send_Result__c ss : newList){
            if((oldMap == null && !String.isBlank(ss.Msg_Id__c)) || (oldMap != null && ss.Msg_Id__c != oldMap.get(ss.Id).Msg_Id__c)){
                sendresultmap.put(ss.Notification__c, ss);
            }
        }
        if(sendresultmap.size()>0){
            Map<Id,Notification__c> notificationmap = new Map<Id,Notification__c>([Select Id,WhatId__c,Notification_Type__c, Recipient__c From Notification__c where ID IN: sendresultmap.keyset()]);
            if(notificationmap.size()>0){
                for (Id ss : notificationmap.keyset()){
                    if(NotificationService.welcomemsgNoticationtypes.Contains(notificationmap.get(ss).Notification_Type__c)){
                        Id whatId = Id.valueOf(notificationmap.get(ss).WhatId__c);
                        Id recipientId = Id.valueOf(notificationmap.get(ss).Recipient__c);
                        if(String.valueOf(whatId.getSobjectType()) == 'Participant_Enrollment__c'){
                            perids.add(whatId);    
                        }
                        else if(String.valueOf(whatId.getSobjectType()) == 'Participant__c'){
                            conids.add(recipientId);    
                            
                        }  
                    }
                }
            }
            if(perids.size()>0){
                List<Participant_Enrollment__c> perlist = [Select Id,Welcome_Message_Sent__c From Participant_Enrollment__c where ID IN : perids];
                for(Participant_Enrollment__c ps : perlist){
                    if(!ps.Welcome_Message_Sent__c){
                        ps.Welcome_Message_Sent__c = true;
                        perrecrdslst.add(ps);
                    }
                }
            }
            if(conids.size()>0){
                List<Contact> conlist = [Select Id,Welcome_Message_Sent__c From Contact where ID IN : conids];
                for(Contact con : conlist){
                    if(!con.Welcome_Message_Sent__c){
                        con.Welcome_Message_Sent__c = true;
                        conrecrdslst.add(con);
                    }
                }
            }
            if(perrecrdslst.size()>0) update perrecrdslst;
            if(conrecrdslst.size()>0) update conrecrdslst;
        }
    }
}