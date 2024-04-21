public without sharing class TokboxSettings {
    public static final String API_URL;
    public static final String API_KEY;
    public static final String API_SECRET;
    public static final String API_ANALYTICS_URL;
    public static final Decimal EARLY_LATE_BUFFER_MINS;
    public static final String SESSION_ID_PARAMETER = 'sessionId';
    public static final String[] HTML_DECODED = new List<String>{ '&', '<', '>', '"', '\'' };
    public static final String[] HTML_ENCODED = new List<String>{
        '&amp;',
        '&lt;',
        '&gt;',
        '&quot;',
        '&#39;'
    };
    
    
    static {
        String sessionId = SFDC_HTMLENCODE(getSessionIdFromURL());
        List<Televisit__c> lstTv = new List<Televisit__c>([Select Id,Televisit_Record_Vendor__c,Televisit_Record_Vendor__r.API_Key__c,Televisit_Record_Vendor__r.API_Secret__c,Session_Id__c from Televisit__c WHERE Session_Id__c =:sessionId limit 1]);
        API_KEY                 = lstTv[0].Televisit_Record_Vendor__r.API_Key__c;
        API_SECRET              = lstTv[0].Televisit_Record_Vendor__r.API_Secret__c;
    }
    
    private static String getSessionIdFromURL() {
        return ApexPages.currentPage().getParameters().get(SESSION_ID_PARAMETER);
    }
    
    public static String SFDC_HTMLENCODE(String input) {
        return ENCODE(input, HTML_DECODED, HTML_ENCODED);
    }
    
    public static String ENCODE(String input, String[] fromArr, String[] toArr) {
        if (input == null || input.length() == 0)
            return input;

        for (Integer i = 0; i < fromArr.size(); ++i) {
            input = input.replace(fromArr[i], toArr[i]);
        }

        return input;
    }

    /*
    static {
        TokBoxSettings2__c tbs = TokBoxSettings2__c.getOrgDefaults();

            API_URL                 = tbs.API_Url__c;
            //API_KEY                 = tbs.API_Key__c;
            API_KEY                 = '47752201';
            //API_SECRET              = tbs.API_Secret__c;
            API_SECRET              = 'f17f94390d0446f1ede3bc4e7d3a5384e72fe6a9';
            API_ANALYTICS_URL       = tbs.API_Analytics_URL__c;
            EARLY_LATE_BUFFER_MINS  = tbs.Early_Late_Buffer_Mins__c != null ? tbs.Early_Late_Buffer_Mins__c : 30;
        
    }
    */    
    
}