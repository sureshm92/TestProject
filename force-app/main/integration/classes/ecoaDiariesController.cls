public class ecoaDiariesController {

    public static final String DIARY_URL = 'DiaryURL';
    public static final String ECOA_INTEGRATION = 'ECOAIntegration';
    public static final String ALGORITHM = 'Algorithm';
    public static final String ISSUER_GUID ='IssuerGuid';
    public static final String AUD ='Environment';
    public static final String ACTOR_TYPE ='ActorType';
    public static final String SCHEDULE ='eCOASchedule';

    @AuraEnabled
    public static String getToken() {
        //get study guid 
        //Subject_GUID
        String subjectGUID;
        String studyGUID;
        
        if(ParticipantContext.getCurrentPEId() != null ){
            studyGUID = ParticipantContext.getCurrentPE().Clinical_Trial_Profile__r.Study_GUID__c;
            subjectGUID = ParticipantContext.getCurrentPE().Subject_GUID__c;
        }
        Map<String, Config_API_Param__mdt> ecoaMetaMap = new Map<String, Config_API_Param__mdt>();
        for (Config_API_Param__mdt mdt : [
            SELECT DeveloperName, ParamValue__c,Param_Value_Long__c
            FROM Config_API_Param__mdt
            WHERE ConfigAPI__r.DeveloperName = :ECOA_INTEGRATION
        ]) {
            ecoaMetaMap.put(mdt.DeveloperName, mdt);
        }

        String jwtToken;
        String endpoint = ecoaMetaMap.get(DIARY_URL).ParamValue__c;
        String payload;
        String verifySign;
        String pvtKey;
        String pubKey ;
        pvtKey = ecoaMetaMap.get('PrivateKey').Param_Value_Long__c;
		pvtkey=pvtkey.replace('\n', '');
        String header ;
		
        JSONGenerator alg = JSON.createGenerator(false);
        alg.writeStartObject();
        alg.writeStringField('alg', ecoaMetaMap.get(ALGORITHM).ParamValue__c);
        alg.writeStringField('typ', 'JWT');
        alg.writeEndObject();
        header=base64URLencode(Blob.valueOf(alg.getAsString()));
        
        JSONGenerator header1 = JSON.createGenerator(false);
        header1.writeStartObject();
        header1.writeStringField('alg', 'RS256');
        header1.writeEndObject();
        
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('iss', ecoaMetaMap.get(ISSUER_GUID).ParamValue__c);
        body.writeStringField('sub', 'guid:'+subjectGUID);
        body.writeStringField('aud', ecoaMetaMap.get(AUD).ParamValue__c);
        Long rightNow = (dateTime.now().getTime()/1000)+1;
        body.writeNumberField('iat', rightNow);
        body.writeNumberField('exp', (rightNow + 36000));
        body.writeStringField('ecoa:study_guid', studyGUID);
        body.writeStringField('ecoa:actor_type', ecoaMetaMap.get(ACTOR_TYPE).ParamValue__c);
        body.writeStringField('ecoa:actor_id', 'guid:'+subjectGUID);
        body.writeStringField('ecoa:schedule', ecoaMetaMap.get(SCHEDULE).ParamValue__c);
        body.writeEndObject();
        
		payload=base64URLencode(Blob.valueOf(body.getAsString()));
        
        String algorithmName = 'rsa-sha256';
       
        Blob privateKey = EncodingUtil.base64Decode(pvtKey);
        
        String jwtTemp= header + '.'+ payload;
        Blob sign = Crypto.sign(algorithmName, Blob.valueOf(jwtTemp), privateKey);
        
        
        String output = EncodingUtil.base64Encode(sign); 
        output = output.replace('+', '-'); 
        output = output.replace('/', '_'); 
        while ( output.endsWith('=')){ 
            output = output.subString(0,output.length()-1); 
        }
        jwtToken = jwtTemp +'.' + output;
        return endpoint+jwtToken;

    }
    public static String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input); 
        output = output.replace('+', '-'); 
        output = output.replace('/', '_'); 
        while ( output.endsWith('=')){ 
            output = output.subString(0,output.length()-1); 
        } 
        return output; 
    }
}