/**
 * Created by Andrii Kryvolap
 */

public without sharing class ProviderPaymentsService {

    public final static String ACTIVITY_TYPE_ORIENTATION = 'orientation';
    public final static String ACTIVITY_TYPE_MRR = 'screener1';


    public static void checkPEForReimbursableActivities(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap){
        List<Participant_Enrollment__c> peWithMRRDateUpdatedFromHCP = new List<Participant_Enrollment__c>();
        Set<Id> studySiteIds = new Set<Id>();
        for(Participant_Enrollment__c pe : newList){
            if(pe.HCP__c != null && pe.Medical_Record_Review_Completed_Date__c != null &&
                    (oldMap == null || oldMap.get(pe.Id).Medical_Record_Review_Completed_Date__c != pe.Medical_Record_Review_Completed_Date__c)){
                peWithMRRDateUpdatedFromHCP.add(pe);
                studySiteIds.add(pe.Study_Site__c);
            }
        }
        Map<Id, String> billableCodesMap = new Map<Id, String>();
        for(Study_Site__c ss : [
                SELECT Id, Billable_Code_CRM_Number__c
                FROM Study_Site__c
                WHERE Id IN :studySiteIds AND Clinical_Trial_Profile__r.Sponsor_Pays_for_Referral_Activity__c = 'Yes']){
            billableCodesMap.put(ss.Id, ss.Billable_Code_CRM_Number__c);
        }
        List<Participant_Enrollment__c> peWithReimbursableActivities = new List<Participant_Enrollment__c>();
        Set<Id> hcpContactIds = new Set<Id>();
        for(Participant_Enrollment__c pe : peWithMRRDateUpdatedFromHCP){
            if(billableCodesMap.containsKey(pe.Study_Site__c)){
                peWithReimbursableActivities.add(pe);
                hcpContactIds.add(pe.HCP_Contact_HCPEnroll__c);
            }
        }
        if(!peWithReimbursableActivities.isEmpty()){
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName FROM Contact WHERE Id IN :hcpContactIds]);
            createProviderPaymentsForPEs(peWithReimbursableActivities, billableCodesMap, contactMap);
        }

    }

    public static void checkHCPEForReimbursableActivities(List<HCP_Enrollment__c> newList, Map<Id, HCP_Enrollment__c> oldMap){
        List<HCP_Enrollment__c> hcpeWithOrientationDateUpdated = new List<HCP_Enrollment__c>();
        Set<Id> studySiteIds = new Set<Id>();
        for(HCP_Enrollment__c hcpe : newList){
            if(hcpe.Orientation_Date__c != null &&
                    (oldMap == null || oldMap.get(hcpe.Id).Orientation_Date__c != hcpe.Orientation_Date__c)){
                hcpeWithOrientationDateUpdated.add(hcpe);
                studySiteIds.add(hcpe.Study_Site__c);
            }
        }
        Map<Id, String> billableCodesMap = new Map<Id, String>();
        for(Study_Site__c ss : [
                SELECT Id, Billable_Code_CRM_Number__c
                FROM Study_Site__c
                WHERE Id IN :studySiteIds AND Clinical_Trial_Profile__r.Sponsor_Pays_for_Referral_Activity__c = 'Yes']){
            billableCodesMap.put(ss.Id, ss.Billable_Code_CRM_Number__c);
        }
        List<HCP_Enrollment__c> hcpeWithReimbursableActivities = new List<HCP_Enrollment__c>();
        for(HCP_Enrollment__c hcpe : hcpeWithOrientationDateUpdated){
            if(billableCodesMap.containsKey(hcpe.Study_Site__c)){
                hcpeWithReimbursableActivities.add(hcpe);
            }
        }
        if(!hcpeWithReimbursableActivities.isEmpty()){
            createProviderPaymentsForHCPEs(hcpeWithReimbursableActivities, billableCodesMap);
        }
    }

    private static void createProviderPaymentsForPEs(List<Participant_Enrollment__c> participantEnrollments, Map<Id, String> billableCodesMap, Map<Id, Contact> contactMap){
        List<Provider_Payment__c> paymentsToCreate = new List<Provider_Payment__c>();
        for(Participant_Enrollment__c pe : participantEnrollments){
            Contact hcpContact = contactMap.get(pe.HCP_Contact_HCPEnroll__c);
            Provider_Payment__c payment = new Provider_Payment__c();
            payment.Activity__c = ACTIVITY_TYPE_MRR;
            payment.Billable_Code__c = billableCodesMap.get(pe.Study_Site__c);
            payment.Patient_ID__c = pe.Patient_ID__c;
            payment.Randomization_ID__c = pe.Screening_ID__c;
            payment.Physicians_Name__c = hcpContact.FirstName + ' ' + hcpContact.LastName;
            payment.Activity_Date__c = pe.Medical_Record_Review_Completed_Date__c.format('MM/dd/yyyy');
            paymentsToCreate.add(payment);
        }
        insert paymentsToCreate;
    }

    private static void createProviderPaymentsForHCPEs(List<HCP_Enrollment__c> hcpEnrollments, Map<Id, String> billableCodesMap){
        List<Provider_Payment__c> paymentsToCreate = new List<Provider_Payment__c>();
        for(HCP_Enrollment__c hcpe : hcpEnrollments){
            Provider_Payment__c payment = new Provider_Payment__c();
            payment.Activity__c = ACTIVITY_TYPE_ORIENTATION;
            payment.Billable_Code__c = billableCodesMap.get(hcpe.Study_Site__c);
            payment.Physicians_Name__c = hcpe.HCP_Name__c;
            payment.Activity_Date__c = hcpe.Orientation_Date__c.format();
            paymentsToCreate.add(payment);
        }
        insert paymentsToCreate;
    }



}