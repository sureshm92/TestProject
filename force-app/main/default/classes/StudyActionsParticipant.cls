public class StudyActionsParticipant extends StudyActions {

    public StudyActionsParticipant() {
        actions = new Map<String, Action>();
        
        actions.put(ACT_SHARE, new Action(
                ACT_SHARE,
                LABEL_SHARE,
                'icon-share',
                false
        )) ;
        
        actions.put(ACT_VIEW_TC, new Action(
                ACT_VIEW_TC,
                LABEL_VIEW_TC_Participant,
                'paper-many',
                false
        ));
        
        actions.put(ACT_DOWNLOAD_CONSENT, new Action(
                ACT_DOWNLOAD_CONSENT,
                LABEL_DOWNLOAD_CONSENT,
                'icon-import',
                false
        ));
        
        actions.put(ACT_HOME, new Action(
                ACT_HOME,
                LABEL_HOME,
                'icon-home-brand-new',
                false
        ));

        ParticipantService.ParticipantState state = ParticipantService.getParticipantState();
        ParticipantService.ParticipantStates stateValue = state.value;

        if(stateValue == ParticipantService.ParticipantStates.REFERRAL ||
                stateValue == ParticipantService.ParticipantStates.PARTICIPANT) {
            if(study == null) study = state.ctp;

            if(study.Terms_And_Conditions_ID__c != null) studyDetailActions.add(actions.get(ACT_VIEW_TC));
        }

        studyDetailActions.add(actions.get(ACT_HOME));
        
        if (stateValue == ParticipantService.ParticipantStates.PARTICIPANT
                || stateValue == ParticipantService.ParticipantStates.REFERRAL) {
            studyDetailActions.add(actions.get(ACT_SHARE));
        }
    }

}
