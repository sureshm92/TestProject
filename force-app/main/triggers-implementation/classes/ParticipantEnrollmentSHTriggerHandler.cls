/**
 * Created by Kryvolap
 */

public without sharing class ParticipantEnrollmentSHTriggerHandler {

    public class SendPESHToEPR extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            sendToEPR(newList);
        }

    }

    private static void sendToEPR(List<Participant_Enrollment_Status_History__c> newList){
        List<Id> ids = new List<Id>();
        for(Participant_Enrollment_Status_History__c obj : newList){
            ids.add(obj.Id);
        }
        IntegrationService.sendPESHToEPRAsync(ids);
    }
}