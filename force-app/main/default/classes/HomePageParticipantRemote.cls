/**
 * Created by Leonid Bartenev
 */

public class HomePageParticipantRemote {
    
    public class InitData{
        public Participant_Enrollment__c pe;
        public String name;
    }
    
    @AuraEnabled
    public static String getInitData(){
        try{
            ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();

            InitData initData = new InitData();
            initData.pe = participantState.pe;
            if(participantState.isDelegate) {
                initData.name = (String) CommunityService.getUserContact().get('Name');
            }
            else {
                initData.name = initData.pe.Participant__r.Full_Name__c;
            }

            return JSON.serialize(initData);
        }catch (Exception e){
             return (String) AuraHelper.throwException(e);
        }
    }
}