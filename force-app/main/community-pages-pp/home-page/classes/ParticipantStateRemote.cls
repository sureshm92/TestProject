/**
 * Created by Leonid Bartenev
 */

public class ParticipantStateRemote {
    
    @AuraEnabled
    public static String getInitData(){
        try{
            ParticipantItem pi = new ParticipantItem(ParticipantService.getInstance().getState());
            ParticipantWorkflowService.populatePatientItemsWithPathWrappers(new List<ParticipantItem>{pi});
            return JSON.serialize(pi);
        }catch (Exception e){
            return (String)AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static String getParticipantName(){
        try{
            List<Participant__c> participants = [
                    SELECT Id, First_Name__c, Last_Name__c
                    FROM Participant__c
                    WHERE Contact__c =: CommunityService.getUserContact().Id
            ];
            String name;
            if(participants.size() > 0) name = participants[0].First_Name__c + ' ' + participants[0].Last_Name__c;
            return name.trim();
        }catch (Exception e){
            return (String)AuraHelper.throwException(e);
        }
    }

}