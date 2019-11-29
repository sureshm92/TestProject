/**
 * Created by Igor Malyuta on 03.09.2019.
 */

public without sharing class IRBParticipantService {

    public class IRBParticipantServiceException extends Exception {
    }
    
    public static String getSuitableLanguageForIRBTranslation(Id peId) {
        List<String> contactLanguages = ContactService.getPreferredLanguages();
        List<String> approvedLanguages = getSSApprovedLanguages(peId);
        String language;
        if (approvedLanguages.isEmpty()) return language;
        for (String contLang : contactLanguages) {
            for (String appLang : approvedLanguages) {
                if (contLang.equals(appLang)) return contLang;
            }
        }

        return language;
    }

    private static List<String> getSSApprovedLanguages(Id peId) {
        List<Participant_Enrollment__c> enrollment = [
                SELECT Study_Site__r.Approved_Lng__c
                FROM Participant_Enrollment__c
                WHERE Id = :peId
        ];
        if (enrollment.isEmpty()) throw new IRBParticipantServiceException('Not found pe with id = ' + peId);

        return enrollment.get(0).Study_Site__r.Approved_Lng__c == null ?
                new List<String>() : enrollment.get(0).Study_Site__r.Approved_Lng__c.split(';');
    }

    public static List<LabelValueItem> getLanguages() {
        List<LabelValueItem> languages = new List<LabelValueItem>();
        Schema.DescribeFieldResult fieldResult = Study_Site__c.Approved_Lng__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : entries) languages.add(new LabelValueItem(entry.getLabel(), entry.getValue()));

        return languages;
    }
}
