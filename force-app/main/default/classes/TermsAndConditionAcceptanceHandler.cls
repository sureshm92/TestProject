/*
 Purpose of this handler is to update the PI Status field value from "Invitation Sent" to "Accepted" on Site
 if the associated PI accepted the Terms and Condition on Study.
*/
public without sharing class TermsAndConditionAcceptanceHandler {
    
    // Handlers: -------------------------------------------------------------------------------------------------------

    public class UpdateStudySitePIStatus extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            handleAcceptance(newList);
        }
    }
    
   // Logic: ----------------------------------------------------------------------------------------------------------

    public static void handleAcceptance(List<Terms_And_Conditions_Acceptance__c> acceptanceList) {
        Map<String, Set<String>> piAndTcMap = new Map<String, Set<String>>();
        List<Study_Site__c> ssToUpdate = new List<Study_Site__c>();
        List<Terms_And_Conditions_Acceptance__c> tcAcceptaceList = [Select Id,Accepted_Date__c,User__c,User__r.ContactId,Terms_And_Conditions__c from Terms_And_Conditions_Acceptance__c where Accepted_Date__c!=null And User__c!=null And Terms_And_Conditions__c!=null And Id In:acceptanceList ];
        for (Terms_And_Conditions_Acceptance__c tc : tcAcceptaceList) {
                String contactId = tc.User__r.ContactId;
                String termsAndConditionsId = tc.Terms_And_Conditions__c;
                if (!piAndTcMap.containsKey(contactId)) {
                    piAndTcMap.put(contactId, new Set<String>());
                }
                piAndTcMap.get(contactId).add(termsAndConditionsId);
            
        }

        List<Study_Site__c> studySites = [SELECT Id, Override_PI_Referral_Status__c, Principal_Investigator__c, Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c
                                          FROM Study_Site__c
                                          WHERE Override_PI_Referral_Status__c = 'Invitation Sent' AND Principal_Investigator__c IN :piAndTcMap.keySet()];

        for (Study_Site__c site : studySites) {
            String contactId = site.Principal_Investigator__c;
            String termsAndConditionsId = site.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c;

            if (piAndTcMap.containsKey(contactId) && piAndTcMap.get(contactId).contains(termsAndConditionsId)) {
                site.Override_PI_Referral_Status__c = 'Accepted';
                ssToUpdate.add(site);
            }
        }
        if (!ssToUpdate.isEmpty()) {
             TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.StudySiteTriggerHandler.class);
            update ssToUpdate;
        }
    }
}