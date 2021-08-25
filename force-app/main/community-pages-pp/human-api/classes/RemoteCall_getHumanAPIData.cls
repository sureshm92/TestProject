public without sharing class RemoteCall_getHumanAPIData {
    
    
    
    public static List<Provider> getHumanSources(String accessToken) {
        List<Provider> providersList=new List<Provider>();
        if(accessToken != null){
            
            try {
                
                String url='HumanAPI_Sources'; 
                Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'Application/JSON ','Authorization' => 'Bearer '+accessToken };
                    Map<String, String> requestMap = new Map<String, String>{};
                        HttpCallout remoteCall = new HttpCallout(url,'GET',headerMap,requestMap,RemoteCall_getHumanAPIData.class);
                providersList = parseHumanResourcesResponse((String)remoteCall.execute());
            }catch (Exception e){
                AuraHelper.throwException(e);
            }
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
            
            Map<String,Object> objMap=(Map<String,Object>)mp_StrObj.get('syncStatus');
            
            Provider providerObj=new Provider();
            providerObj.providerName =(String)mp_StrObj.get('sourceName');
            providerObj.status = (String)objMap.get('status');
            providersList.add(providerObj);
        }
        Provider providerObj3=new Provider();
        providerObj3.providerName ='providerName ';
        providerObj3.status = 'status';
        return providersList;
    }
    
    
    
    
}