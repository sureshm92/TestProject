/**
 * Created by Leonid Bartenev
 */

public class StudyActionsHCP extends StudyActions{

    public StudyActionsHCP(HCP_Enrollment__c hcpEnrollment){
        this(
                hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r,
                hcpEnrollment.Study_Site__r,
                hcpEnrollment
        );
    }

    public StudyActionsHCP(Participant_Enrollment__c pe){
        this(
                pe.Study_Site__r.Clinical_Trial_Profile__r,
                pe.Study_Site__r,
                pe.HCP__r
        );
    }

    public StudyActionsHCP(Clinical_Trial_Profile__c study, Study_Site__c studySite, HCP_Enrollment__c hcpEnrollment){
        super(study,studySite, hcpEnrollment, CommunityService.USER_MODE_HCP);

        //init actions:
        actions.put(ACT_MEDICAL_RECORD_REVIEW, new Action(
                ACT_MEDICAL_RECORD_REVIEW,
                LABEL_MEDICAL_RECORD_REVIEW,
                'chart-review-sent',
                new List<DisableReason>{
                        tcAcceptanceRequiredReason,
                        hcpOnHoldReason,
                        studySiteOnHoldReason,
                        hcpNotActiveReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason
                }
        ));

        actions.put(ACT_EXCLUDE_FROM_REFERRING, new Action(
                ACT_EXCLUDE_FROM_REFERRING,
                LABEL_EXCLUDE_FROM_REFERRING,
                '',
                new List<DisableReason>{
                        level2AndLowReason,
                        tcAcceptanceRequiredReason,
                        hcpOnHoldReason,
                        studySiteOnHoldReason,
                        hcpNotActiveReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason
                }
        ));

        actions.put(ACT_UNDO_EXCLUDE_FROM_REFERRING, new Action(
                ACT_UNDO_EXCLUDE_FROM_REFERRING,
                LABEL_UNDO_EXCLUDE_FROM_REFERRING,
                '',
                new List<DisableReason>{
                        level2AndLowReason,
                        tcAcceptanceRequiredReason,
                        hcpOnHoldReason,
                        studySiteOnHoldReason,
                        hcpNotActiveReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason
                }
        ));

        actions.put(ACT_REFER_TO_THIS_STUDY, new Action(
                ACT_REFER_TO_THIS_STUDY,
                LABEL_REFER_TO_THIS_STUDY,
                'referral',
                new List<DisableReason>{
                        level2AndLowReason,
                        tcAcceptanceRequiredReason,
                        hcpOnHoldReason,
                        studySiteOnHoldReason,
                        hcpNotActiveReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason
                }
        ));

        actions.put(ACT_REFER, new Action(
                ACT_REFER,
                LABEL_REFER,
                'referral',
                new List<DisableReason>{
                        level2AndLowReason,
                        tcAcceptanceRequiredReason,
                        hcpOnHoldReason,
                        studySiteOnHoldReason,
                        hcpNotActiveReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason
                }
        ));

        List<String> shareStatuses = new List<String>{
                HCPEnrollmentService.HCP_S_ACTIVATED,
                HCPEnrollmentService.HCP_S_ACTIVATED_A,
                HCPEnrollmentService.HCP_S_APPROVAL_PENDING,
                HCPEnrollmentService.HCP_S_ACTIVATION_PENDING,
                HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O,
                HCPEnrollmentService.HCP_S_ON_HOLD_A,
                HCPEnrollmentService.HCP_S_ON_HOLD_ACCEPTANCE,
                HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION,
                HCPEnrollmentService.HCP_S_ON_HOLD_APPROVAL,
                HCPEnrollmentService.HCP_S_DEACTIVATED_A,
                HCPEnrollmentService.HCP_S_DECLINED_ACCEPTANCE
        };
    
        actions.put(ACT_SHARE, new Action(
                ACT_SHARE,
                LABEL_SHARE,
                'share',
                new List<DisableReason>{
                        new DisableReason(
                                hcpEnrollment== null || !shareStatuses.contains(hcpEnrollment.Status__c),
                                REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_HCP_STATUS
                        )
                }
        ));

        List<String> findStudySiteStatuses = new List<String>{
                HCPEnrollmentService.HCP_S_INVITATION_SENT,
                HCPEnrollmentService.HCP_S_DECLINED_ACCEPTANCE,
                HCPEnrollmentService.HCP_S_NON_RESPONCIVE_A
        };
    
        actions.put(ACT_FIND_STUDY_SITES, new Action(
                ACT_FIND_STUDY_SITES,
                LABEL_FIND_STUDY_SITES,
                'referred-clinic',
                new List<DisableReason>{
                        studyNoLongerEnrollingReason,
                        new DisableReason(
                                hcpEnrollment== null || !findStudySiteStatuses.contains(hcpEnrollment.Status__c),
                                REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_HCP_STATUS
                        )
                },
                'primary'
        ));

        actions.put(ACT_NO_THANKS, new Action(
                ACT_NO_THANKS,
                LABEL_NO_THANKS,
                'icon-disabled',
                new List<DisableReason>{
                        studyNoLongerEnrollingReason,
                        studySiteOnHoldReason,
                        new DisableReason(
                                hcpEnrollment== null || hcpEnrollment.Status__c != HCPEnrollmentService.HCP_S_INVITATION_SENT,
                                REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_HCP_STATUS
                        )
                },
                'secondary'
        ));
    
    
        actions.put(ACT_SEND_SITE_REQUEST, new Action(
                ACT_SEND_SITE_REQUEST,
                LABEL_SEND_SITE_REQUEST,
                '',
                new List<DisableReason>{
                        level1AndLowReason,
                        tcAcceptanceRequiredReason,
                        new DisableReason(
                                hcpEnrollment== null || !findStudySiteStatuses.contains(hcpEnrollment.Status__c),
                                REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_HCP_STATUS
                        ),
                        studyNoLongerEnrollingReason
                }
        ));


        //prepare study item actions list:
        //MRR, Referring
        if(hcpEnrollment!= null && HCPEnrollmentService.STATUS_GROUP_ACTIVATED.contains(hcpEnrollment.Status__c)){
            if(study.Link_to_Medical_Record_Review__c != null) studyListViewItemActions.add(actions.get(ACT_MEDICAL_RECORD_REVIEW));
            if(study.Link_to_Pre_screening__c != null) studyListViewItemActions.add(actions.get(ACT_REFER_TO_THIS_STUDY));
            if(study.Link_to_Medical_Record_Review__c != null && study.Link_to_Pre_screening__c == null){
                studyListViewItemActions.add(actions.get(ACT_REFER));
            }
        }

        //Accept TC
        List<String> tcStatuses = new List<String>{
                HCPEnrollmentService.HCP_S_INVITATION_SENT,
                HCPEnrollmentService.HCP_S_NON_RESPONCIVE_A,
                HCPEnrollmentService.HCP_S_DECLINED_ACCEPTANCE,
                HCPEnrollmentService.HCP_S_DECLINED_APPROVAL,
                HCPEnrollmentService.HCP_S_DECLINE_ACTIVATION,
                HCPEnrollmentService.HCP_S_DECLINED_A

        };
        if(hcpEnrollment!= null && tcStatuses.contains(hcpEnrollment.Status__c) && (isTCAcceptanceRequired)){
            studyListViewItemActions.add(actions.get(ACT_VIEW_TC));
        }

        //Find study sites:
        if(hcpEnrollment!= null && findStudySiteStatuses.contains(hcpEnrollment.Status__c) && !isTCAcceptanceRequired){
            studyListViewItemActions.add(actions.get(ACT_FIND_STUDY_SITES));
        }

        //No thanks:
        if(hcpEnrollment!= null && hcpEnrollment.Status__c == HCPEnrollmentService.HCP_S_INVITATION_SENT){
            studyListViewItemActions.add(actions.get(ACT_NO_THANKS));
        }

        //Share
        if(hcpEnrollment!= null && shareStatuses.contains(hcpEnrollment.Status__c)) studyListViewItemActions.add(actions.get(ACT_SHARE));


        //prepare study detail actions list:
        if(study.Link_to_Medical_Record_Review__c != null) studyDetailActions.add(actions.get(ACT_MEDICAL_RECORD_REVIEW));
        if(study.Link_to_Pre_screening__c != null) studyDetailActions.add(actions.get(ACT_REFER_TO_THIS_STUDY));
        if(study.Link_to_Medical_Record_Review__c != null && study.Link_to_Pre_screening__c == null){
            studyDetailActions.add(actions.get(ACT_REFER));
        }
        if(study.Terms_And_Conditions_ID__c != null) studyDetailActions.add(actions.get(ACT_VIEW_TC));
        studyDetailActions.add(actions.get(ACT_SHARE));

        //prepare bottom bar actions:
        if(hcpEnrollment!= null && findStudySiteStatuses.contains(hcpEnrollment.Status__c)){
            if(isTCAcceptanceRequired){
                studyDetailBottomBarActions.add(actions.get(ACT_VIEW_TC));
            }else{
                studyDetailBottomBarActions.add(actions.get(ACT_FIND_STUDY_SITES));
            }
            if(hcpEnrollment.Status__c == HCPEnrollmentService.HCP_S_INVITATION_SENT){
                studyDetailBottomBarActions.add(actions.get(ACT_NO_THANKS));
            }
        }
    }

}