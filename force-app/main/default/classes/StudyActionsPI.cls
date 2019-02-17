/**
 * Created by Leonid Bartenev
 */

public class StudyActionsPI extends StudyActions{
    
    public StudyActionsPI(Study_Site__c studySite){
        this(
                studySite.Clinical_Trial_Profile__r,
                studySite,
                null,
                null
        );
    }
    
    public StudyActionsPI(HCP_Enrollment__c hcpEnrollment){
        this(
                hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r,
                hcpEnrollment.Study_Site__r,
                hcpEnrollment,
                null
        );
    }
    
    public StudyActionsPI(Participant_Enrollment__c pe){
        this(
                pe.Study_Site__r.Clinical_Trial_Profile__r,
                pe.Study_Site__r,
                pe.HCP__r,
                pe
        );
    }
    
    public StudyActionsPI(Clinical_Trial_Profile__c study, Study_Site__c studySite, HCP_Enrollment__c hcpEnrollment, Participant_Enrollment__c pe){
        super(study,studySite, hcpEnrollment, CommunityService.USER_MODE_PI);
    
        //init reasons:
        List<String> manageReferralsStatuses = new List<String>{
                StudySiteService.PI_S_ACCEPTED,
                StudySiteService.PI_S_ACCEPTED_A,
                StudySiteService.PI_S_ON_HOLD,
                StudySiteService.PI_S_ON_HOLD_A
        };
        
        DisableReason manageReferralsStatusesReason = new DisableReason(
                !manageReferralsStatuses.contains(studySite.Override_PI_Referral_Status__c),
                REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_SS_STATUS
        );
        
        DisableReason delegateL3CannotAccept = new DisableReason(
                studyAccessLevel == DelegateService.DELEGATE_LEVEL_3 && pe != null &&
                        pe.Participant_Status__c.contains('Referral') && !pe.Participant_Status__c.contains('Accepted'),
                REASON_LABEL_ACTION_NOT_ALLOWED_ON_ACCESS_LEVEL
        );


        //init actions:
        actions.put(ACT_MANAGE_REFERRALS, new Action(
                ACT_MANAGE_REFERRALS,
                LABEL_MANAGE_REFERRALS,
                'referrals',
                new List<DisableReason>{
                        studyNoLongerEnrollingReason,
                        manageReferralsStatusesReason
                }
        ));
        actions.put(ACT_MANAGE_REFERRING_CLINICS, new Action(
                ACT_MANAGE_REFERRING_CLINICS,
                LABEL_MANAGE_REFERRING_CLINICS,
                'referring-clinic',
                new List<DisableReason>{
                        studyNoLongerEnrollingReason,
                        manageReferralsStatusesReason
                }
        ));
        actions.put(ACT_CHANGE_PE_STATUS_BY_PI, new Action(
                ACT_CHANGE_PE_STATUS_BY_PI,
                null,
                null,
                new List<DisableReason>{
                        delegateL3CannotAccept,
                        hcpOnHoldReason,
                        studySiteOnHoldReason,
                        hcpNotActiveReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason,
                        tcAcceptanceRequiredReason
                }
        ));
    
        actions.put(ACT_HCP_ACTIVATE, new Action(
                ACT_HCP_ACTIVATE,
                LABEL_HCP_ACTIVATE,
                null,
                new List<DisableReason>{
                        level2AndLowReason,
                        hcpLockedByAdmin,
                        studySiteOnHoldReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason,
                        tcAcceptanceRequiredReason
                },
                'green'
        ));
        actions.put(ACT_HCP_APPROVE, new Action(
                ACT_HCP_APPROVE,
                LABEL_HCP_APPROVE,
                null,
                new List<DisableReason>{
                        level2AndLowReason,
                        hcpLockedByAdmin,
                        studySiteOnHoldReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason,
                        tcAcceptanceRequiredReason
                },
                'green'
        ));
        actions.put(ACT_HCP_ORIENTATION_ATTENDED_AND_ACTIVATE, new Action(
                ACT_HCP_ORIENTATION_ATTENDED_AND_ACTIVATE,
                LABEL_HCP_ORIENTATION_ATTENDED_AND_ACTIVATE,
                null,
                new List<DisableReason>{
                        level2AndLowReason,
                        hcpLockedByAdmin,
                        studySiteOnHoldReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason,
                        tcAcceptanceRequiredReason
                },
                'green'
        ));
        actions.put(ACT_HCP_DECLINE, new Action(
                ACT_HCP_DECLINE,
                LABEL_HCP_DECLINE,
                null,
                new List<DisableReason>{
                        level2AndLowReason,
                        hcpLockedByAdmin,
                        studySiteOnHoldReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason,
                        tcAcceptanceRequiredReason
                },
                'red'
        ));
        actions.put(ACT_HCP_DEACTIVATE, new Action(
                ACT_HCP_DEACTIVATE,
                LABEL_HCP_DEACTIVATE,
                null,
                new List<DisableReason>{
                        supportLevelReason,
                        hcpLockedByAdmin,
                        studySiteOnHoldReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason,
                        tcAcceptanceRequiredReason
                },
                'red'
        ));
        actions.put(ACT_HCP_ON_HOLD, new Action(
                ACT_HCP_ON_HOLD,
                LABEL_HCP_ON_HOLD,
                null,
                new List<DisableReason>{
                        level2AndLowReason,
                        hcpLockedByAdmin,
                        studySiteOnHoldReason,
                        studySiteNotAcceptedReason,
                        studyNoLongerEnrollingReason,
                        tcAcceptanceRequiredReason
                },
                'orange'
        ));
        
        List<String> openToReceiveReferralsStatuses = new List<String>{
                StudySiteService.PI_S_INVITATION_SENT,
                StudySiteService.PI_S_DECLINED_ACCEPTANCE,
                StudySiteService.PI_S_NON_RESPONCIVE_A
        };
        
        actions.put(ACT_OPEN_TO_RECEIVE_REFERRALS, new Action(
                ACT_OPEN_TO_RECEIVE_REFERRALS,
                LABEL_OPEN_TO_RECEIVE_REFERRALS,
                'check-in-square-cut',
                new List<DisableReason>{
                        level1AndLowReason,
                        studyNoLongerEnrollingReason,
                        tcAcceptanceRequiredReason,
                        new DisableReason(
                                !openToReceiveReferralsStatuses.contains(studySite.Override_PI_Referral_Status__c),
                                REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_SS_STATUS
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
                        new DisableReason(
                                studySite.Override_PI_Referral_Status__c != StudySiteService.PI_S_INVITATION_SENT,
                                REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_SS_STATUS
                        )
                },
                'secondary'
        ));
        
        //init study item actions list
        if(manageReferralsStatuses.contains(studySite.Override_PI_Referral_Status__c)){
            studyListViewItemActions.add(actions.get(ACT_MANAGE_REFERRALS));
            studyListViewItemActions.add(actions.get(ACT_MANAGE_REFERRING_CLINICS));
        }
        
        if(openToReceiveReferralsStatuses.contains(studySite.Override_PI_Referral_Status__c)){
            if(isTCAcceptanceRequired){
                studyListViewItemActions.add(actions.get(ACT_VIEW_TC));
            }else{
                studyListViewItemActions.add(actions.get(ACT_OPEN_TO_RECEIVE_REFERRALS));
            }
        }
        if(studySite.Override_PI_Referral_Status__c == StudySiteService.PI_S_INVITATION_SENT){
            studyListViewItemActions.add(actions.get(ACT_NO_THANKS));
        }
        
        //prepare bottom bar actions:
        if(openToReceiveReferralsStatuses.contains(studySite.Override_PI_Referral_Status__c)){
            if(isTCAcceptanceRequired){
                studyDetailBottomBarActions.add(actions.get(ACT_VIEW_TC));
            }else{
                studyDetailBottomBarActions.add(actions.get(ACT_OPEN_TO_RECEIVE_REFERRALS));
            }
            if(studySite.Override_PI_Referral_Status__c == StudySiteService.PI_S_INVITATION_SENT){
                studyDetailBottomBarActions.add(actions.get(ACT_NO_THANKS));
            
            }
        }
        
        //prepare study detail actions list:
        if(study.Terms_And_Conditions_ID__c != null) studyDetailActions.add(actions.get(ACT_VIEW_TC));
    
    
      
    }

}