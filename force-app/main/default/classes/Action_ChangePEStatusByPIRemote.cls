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
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void updatePE(String peId, String status, String reason, String notes) {
        try {
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                    Id = peId,
                    Participant_Status_Last_Changed_Date__c = Datetime.now(),
                    Last_Status_Changed_Notes__c = notes,
                    Participant_Status__c = status,
                    Non_Enrollment_Reason__c = reason
            );

            if (status == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS) {
                pe.Informed_Consent__c = true;
            }
            update pe;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

}