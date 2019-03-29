/**
 * Created by Kryvolap
 */

public without sharing class ParticipantEnrollmentSHTriggerHandler {
    public static void sendToEPR(){
        IntegrationService.sendPESHToEPRAsync(new List<Id>(Trigger.newMap.keySet()));
    }
}