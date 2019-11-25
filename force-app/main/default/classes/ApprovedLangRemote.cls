/**
 * Created by Igor Malyuta on 22.08.2019.
 */

public without sharing class ApprovedLangRemote {

    public static final String FEATURE_APPROVED_LANGS = 'Approved_Languages';

    public class InitData {
        @AuraEnabled public StudySiteFilter filter;
        @AuraEnabled public ApprovedLangSearchResponse searchResponse;
        @AuraEnabled public String viewMode;
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            initData.filter = new StudySiteFilter(ctpId);
            initData.searchResponse = new ApprovedLangSearchResponse(initData.filter, new PaginationData(15));
            initData.viewMode = GetPermissions.getViewMode(FEATURE_APPROVED_LANGS);

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static ApprovedLangSearchResponse getItems(String ssItemsJSON, String filterJSON, String paginationJSON) {
        try {
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            if(ssItemsJSON != null) {
                List<StudySiteItem> studySiteItems =
                        (List<StudySiteItem>) JSON.deserialize(ssItemsJSON, List<StudySiteItem>.class);
                save(studySiteItems);
            }
            return new ApprovedLangSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (ApprovedLangSearchResponse) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static ApprovedLangSearchResponse setLanguageForAll(String filterJS, String paginationJS, String language, Boolean state) {
        try {
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJS, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJS, PaginationData.class);

            List<StudySiteItem> studySiteItems = ApprovedLangSearchResponse.convertToSSItems(getCtpStudySites(filter), language);
            for(StudySiteItem item : studySiteItems) {
                for(ValueStateItem assignment : item.assignments) assignment.state = state;
            }
            save(studySiteItems);

            return new ApprovedLangSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (ApprovedLangSearchResponse) AuraHelper.throwException(e);
        }
    }

    private static void save(List<StudySiteItem> studySiteItems) {
        try {
            List<Study_Site__c> studySites = new List<Study_Site__c>();
            for(StudySiteItem item : studySiteItems) {
                for(ValueStateItem assigment : item.assignments) {
                    if(assigment.initialState && !assigment.state) {
                        item.ss.Approved_Lng__c = updateLanguage(item.ss.Approved_Lng__c, assigment.value, false);
                    } else if(!assigment.initialState && assigment.state){
                        item.ss.Approved_Lng__c = updateLanguage(item.ss.Approved_Lng__c, assigment.value, true);
                    }
                }
                studySites.add(item.ss);
            }
            update studySites;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    public static List<Study_Site__c> getCtpStudySites(StudySiteFilter filter) {
        List<Study_Site__c> ctpStudySites = (List<Study_Site__c>) DatabaseService.query(
                filter.getFields(),
                filter.getSObjectType(),
                filter.getFilterString());
        return ctpStudySites;
    }

    private static String updateLanguage(String ssApproved, String langCodes, Boolean isAdd) {
        Set<String> resultApprove = new Set<String>();
        if(ssApproved == null) ssApproved = '';

        List<String> approvedSplit = ssApproved.split(';');
        if(!isAdd) {
            for(String appLang : approvedSplit) {
                if(appLang != langCodes) resultApprove.add(appLang);
            }
        } else {
            resultApprove.addAll(approvedSplit);
            resultApprove.add(langCodes);
        }

        return String.join(new List<String>(resultApprove), ';');
    }
}