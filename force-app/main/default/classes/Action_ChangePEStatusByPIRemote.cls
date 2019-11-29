/**
 * Created by Leonid Bartenev
 */

public without sharing class Action_ChangePEStatusByPIRemote {

    @AuraEnabled
    public static String getReferralDeclineReasons() {
        try {
            List<LabelValueItem> referralDeclineReasons = new List<LabelValueItem>();
            for (String reason : ReferralProfileRemote.REASONS_MAP.get('Referral Declined')) {
                referralDeclineReasons.add(new LabelValueItem(TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c, reason), reason));
            }
            return JSON.serialize(referralDeclineReasons);
        } catch (Exception e) {
            return (String)AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String updatePE(String pe, String status, String reason, String notes) {
        Participant_Enrollment__c penr = (Participant_Enrollment__c) JSON.deserialize(pe,Participant_Enrollment__c.class);
        if(status == 'Enrollment Success'){
            update penr;
        }
        try {
            Participant_Enrollment_Status_History__c history = new Participant_Enrollment_Status_History__c(
                    Date__c = Datetime.now(),
                    Status__c = status,
                    Notes__c = notes,
                    ParticipantEnrollment__c = penr.Id,
                    Reason__c = reason
            );
            insert history;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return ReferralProfileRemote.getReferralProfileDetail(penr.Id, CommunityService.USER_MODE_PI);
    }
}