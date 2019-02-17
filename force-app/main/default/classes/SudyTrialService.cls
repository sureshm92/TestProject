/**
 * Created by D.Yasinskyi on 26.02.2018
 */
public without sharing class SudyTrialService {

    public static List<Clinical_Trial_Profile__c> getTrials(Set<Id> trialsId) {

        return [
                SELECT Id
                        , Name
                        , Study_Sponsor__c
                        , Detailed_Description__c
                        , Override_Recruitment_Status__c
                        , Terms_And_Conditions_ID__c
                        , Link_to_Medical_Record_Review__c
                        , Link_to_Pre_screening__c
                        , Study_Title__c
                        , Study_Code_Name__c
                        , Official_Title__c
                        , Sponsor_Pays_for_Referral_Activity__c
        
                FROM Clinical_Trial_Profile__c
                WHERE Id IN :trialsId
        ];
    }

    public static List<Clinical_Trial_Profile__c> getFullTrials(Set<Id> trialsId) {

        return [
                SELECT Id
                        , Orientation_Required__c
                        , Name
                        , Terms_And_Conditions_ID__c
                        , Study_Sponsor__c
                        , Study_Type__c
                        , Detailed_Description__c
                        , Override_Recruitment_Status__c
                        , Brief_Summary__c
                        , Override_Description__c
                        , Override_Inclusion_Criteria__c
                        , Override_Exclusion_Criteria__c
                        , Condition_s_Therapeutic_Area__c
                        , Sponsor_Pays_for_Referral_Activity__c
                        , Study_Phase__c
                        , NCT_Number__c
                        , Protocol_ID__c
                        , Enrollment_Start_Date__c
                        , Enrolled_End_Date__c
                        , Link_to_Medical_Record_Review__c
                        , Link_to_Pre_screening__c
                        , Study_Title__c
                        , Study_Code_Name__c
                        , Official_Title__c
                        , Interventions__c
                FROM Clinical_Trial_Profile__c
                WHERE Id IN :trialsId
        ];
    }

    public static Clinical_Trial_Profile__c getFullTrial(Id trialId){
        List<Clinical_Trial_Profile__c> trials = getFullTrials(new Set<Id>{trialId});
        if(trials.size() > 0) return trials[0];
        return null;
    }
}