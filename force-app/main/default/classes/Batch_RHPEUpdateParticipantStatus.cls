global without sharing class Batch_RHPEUpdateParticipantStatus extends Batch_ScheduledAbstract implements Database.Batchable<sObject>, Database.Stateful {
    global List<Participant_Enrollment__c> PEUpdateList = new List<Participant_Enrollment__c>();
    global List<Id> PEIDList = new List<Id>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        @TestVisible 
        String str = label.PERHStudyId;
        @TestVisible
        String lmt = label.RHPElimit15;
        @TestVisible
        String ctp;
        @TestVisible
        String pecreateddate;
        @TestVisible
        String Status;
        lmt = label.RHPElimit15;
        String query;
        Status= '(\''+label.PERHParticipantStatusExclude+'\')';
        ctp = '(\''+label.PERHStudyId+'\')';
        pecreateddate = ''+label.RHPECreatedDate+'';
        if(!Test.isRunningTest()){
        query = 'SELECT Id,Participant_Status__c FROM Participant_Enrollment__c WHERE Clinical_Trial_Profile__c IN '+ctp+' AND Participant_Status__c NOT IN '+Status+' AND Is_Virtual_Study_Site__c=true AND Study_Hub_Log__r.Response_Status_Code__c!=201 AND CreatedDate >= '+pecreateddate+' order by CreatedDate Asc LIMIT '+lmt;
        }else{
        query = 'SELECT Id,Participant_Status__c FROM Participant_Enrollment__c WHERE Participant_Status__c NOT IN '+Status+' AND Is_Virtual_Study_Site__c=true LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Participant_Enrollment__c> peList) {
        //Set flag to 0 to turn off this batch and set 1 in the label to turn on
        if (label.RHPEUpdateParticipantStatus_Flag == '1') {
            UploadParticipantsBatch.isCalloutFromUploadParticipantsBatch = true;
            for (Participant_Enrollment__c pe : peList) {
                pe.Participant_Status__c = 'Eligibility Passed';
                PEUpdateList.add(pe);
            }
            if (PEUpdateList != null && !PEUpdateList.isEmpty()) {
                Database.SaveResult[] saveResultList = Database.update(PEUpdateList, false);
                for (Database.SaveResult saveRes : saveResultList) {
                    if (saveRes.isSuccess()) {
                        PEIDList.add(saveRes.getId());
                    } else {
                        for (Database.Error err : saveRes.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug(
                                'Resource fields that affected this error: ' + err.getFields()
                            );
                        }
                    }
                }
            }
        }
    }

    global override void finish(Database.BatchableContext BC) {
        if (PEIDList != null && !PEIDList.IsEmpty()) {
            UploadParticipantsBatchHelper obj = new UploadParticipantsBatchHelper(PEIDList);
            Database.executeBatch(obj, 20);
        }
    }
    public override Type getType() {
        return Batch_RHPEUpdateParticipantStatus.class;
    }

    public override String getBatchDescription() {
        return 'This job send participant record from RH to SH 100 records every hour';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}