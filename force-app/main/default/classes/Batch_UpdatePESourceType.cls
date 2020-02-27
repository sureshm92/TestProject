/**
 * Created by Alexey Moseev
 */
global without sharing class Batch_UpdatePESourceType implements Database.Batchable<SObject> {

    global Batch_UpdatePESourceType() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,
                                                Referral_Source__c,
                                                Source_Type__c
                                         FROM Participant_Enrollment__c
                                         WHERE Source_Type__c = NULL OR Source_Type__c = '']);
    }

    global void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> scope) {
        for (Participant_Enrollment__c pe : scope) {
            if ('PI' == pe.Referral_Source__c) {
                pe.Source_Type__c = ParticipantEnrollmentService.PE_SOURCE_TYPE_PI;
            } else if (pe.Referral_Source__c != null && pe.Referral_Source__c.contains('HCP')) {
                pe.Source_Type__c = ParticipantEnrollmentService.PE_SOURCE_TYPE_RP;
            } else {
                pe.Source_Type__c = ParticipantEnrollmentService.PE_SOURCE_TYPE_EPR;
            }
        }

        update scope;
    }

    global void finish(Database.BatchableContext bc) {}

}