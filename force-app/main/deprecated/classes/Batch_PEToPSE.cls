/**
 * Created by Leonid Bartenev
 */

public without sharing class Batch_PEToPSE implements Database.Batchable<Id>, Database.Stateful {
    
    private List<Id> peIds;
    
    public Batch_PEToPSE(List<Id> peIds) {
        this.peIds = peIds;
    }
    
    public Iterable<Id> start(Database.BatchableContext bc) {
        return peIds;
    }
    
    public void execute(Database.BatchableContext bc, List<Id> scope) {
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for (Id peId : scope) {
            peList.add(new Participant_Enrollment__c(
                    Id = peId,
                    Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
            ));
        }
        update peList;
    }
    
    public void finish(Database.BatchableContext bc) {
    
    }
    
}