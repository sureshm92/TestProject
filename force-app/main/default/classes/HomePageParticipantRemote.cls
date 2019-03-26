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
            List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
            InitData initData = new InitData();
            if(peList.size() > 0){
                initData.pe = peList[0];
            }
            if(ParticipantService.getParticipantState().isDelegate) {
                initData.name = (String) CommunityService.getUserContact().get('Name');
            } else {
                initData.name = peList[0].Participant__r.Full_Name__c;
            }

            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}