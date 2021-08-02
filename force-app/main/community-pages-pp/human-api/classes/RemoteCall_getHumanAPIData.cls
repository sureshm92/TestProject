public without sharing class RemoteCall_getHumanAPIData {
    
    
    
    public static List<Provider> getHumanSources(String accessToken) {
        System.debug('getHumanSources::');
        List<Provider> providersList=new List<Provider>();
        try {
            System.debug('getHumanSources::22');
            //RemoteCall_getHumanAPITokens remoteTokens =  RemoteCall_getHumanAPITokens.getInstance();
           // RemoteCall_getHumanAPITokens.AccessTokenInfo accessTokenInfo = remoteTokens.remoteCallGetAccessToken();
            //System.debug('accessTokenInfo::'+accessTokenInfo);
           
            String url='HumanAPI_Sources'; 
            Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'Application/JSON ','Authorization' => 'Bearer '+accessToken };
                Map<String, String> requestMap = new Map<String, String>{};
                    HttpCallout remoteCall = new HttpCallout(url,'GET',headerMap,requestMap,RemoteCall_getHumanAPIData.class);
           // String respBody = ;
            providersList = parseHumanResourcesResponse((String)remoteCall.execute());
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        
         
        return providersList;
    }
    
    public static List<Provider> parseHumanResourcesResponse(String respBody)
    {
        
        System.debug('respBody::::'+respBody);
        
        List<Object> objslist = (List<Object>)Json.deserializeUntyped(respBody); 
        System.debug('objslist:::::'+objslist);
        System.debug(objslist.size());
        
        List<Provider> providersList=new List<Provider>();
        for(Object obj : objslist)
        {
            System.debug('obj::::'+obj);
            //Account c = null;
      //  System.debug(c.Id);
            Map<String,Object> mp_StrObj = (Map<string,Object>)obj;
            
            system.debug(mp_StrObj.get('sourceName')+'::::connectedSince==='+mp_StrObj.get('connectedSince'));
            Map<String,Object> objMap=(Map<String,Object>)mp_StrObj.get('syncStatus');
            System.debug('status'+objMap.get('status'));
            
            Provider providerObj=new Provider();
            providerObj.providerName =(String)mp_StrObj.get('sourceName');
            providerObj.status = (String)objMap.get('status');
            providersList.add(providerObj);
        }
        System.debug('providersList::'+providersList); 
          List<sObject> records = new List<sObject>();
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();

        Participant_Enrollment__c peObj=new Participant_Enrollment__c();
        
        if(providersList.size()>0){
        peObj.id=participantState.pe.Id;
        peObj.isAuthorized__c = true;
        records.add(peObj);
        upsert records;
        }
           Provider providerObj3=new Provider();
            providerObj3.providerName ='providerName ';
            providerObj3.status = 'status';
        providersList.add(providerObj3);
         providersList.add(providerObj3);
         providersList.add(providerObj3); 
      providersList.add(providerObj3);
        providersList.add(providerObj3);
        
        return providersList;
    }
    
    
    
    
}