public class StudyActionsParticipant /*extends StudyActions*/ {
   /* public StudyActionsParticipant(Participant_Enrollment__c participantEnrollment){
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

        studyDetailActions.add(new Action(
                'downloadConsent',
                'Download Consent',
                'icon-import',
                false
        ));
        studyDetailActions.add(new Action(
                ACT_SHARE,
                LABEL_SHARE,
                'share',
                false
        ));
        studyDetailActions.add(new Action(
                'backHome',
                'Back to Home',
                'icon-home',
                false
        ));
    }*/

    public List <StudyActions.Action> studyDetailActions ;
    public Map<String, StudyActions.Action> actions;


    public StudyActionsParticipant() {
        this.actions  = new Map<String, StudyActions.Action>();
        this.studyDetailActions = new List<StudyActions.Action>();

        actions.put('facebook', new StudyActions.Action(
                'facebook',
                '',
                'icon-facebook',
                false
        )) ;
        actions.put('twitter', new StudyActions.Action(
                'twitter',
                '',
                'icon-twitter',
                false
        )) ;
        actions.put('linkedin', new StudyActions.Action(
                'linkedin',
                '',
                'icon-linkedin',
                false
        ));
        actions.put('envelope', new StudyActions.Action(
                StudyActions.ACT_SHARE,
                '',
                'icon-envelope',
                false
        ));

//        studyDetailActions.add(new StudyActions.Action(
//                'downloadConsent',
//                'Download Consent',
//                'icon-download-brand-new',
//                false
//        ));
        studyDetailActions.add(new StudyActions.Action(
                'shares',
                StudyActions.LABEL_SHARE,
                'share',
                false
        ));
        studyDetailActions.add(new StudyActions.Action(
                'backHome',
                'Back to Home',
                'icon-home-brand-new',
                false
        ));

    }


}