/**
 * Created by Igor Malyuta on 22.08.2019.
 */

public without sharing class ApprovedLangRemote {

    public static final String FEATURE_APPROVED_LANGS = 'Approved_Languages';
    public static List<LabelValueItem> languagesValueItems = IRBParticipantService.getLanguages();

    public class InitData {
        @AuraEnabled public StudySiteFilter.StudySiteSearchWrapper searchWrapper;
        @AuraEnabled public List<LabelValueItem> languages;
        @AuraEnabled public List<StudySiteItem> studySiteItems;
        @AuraEnabled public String viewMode;

        public InitData() {
            searchWrapper = new StudySiteFilter.StudySiteSearchWrapper(new StudySiteFilter(), new PaginationData());
            languages = languagesValueItems;
        }
    }

    public class StudySiteItem {
        @AuraEnabled public LabelValueItem country;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean emptyAssignments;
        @AuraEnabled public List<ValueStateItem> assignments;
        @AuraEnabled public Study_Site__c ss;

        public StudySiteItem() {
        }

        public StudySiteItem(LabelValueItem country, String ssName, Study_Site__c ss) {
            this.country = country;
            this.name = ssName;
            this.ss = ss;

            emptyAssignments = false;
            assignments = new List<ValueStateItem>();
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

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            initData.viewMode = GetPermissions.getViewMode(FEATURE_APPROVED_LANGS);
            initData.searchWrapper.filter.ctpId = ctpId;
            List<Study_Site__c> ctpStudySites = SearchService.search(initData.searchWrapper.filter, initData.searchWrapper.pagination);
            if(!ctpStudySites.isEmpty()) {
                loadInitData(initData.searchWrapper, ctpStudySites);
                initPageItems(initData);
            }

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getNextData(String data) {
        try {
            InitData initData = save(data);
            initPageItems(initData);
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getFilteredItems(String data) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);
            List<String> languages = StudySiteFilter.getListByString(initData.searchWrapper.filter.pageFeatureIds);

            List<LabelValueItem> orgLanguages = languagesValueItems;
            initData.languages = new List<LabelValueItem>();
            for (LabelValueItem lang : orgLanguages) {
                if (languages.isEmpty() || (!languages.isEmpty() && languages.contains(lang.value))) {
                    initData.languages.add(lang);
                }
            }

            List<Study_Site__c> studySites =
                    (List<Study_Site__c>) SearchService.search(initData.searchWrapper.filter, initData.searchWrapper.pagination);
            initData.studySiteItems = getStudySiteItems(studySites, languages);

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getSortedItems(String data) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);

            String selectedSSIds = '';
            if(!String.isEmpty(initData.searchWrapper.filter.selectedSSIds)) {
                selectedSSIds = initData.searchWrapper.filter.selectedSSIds;
            }

            //For sorting only for current page items
            String pageSSIds = '';
            for (StudySiteItem item : initData.studySiteItems) pageSSIds += item.ss.Id + ';';

            initData.searchWrapper.filter.selectedSSIds = pageSSIds.removeEnd(';');
            List<Study_Site__c> studySites =
                    (List<Study_Site__c>) SearchService.search(initData.searchWrapper.filter, initData.searchWrapper.pagination);
            initData.studySiteItems =
                    getStudySiteItems(studySites, StudySiteFilter.getListByString(initData.searchWrapper.filter.pageFeatureIds));

            initData.searchWrapper.filter.selectedSSIds = selectedSSIds;
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void setLanguageForAll(String data, String language, Boolean state) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);
            List<Study_Site__c> ctpStudySites = getCtpStudySites(initData.searchWrapper.filter);

            for (Study_Site__c ss : ctpStudySites) {
                if(String.isEmpty(ss.Approved_Lng__c)) ss.Approved_Lng__c = '';

                List<String> appLanguages = ss.Approved_Lng__c.split(';');

                if(state){
                    if(!appLanguages.contains(language)) appLanguages.add(language);
                } else {
                    Integer langIndex = appLanguages.indexOf(language);
                    if (langIndex != -1) appLanguages.remove(langIndex);
                }

                appLanguages.sort();
                ss.Approved_Lng__c = String.join(appLanguages, ';');
            }

            update ctpStudySites;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData save(String data) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);

            Map<Id, StudySiteItem> updateItemsMap = new Map<Id, StudySiteItem>();
            for (StudySiteItem item : initData.studySiteItems) updateItemsMap.put(item.ss.Id, item);

            List<Study_Site__c> ctpStudySites = getCtpStudySites(initData.searchWrapper.filter);
            List<StudySiteItem> oldStudySiteItems = getStudySiteItems(ctpStudySites, null);
            Map<Id, StudySiteItem> oldItemsMap = new Map<Id, StudySiteItem>();
            for (StudySiteItem item : oldStudySiteItems) oldItemsMap.put(item.ss.Id, item);

            List<Study_Site__c> studySites = new List<Study_Site__c>();
            for (Id itemId : oldItemsMap.keySet()) {
                if (!updateItemsMap.containsKey(itemId)) continue;

                StudySiteItem oldItem = oldItemsMap.get(itemId);
                StudySiteItem updatedItem = updateItemsMap.get(itemId);

                Study_Site__c ss = oldItem.ss;
                ss.Approved_Lng__c = '';

                oldItem.assignments.sort();
                updatedItem.assignments.sort();
                for (Integer i = 0; i < oldItem.assignments.size(); i++) {
                    ValueStateItem old = oldItem.assignments.get(i);
                    for (Integer j = 0; j < updatedItem.assignments.size(); j++) {
                        ValueStateItem updated = updatedItem.assignments.get(j);
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

            Integer withoutApprove = Database.countQuery(
                    'SELECT count() FROM Study_Site__c WHERE Clinical_Trial_Profile__c = \''
                            + initData.searchWrapper.filter.ctpId + '\' AND Approved_Lng__c = NULL');
            initData.searchWrapper.haveEmptyAssigment = withoutApprove > 0;

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    //Search lookup logic: ---------------------------------------------------------------------------------------------
    @AuraEnabled
    public static List<LookupSearchResult> searchLanguages(String searchTerm, String value) {
        try {
            List<LookupSearchResult> resList = new List<LookupSearchResult>();

            List<LabelValueItem> languages = languagesValueItems;

            List<String> selectedLangs = new List<String>();
            if (!String.isEmpty(value)) selectedLangs = value.split(';');
            for (LabelValueItem labelValueItem : languages) {
                if (labelValueItem.label.containsIgnoreCase(searchTerm) && !selectedLangs.contains(labelValueItem.value)) {
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
            List<LabelValueItem> languages = languagesValueItems;

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

    //Inner logic: -----------------------------------------------------------------------------------------------------
    private static void loadInitData(StudySiteFilter.StudySiteSearchWrapper searchWrapper, List<Study_Site__c> ctpStudySites) {
        for (Study_Site__c ss : ctpStudySites) {
            if (ss.Site__r.BillingCountryCode != null && !searchWrapper.filter.countryCodes.contains(ss.Site__r.BillingCountryCode)) {
               searchWrapper.filter.countryCodes += ss.Site__r.BillingCountryCode + ';';
            }
            if (ss.Approved_Lng__c == null) searchWrapper.haveEmptyAssigment = true;
        }

        searchWrapper.filter.countryCodes = searchWrapper.filter.countryCodes.removeEnd(';');
    }

    public static void initPageItems(InitData initData) {
        initData.studySiteItems = getStudySiteItems(
                (List<Study_Site__c>) SearchService.search(initData.searchWrapper.filter, initData.searchWrapper.pagination),
                StudySiteFilter.getListByString(initData.searchWrapper.filter.pageFeatureIds)
        );
    }

    private static List<StudySiteItem> getStudySiteItems(List<Study_Site__c> studySites, List<String> langCodes) {
        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item = new StudySiteItem(new LabelValueItem(countryName, countryCode), ss.Name, ss);
            List<String> lngs = ss.Approved_Lng__c != null ? ss.Approved_Lng__c.split(';') : new List<String>();
            item.emptyAssignments = lngs.isEmpty();
            for (LabelValueItem lang : languagesValueItems) {
                if (langCodes == null || langCodes.isEmpty() || (!langCodes.isEmpty() && langCodes.contains(lang.value))) {
                    item.assignments.add(new ValueStateItem(lang.value, lngs.contains(lang.value) ? true : false));
                }
            }

            studySiteItems.add(item);
        }
        return studySiteItems;
    }

    public static List<Study_Site__c> getCtpStudySites(StudySiteFilter filter) {
        List<Study_Site__c> ctpStudySites = (List<Study_Site__c>) DatabaseService.query(
                filter.getFields(),
                filter.getSObjectType(),
                'Clinical_Trial_Profile__c = \'' + filter.ctpId + '\'');
        return ctpStudySites;
    }
}