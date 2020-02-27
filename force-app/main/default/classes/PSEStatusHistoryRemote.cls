/**
 * Created by Leonid Bartenev
 */

public without sharing class PSEStatusHistoryRemote {
    
    public class PathItem{
        @AuraEnabled public String state;
        @AuraEnabled public Participant_Enrollment_Status_History__c peSH;
        @AuraEnabled public String iconName;
        
        public PathItem(Participant_Enrollment_Status_History__c peSH){
            this.peSH = peSH;
            this.state = 'success';
            this.iconName = 'icon-check';
        }
    }

    @AuraEnabled
    public static String getParticipationStatusHistory(Id peId){
        try{
            List<Participant_Enrollment__c> enrollments = [SELECT Id, Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c
            FROM Participant_Enrollment__c WHERE Id = :peId];
            if(enrollments.isEmpty()) return '';
            List<String> participationFlowSteps = PEStatusState.getParticipationFlowSteps(enrollments[0]);

            List<Participant_Enrollment_Status_History__c> histories = [
                    SELECT Id, Status__c, Date__c
                    FROM Participant_Enrollment_Status_History__c
                    WHERE ParticipantEnrollment__c =: peId
                    AND Status__c IN: participationFlowSteps
                    ORDER BY Date__c DESC
            ];

            List<PathItem> items = new List<PathItem>();
            for(Participant_Enrollment_Status_History__c peSH : histories) {
                peSH.Status__c = TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c, peSH.Status__c);
                items.add(new PathItem(peSH));
            }
            return JSON.serialize(items);
        }catch (Exception e){
            AuraHelper.throwException(e);
            return null;
        }
    }

}