/**
 * Created by Leonid Bartenev
 */

trigger PEIntegrationSend on Participant_Enrollment__c (after insert, after update) {
    String referralSentToPIStatus = ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI;
    String acceptedStatus = 'Eligibility Passed';
    
    for(Participant_Enrollment__c pe : Trigger.new){
        if((Trigger.isInsert && pe.Participant_Status__c == referralSentToPIStatus) ||
                (Trigger.isUpdate && pe.Participant_Status__c == referralSentToPIStatus &&
                Trigger.oldMap.get(pe.Id).Participant_Status__c != referralSentToPIStatus)){
            //IntegrationService.sendPEToServiceNowAsync(pe.Id);
        }
        if(Trigger.isUpdate && pe.Participant_Status__c == acceptedStatus &&
                Trigger.oldMap.get(pe.Id).Participant_Status__c != acceptedStatus){
            IntegrationService.sendPEToStudyHubAsync(pe.Id);
        }
    }
}