/**
 * Created by Igor Malyuta on 03.09.2019.
 */

public without sharing class IRBParticipantService {

    public class IRBParticipantServiceException extends Exception {
    }

    public class IRBModeWrapper {
        @AuraEnabled public String mode;
        @AuraEnabled public String languageToTranslate;
        @AuraEnabled public String message;
        @AuraEnabled public String studyCodeName;
        @AuraEnabled public Boolean isNewSession;
    }


    public static IRBModeWrapper getIRBLanguageMode(Id peId) {
        List<Participant_Enrollment__c> pe = [
                SELECT
                        Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site__r.Approved_Lng__c
                FROM Participant_Enrollment__c
                WHERE Id = :peId
        ];
        if (pe.isEmpty()) throw new IRBParticipantServiceException('Not found pe with id = ' + peId);

        List<String> siteApprovedLng = pe.get(0).Study_Site__r.Approved_Lng__c == null ?
                new List<String>() : pe.get(0).Study_Site__r.Approved_Lng__c.split(';');

        IRBModeWrapper wrapper = new IRBModeWrapper();
        //wrapper.isNewSession = CommunityService.isNewSession();
        wrapper.mode = 'no-approved';

        Contact userContact = CommunityService.getUserContact();
        if (siteApprovedLng.isEmpty()) {
            wrapper.mode = 'empty';
        } else {
            if (siteApprovedLng.contains(userContact.Language__c)) {
                wrapper.mode = 'preferred';
                wrapper.languageToTranslate = userContact.Language__c;
            } else if (siteApprovedLng.contains(userContact.Second_Choice_Language__c)) {
                wrapper.mode = 'alternative';
                wrapper.languageToTranslate = userContact.Second_Choice_Language__c;
            } else if (siteApprovedLng.contains(userContact.Third_Choice_Language__c)) {
                wrapper.mode = 'alternative';
                wrapper.languageToTranslate = userContact.Third_Choice_Language__c;
            }

            if (wrapper.languageToTranslate == null) wrapper.languageToTranslate = siteApprovedLng.get(0);
        }

        List<LabelValueItem> languages = ApprovedLangRemote.getLanguages();
        String langs = '';
        for (LabelValueItem lang : languages) {
            if (siteApprovedLng.contains(lang.value)) langs += lang.label + ', ';
        }

        langs = langs.removeEnd(', ');
        wrapper.studyCodeName = pe.get(0).Clinical_Trial_Profile__r.Study_Code_Name__c;
        String message = Label.PP_IRB_LangList.replace(
                '##StudyCodeName',
                wrapper.studyCodeName
        );
        message = message.replace('##LangList', langs);
        wrapper.message = message;

        return wrapper;
    }

    public static List<String> getIRBApprovedLanguages(String pe, ParticipantService.ParticipantStates participantStatus) {
        Set<String> contactLanguage = new Set<String>();
        List<Participant_Enrollment__c> pes = getRalatedParticipantEnrollment(pe);
        List<String> siteApprovedLng = pes.get(0).Study_Site__r.Approved_Lng__c == null ?
                new List<String>() : CollectionUtil.split(pes.get(0).Study_Site__r.Approved_Lng__c, ';');
        Set<String> approvedLanguages = getContactPreferredLanguages();
        if (participantStatus == ParticipantService.ParticipantStates.ALUMNI) {
            contactLanguage = approvedLanguages;
        } else {
            for (String s : approvedLanguages) {
                if (siteApprovedLng.contains(s)) {
                    contactLanguage.add(s);
                }
            }
        }

        return new List<String>(contactLanguage);
    }

    private static Set<String> getContactPreferredLanguages() {
         User user = getUser();
        Set<String> contactLanguage = new Set<String>();
        contactLanguage.add(UserInfo.getLanguage());
        if (String.isNotBlank(user.Contact.Language__c)) {
            contactLanguage.add(user.Contact.Language__c);
        }
        if (String.isNotBlank(user.Contact.Second_Choice_Language__c)) {
            contactLanguage.add(user.Contact.Second_Choice_Language__c);
        }
        if (String.isNotBlank(user.Contact.Third_Choice_Language__c)) {
            contactLanguage.add(user.Contact.Third_Choice_Language__c);
        }
        return contactLanguage;
    }
    private static List<Participant_Enrollment__c> getRalatedParticipantEnrollment(String pe) {
        DatabaseProxy proxy = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class));
        String queryPE = 'SELECT ' +
                'Study_Site__r.Approved_Lng__c ' +
                'FROM Participant_Enrollment__c' +
                ' WHERE Id = \'' + pe + '\'';
        List<Participant_Enrollment__c> pes = (List<Participant_Enrollment__c>) proxy.query(queryPE);
        return pes;


    }

    private static User getUser() {
        DatabaseProxy proxy = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class));
        String queryUser = 'SELECT ' +
                'ContactId, ' +
                'Contact.Language__c, ' +
                'Contact.Second_Choice_Language__c, ' +
                'Contact.Third_Choice_Language__c ' +
                'FROM User ' +
                'WHERE Id = \'' + UserInfo.getUserId() + '\'';
        return (User) proxy.query(queryUser)[0];
    }
}