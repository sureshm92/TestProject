@IsTest
global class Test_HumanAPIMultipleCallout implements HttpCalloutMock {    
     
        public HTTPResponse respond(HTTPRequest req) { 
            System.debug('sit');
            System.debug('req'+req);
            System.debug('req.getEndpoint():::'+req.getEndpoint());
            System.debug('req.getBody::::'+req.getBody());
            HTTPResponse res = new HTTPResponse(); 
            res.setStatusCode(200); 
            if (req.getEndpoint().endsWith('Connect')) {
                String cmap=req.getBody();
                System.debug('cmap:::'+cmap);
				Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(cmap);
                if(result.get('type')=='session'){
                    
                res.setBody(JSON.serialize(new Map<String, Object>{ 
                        'expires_in' => '3600', 
                        'human_id' => 'e34d94a431bee5c579fee38da041ced1', 
                        'session_token' => 'Resource1 successfully updated'
                            
                })); 
                    System.debug('sessionk');
                    return res; 
                }
                if(result.get('type')=='id'){
                    System.debug('cid');
                res.setBody(JSON.serialize(new Map<String, Object>{ 
                        'token_type' => '3600', 
                        'id_token' => 'e34d94a431bee5c579fee38da041ced1', 
                        'id_refresh_token' => 'Resource1 successfully updated',
                        'id_token_expires_in' => '777'
                            
                })); 
                     return res; 
                }
                if(result.get('type')=='access'){
                    System.debug('acd');
                res.setBody(JSON.serialize(new Map<String, Object>{ 
                        'token_type' => 'Bearer', 
                        'access_token' => 'e34d94a431bee5c579fee38da041ced1', 
                        'refresh_token' => 'Resource1 successfully updated',
                        'expires_in' => '777'
                            
                })); 
                    return res; 
                }
            } else if (req.getEndpoint().endsWith('Sources')) { 
               Map<String,Object> synchStatusValueMap = new Map<String,Object>
				{
				'status' => 'ok'			
				};
                Map<String,Object> synchStatusmap = new Map<String,Object>();
				synchStatusmap.put('syncStatus',synchStatusValueMap);
                synchStatusmap.put('sourceName','Starfleet Medical');
                
                List<Object> objList = new List<Object>();
				objList.add(synchStatusmap);
                res.setBody(JSON.serialize(objList));
            } 
            System.debug('KKK');
            return res; 
        } 
   
}