/**
 * Created by Igor Malyuta on 06.03.2020.
 */

public without sharing class Batch_UpdateParticipantStudyFlag implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id, Has_Studies_In_Progress__c, Has_Past_Studies__c FROM Participant__c
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Participant__c> participants) {
        ParticipantEnrollmentService.updateParticipantState(participants);
    }

    public void finish(Database.BatchableContext param1) {
    }

    public static void launch() {
        Database.executeBatch(new Batch_UpdateParticipantStudyFlag());
    }
}