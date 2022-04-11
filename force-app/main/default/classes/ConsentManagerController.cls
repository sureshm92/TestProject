public class ConsentManagerController {
    @AuraEnabled
    public static Study_Site__c fetchStudySite(String studySiteId){
        Study_Site__c studySite = new Study_Site__c();
        try {
            studySite = [select Id,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.IQVIA_Outreach__c
            from  Study_Site__c 
            where Id=:studySiteId];
        
            return studySite;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}