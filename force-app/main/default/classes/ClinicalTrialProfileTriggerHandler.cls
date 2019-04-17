/**
 * Created by AlexKetch on 4/16/2019.
 */

public with sharing class ClinicalTrialProfileTriggerHandler extends TriggerHandler {

    public override void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        this.deleteRelatedToStudyDocuments((List<Clinical_Trial_Profile__c>) newList,(Map<Id, Clinical_Trial_Profile__c>)oldMap);
    }

    private void deleteRelatedToStudyDocuments(List<Clinical_Trial_Profile__c> newList, Map<Id, Clinical_Trial_Profile__c> oldMap) {
        List<Clinical_Trial_Profile__c> completedTrials = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c t : newList) {
            if (t.Status__c != oldMap.get(t.Id).Status__c) {
                if (t.Status__c == 'Completed') {
                    completedTrials.add(t);
                }
            }
        }
        //todo Complete tests
        ResourceService resService = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        resService.deleterelatedTostudyDocuments(completedTrials);
    }
}