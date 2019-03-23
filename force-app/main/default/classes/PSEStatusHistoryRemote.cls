/**
 * Created by Leonid Bartenev
 */

public class PSEStatusHistoryRemote {
    
    public class PathItem{
        @AuraEnabled public String state;
        @AuraEnabled public PSE_Status_History__c pseSH;
        @AuraEnabled public String iconName;
        
        public PathItem(PSE_Status_History__c pseSH){
            this.pseSH = pseSH;
            this.state = 'success';
            this.iconName = 'icon-check';
        }
    }

    @AuraEnabled
    public static String getPSEStatusHistory(Id pseId){
        try{
            List<PSE_Status_History__c> history = [
                    SELECT Id, Status__c, CreatedDate
                    FROM PSE_Status_History__c
                    WHERE PSE__c =: pseId
                    ORDER BY CreatedDate DESC
            ];
            List<PathItem> items = new List<PathItem>();
            for(PSE_Status_History__c pseSH : history) {
                pseSH.Status__c = TranslateHelper.getPickListLabel(Participant_Study_Enrollment__c.Status__c, pseSH.Status__c);
                items.add(new PathItem(pseSH));
            }
            return JSON.serialize(items);
        }catch (Exception e){
            AuraHelper.throwException(e);
            return null;
        }
    }

}