@isTest
private without sharing class Test_SiteListPageRemote {
    @TestSetup
    static void makeData() {
        ClassFactory.putStubTypeByClassName(
            CommunityService.class,
            StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );
        TestData.loadTestData();
    }

    @isTest
    private static void testGetSearchResults() {
        TestData td = new TestData();
        Test.startTest();
        SiteListPageRemote.PaginatedSiteWrapper paginatedWrapper0 = SiteListPageRemote.getSearchResults(
            'Principal_Investigator__r.Name',
            'PITD',
            'Name ASC',
            null
        );
        SiteListPageRemote.PaginatedSiteWrapper paginatedWrapper1 = SiteListPageRemote.getSearchResults(
            'Name',
            'Test',
            'Name ASC',
            null
        );
        SiteListPageRemote.PaginatedSiteWrapper paginatedWrapper2 = SiteListPageRemote.getSearchResults(
            'Study_Site_Number__c',
            'SS1',
            'Name ASC',
            null
        );
        //Negative scenario
        try {
            SiteListPageRemote.PaginatedSiteWrapper paginatedWrapper3 = SiteListPageRemote.getSearchResults(
                '',
                '',
                'Name ASC',
                null
            );
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
        System.assertNotEquals(0, paginatedWrapper0.sites.size(), 'Expected a non-empty list.');
        System.assertEquals(0, paginatedWrapper1.sites.size(), 'Expected a non-empty list.');
        System.assertNotEquals(0, paginatedWrapper2.sites.size(), 'Expected a non-empty list.');
    }

    @isTest
    private static void testGetAllSearchResults() {
        TestData td = new TestData();
        Test.startTest();
        SiteListPageRemote.CSVWrapper paginatedWrapper0 = SiteListPageRemote.getAllSearchResults(
            'Principal_Investigator__r.Name',
            'PITD',
            new List<String>{ td.ss.Id },
            1
        );
        SiteListPageRemote.CSVWrapper paginatedWrapper1 = SiteListPageRemote.getAllSearchResults(
            'Name',
            'Test',
            new List<String>{},
            50000
        );
        SiteListPageRemote.CSVWrapper paginatedWrapper2 = SiteListPageRemote.getAllSearchResults(
            'Study_Site_Number__c',
            'SS1',
            new List<String>{},
            1
        );
        //Negative scenario
        try {
            SiteListPageRemote.CSVWrapper paginatedWrapper3 = SiteListPageRemote.getAllSearchResults(
                '',
                '',
                null,
                0
            );
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(0, paginatedWrapper0.sites.size(), 'Expected a non-empty list.');
        System.assertEquals(0, paginatedWrapper1.sites.size(), 'Expected a non-empty list.');
        System.assertNotEquals(0, paginatedWrapper2.sites.size(), 'Expected a non-empty list.');
    }
}
