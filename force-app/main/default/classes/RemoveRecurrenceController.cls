public class RemoveRecurrenceController {

    @AuraEnabled
    public static Manual_Creation_Panel_Task__c getTaskDetails(String configId){
        Manual_Creation_Panel_Task__c mcpt = new Manual_Creation_Panel_Task__c();
        if(configId != null && configId != ''){
            mcpt = [Select Id,Next_Occurence_Date__c,Status__c,Start_Date__c From Manual_Creation_Panel_Task__c Where Id=:configId];
        }
        return mcpt;
    }
    
    @AuraEnabled
    public static String removeRecurrence(String configId){
        if(configId != null && configId != ''){
            Manual_Creation_Panel_Task__c mcpt = [Select Id,Next_Occurence_Date__c,Status__c,Start_Date__c From Manual_Creation_Panel_Task__c Where Id=:configId];
            try {
                if(mcpt.Start_Date__c > System.today() && mcpt.Start_Date__c == mcpt.Next_Occurence_Date__c){
                    mcpt.Status__c = 'Cancelled';
                    mcpt.Date_Cancelled_Inactive__c = System.today();
                    update mcpt;
                }else {
                    mcpt.Status__c = 'Inactive';
                    mcpt.Date_Cancelled_Inactive__c = System.today();
                    update mcpt;
                }
            } catch (Exception e) {
                System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            }
        }
        return 'Success';
    }
}