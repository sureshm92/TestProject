public without sharing class Batch_SCDeactivateUser implements Database.Batchable<sObject>, Database.Stateful {
    // Study closure Id(CTP Id)
    public Id studyClosureId;
    // Study related contact Ids(Patient, Patient Delegate, Site PI, Site staff)
    public Set<Id> studyContactIds = new Set<Id>();
    // Batch process for Study closure review or delete 
    public Boolean isStudyToDelete = false;
    // Batch executed from the Participant enrollment/Studysite 
    public Boolean executeFromPEBatch;
    
    // Study Closure Process Id
    private Id studyClosureProcessId;
    public class BatchControlException extends Exception{}
    private Set<Id> userIds = new Set<Id>();
    private Set<Id> permissionSetAssignmentIds = new Set<Id>();
    private Set<Id> permissionSetLicenseAssignIds = new Set<Id>();
    private Set<Id> userPackageLicenseIds = new Set<Id>();
    
    // Query the independant users related with the current CTP
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
        
        String query = 'SELECT Id FROM User '
            +'WHERE ContactId IN :studyContactIds AND IsActive = true AND IsPortalEnabled = true';
        return Database.getQueryLocator(query);
    }
    // Remove the user permission and deactivate the study site users
    public void execute(Database.BatchableContext bc, List<User> records) {
        
        // Remove the community related permission set from study closure related users
        removeUserPermissions(
            isStudyToDelete, records, permissionSetAssignmentIds, permissionSetLicenseAssignIds, userPackageLicenseIds
        );
        // Deactivate all the study closure related independant users
        deactivateUser(isStudyToDelete, records, userIds);
    }
    public void finish(Database.BatchableContext bc) {
    
        System.debug('studyContactIds -->'+studyContactIds);
        
         if(isStudyToDelete == false) {
            List<ContentVersion> contentVersions =new List<ContentVersion>();
            
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Users', userIds
            ));
            /*contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Users Permission Set Assignment', permissionSetAssignmentIds
            ));
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Users Permission SetLicense Assign', permissionSetLicenseAssignIds
            ));
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Users Package License', userPackageLicenseIds
            ));*/
            
            Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessId, contentVersions);
        }
        
        Batch_SCDeleteContact contactBatch = new Batch_SCDeleteContact();
        contactBatch.studyClosureId = studyClosureId;
        contactBatch.studyContactIds = studyContactIds;
        contactBatch.isStudyToDelete = isStudyToDelete;
        contactBatch.executeFromPEBatch = executeFromPEBatch;
        Database.executeBatch(contactBatch); 
    }
    // Remove the community related permission set from study closure related users
    public static void removeUserPermissions(
        Boolean isStudyToDelete, List<User> records, Set<Id> permissionSetAssignmentIds, 
        Set<Id> permissionSetLicenseAssignIds, Set<Id> userPackageLicenseIds  
    ) {
        
        if(isStudyToDelete) {
        
            delete [
                SELECT Id FROM PermissionSetAssignment 
                WHERE AssigneeId IN :records AND PermissionSet.IsOwnedByProfile = FALSE
            ]; 
            /*delete [SELECT Id FROM PermissionSetLicenseAssign WHERE AssigneeId IN :records];
            delete [SELECT Id FROM UserPackageLicense WHERE UserId IN :records];*/
            
        } else {
    
            /*permissionSetAssignmentIds.addAll((new Map<Id,PermissionSetAssignment>([
                SELECT Id FROM PermissionSetAssignment 
                WHERE AssigneeId IN :records AND PermissionSet.IsOwnedByProfile = FALSE
            ])).keySet());
            
            permissionSetLicenseAssignIds.addAll((new Map<Id,PermissionSetLicenseAssign>([
                SELECT Id FROM PermissionSetLicenseAssign WHERE AssigneeId IN :records
            ])).keySet());
            
            userPackageLicenseIds.addAll((new Map<Id,UserPackageLicense>([
                SELECT Id FROM UserPackageLicense WHERE UserId IN :records
            ])).keySet());*/
        }
    }
    
    // Deactivate all the study closure related independant users
    public static void deactivateUser(Boolean isStudyToDelete, List<User> records, Set<Id> userIds) {
        
        if(isStudyToDelete) {
        
            for (User userRec : records) {
            
                userRec.IsPortalEnabled = false;
            }
            update records;
            System.debug('User records -->'+[SELECT Id, ContactId, IsPortalEnabled, IsActive FROM User WHERE Id IN :records]);
        } else {
            
            userIds.addAll((new Map<Id,User>(records)).keySet());
        }
    }
}