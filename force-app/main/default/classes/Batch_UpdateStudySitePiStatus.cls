/*
------One Time data correction batch Jira id RH - 6394------
Purpose of this batch is to update the existing Study Sites PI Status field value from "Invitation Sent" to "Accepted" 
if the associated PI has already accepted the Terms and condition on Study
*/

global class Batch_UpdateStudySitePiStatus implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Terms_And_Conditions_ID__c, (SELECT Id, Override_PI_Referral_Status__c, Principal_Investigator__c,Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c FROM Study_Site_Profiles__r WHERE Override_PI_Referral_Status__c = \'Invitation Sent\' AND Principal_Investigator__c!=null) From Clinical_Trial_Profile__c Where Terms_And_Conditions_ID__c!= null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Clinical_Trial_Profile__c> ctpList) {
        Set<String> termsSet = new Set<String>();
        Set<String> piSet = new Set<String>();
        for(Clinical_Trial_Profile__c  ctp : ctpList){
            if(ctp.Study_Site_Profiles__r!=null && ctp.Study_Site_Profiles__r.size()>0){
                for (Study_Site__c ss : ctp.Study_Site_Profiles__r) {
                    termsSet.add(ss.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c);
                    piSet.add(ss.Principal_Investigator__c);
                }
            }
        } 
        
        Set<String> piAndTcCombination = new Set<String>();
        List<Terms_And_Conditions_Acceptance__c> tcAccept = [SELECT Id, User__r.ContactId, Terms_And_Conditions__c, Accepted_Date__c FROM Terms_And_Conditions_Acceptance__c
                                                             WHERE Accepted_Date__c != null AND Terms_And_Conditions__c IN :termsSet AND User__r.ContactId IN :piSet ];
        
        for (Terms_And_Conditions_Acceptance__c tc : tcAccept) {
            piAndTcCombination.add((String.valueOf(tc.User__r.ContactId)) + (String.valueOf(tc.Terms_And_Conditions__c)));
        }
        
        List<Study_Site__c> ssToUpdate = new List<Study_Site__c>();
        
        for(Clinical_Trial_Profile__c  ctp : ctpList){
            if(ctp.Study_Site_Profiles__r!=null && ctp.Study_Site_Profiles__r.size()>0){
                for (Study_Site__c site : ctp.Study_Site_Profiles__r) {
                    String combination = ((String.valueOf(site.Principal_Investigator__c))+(String.valueOf(site.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c)));
                    system.debug('Combination condition '+combination);
                    if (piAndTcCombination.contains(combination)) {
                        site.Override_PI_Referral_Status__c = 'Accepted';
                        ssToUpdate.add(site);
                    }
                }
            }
        }
        
        if (!ssToUpdate.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.StudySiteTriggerHandler.class);
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.UpdateStudySitePiStatus.class);
            update ssToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}