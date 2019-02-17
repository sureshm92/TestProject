/**
 * Created by Leonid Bartenev
 */

public class Action_ChangePEStatusByPIRemote {
    
    @AuraEnabled
    public static String getReferralDeclineReasons(){
        try {
            List<LabelValueItem> referralDeclineReasons = new List<LabelValueItem>();
            for(String reason : ReferralProfileRemote.REASONS_MAP.get('Referral Declined')){
                referralDeclineReasons.add(new LabelValueItem(TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c,reason), reason));
            }
            return JSON.serialize(referralDeclineReasons);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static void updatePE(String peId, String status, String reason, String notes){
        Savepoint sp = Database.setSavepoint();
        try{
            Participant_Enrollment__c pe  = [SELECT Id, Participant__c FROM Participant_Enrollment__c WHERE Id =: peId];
            pe.Id = peId;
            pe.Participant_Status_Last_Changed_Date__c = Datetime.now();
            pe.Last_Status_Changed_Notes__c = notes;
            pe.Participant_Status__c = status;
            pe.Non_Enrollment_Reason__c = reason;
            update pe;
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}