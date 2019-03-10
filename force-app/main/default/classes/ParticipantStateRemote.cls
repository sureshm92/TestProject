/**
 * Created by Leonid Bartenev
 */

public class ParticipantStateRemote {
    
    public class InitData{
        Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        Participant_Enrollment__c pe;
    }
    
    @AuraEnabled
    public static String getInitData(){
        InitData initData = new InitData();
        Participant_Enrollment__c[] peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
        if(peList.size() > 0) initData.pe = peList[0];
        return JSON.serialize(initData);
    }
    
    @AuraEnabled
    public static String getParticipantName(){
        List<Participant__c> participants = [
                SELECT Id, First_Name__c, Last_Name__c
                FROM Participant__c
                WHERE Contact__c =: CommunityService.getUserContact().Id
        ];
        String name;
        if(participants.size() > 0) name = participants[0].First_Name__c + ' ' + participants[0].Last_Name__c;
        return name.trim();
    }

}