/**
 * Created by Leonid Bartenev
 */

public class ParticipantItem {
    
    @AuraEnabled public Participant_Enrollment__c pe;
    @AuraEnabled public Participant_Study_Enrollment__c pse;
    @AuraEnabled public Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
    @AuraEnabled public List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
    @AuraEnabled public List<LabelValueItem> psePathSteps = PSEService.getInstance().getPSEPathSteps();
    
    public ParticipantItem(Participant_Enrollment__c pe){
        this.pe = pe;
        this.pse = pe.Participant_Study_Enrollment__r;
    }
    
}