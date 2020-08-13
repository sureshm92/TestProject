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
    public static void createSupportCases(List<String> optOutValueList,List<String> techSupportValueList,String strContactId){
        try{
            OptOutAndTechnicalSupport.createSupportCases(optOutValueList,techSupportValueList,strContactId);
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
}