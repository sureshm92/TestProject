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

    public static void clearBuffer(){
        buffer.clear();
    }

    private static void updateBuffer(){
        System.debug('buffer init');
        List<Participant_Enrollment__c> newList = Trigger.new;
        List<Id> ssIds = new List<Id>();
        List<Id> hcpeIds = new List<Id>();
        List<Id> participantIds = new List<Id>();
        List<Id> ctpIds = new List<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (pe.Study_Site__c != null) ssIds.add(pe.Study_Site__c);
            if (pe.HCP__c != null) hcpeIds.add(pe.HCP__c);
            if (pe.Participant__c != null) participantIds.add(pe.Participant__c);
            if (pe.Clinical_Trial_Profile__c != null) ctpIds.add(pe.Clinical_Trial_Profile__c);
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
                        Adult__c,
                        Balance__c,
                        Contact__c,
                        Contact__r.Visit_Results_OptIn__c,
                        Email__c,
                        Emancipation_in_progress__c,
                        First_Name__c,
                        Full_Name__c,
                        Has_Studies__c,
                        Has_Studies_In_Progress__c,
                        Has_Past_Studies__c,
                        IsCountry_NOT_Eligible_for_Emails__c,
                        Last_Name__c,
                        Name,
                        Status__c
                FROM Participant__c
                WHERE Id IN:participantIds
        ]);
        buffer.putAll([
                SELECT Id,
                        Patient_Portal_Enabled__c,
                        Visit_Plan__c,
                        Protocol_ID__c,
                        CommunityTemplate__c,
                        Tasks_Are_Available__c,
                        Initial_Visit_Required__c,
                        Participant_Workflow_Final_Step__c
                FROM Clinical_Trial_Profile__c
                WHERE Id IN:ctpIds
        ]);
    }

}