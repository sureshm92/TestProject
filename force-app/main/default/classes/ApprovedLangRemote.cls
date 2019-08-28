/**
 * Created by Igor Malyuta on 22.08.2019.
 */

public without sharing class ApprovedLangRemote {

    public class InitData {
        @AuraEnabled public List<LabelValueItem> languages;
        @AuraEnabled public String countryCodes;
        @AuraEnabled public List<StudySiteItem> studySiteItems;
    }

    public class StudySiteItem {
        @AuraEnabled public LabelValueItem country;
        @AuraEnabled public String name;
        @AuraEnabled public List<ValueStateItem> approvedLangCodes;
        @AuraEnabled public Study_Site__c ss;

        public StudySiteItem(LabelValueItem country, String ssName, Study_Site__c ss) {
            this.country = country;
            this.name = ssName;
            this.ss = ss;

            approvedLangCodes = new List<ValueStateItem>();
        }
    }

    public class ValueStateItem implements Comparable {
        @AuraEnabled public String value;
        @AuraEnabled public Boolean state;

        public ValueStateItem(String value, Boolean state) {
            this.value = value;
            this.state = state;
        }

        public Integer compareTo(Object compareTo) {
            String compareValue = ((ValueStateItem) compareTo).value;
            if (this.value > compareValue) return 1;
            if (this.value < compareValue) return -1;

            return 0;
        }

    }

    @AuraEnabled//(Cacheable = true)
    public static InitData getInitData(Id ctpId) {
        InitData initData = new InitData();
        try {
            initData.languages = getLanguages();
            initData.countryCodes = '';

            initData.studySiteItems = getStudySiteItems(null, null, ctpId, null, initData.languages);
            Set<String> uniqueCC = new Set<String>();
            for (StudySiteItem item : initData.studySiteItems) {
                String countryName = item.ss.Site__r.BillingCountry;
                String countryCode = item.ss.Site__r.BillingCountryCode;
                if ((countryCode != null && countryName != null) && !uniqueCC.contains(countryCode)) {
                    uniqueCC.add(countryCode);
                    initData.countryCodes += countryCode + ';';
                }
            }

            initData.countryCodes = initData.countryCodes.removeEnd(';');
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
        return initData;
    }

    @AuraEnabled
    public static InitData getFilteredItems(String countryCodes, String langCodes, Id ctpId, String ssId) {
        InitData initData = new InitData();
        try {
            List<String> countries;
            if (countryCodes != null && !String.isEmpty(countryCodes)) countries = countryCodes.split(';');
            List<String> languages;
            if (langCodes != null && !String.isEmpty(langCodes)) languages = langCodes.split(';');
            List<String> studyIds;
            if(ssId != null && !String.isEmpty(ssId)) studyIds = ssId.split(';');

            List<LabelValueItem> orgLanguages = getLanguages();
            initData.languages = new List<LabelValueItem>();
            for (LabelValueItem lang : orgLanguages) {
                if (languages == null || (!languages.isEmpty() && languages.contains(lang.value))) {
                    initData.languages.add(lang);
                }
            }

            initData.studySiteItems = getStudySiteItems(countries, languages, ctpId, studyIds, orgLanguages);
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
        return initData;
    }

    @AuraEnabled
    public static void save(String items, Id ctpId) {
        try {
            List<StudySiteItem> itemsToUpdate = (List<StudySiteItem>) JSON.deserialize(items, List<StudySiteItem>.class);
            Map<Id, StudySiteItem> updateItemsMap = new Map<Id, ApprovedLangRemote.StudySiteItem>();
            for (StudySiteItem item : itemsToUpdate) updateItemsMap.put(item.ss.Id, item);

            List<StudySiteItem> studySiteItems =
                    getStudySiteItems(null, null, ctpId, null, getLanguages());
            Map<Id, StudySiteItem> oldItemsMap = new Map<Id, ApprovedLangRemote.StudySiteItem>();
            for (StudySiteItem item : studySiteItems) oldItemsMap.put(item.ss.Id, item);

            List<Study_Site__c> studySites = new List<Study_Site__c>();
            for (Id itemId : oldItemsMap.keySet()) {
                if (!updateItemsMap.containsKey(itemId)) continue;

                StudySiteItem oldItem = oldItemsMap.get(itemId);
                StudySiteItem updatedItem = updateItemsMap.get(itemId);

                Study_Site__c ss = oldItem.ss;
                ss.Approved_Lng__c = '';

                oldItem.approvedLangCodes.sort();
                updatedItem.approvedLangCodes.sort();
                for (Integer i = 0; i < oldItem.approvedLangCodes.size(); i++) {
                    ValueStateItem old = oldItem.approvedLangCodes.get(i);
                    for (Integer j = 0; j < updatedItem.approvedLangCodes.size(); j++) {
                        ValueStateItem updated = updatedItem.approvedLangCodes.get(j);
                        if (old.value.equals(updated.value)) {
                            if (updated.state) {
                                ss.Approved_Lng__c += updated.value + ';';
                            } else {
                                old.state = false;
                            }
                            break;
                        }
                    }
                    if (old.state && !ss.Approved_Lng__c.contains(old.value)) {
                        ss.Approved_Lng__c += old.value + ';';
                    }
                }

                ss.Approved_Lng__c = ss.Approved_Lng__c.removeEnd(';');
                studySites.add(ss);
            }

            update studySites;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    public static List<StudySiteItem> getStudySiteItems(List<String> countryCodes, List<String> langCodes, Id ctpId,
            List<String> ssIds, List<LabelValueItem> orgLanguages) {
        String filter = 'Clinical_Trial_Profile__c = \'' + ctpId + '\'';

        if (countryCodes != null && !countryCodes.isEmpty()) {
            filter += ' AND ' + DatabaseService.fieldJoin('Site__r.BillingCountryCode', countryCodes);
        }
        if(ssIds != null && !ssIds.isEmpty()) {
            filter += ' AND ' + DatabaseService.fieldJoin('Id', ssIds);
        }

        List<Study_Site__c> studySites = (List<Study_Site__c>) DatabaseService.getInstance().queryImpl(new List<String>{
                'Id',
                'Approved_Lng__c',
                'Clinical_Trial_Profile__c',
                'Name',
                'Site__r.BillingCountry',
                'Site__r.BillingCountryCode',
                'Study_Site_Number__c'
        }, Study_Site__c.getSObjectType(), filter, 'Name', null);

        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item = new StudySiteItem(new LabelValueItem(countryName, countryCode), ss.Name, ss);
            List<String> lngs = ss.Approved_Lng__c != null ? ss.Approved_Lng__c.split(';') : new List<String>();
            for (LabelValueItem lang : orgLanguages) {
                if (langCodes == null || (!langCodes.isEmpty() && langCodes.contains(lang.value))) {
                    item.approvedLangCodes.add(new ValueStateItem(lang.value, lngs.contains(lang.value) ? true : false));
                }
            }

            studySiteItems.add(item);
        }
        return studySiteItems;
    }

    public static List<LabelValueItem> getLanguages() {
        List<LabelValueItem> languages = new List<LabelValueItem>();
        Schema.DescribeFieldResult fieldResult = Study_Site__c.Approved_Lng__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : entries) languages.add(new LabelValueItem(entry.getLabel(), entry.getValue()));

        return languages;
    }

    @AuraEnabled
    public static List<LookupSearchResult> searchLanguages(String searchTerm, String value) {
        try {
            List<LookupSearchResult> resList = new List<LookupSearchResult>();

            List<LabelValueItem> languages = getLanguages();

            List<String> selectedLangs = new List<String>();
            if (!String.isEmpty(value)) selectedLangs = value.split(';');
            for (LabelValueItem labelValueItem : languages) {
                if (labelValueItem.value.containsIgnoreCase(searchTerm) && !selectedLangs.contains(labelValueItem.value)) {
                    resList.add(new LookupSearchResult(
                            labelValueItem.value,
                            null,
                            'standard:task2',
                            labelValueItem.label,
                            null
                    ));
                }
            }

            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<LookupSearchResult> searchLanguagesByValue(String value) {
        try {
            List<LabelValueItem> languages = getLanguages();

            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            if (String.isBlank(value)) return resList;

            for (LabelValueItem labelValueItem : languages) {
                for (String item : value.split(';')) {
                    if (item.equals(labelValueItem.value)) {
                        resList.add(new LookupSearchResult(
                                labelValueItem.value,
                                null,
                                'standard:task2',
                                labelValueItem.label,
                                null
                        ));
                    }
                }
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }
}