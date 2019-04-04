/**
 * Created by Leonid Bartenev
 */

public class HomePageParticipantRemote {
    
    public class InitData{
        public Participant_Enrollment__c pe;
        public Participant_Study_Enrollment__c pse;
        public String name;
    }
    
    @AuraEnabled
    public static String getInitData(){
        try{
            ParticipantService.ParticipantState state = ParticipantService.getParticipantState();
            InitData initData = new InitData();
            initData.pe = state.pe;
            initData.pse = state.pse;

            if(state.isDelegate) {
                initData.name = (String) CommunityService.getUserContact().get('Name');
            } else {
                initData.name = state.pe.Participant__r.Full_Name__c;
            }

            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}