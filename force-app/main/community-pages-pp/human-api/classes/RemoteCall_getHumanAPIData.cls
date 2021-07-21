public class RemoteCall_getHumanAPIData {
    
    
    
    public static List<Provider> getHumanSources() {
        System.debug('getHumanSources::');
        List<Provider> providersList=new List<Provider>();
        try {
            System.debug('getHumanSources::22');
            RemoteCall_getHumanAPITokens remoteTokens =  RemoteCall_getHumanAPITokens.getInstance();
            RemoteCall_getHumanAPITokens.AccessTokenInfo accessTokenInfo = remoteTokens.remoteCallGetAccessToken();
            System.debug('accessTokenInfo::'+accessTokenInfo);
            String url='HumanAPI_Sources'; 
            Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'Application/JSON ','Authorization' => 'Bearer '+accessTokenInfo.access_token };
                Map<String, String> requestMap = new Map<String, String>{};
                    HttpCallout remoteCall = new HttpCallout(url,'GET',headerMap,requestMap,RemoteCall_getHumanAPIData.class);
            String respBody = (String)remoteCall.execute();
            providersList = parseHumanResourcesResponse(respBody);
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        return providersList;
    }
    
    public static List<Provider> parseHumanResourcesResponse(String respBody)
    {
        List<Object> objslist = (List<Object>)Json.deserializeUntyped(respBody);      
        List<Provider> providersList=new List<Provider>();
        for(Object obj : objslist)
        {
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
        return providersList;
    }
    
    
    
    
}