public with sharing class OpenTokJWT {
    
    private final String apiUrl;
    private final String apiKey;
    private final String apiSecret;

    public OpenTokJWT(String apiUrl, String apiKey, String apiSecret) {
        this.apiUrl     = apiUrl;
        this.apiKey     = apiKey;
        this.apiSecret  = apiSecret;
    }

    public class JWTHeader {
        public String alg {get; set;}
        public String typ {get; set;}
    }

    public class JWTPayload {
        public String iss {get; set;}
        public String ist {get; set;}
        public String iat {get; set;}
        public String exp {get; set;}
    }

    public String getAuthJWTHeader() {

        JWTPayload jwtToken = new JWTPayload();
        jwtToken.iss = apiKey;
        jwtToken.ist = 'project';
        jwtToken.iat = String.valueOf(Datetime.now().getTime()/1000);
        jwtToken.exp = String.valueOf(Datetime.now().addMinutes(3).getTime()/1000);

        JWTHeader jwtHeader = new JWTHeader();
        jwtHeader.alg = 'HS256';
        jwtHeader.typ = 'JWT';
        
        String unSignedJWT = getJWT(jwtHeader, jwtToken);
        String signedJWT = getSignature(unSignedJWT);
    
        return unSignedJWT + '.' + signedJWT;
    }

    private String getSignature(String jwt){
        if (String.isEmpty(jwt)) {
            return 'No value provided for required jwt parameter.';
        }

        if (String.isEmpty(apiSecret)) {
            return 'No value provided for required apiSecret parameter.';
        }

        Blob data = Crypto.generateMac('HmacSHA256', Blob.valueOf(jwt), Blob.valueOf(apiSecret));
        return base64URLEncode(data);           
    }

    private String getJWT(JWTHeader jwtHeader, JWTPayload jwtToken) {
        return base64URLEncode(Blob.valueOf(JSON.serialize(jwtHeader))) + '.' + base64URLEncode(Blob.valueOf(JSON.serialize(jwtToken)));
    }

    private static String base64URLEncode(Blob input){ 
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');

        while ( output.endsWith('=')) {
            output = output.subString(0,output.length()-1);
        }
        
        return output;
    }
}