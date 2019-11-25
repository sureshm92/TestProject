/**
 * Created by Igor Malyuta on 22.08.2019.
 */

public without sharing class ApprovedLangRemote {

    public static final String FEATURE_APPROVED_LANGS = 'Approved_Languages';
    public static List<LabelValueItem> languagesValueItems = IRBParticipantService.getLanguages();

    public class InitData {
        @AuraEnabled public StudySiteFilter filter;
        @AuraEnabled public StudySitePageWrapper pageWrapper;
        @AuraEnabled public String viewMode;
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            initData.filter = new StudySiteFilter(ctpId);
            initData.pageWrapper = new StudySitePageWrapper(new PaginationData(15), languagesValueItems);
            initData.viewMode = GetPermissions.getViewMode(FEATURE_APPROVED_LANGS);

            List<Study_Site__c> ctpStudySites = SearchService.search(initData.filter, initData.pageWrapper.pagination);
            if(!ctpStudySites.isEmpty()) {
                for (Study_Site__c ss : ctpStudySites) {
                    if (ss.Site__r.BillingCountryCode != null && !initData.filter.countryCodes.contains(ss.Site__r.BillingCountryCode)) {
                        initData.filter.countryCodes += ss.Site__r.BillingCountryCode + ';';
                    }
                    if (ss.Approved_Lng__c == null) initData.pageWrapper.haveEmptyAssigment = true;
                }

                initData.filter.countryCodes = initData.filter.countryCodes.removeEnd(';');
                initPageItems(initData.pageWrapper, initData.filter);
            }

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static StudySitePageWrapper getNextData(String wrapper, String filter) {
        try {
            StudySitePageWrapper pageWrapper = save(wrapper, filter);
            StudySiteFilter ssFilter = (StudySiteFilter) JSON.deserialize(filter, StudySiteFilter.class);
            initPageItems(pageWrapper, ssFilter);
            return pageWrapper;
        } catch (Exception e) {
            return (StudySitePageWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static StudySitePageWrapper getFilteredItems(String wrapper, String filter) {
        try {
            StudySitePageWrapper pageWrapper = (StudySitePageWrapper) JSON.deserialize(wrapper, StudySitePageWrapper.class);
            StudySiteFilter ssFilter = (StudySiteFilter) JSON.deserialize(filter, StudySiteFilter.class);

            List<String> languages = StudySiteFilter.getListByString(ssFilter.pageFeatureIds);
            List<LabelValueItem> orgLanguages = languagesValueItems;
            pageWrapper.pageColumnItems = new List<LabelValueItem>();
            for (LabelValueItem lang : orgLanguages) {
                if (languages.isEmpty() || (!languages.isEmpty() && languages.contains(lang.value))) {
                    pageWrapper.pageColumnItems.add(lang);
                }
            }

            List<Study_Site__c> studySites =
                    (List<Study_Site__c>) SearchService.search(ssFilter, pageWrapper.pagination);
            pageWrapper.studySiteItems = getStudySiteItems(studySites, languages);

            return pageWrapper;
        } catch (Exception e) {
            return (StudySitePageWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getSortedItems(String wrapper, String filter) {
        try {
            StudySitePageWrapper pageWrapper = (StudySitePageWrapper) JSON.deserialize(wrapper, StudySitePageWrapper.class);
            StudySiteFilter ssFilter = (StudySiteFilter) JSON.deserialize(filter, StudySiteFilter.class);

            String pageSSIds = '';
            for (StudySiteItem item : pageWrapper.studySiteItems) pageSSIds += item.ss.Id + ';';

            ssFilter.selectedSSIds = pageSSIds.removeEnd(';');
            List<Study_Site__c> studySites =
                    (List<Study_Site__c>) SearchService.search(ssFilter, pageWrapper.pagination);

            return JSON.serialize(getStudySiteItems(studySites, StudySiteFilter.getListByString(ssFilter.pageFeatureIds)));
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void setLanguageForAll(String filter, String language, Boolean state) {
        try {
            StudySiteFilter studySiteFilter = (StudySiteFilter) JSON.deserialize(filter, StudySiteFilter.class);
            List<Study_Site__c> ctpStudySites = getCtpStudySites(studySiteFilter);

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
    public static StudySitePageWrapper save(String wrapper, String filter) {
        try {
            StudySitePageWrapper pageWrapper = (StudySitePageWrapper) JSON.deserialize(wrapper, StudySitePageWrapper.class);
            StudySiteFilter studySiteFilter = (StudySiteFilter) JSON.deserialize(filter, StudySiteFilter.class);

            Map<Id, StudySiteItem> updateItemsMap = new Map<Id, StudySiteItem>();
            for (StudySiteItem item : pageWrapper.studySiteItems) updateItemsMap.put(item.ss.Id, item);

            List<Study_Site__c> ctpStudySites = getCtpStudySites(studySiteFilter);
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
                            + studySiteFilter.ctpId + '\' AND Approved_Lng__c = NULL');
            pageWrapper.haveEmptyAssigment = withoutApprove > 0;

            return pageWrapper;
        } catch (Exception e) {
            return (StudySitePageWrapper) AuraHelper.throwException(e);
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
    public static void initPageItems(StudySitePageWrapper pageWrapper, StudySiteFilter filter) {
        pageWrapper.studySiteItems = getStudySiteItems(
                (List<Study_Site__c>) SearchService.search(filter, pageWrapper.pagination),
                StudySiteFilter.getListByString(filter.pageFeatureIds)
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