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
        system.debug('exception respBody'+respBody);
        List<Object> objslist = (List<Object>)Json.deserializeUntyped(respBody); 
        List<Provider> providersList=new List<Provider>();
        for(Object obj : objslist)
        {
            Map<String,Object> mp_StrObj = (Map<string,Object>)obj;
            
            Map<String,Object> objMap=(Map<String,Object>)mp_StrObj.get('syncStatus');
            
            Provider providerObj=new Provider();
            providerObj.providerName =(String)mp_StrObj.get('sourceName');
            if((String)objMap.get('status')=='ok'){
                providerObj.status='Active';
            }else if((String)objMap.get('status')=='inProgress'){
                providerObj.status='In-Progress';
            }else{
                providerObj.status = (String)objMap.get('status');
            }
            providerObj.dotClass = 'slds-p-around_small greendot'; 
            if(providerObj.status=='In-Progress'){
                providerObj.dotClass = 'slds-p-around_small orangedot';
            }
            providersList.add(providerObj);
        }
        Provider providerObj3=new Provider();
        providerObj3.providerName ='providerName ';
        providerObj3.status = 'status';
        return providersList;
    }
    
    
    
    
}