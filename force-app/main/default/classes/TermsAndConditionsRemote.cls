/**
 * Created by Leonid Bartenev
 */

public without sharing class TermsAndConditionsRemote {

    class TCData{
        Terms_And_Conditions__c tc;
        Datetime acceptedDate;
        Boolean isAccepted;
        Clinical_Trial_Profile__c trial;
        
    }

    @AuraEnabled
    public static String getPortalTcData() {
        try{
            return JSON.serialize(getTCData(TermsAndConditions.getPortalTC()));
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String getTrialTcData(Id ctpId){
        try{
            TCData tcData = getTCData(TermsAndConditions.getTrialTC(ctpId));
            tcData.trial = SudyTrialService.getFullTrial(ctpId);
            return JSON.serialize(tcData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String getTC(Id tcId, String languageCode){
        try{
            TCData tcData = new TCData();
            tcData.tc = TermsAndConditions.getTC(tcId, languageCode);
            return JSON.serialize(tcData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static void acceptTC(Id tcId){
        try{
            TermsAndConditions.acceptTC(tcId);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static TCData getTCData(Terms_And_Conditions__c tc){
        TCData tcData = new TCData();
        if(tc != null){
            tcData.tc = tc;
            Terms_And_Conditions_Acceptance__c tca = TermsAndConditions.getTCA(tc.Id);
            tcData.isAccepted = tca != null;
            if(tca != null) tcData.acceptedDate = tca.Accepted_Date__c;
        }
        return tcData;

    }


}