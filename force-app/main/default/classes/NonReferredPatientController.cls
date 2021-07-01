public without sharing class NonReferredPatientController {
    @AuraEnabled
    public static String changeStatusToExcludeFromReferring(List<Id> participantEnrollmentId) {
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        try {
            
            for(Participant_Enrollment__c pe : [
                SELECT Id,Participant_Status__c 
                FROM Participant_Enrollment__c
                WHERE ID IN: participantEnrollmentId]){
                    pe.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING;
                    peList.add(pe);
                    
                }
           
            update peList;
            return ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
    @AuraEnabled
    public static Participant_Enrollment__c getpatientdetails(id patid){
        try {
              Participant_Enrollment__c per = new Participant_Enrollment__c();
              per = [select Id,Participant_Name__c,Participant_Surname__c,Patient_ID__c,
                      YOB__c,
                      Email__c,
                      Country__c,State__c,Attestation__c,Medical_Record_Review_Status__c,Final_consent__c
                      from Participant_Enrollment__c where id=:patid];
              return per ;
         }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}