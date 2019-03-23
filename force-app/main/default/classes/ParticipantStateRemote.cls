/**
 * Created by Leonid Bartenev
 */

public class ParticipantStateRemote {
    
    public class InitData{
        public Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        public List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        public ParticipantService.ParticipantState participantState;
        public List<Path.PathItem> psePath;
    }
    
    @AuraEnabled
    public static String getInitData(){
        InitData initData = new InitData();
        initData.participantState = ParticipantService.getParticipantState();
        if(initData.participantState.pse != null){
            List<String> translatedStatuses = new List<String>();
            for(String status : PSEService.PSE_STATUS_GROUP_ALL) translatedStatuses.add(TranslateHelper.getPickListLabel(Participant_Study_Enrollment__c.Status__c, status));
            initData.psePath = Path.generatePath(translatedStatuses, initData.participantState.pse.Status__c);
        }
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