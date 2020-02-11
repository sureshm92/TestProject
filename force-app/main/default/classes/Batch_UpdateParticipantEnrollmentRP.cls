global without sharing class Batch_UpdateParticipantEnrollmentRP implements Database.Batchable<SObject> {
    private static final String SourceTypeRP = 'Referring Provider';
    private static final String ReferralSourceHCP = 'HCP';


    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([SELECT Id, Show_Referring_Provider__c
                                        FROM Participant_Enrollment__c
                                        WHERE Source_Type__c =: SourceTypeRP
                                        AND Referral_Source__c =: ReferralSourceHCP]);
    }

    global void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> scope) {
        for (Participant_Enrollment__c pe : scope) {
            pe.Show_Referring_Provider__c = true;
        }

        Database.update(scope, false);
    }

    global void finish(Database.BatchableContext bc) {}

}