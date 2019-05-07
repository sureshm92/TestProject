/**
 * Created by AlexKetch on 4/16/2019.
 */

public with sharing class ClinicalTrialProfileTriggerHandler extends TriggerHandler {

    public override void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        ClinicalTrialProfileService service = (ClinicalTrialProfileService) ClassFactory.newInstance(ClinicalTrialProfileService.class);
        service.deleteRelatedToStudyDocuments((List<Clinical_Trial_Profile__c>) newList,(Map<Id, Clinical_Trial_Profile__c>)oldMap);
        service.addTherapeuticAreasToParticipants((List<Clinical_Trial_Profile__c>) newList, (Map<Id, Clinical_Trial_Profile__c>)oldMap);
    }
}