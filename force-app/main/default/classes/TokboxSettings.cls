public with sharing class TokboxSettings {

	public static final String API_URL;
    public static final String API_KEY;
    public static final String API_SECRET;
    public static final String API_ANALYTICS_URL;
    public static final Decimal EARLY_LATE_BUFFER_MINS;

    static {
        TokBoxSettings2__c tbs = TokBoxSettings2__c.getOrgDefaults();

            API_URL                 = tbs.API_Url__c;
            API_KEY                 = tbs.API_Key__c;
            API_SECRET              = tbs.API_Secret__c;
            API_ANALYTICS_URL       = tbs.API_Analytics_URL__c;
            EARLY_LATE_BUFFER_MINS  = tbs.Early_Late_Buffer_Mins__c != null ? tbs.Early_Late_Buffer_Mins__c : 30;
        
    }
}