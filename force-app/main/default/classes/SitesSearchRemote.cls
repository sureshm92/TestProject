/**
 * Created by Kryvolap
 */


public without sharing class SitesSearchRemote {

    public class InitData{
        public Clinical_Trial_Profile__c trial;
        public StudySiteService.SiteFilter siteFilter;
        public StudySiteService.SiteFilterData siteFilterData;
        public List<StudySiteService.StudySiteDistanceWrapper> currentPageList;
        public PaginationData paginationData;
        public List<Id> trialIds;
        public List<MapMarker> mapMarkers;
    }

    public class SiteWrapper{
        public Study_Site__c site;

        public SiteWrapper(Study_Site__c site){
            this.site = site;
        }
    }

    public class MapMarker{
        public MapLocation location;
        public String title;
        public  MapMarker(Study_Site__c site){
            title = site.Name;
            location = new MapLocation(site);
        }
    }
    public class MapLocation{
        public String City;
        public String Country;
        public String Street;
        public String PostalCode;
        public String State;

        public MapLocation(Study_Site__c site){
            Country = site.Site__r.BillingCountry;
            City = site.Site__r.BillingCity;
            Street = site.Site__r.BillingStreet;
            PostalCode = site.Site__r.BillingPostalCode;
            State = site.Site__r.BillingStateCode;
        }
    }



    @AuraEnabled
    public static String getInitData(Id trialId, String mode, String btnFilter, String userMode){
        try{
            InitData initData = new InitData();

            initData.trial = TrialService.getTrial(trialId);
            //pagination:
            initData.paginationData = new PaginationData();
            //filters data:
            initData.siteFilterData = StudySiteService.getSiteFilterData(trialId, 'HCP');

            initData.siteFilter = new StudySiteService.SiteFilter(initData.siteFilterData);

            initData.currentPageList = StudySiteService.getStudySitesWithDistanceForHCPByTrialId(initData.siteFilter, initData.paginationData);
            for(Integer i = 1; i<= initData.currentPageList.size(); i++){
                initData.currentPageList[i-1].site.Name = String.valueOf(i) + '. ' + initData.currentPageList[i-1].site.Name;
            }
            initData.mapMarkers = new List<MapMarker>();
            for(StudySiteService.StudySiteDistanceWrapper siteWrapper : initData.currentPageList){
                if(siteWrapper.site.Site__r.BillingAddress != null){
                    initData.mapMarkers.add(new MapMarker(siteWrapper.site));
                }
            }

            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}