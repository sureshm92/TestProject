/*
------One Time data correction batch Jira RH - 6394------
Purpose of this batch is to update the existing Study Sites PI Status field value from "Invitation Sent" to "Accepted" 
if the associated PI has already accepted the Terms and condition on Study
*/

global class Batch_UpdateStudySitePiStatus implements Database.Batchable<SObject>, Database.Stateful {
    global List<String> exception_List = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Clinical_Trial_Profile__c, Override_PI_Referral_Status__c, Principal_Investigator__c, Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c, Clinical_Trial_Profile__r.CommunityTemplate__c FROM Study_Site__c WHERE Override_PI_Referral_Status__c = \'Invitation Sent\' AND Principal_Investigator__c!=null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Study_Site__c> ssList) {
        Set<String> termsSet = new Set<String>();
        Set<String> piSet = new Set<String>();
        Map<String, Set<String>> piTcCommunityMap = new Map<String, Set<String>>();
        
        
        for (Study_Site__c ss : ssList) {
            if(ss.Clinical_Trial_Profile__r != null && ss.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c != null){
                termsSet.add(ss.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c);
            }
            piSet.add(ss.Principal_Investigator__c);
        } 
        
        Set<String> piAndTcCombination = new Set<String>();
        List<Terms_And_Conditions_Acceptance__c> tcAccept = [SELECT Id, User__r.ContactId, Terms_And_Conditions__c, Accepted_Date__c, Terms_And_Conditions__r.Active__c, Terms_And_Conditions__r.Community_Name__c
                                                             FROM Terms_And_Conditions_Acceptance__c WHERE Accepted_Date__c != null AND User__r.ContactId IN :piSet ];
        
        for (Terms_And_Conditions_Acceptance__c tc : tcAccept) {
            piAndTcCombination.add((String.valueOf(tc.User__r.ContactId)) + (String.valueOf(tc.Terms_And_Conditions__c)));
            if(tc.Terms_And_Conditions__r.Active__c){
                if (!piTcCommunityMap.containsKey(tc.User__r.contactId)) {
                    piTcCommunityMap.put(tc.User__r.contactId, new Set<String>());
                }
                piTcCommunityMap.get(tc.User__r.contactId).add(tc.Terms_And_Conditions__r.Community_Name__c);
            }
            
        }
        
        List<Study_Site__c> ssToUpdate = new List<Study_Site__c>();
        
        for (Study_Site__c site : ssList) {
            String combination = (String.valueOf(site.Principal_Investigator__c) + String.valueOf(site.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c));
            if(site.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c!=null){
                if (piAndTcCombination.contains(combination)) {
                    site.Override_PI_Referral_Status__c = 'Accepted';
                    ssToUpdate.add(site);
                }
            } else if (site.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c == null && piTcCommunityMap.containsKey(site.Principal_Investigator__c)) {
                boolean acceptedForJanssen = piTcCommunityMap.get(site.Principal_Investigator__c).contains('Janssen Community');
                boolean acceptedForRefralHub = piTcCommunityMap.get(site.Principal_Investigator__c).contains('IQVIA Referral Hub');
                
                if (site.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen' && acceptedForJanssen) {
                    ssToUpdate.add(new Study_Site__c(Id = site.Id, Override_PI_Referral_Status__c = 'Accepted'));
                } else if (site.Clinical_Trial_Profile__r.CommunityTemplate__c != 'Janssen' && acceptedForRefralHub) {
                    ssToUpdate.add(new Study_Site__c(Id = site.Id, Override_PI_Referral_Status__c = 'Accepted'));
                }
            }
            
        }
        
        if (!ssToUpdate.isEmpty()) {
             try {
            TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.StudySiteTriggerHandler.class);
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.UpdateStudySitePiStatus.class);
                 Database.SaveResult[] SaveResultList = Database.update(ssToUpdate,false);
                 for(integer i =0; i<SaveResultList.size();i++){
                     String msg='';
                     If(!SaveResultList[i].isSuccess()){
                         for(Database.Error err: SaveResultList[i].getErrors()){  
                             msg += err.getmessage()+'"\n\n';
                         } 
                     }
                     if(msg!='')
                         exception_List.add(msg);
                 }
             }catch (Exception e) {
                  system.debug('errors are '+exception_List);
             }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
         
    }

}