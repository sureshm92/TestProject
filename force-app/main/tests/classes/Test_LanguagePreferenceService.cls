/**
 * Created by Denis Zmiter on 14-Aug-19.
 */

@IsTest
private without sharing class Test_LanguagePreferenceService {

    @IsTest
    static void checkCodesReturn(){
        System.assertEquals('ru', LanguagePreferenceService.getLanguageCode('ru'));
        System.assertEquals('ru', LanguagePreferenceService.getLanguageCode('ru_BY'));
        System.assertEquals('en_US', LanguagePreferenceService.getLanguageCode('en'));
        System.assertEquals('en_US', LanguagePreferenceService.getLanguageCode('en_BY'));
        System.assertEquals(LanguagePreferenceService.DEFAULT_LANGUAGE_CODE, LanguagePreferenceService.getLanguageCode('by'));
        System.assertEquals(LanguagePreferenceService.DEFAULT_LANGUAGE_CODE, LanguagePreferenceService.getLanguageCode(null));
    }
}