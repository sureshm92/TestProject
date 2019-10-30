/**
 * Created by Denis Z on 14-Aug-19.
 */

public without sharing class LanguagePreferenceService {

    public static final String DEFAULT_LANGUAGE_CODE = 'en_US';
    private static Set<String> languageCodes;

    public static String getLanguageCode(String externalCode){
        if(String.isEmpty(externalCode))
            return DEFAULT_LANGUAGE_CODE;
    
        // this is a bug fix to normalize externalCode (JIRA REF-565)
        List<String> codeTokens = externalCode.split('_');
        if (codeTokens.size() > 1) {
            externalCode = codeTokens[0] + '_' + codeTokens[1].toUpperCase();
        }
    
        if(languageCodes == null){
            languageCodes = new Set<String>();
            Schema.DescribeFieldResult fieldResult = Participant__c.Preferred_Language__c.getDescribe();
            List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry entry : entries) {
                languageCodes.add(entry.getValue());
            }
        }
        if(languageCodes.contains(externalCode)) return externalCode;
        externalCode = externalCode.split('_')[0];
        if(languageCodes.contains(externalCode)) return externalCode;
        for(String code : languageCodes){
            if(code.startsWith(externalCode)) return code;
        }
        return DEFAULT_LANGUAGE_CODE;
    }
}