/**
 * Created by Denis Zmiter on 14-Aug-19.
 */

@IsTest
private without sharing class Test_LanguagePreferenceService {

    @IsTest
    static void checkCodesReturn(){
        System.assert(LanguagePreferenceService.getLanguageCode('en').startsWith('en'));
        System.assert(LanguagePreferenceService.getLanguageCode('en_BY').startsWith('en'));
        System.assertEquals(LanguagePreferenceService.DEFAULT_LANGUAGE_CODE, LanguagePreferenceService.getLanguageCode('by'));
        System.assertEquals(LanguagePreferenceService.DEFAULT_LANGUAGE_CODE, LanguagePreferenceService.getLanguageCode(null));
    }
}