/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantStateRemote {
    @AuraEnabled
    public static String getInitData() {
        try {
            ParticipantItem pi = new ParticipantItem(ParticipantService.getInstance().getState());
            ParticipantWorkflowService.populatePatientItemsWithPathWrappers(
                new List<ParticipantItem>{ pi }
            );
            String referralSourceName;
            if(pi!=null && pi.pe!=null && pi.pe.PI_Contact__c!= null){
                referralSourceName = getSourceNameFromPE(pi.pe.PI_Contact__c); 
            }
            ParticipantItemAndDetails participantItemAndDetails = new ParticipantItemAndDetails();
            participantItemAndDetails.pi = pi;
            participantItemAndDetails.referralSourceName = referralSourceName;
            return JSON.serialize(participantItemAndDetails);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
    
    public Class ParticipantItemAndDetails{
        ParticipantItem pi;
        String referralSourceName;
    }
    
    public static String getSourceNameFromPE(Id piContactId){
        String source;
	List<Participant__c> partList = [SELECT Id,First_Name__c,Middle_Name__c,Last_Name__c,Suffix__c FROM Participant__c WHERE Contact__c =:piContactId];
        if(!partList.isEmpty()){
            if(partList[0].First_Name__c!=null){
                source = source==null?partList[0].First_Name__c : source + ' ' + partList[0].First_Name__c;
            }
            if(partList[0].Middle_Name__c!=null){
                source = source==null?partList[0].Middle_Name__c : source + ' ' + partList[0].Middle_Name__c;
            }
            if(partList[0].Last_Name__c!=null){
                source = source==null?partList[0].Last_Name__c : source + ' ' + partList[0].Last_Name__c;
            }
            if(partList[0].Suffix__c!=null){
                source = source==null?partList[0].Suffix__c : source + ' ' + partList[0].Suffix__c;
            }            
        }
        return source;
    }
    
    @AuraEnabled
    public static String getParticipantName() {
        try {
            List<Participant__c> participants = [
                SELECT Id, First_Name__c, Last_Name__c
                FROM Participant__c
                WHERE Contact__c = :CommunityService.getUserContact().Id
            ];
            String name;
            if (participants.size() > 0)
                name = participants[0].First_Name__c + ' ' + participants[0].Last_Name__c;
            return name.trim();
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
}
