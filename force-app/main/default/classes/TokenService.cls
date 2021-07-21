public without sharing class TokenService {
    
    public static void storeToken(String participantReferralId,String tokenType, String token) {
        try{
        List<Token__c> tokenDataToUpsert = new List<Token__c>();
        List<Token__c> existingTokenData= [Select Id,Participant_Enrollment__c,Token_Type__c,Token_Value__c,Expiration_Date__c from Token__c where Participant_Enrollment__c =: participantReferralId AND Token_Type__c =: tokenType];
        if(existingTokenData.size() >0){
           if(tokenType == 'access'){
             existingTokenData[0].Participant_Enrollment__c = participantReferralId;
             existingTokenData[0].Token_Type__c = tokenType;
             existingTokenData[0].Token_Value__c = token;
             existingTokenData[0].Expiration_Date__c = System.now().addDays(1);
  
        }else{
             existingTokenData[0].Participant_Enrollment__c = participantReferralId ;
             existingTokenData[0].Token_Type__c = tokenType ;
             existingTokenData[0].Token_Value__c = token ;                                     
             existingTokenData[0].Expiration_Date__c = System.now().addSeconds(3600);
        } 
            tokenDataToUpsert = existingTokenData;
        }
        else{
             if(tokenType == 'access'){
              tokenDataToUpsert.add(new Token__c(Participant_Enrollment__c = participantReferralId ,Token_Type__c = tokenType , Token_Value__c = token , Expiration_Date__c = System.now().addDays(1)));
  
        }else{
            tokenDataToUpsert.add(new Token__c(Participant_Enrollment__c = participantReferralId ,Token_Type__c = tokenType , Token_Value__c = token , Expiration_Date__c = System.now().addSeconds(3600)));
        }
        }
        if(existingTokenData.size() > 0){
            update tokenDataToUpsert;
        }
        else{
            insert tokenDataToUpsert;
        }
         
        }
        catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
    
     public static string fetchToken(String participantReferralId,String tokenType) {
         try{
         String token;
         List<Token__c> tokenData = [Select Id,Participant_Enrollment__c,Token_Type__c,Token_Value__c,Expiration_Date__c from Token__c where Participant_Enrollment__c =: participantReferralId AND Token_Type__c =: tokenType];
         if(tokenData.size() > 0 && tokenData[0].Token_Value__c != null && System.now() < tokenData[0].Expiration_Date__c ){
             token = tokenData[0].Token_Value__c;
         }
             return token;
         }
         catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

}