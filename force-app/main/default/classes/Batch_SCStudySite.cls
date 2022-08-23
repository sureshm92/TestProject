public without sharing class Batch_SCStudySite implements Database.Batchable<sObject>, Database.Stateful {
    // Study closure Id(CTP Id)
    public Id studyClosureId;
    // Batch process for Study closure review or delete 
    public Boolean isStudyToDelete = false;
    // Site related contact Ids(PI, Site staff)
    public Set<Id> siteContactIds = new Set<Id>();
    // participant contact Ids
    public Set<Id> participantContactIds = new Set<Id>();
    // patient delegate contact Ids
    public Set<Id> patientDelegateContactIds =new Set<Id>();
    
    // Study Closure Process Id
    private Id studyClosureProcessId;
    private Set<Id> siteStaffIds = new Set<Id>();
    private Set<Id> studySiteIds = new Set<Id>();
    public class BatchControlException extends Exception{}
    
    // Query the study site related with the current CTP
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        if(isStudyToDelete == false && String.isNotBlank(studyClosureId)) {
            
            List<Study_Closure__c> studyClosureProcessList = [
                SELECT Id FROM Study_Closure__c WHERE Clinical_Trial_Profile_Id__c = :studyClosureId LIMIT 1
            ];
            
            if(studyClosureProcessList.isEmpty() == false) {
                
                studyClosureProcessId = studyClosureProcessList[0].Id;
            } else {
                throw new BatchControlException('Please check the studyClosureId and created studyClosure record.');
            }
        }   
        
        String query = 'SELECT Id, Principal_Investigator__c, '
            + '(SELECT Id, Site_Contact__c FROM Site_Staff__r) '
            + 'FROM Study_Site__c '
            + 'WHERE Clinical_Trial_Profile__c = :studyClosureId';
        return Database.getQueryLocator(query);
    }
    // Check the study site related contact(PI and site staff) roles and initiate delete independant contcat records
    public void execute(Database.BatchableContext bc, List<Study_Site__c> records) {
        
        // Collect all the site contcat Ids(PI and Site staff) related with the study site
        getStudySiteContactIds(records, siteContactIds);
        // Check site contacts has enrolled as participant in any other CTP
        checkContactStudyEnrollment(studyClosureId, siteContactIds);
        // Check site contacts has any roles(PI, Site staff, CC staff, HCP, RP Delegate and Patient delegate) in any other CTP
        checkContactRoles(studyClosureId, siteContactIds);
        // Delete all the Site staff records related with the Study closure(CTP)
        deleteSiteStaffs(isStudyToDelete, records, siteStaffIds);
        // Delete the Sites related to the Study(CTP)
        deleteSites(isStudyToDelete, records, studySiteIds);
    }
    public void finish(Database.BatchableContext bc) {
        
        if(isStudyToDelete == false) {
            
            List<ContentVersion> contentVersions =new List<ContentVersion>();
            
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, 'Site staff', siteStaffIds
            ));
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, 'Study Site', studySiteIds
            ));
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, 'Study site Contacts(PI&Sitestaff)', siteContactIds
            ));
            Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessId, contentVersions);
        }
        
        System.debug('siteContactIds -->'+siteContactIds);
        //Set<Id> studyContactIds = new Set<Id>(participantContactIds);
        //studyContactIds.addAll(patientDelegateContactIds);
        //studyContactIds.addAll(siteContactIds);
        //System.debug('studyContactIds -->'+studyContactIds);
        
        Batch_SCDeactivateUser userBatch = new Batch_SCDeactivateUser();
        userBatch.studyClosureId = studyClosureId;
        userBatch.studyContactIds = siteContactIds;
        userBatch.isStudyToDelete = isStudyToDelete;
        userBatch.executeFromPEBatch = false;
        Database.executeBatch(userBatch); 
    }
    // Check site contacts has enrolled as participant in any other CTP
    public static void checkContactStudyEnrollment(Id studyClosureId, Set<Id> siteContactIds) {
        
        for(Participant_Enrollment__c parEnrRec: [
            SELECT Id, Participant_Contact__c 
            FROM Participant_Enrollment__c 
            WHERE Participant_Contact__c IN :siteContactIds AND Clinical_Trial_Profile__c != :studyClosureId
        ]){
            
            siteContactIds.remove(parEnrRec.Participant_Contact__c);
        }
    }
    // Collect all the site contcat Ids(PI and Site staff) related with the study site
    public static void getStudySiteContactIds(List<Study_Site__c> records, Set<Id> siteContactIds) {

        for(Study_Site__c studySite : records) {
            
            siteContactIds.add(studySite.Principal_Investigator__c);
            
            for(Site_Staff__c siteStaff :studySite.Site_Staff__r) {
                
                if(siteStaff.Site_Contact__c != null) {
                    siteContactIds.add(siteStaff.Site_Contact__c);
                }
            }
        }
    }
    // Check site contacts has any roles(PI, Site staff, CC staff, HCP, RP Delegate and Patient delegate) in any other CTP
    public static void checkContactRoles(Id studyClosureId, Set<Id> siteContactIds) {
        
        // Check site contacts as PI of any other CTP 
        checkContactAsPI(studyClosureId, siteContactIds);
        // Check site contacts as Site staff of any other CTP
        checkContactAsSiteStaff(studyClosureId, siteContactIds);
        // Check site contacts enrolled as CC staff 
        checkContactAsCCStaff(siteContactIds);
        // Check site contacts enrolled as RP Delegate 
        checkContactAsRPDelegate(siteContactIds);
        // Check site contacts as HCP of any other CTP
        checkContactAsHCP(studyClosureId, siteContactIds);
        // Check site contacts as Patient delegate of any Patient
        checkContactAsDelegate(siteContactIds);
    }
    
    // Check site contacts as PI of any other CTP 
    public static void checkContactAsPI(Id studyClosureId, Set<Id> siteContactIds) {
    
        if(siteContactIds.isEmpty() == false) {
        
            For(Study_Site__c piUser:[
                SELECT Id, Principal_Investigator__c 
                FROM Study_Site__c 
                WHERE Principal_Investigator__c IN :siteContactIds AND Clinical_Trial_Profile__c != :studyClosureId
            ]){
            
                if(siteContactIds.contains(piUser.Principal_Investigator__c)){
                    siteContactIds.remove(piUser.Principal_Investigator__c);
                }
            }
        }
    }
    // Check site contacts as Site staff of any other CTP
    public static void checkContactAsSiteStaff(Id studyClosureId, Set<Id> siteContactIds) {
    
        if(siteContactIds.isEmpty() == false) {
        
            for(Site_Staff__c ssorRPUser:[
                SELECT Id, Site_Contact__c 
                FROM Site_Staff__c 
                WHERE Site_Contact__c IN :siteContactIds AND Study_Site__r.Clinical_Trial_Profile__c != :studyClosureId
            ]){
                if(siteContactIds.contains(ssorRPUser.Site_Contact__c)){
                    siteContactIds.remove(ssorRPUser.Site_Contact__c);
                }
            }
        }
    }
    // Check site contacts enrolled as CC staff 
    public static void checkContactAsCCStaff(Set<Id> siteContactIds) {
        
        if(siteContactIds.isEmpty() == false) {
        
            for(CC_Staff__c ccUser:[
                SELECT Id, Contact__c 
                FROM CC_Staff__c 
                WHERE Contact__c IN :siteContactIds
            ]){
                
                if(siteContactIds.contains(ccUser.Contact__c)){
                    siteContactIds.remove(ccUser.Contact__c);
                }
            }
        }
    }
    // Check site contacts enrolled as RP Delegate
    public static void checkContactAsRPDelegate(Set<Id> siteContactIds) {
    
        if(siteContactIds.isEmpty() == false) {
        
            for(RP_Delegate_Relationship__c pdUser:[
                SELECT Id, Delegate__c 
                FROM RP_Delegate_Relationship__c 
                WHERE Delegate__c IN :siteContactIds
            ]){
                if(siteContactIds.contains(pdUser.Delegate__c)){
                    siteContactIds.remove(pdUser.Delegate__c);
                }
            }
        }
    }
    // Check site contacts as HCP of any other CTP
    public static void checkContactAsHCP(Id studyClosureId, Set<Id> siteContactIds) {
        
        if(siteContactIds.isEmpty() == false) {
        
            for(HCP_Enrollment__c hcpEnroll:[
                SELECT Id, HCP_Contact__c 
                FROM HCP_Enrollment__c 
                WHERE HCP_Contact__c IN :siteContactIds AND Clinical_Trial_Profile__c != :studyClosureId
            ]){
                
                if(siteContactIds.contains(hcpEnroll.HCP_Contact__c)){
                    siteContactIds.remove(hcpEnroll.HCP_Contact__c);
                }
            }
        }
    }
    // Check site contacts as Patient delegate of any Patient
    public static void checkContactAsDelegate(Set<Id> siteContactIds) {
        
        if(siteContactIds.isEmpty() == false) {
          
            for(Patient_Delegate__c pdUser:[
                SELECT Id, Contact__c 
                FROM Patient_Delegate__c 
                WHERE Contact__c IN :siteContactIds
            ]){
                if(siteContactIds.contains(pdUser.Contact__c)){
                    siteContactIds.remove(pdUser.Contact__c);
                }
            }
        }
    }
    // Delete all the Site staff records related with the Study closure(CTP)
    public static void deleteSiteStaffs(Boolean isStudyToDelete, List<Study_Site__c> records, Set<Id> siteStaffIds) {
        
        if(isStudyToDelete) {
            delete [SELECT Id FROM Site_Staff__c WHERE Study_Site__c IN :records];
            
        } else {
        
            siteStaffIds.addAll((new Map<Id, Site_Staff__c>([
                SELECT Id FROM Site_Staff__c WHERE Study_Site__c IN :records
            ])).keySet());
        }
    }
    
    // Delete the Study sites related to the Study(CTP)
    public static void deleteSites(Boolean isStudyToDelete, List<Study_Site__c> records, Set<Id> studySiteIds) {
        
        if(isStudyToDelete) {
            delete records;
            System.debug('Sites -->'+records);
        } else {
            studySiteIds.addAll((new Map<Id,Study_Site__c>(records)).keySet());
        }
    }
}