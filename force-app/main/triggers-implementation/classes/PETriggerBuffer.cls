/**
 * Created by Leonid Bartenev
 *
 *
 *  Used in PE Trigger Handlers to get lookup objects data and keep SOQL limits
 */

public without sharing class PETriggerBuffer {
    
    private static Map<Id, SObject> buffer = new Map<Id, SObject>();
    
    public static SObject getSObject(Id sObjectId){
        SObject sobj = buffer.get(sObjectId);
        if(sobj == null) {
            updateBuffer();
            sobj = buffer.get(sObjectId);
        }
        return sobj;
    }
    
    private static void updateBuffer(){
        List<Participant_Enrollment__c> newList = Trigger.new;
        List<Id> ssIds = new List<Id>();
        List<Id> hcpeIds = new List<Id>();
        List<Id> participantIds = new List<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (pe.Study_Site__c != null) ssIds.add(pe.Study_Site__c);
            if (pe.HCP__c != null) hcpeIds.add(pe.HCP__c);
            if (pe.Participant__c != null) participantIds.add(pe.Participant__c);
        }
        buffer.putAll([
                SELECT Id, Principal_Investigator__c,
                        Principal_Investigator__r.Name,
                        Principal_Investigator__r.Full_Name__c,
                        Principal_Investigator__r.Phone,
                        Suppress_Participant_Emails__c,
                        Clinical_Trial_Profile__c,
                        Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Clinical_Trial_Profile__r.Shareback_Settings_On_Participant_Level__c,
                        Clinical_Trial_Profile__r.Visit_Data_Shareback__c,
                        Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                        Clinical_Trial_Profile__r.NCT_Number__c,
                        Clinical_Trial_Profile__r.CommunityTemplate__c
                FROM Study_Site__c
                WHERE Id IN:ssIds
        ]);
        buffer.putAll([
                SELECT Id, HCP_Contact__c
                FROM HCP_Enrollment__c
                WHERE Id IN:hcpeIds
        ]);
        buffer.putAll([
                SELECT Id,
                        Contact__c,
                        Full_Name__c,
                        Adult__c,
                        Contact__r.Visit_Results_Opt_In__c,
                        Name,
                        IsCountry_NOT_Eligible_for_Emails__c,
                        Emancipation_in_progress__c
                FROM Participant__c
                WHERE Id IN:participantIds
        ]);
    }

}