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

        ParticipantService.ParticipantStates participantStateValue = ParticipantService.getParticipantState().value;
        if (participantStateValue != ParticipantService.ParticipantStates.ALUMNI) {
            studyDetailActions.add(new Action(
                    'downloadConsent',
                    TranslateHelper.getLabelValue('BTN_View_Download_Consent'),
                    'icon-import',
                    false
            ));
        }
        if(participantStateValue == ParticipantService.ParticipantStates.PARTICIPANT && study.Terms_And_Conditions_ID__c != null) {
            studyDetailActions.add(new Action(
                    'viewTermsAndConditions',
                    TranslateHelper.getLabelValue('BTN_View_terms_and_conditions'),
                    'paper-many',
                    false
            ));
        }

        if (participantStateValue != ParticipantService.ParticipantStates.ALUMNI) {
            actions.put('facebook', new Action(
                    'facebook',
                    '',
                    'icon-facebook',
                    false
            )) ;
            actions.put('twitter', new Action(
                    'twitter',
                    '',
                    'icon-twitter',
                    false
            )) ;
            actions.put('linkedin', new Action(
                    'linkedin',
                    '',
                    'icon-linkedin',
                    false
            ));
            actions.put('envelope', new Action(
                    ACT_SHARE,
                    '',
                    'icon-envelope',
                    false
            ));

            studyDetailActions.add(new Action(
                    'shares',
                    LABEL_SHARE,
                    'share',
                    false
            ));
        }

        studyDetailActions.add(new Action(
                'backHome',
                TranslateHelper.getLabelValue('Link_Back_To_Home'),
                'icon-home-brand-new',
                false
        ));
    }

}