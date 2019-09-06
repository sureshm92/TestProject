/**
 * Created by Igor Malyuta on 03.09.2019.
 */

public without sharing class IRBParticipantService {

    public class IRBParticipantServiceException extends Exception{}

    public class IRBModeWrapper {
        @AuraEnabled public String mode;
        @AuraEnabled public String languageToTranslate;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean isNewSession;
    }

    public static IRBModeWrapper getIRBLanguageMode(Id peId) {
        List<Participant_Enrollment__c> pe = [
                SELECT
                        Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site__r.Approved_Lng__c,
                        Participant_Contact__r.Language__c,
                        Participant_Contact__r.Second_Choice_Language__c,
                        Participant_Contact__r.Third_Choice_Language__c
                FROM Participant_Enrollment__c
                WHERE Id = :peId
        ];
        if(pe.isEmpty()) throw new IRBParticipantServiceException('Not found pe with id = ' + peId);

        List<String> siteApprovedLng = pe.get(0).Study_Site__r.Approved_Lng__c == null ?
                new List<String>() : pe.get(0).Study_Site__r.Approved_Lng__c.split(';');

        IRBModeWrapper wrapper = new IRBModeWrapper();
        wrapper.isNewSession = CommunityService.isNewSession();
        wrapper.mode = 'no-approved';

        if (siteApprovedLng.isEmpty()) {
            wrapper.mode = 'empty';
        } else {
            if (siteApprovedLng.contains(pe.get(0).Participant_Contact__r.Language__c)) {
                wrapper.mode = 'preferred';
                wrapper.languageToTranslate = pe.get(0).Participant_Contact__r.Language__c;
            } else if (siteApprovedLng.contains(pe.get(0).Participant_Contact__r.Second_Choice_Language__c))  {
                wrapper.mode = 'alternative';
                wrapper.languageToTranslate = pe.get(0).Participant_Contact__r.Second_Choice_Language__c;
            } else if(siteApprovedLng.contains(pe.get(0).Participant_Contact__r.Third_Choice_Language__c)) {
                wrapper.mode = 'alternative';
                wrapper.languageToTranslate = pe.get(0).Participant_Contact__r.Third_Choice_Language__c;
            }

            if(wrapper.languageToTranslate == null) wrapper.languageToTranslate = siteApprovedLng.get(0);
        }

        List<LabelValueItem> languages = ApprovedLangRemote.getLanguages();
        String langs = '';
        for (LabelValueItem lang : languages) {
            if (siteApprovedLng.contains(lang.value)) langs += lang.label + ', ';
        }

        langs = langs.removeEnd(', ');
        String message = Label.PP_IRB_LangList.replace(
                '##StudyCodeName',
                pe.get(0).Clinical_Trial_Profile__r.Study_Code_Name__c
        );
        message = message.replace('##LangList', langs);
        wrapper.message = message;

        return wrapper;
    }
}