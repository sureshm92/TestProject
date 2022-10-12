/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantItem {
    @AuraEnabled
    public Participant_Enrollment__c pe;
    @AuraEnabled
    public Participant_PrescreenerResponse__c screenerResponse;
    @AuraEnabled
    public Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
    @AuraEnabled
    public List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
    @AuraEnabled
    public List<LabelValueItem> participationFlowSteps;
    @AuraEnabled
    public Boolean showParticipationSteps;
    @AuraEnabled
    public List<ViewPatientsRemote.PEWrapper> currentPageList;
    @AuraEnabled
    public Boolean showVisits;
    @AuraEnabled
    public Boolean showVisitsinPreTrial;
    
    //
     @AuraEnabled
        public Boolean isPNS{ get; set; }
        @AuraEnabled
        public String dateOccured;
        @AuraEnabled
        public Date occuredDate;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public Boolean isContact{ get; set; }
        @AuraEnabled
        public String historyTitle;
        @AuraEnabled
        public String detailDate;
        @AuraEnabled
        public String createdBy;
        @AuraEnabled
        public String detail;
    //

    @AuraEnabled //REF-2826
    public Boolean containsFile;

    @AuraEnabled
    public List<ParticipantWorkflowService.PathStepWrapper> pathItems;
    @AuraEnabled
    public Boolean showNonInitialVisits;
    public ParticipantItem(Participant_Enrollment__c pe) {
        pe.Referral_Source__c = TranslateHelper.getPickListLabel(
            Participant_Enrollment__c.Referral_Source__c,
            pe.Referral_Source__c
        );
        this.pe = pe;
        // String participantId = pe.Participant__c;//REF-2826
        /* Integer count= database.countQuery('Select count() from ContentDocumentLink where LinkedEntityId = :participantId');
        if(count > 0)
        {
            this.containsFile = true;
        }else
        {
            this.containsFile = false;
        } */
        this.participationFlowSteps = PEStatusState.getParticipationFlowStepsLV(pe);
        this.showParticipationSteps = PEStatusState.getParticipationFlowSteps(pe)
            .contains(pe.Participant_Status__c);
    }

    public ParticipantItem(ParticipantService.ParticipantState participantState) {
        this.pe = participantState.pe;
        this.showVisits =
            pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c &&
            participantState.showVisits &&
            pe.Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c;
        this.participationFlowSteps = PEStatusState.getParticipationFlowStepsLV(
            participantState.pe
        );
        /**PEH-525 START*/

        this.showVisitsinPreTrial =
            participantState.showVisitsinPreTrial &&
            pe.Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c &&
            participantState.value == ParticipantService.ParticipantStates.REFERRAL;
        /**PEH-525 END*/
        this.showParticipationSteps = PEStatusState.getParticipationFlowSteps(participantState.pe)
            .contains(participantState.pe.Participant_Status__c);
        this.showNonInitialVisits = participantState.showNonInitialVisits;
    }
}