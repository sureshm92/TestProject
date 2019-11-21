/**
 * Created by Igor Malyuta on 22.08.2019.
 */

public without sharing class ApprovedLangRemote {

    public static final String FEATURE_APPROVED_LANGS = 'Approved_Languages';

    public static List<LabelValueItem> languagesValueItems = IRBParticipantService.getLanguages();
    public static List<Study_Site__c> ctpStudySites;

    public static final String QUERY_MAIN_FILTER = 'Clinical_Trial_Profile__c = \'ctpId\'';
    public static final Integer QUERY_LIMIT = 50;

    public class InitData {
        @AuraEnabled public List<LabelValueItem> languages;
        @AuraEnabled public String countryCodes;
        @AuraEnabled public String selectedSSIds;
        @AuraEnabled public Id ctpId;
        @AuraEnabled public List<StudySiteItem> studySiteItems;
        @AuraEnabled public Boolean haveEmptyLangSS;
        @AuraEnabled public PaginationData paginationData;
        @AuraEnabled public Map<String, String> countryBySSId;
        @AuraEnabled public String viewMode;

        public InitData() {
            paginationData = new PaginationData();
            languages = languagesValueItems;
            countryCodes = '';
            haveEmptyLangSS = false;

            countryBySSId = new Map<String, String>();
            viewMode = '';
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
            initData.ctpId = ctpId;
            initData.viewMode = GetPermissions.getViewMode(FEATURE_APPROVED_LANGS);
            ctpStudySites = getStudySites(QUERY_MAIN_FILTER.replace('ctpId', ctpId));
            if(!ctpStudySites.isEmpty()) {
                loadInitData(initData);
                initPageItems(initData, initData.countryCodes, null, null);
            }

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getNextData(String data, String countryCodes, String langCodes, String ssId) {
        try {
            InitData initData = save(data);
            initData.paginationData.reCalc();
            initPageItems(initData, countryCodes, langCodes, ssId);
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getFilteredItems(String data, String countryCodes, String langCodes, String ssId) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);

            List<String> countries = getListByString(countryCodes);
            List<String> languages = getListByString(langCodes);
            List<String> studyIds = getListByString(ssId);

            List<LabelValueItem> orgLanguages = languagesValueItems;
            initData.languages = new List<LabelValueItem>();
            for (LabelValueItem lang : orgLanguages) {
                if (languages.isEmpty() || (!languages.isEmpty() && languages.contains(lang.value))) {
                    initData.languages.add(lang);
                }
            }

            List<Study_Site__c> studySites =
                    getStudySites(initData.ctpId, countries, studyIds, null, 'ASC', -1, 0);
            initData.paginationData.setRecordsCount(studySites.size());

            List<Study_Site__c> ssPart = new List<Study_Site__c>();
            for(Integer i = 0; i < studySites.size(); i++) {
                if(ssPart.size() - 1 < QUERY_LIMIT) {
                    if(countries.isEmpty() || countries.contains(studySites.get(i).Site__r.BillingCountryCode)) {
                        ssPart.add(studySites.get(i));
                    }
                } else {
                    break;
                }
            }

            initData.studySiteItems = getStudySiteItems(ssPart, languages);

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getSortedItems(String data, String langCodes, String sortOrder, Boolean sortDirection) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);

            List<String> ssIds = new List<String>();
            for (StudySiteItem item : initData.studySiteItems) ssIds.add(item.ss.Id);

            String direction = sortDirection ? 'ASC' : 'DESC';

            List<Study_Site__c> studySites =
                    getStudySites(initData.ctpId, null, ssIds, sortOrder, direction, -1, QUERY_LIMIT);
            initData.studySiteItems = getStudySiteItems(studySites, getListByString(langCodes));

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void setLanguageForAll(String data, String language, Boolean state) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);
            if (ctpStudySites == null) ctpStudySites = getStudySites(QUERY_MAIN_FILTER.replace('ctpId', initData.ctpId));

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

            if (ctpStudySites == null) ctpStudySites = getStudySites(QUERY_MAIN_FILTER.replace('ctpId', initData.ctpId));
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
                    'SELECT count() FROM Study_Site__c WHERE '
                            + QUERY_MAIN_FILTER.replace('ctpId', initData.ctpId)
                            + ' AND Approved_Lng__c = NULL');
            initData.haveEmptyLangSS = withoutApprove > 0;

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
    private static void loadInitData(InitData initData) {
        for (Study_Site__c ss : ctpStudySites) {
            if (ss.Site__r.BillingCountryCode != null && !initData.countryCodes.contains(ss.Site__r.BillingCountryCode)) {
                initData.countryCodes += ss.Site__r.BillingCountryCode + ';';
            }
            if (ss.Approved_Lng__c == null) initData.haveEmptyLangSS = true;
        }

        initData.countryCodes = initData.countryCodes.removeEnd(';');
        initData.paginationData.setRecordsCount(ctpStudySites.size());
    }

    private static void initPageItems(InitData initData, String countryCodes, String langCodes, String ssId) {
        initData.studySiteItems = getStudySiteItems(
                getStudySites(initData.ctpId, getListByString(countryCodes), getListByString(ssId), null, 'ASC',
                        initData.paginationData.offset, QUERY_LIMIT
                ),
                getListByString(langCodes)
        );
        initData.paginationData.pageRecordsCount = initData.studySiteItems.size();
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

    public static List<Study_Site__c> getStudySites(String filter) {
        return (List<Study_Site__c>) DatabaseService.getInstance().queryImpl(new List<String>{
                'Id',
                'Approved_Lng__c',
                'Clinical_Trial_Profile__c',
                'Name',
                'Site__r.BillingCountry',
                'Site__r.BillingCountryCode',
                'Study_Site_Number__c'
        }, Study_Site__c.getSObjectType(), filter);
    }

    public static List<Study_Site__c> getStudySites(Id ctpId, List<String> countryCodes, List<String> ssIds,
            String sortOrder, String sortDirection, Integer offset, Integer queryLimit
    ) {
        String filter = QUERY_MAIN_FILTER.replace('ctpId', ctpId);

        if (countryCodes != null && !countryCodes.isEmpty()) {
            filter += ' AND ' + DatabaseService.fieldInValues('Site__r.BillingCountryCode', countryCodes);
        }
        if (ssIds != null && !ssIds.isEmpty()) {
            filter += ' AND ' + DatabaseService.fieldInValues('Id', ssIds);
        }

        if (sortOrder == null || String.isEmpty(sortOrder)) {
            sortOrder = 'Site__r.BillingCountry';
        } else {
            switch on sortOrder {
                when 'name' {
                    sortOrder = 'Name';
                }
                when 'number' {
                    sortOrder = 'Study_Site_Number__c';
                }
                when else {
                    sortOrder = 'Site__r.BillingCountry';
                }
            }
        }

        filter += ' ORDER BY ' + sortOrder + ' ' + sortDirection;
        if (queryLimit > 0) {
            filter += ' LIMIT ' + queryLimit;
            if (offset > 0) filter += ' OFFSET ' + offset;
        }

        return getStudySites(filter);
    }

    public static List<String> getListByString(String toSplit) {
        List<String> splitted;
        if (toSplit != null && !String.isEmpty(toSplit)) splitted = toSplit.split(';');

        return splitted == null ? new List<String>() : splitted;
    }
}