public without sharing class TokenService {
    
    
  
    public static void storeToken(String participantReferralId,String tokenType, String token,String humanId,String expiresIn) {
        try{
        TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.class
            );

        List<sObject> records = new List<sObject>();
        system.debug('inside storeToken');
        List<Token__c> tokenDataToUpsert = new List<Token__c>();
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        Participant_Enrollment__c peObj=new Participant_Enrollment__c();
        peObj.id=participantReferralId;
        system.debug('participantReferralId '+participantReferralId);

        if(String.isNotBlank(humanId)) 
        {   system.debug('humanId '+humanId);

            peObj.Human_Id__c = humanId;
        } 
        List<Token__c> existingTokenData= [Select Id,Participant_Enrollment__c,Token_Type__c,Token_Value__c,Expiration_Date__c from Token__c where Participant_Enrollment__c =: participantReferralId AND Token_Type__c =: tokenType];
        if(existingTokenData !=null && existingTokenData.size() >0){
                    system.debug(' existingTokenData'+existingTokenData);

             existingTokenData[0].Participant_Enrollment__c = participantReferralId ;
             existingTokenData[0].Token_Type__c = tokenType ;
             existingTokenData[0].Token_Value__c = token ;  
            System.debug('expiresIn::::'+expiresIn);
             existingTokenData[0].Expiration_Date__c = System.now().addSeconds(Integer.valueOf(expiresIn));
             tokenDataToUpsert = existingTokenData;
        }
        else{
            tokenDataToUpsert.add(new Token__c(Participant_Enrollment__c = participantReferralId ,Token_Type__c = tokenType , Token_Value__c = token , Expiration_Date__c = System.now().addSeconds(Integer.valueOf(expiresIn))));
        }
        records.addAll(tokenDataToUpsert);
        if(String.isEmpty(participantState.pe.Human_Id__c)){
                        records.add(peObj);
         }
       /** if(existingTokenData.size() > 0){
            update records;
        }
        else{
            insert records;
        } **/
        upsert records;  
         
        }
        catch (Exception e) {
            Contact c = null;
          //  System.debug(c.Id);
          System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            if(tokenType=='session') AuraHelper.throwException(e);
        }
    }
    
     public static string fetchToken(String participantReferralId,String tokenType) {
         try{
         String token = '';
         System.debug('participantReferralId:::'+participantReferralId+'tokenType:::'+tokenType);
         List<Token__c> tokenData = [Select Id,Participant_Enrollment__c,IsActive__c,Token_Type__c,Token_Value__c,Expiration_Date__c from Token__c where Participant_Enrollment__c =: participantReferralId AND Token_Type__c =: tokenType AND IsActive__c = true];
         if(tokenData != null && tokenData.size() > 0 && tokenData[0].Token_Value__c != null && tokenData[0].IsActive__c == true ){
             System.debug('tokenvalue:::: '+tokenData[0].Token_Value__c);
             token = tokenData[0].Token_Value__c; 
         }
             System.debug('participantReferralId:::'+participantReferralId+'token:::'+token);
             return token;
         }
         catch (Exception e) {
            //return (String) AuraHelper.throwException(e);
            AuraHelper.throwException(e);
             return '';
        }
    }

}