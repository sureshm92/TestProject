/**
 * Created by Igor Malyuta on 02.09.2019.
 */

public without sharing class ParticipantIRBCheckerRemote {

    @AuraEnabled
    public static IRBModeWrapper checkLanguagePermissions(Id peId) {
        try {
            List<Participant_Enrollment__c> pe = [
                    SELECT
                            Clinical_Trial_Profile__r.Study_Code_Name__c,
                            Study_Site__r.Approved_Lng__c
                    FROM Participant_Enrollment__c
                    WHERE Id = :peId
            ];
            String studyCodeName = pe.get(0).Clinical_Trial_Profile__r.Study_Code_Name__c;
            List<String> siteApprovedLng = pe.get(0).Study_Site__r.Approved_Lng__c == null ?
                    new List<String>() : pe.get(0).Study_Site__r.Approved_Lng__c.split(';');

            IRBModeWrapper wrapper = new IRBModeWrapper();
            wrapper.studyCodeName = studyCodeName;
            wrapper.message = getIRBMessage(siteApprovedLng, studyCodeName);
            wrapper.mode = getIRBMode(siteApprovedLng);
            return wrapper;
        } catch (Exception e) {
            return (IRBModeWrapper) AuraHelper.throwException(e);
        }
    }

    public static String getIRBMode(List<String> approveSSLangs) {
        if (approveSSLangs.isEmpty()) return 'empty';

        String mode = 'no-approved';

        Contact userContact = CommunityService.getUserContact();
        if (approveSSLangs.contains(userContact.Language__c)) {
            mode = 'preferred';
        } else if (approveSSLangs.contains(userContact.Second_Choice_Language__c) ||
                approveSSLangs.contains(userContact.Third_Choice_Language__c)) {
            mode = 'alternative';
        }

        return mode;
    }

    public static String getIRBMessage(List<String> approvedLng, String studyCodeName) {
        List<LabelValueItem> allLanguages = IRBParticipantService.getLanguages();
        String languages = '';
        for (LabelValueItem lang : allLanguages) {
            if (approvedLng.contains(lang.value)) languages += lang.label + ', ';
        }
        languages = languages.removeEnd(', ');

        String message = Label.PP_IRB_LangList.replace('##StudyCodeName', studyCodeName);
        return message.replace('##LangList', languages);
    }

    public class IRBModeWrapper {
        @AuraEnabled public String mode;
        @AuraEnabled public String message;
        @AuraEnabled public String studyCodeName;
        @AuraEnabled public Boolean isNewSession;
    }
}