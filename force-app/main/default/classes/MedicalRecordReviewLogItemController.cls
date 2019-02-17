/**
 * Created by D.Yasinskyi on 18.04.2018
 */
public without sharing class MedicalRecordReviewLogItemController {

    @AuraEnabled
    public static String changeStatusToExcludeFromReferring(String participantEnrollmentId) {
        try {
            Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
                    Id = participantEnrollmentId,
                    Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING
            );
            update participantEnrollment;
            return ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
}