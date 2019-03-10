/**
 * Created by Leonid Bartenev
 */

public class HomePageParticipantRemote {
    
    public class InitData{
        public Participant_Enrollment__c pe;
    }
    
    @AuraEnabled
    public static String getInitData(){
        try{
            List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
            InitData initData = new InitData();
            if(peList.size() > 0){
                initData.pe = peList[0];
            }
            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}