/**
 * Created by Kryvolap
 */

public without sharing class SitesSearchRemote {
    public class InitData {
        public Clinical_Trial_Profile__c trial;
        public StudySiteService.SiteFilter siteFilter;
        public StudySiteService.SiteFilterData siteFilterData;
        public List<StudySiteService.StudySiteDistanceWrapper> currentPageList;
        public PaginationData paginationData;
        public List<Id> trialIds;
        public List<MapMarker> mapMarkers;
        Public String accessLevel;
    }

    public class MapMarker {
        public MapLocation location;
        public String title;
        public MapMarker(Study_Site__c site) {
            title = site.Name;
            location = new MapLocation(site);
        }
    }
    public class MapLocation {
        public String City;
        public String Country;
        public String Street;
        public String PostalCode;
        public String State;

        public MapLocation(Study_Site__c site) {
            Country = site.Site__r.BillingCountry;
            City = site.Site__r.BillingCity;
            Street = site.Site__r.BillingStreet;
            PostalCode = site.Site__r.BillingPostalCode;
            State = site.Site__r.BillingStateCode;
        }
    }

    @AuraEnabled
    public static String getInitData(Id trialId, String delegateId) {
        try {
            InitData initData = new InitData();

            initData.trial = TrialService.getTrial(trialId);
            //pagination:
            initData.paginationData = new PaginationData();
            //filters data:
            initData.siteFilterData = StudySiteService.getSiteFilterData(trialId, 'HCP');

            initData.siteFilter = new StudySiteService.SiteFilter(initData.siteFilterData);

            initData.currentPageList = StudySiteService.getStudySitesWithDistanceForHCPByTrialId(
                initData.siteFilter,
                initData.paginationData,
                false,
                delegateId
            );
            for (Integer i = 1; i <= initData.currentPageList.size(); i++) {
                initData.currentPageList[i - 1].site.Name =
                    String.valueOf(i) +
                    '. ' +
                    initData.currentPageList[i - 1].site.Name;
            }
            initData.mapMarkers = new List<MapMarker>();
            for (StudySiteService.StudySiteDistanceWrapper siteWrapper : initData.currentPageList) {
                if (
                    siteWrapper.siteType != 'Virtual' &&
                    siteWrapper.site.Site__r.BillingAddress != null
                ) {
                    initData.mapMarkers.add(new MapMarker(siteWrapper.site));
                }
            }
            initData.accessLevel = CommunityService.getInstance().getUserAccessLevel(delegateId);
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    class SearchResult {
        List<StudySiteService.StudySiteDistanceWrapper> siteList;
        PaginationData paginationData;
        List<MapMarker> mapMarkers;
    }

    @AuraEnabled
    public static String getRecords(String filterJSON, String paginationJSON, String delegateId) {
        StudySiteService.SiteFilter filter = (StudySiteService.SiteFilter) JSON.deserialize(
            filterJSON,
            StudySiteService.SiteFilter.class
        );
        PaginationData pagination = (PaginationData) JSON.deserialize(
            paginationJSON,
            PaginationData.class
        );
        try {
            SearchResult result = new SearchResult();
            result.siteList = StudySiteService.getStudySitesWithDistanceForHCPByTrialId(
                filter,
                pagination,
                false,
                delegateId
            );
            for (Integer i = 1; i <= result.siteList.size(); i++) {
                result.siteList[i - 1].site.Name =
                    String.valueOf(pagination.offset + i) +
                    '. ' +
                    result.siteList[i - 1].site.Name;
            }
            result.mapMarkers = new List<MapMarker>();
            for (StudySiteService.StudySiteDistanceWrapper siteWrapper : result.siteList) {
                if (
                    siteWrapper.siteType != 'Virtual' &&
                    siteWrapper.site.Principal_Investigator__r.Account.BillingAddress != null
                ) {
                    result.mapMarkers.add(new MapMarker(siteWrapper.site));
                }
            }
            result.paginationData = pagination;
            return JSON.serialize(result);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}
