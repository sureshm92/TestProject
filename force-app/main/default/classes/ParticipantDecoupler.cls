public without sharing class ParticipantDecoupler {
    
    public static List<Therapeutic_Area_Patient__c> getTherapeuticAreaPatients() {
        Id currentContact = CommunityService.getUserContact().userCommunityDelegateId__c;
        if(currentContact == null) currentContact = CommunityService.getUserContact().Id;
        return [
                SELECT
                        Condition_Of_Interest_Order__c,
                        Therapeutic_Area__c,
                        Therapeutic_Area__r.Name
                FROM Therapeutic_Area_Patient__c WHERE Participant__r.Contact__c = :currentContact
        ];
    }
    
}