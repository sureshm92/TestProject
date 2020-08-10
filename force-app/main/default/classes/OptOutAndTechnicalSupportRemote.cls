public class OptOutAndTechnicalSupportRemote{
    @AuraEnabled
    public static List<OptOutAndTechnicalSupport.InitDataWrapper> getInitData(String strLanguage){
        try{
            return OptOutAndTechnicalSupport.getOptoutAndTechnicalSupportData(strLanguage);
        }
        Catch(Exception e){
             throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        
    }
    @AuraEnabled
    public static void createSupportCases(String strOptOutValue,String strTechSupportValue,String strContactId){
        try{
            OptOutAndTechnicalSupport.createSupportCases(strOptOutValue,strTechSupportValue,strContactId);
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
}