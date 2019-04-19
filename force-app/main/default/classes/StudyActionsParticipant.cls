public class StudyActionsParticipant extends StudyActions {

    public StudyActionsParticipant(Participant_Enrollment__c participantEnrollment){
        this(
                participantEnrollment.Clinical_Trial_Profile__r,
                participantEnrollment.Study_Site__r,
                null,
                participantEnrollment
        );
    }
    public StudyActionsParticipant(Clinical_Trial_Profile__c study, Study_Site__c studySite, HCP_Enrollment__c hcpEnrollment, Participant_Enrollment__c pe) {
        super(
                study,
                studySite,
                hcpEnrollment,
                CommunityService.USER_MODE_PARTICIPANT
        );

        actions = new Map<String, Action>();
        
        actions.put(ACT_SHARE_FACEBOOK, new Action(
                ACT_SHARE_FACEBOOK,
                LABEL_SHARE,
                'icon-facebook',
                false
        )) ;
        actions.put(ACT_SHARE_TWITTER, new Action(
                ACT_SHARE_TWITTER,
                LABEL_SHARE,
                'icon-twitter',
                false
        )) ;
        actions.put(ACT_SHARE_LINKEDIN, new Action(
                ACT_SHARE_LINKEDIN,
                LABEL_SHARE,
                'icon-linkedin',
                false
        ));
        actions.put(ACT_SHARE_EMAIL, new Action(
                ACT_SHARE_EMAIL,
                LABEL_SHARE,
                'icon-envelope',
                false
        ));
        
        actions.put(ACT_VIEW_TC, new Action(
                ACT_VIEW_TC,
                LABEL_VIEW_TC,
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

        ParticipantService.ParticipantStates participantStateValue = ParticipantService.getParticipantState().value;
        if (participantStateValue != ParticipantService.ParticipantStates.ALUMNI) studyDetailActions.add(actions.get(ACT_DOWNLOAD_CONSENT));
        
        if(participantStateValue == ParticipantService.ParticipantStates.PARTICIPANT && study.Terms_And_Conditions_ID__c != null) {
            studyDetailActions.add(actions.get(ACT_VIEW_TC));
        }

        if (participantStateValue != ParticipantService.ParticipantStates.ALUMNI) {
            studyDetailActions.add(actions.get(ACT_SHARE_EMAIL));
            studyDetailActions.add(actions.get(ACT_SHARE_FACEBOOK));
            studyDetailActions.add(actions.get(ACT_SHARE_LINKEDIN));
            studyDetailActions.add(actions.get(ACT_SHARE_TWITTER));
        }
    
        studyDetailActions.add(actions.get(ACT_HOME));


    }

}