/**
 * Created by Igor Malyuta on 25.11.2019.
 */

public without sharing class ApprovedLangSearchResponse {

    @AuraEnabled public PaginationData pagination;
    @AuraEnabled public List<StudySiteItem> studySiteItems;
    @AuraEnabled public List<LabelValueItem> languages;
    @AuraEnabled public Boolean haveEmptyAssigment;

    public ApprovedLangSearchResponse(StudySiteFilter filter, PaginationData pagination) {
        this.pagination = pagination;
        studySiteItems = convertToSSItems(SearchService.search(filter, this.pagination), filter.pageFeatureIds);
        languages = getSelectedLanguages(filter.pageFeatureIds);
        haveEmptyAssigment = isHaveEmptyAssigment(filter.ctpId);
    }

    public static List<StudySiteItem> convertToSSItems(List<Study_Site__c> studySites, String langCodesStr) {
        List<LabelValueItem> languagesValueItems = IRBParticipantService.getLanguages();

        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item = new StudySiteItem(new LabelValueItem(countryName, countryCode), ss.Name, ss);
            List<String> lngs = ss.Approved_Lng__c != null ? ss.Approved_Lng__c.split(';') : new List<String>();
            item.emptyAssignments = lngs.isEmpty();
            for (LabelValueItem lang : languagesValueItems) {
                if(String.isEmpty(langCodesStr) || langCodesStr.split(';').contains(lang.value)) {
                    item.assignments.add(new ValueStateItem(lang.value, lngs.contains(lang.value)));
                }
            }

            studySiteItems.add(item);
        }
        return studySiteItems;
    }

    private Boolean isHaveEmptyAssigment(Id ctpId) {
        Integer withoutApprove = Database.countQuery(
                'SELECT count() FROM Study_Site__c WHERE Clinical_Trial_Profile__c = \'' + ctpId + '\' AND Approved_Lng__c = NULL'
        );
        return withoutApprove > 0;
    }

    private List<LabelValueItem> getSelectedLanguages(String langCodesStr) {
        List<LabelValueItem> languages = IRBParticipantService.getLanguages();
        if(String.isEmpty(langCodesStr)) return languages;

        List<String> langCodes = langCodesStr.split(';');
        List<LabelValueItem> selectedLanguages = new List<LabelValueItem>();
        for(LabelValueItem language : languages) {
            if(langCodes.contains(language.value)) selectedLanguages.add(language);
        }

        return selectedLanguages;
    }
}