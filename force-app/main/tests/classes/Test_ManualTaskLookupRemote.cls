/**
 * Created by Igor Malyuta on 22.04.2019.
 */

@IsTest(IsParallel=false)
private class Test_ManualTaskLookupRemote {

    public class CommunityServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'createPortalUsers') {
                return null;
            }
            return null;
        }
    }

    @IsTest
    static void searchTherapeuticTest() {
        //Mock data for search
        Therapeutic_Area__c searchingTA = new Therapeutic_Area__c(Name = 'Test Area');
        insert searchingTA;
        List<String> searchingTAIds = new List<String>();
        searchingTAIds.add(searchingTA.Id);

        //Mock data already found
        Therapeutic_Area__c selectedTA = new Therapeutic_Area__c(Name = 'Test Area 2');
        insert selectedTA;
        List<String> selectedTAIds = new List<String>();
        selectedTAIds.add(selectedTA.Id);

        Test.startTest();
        Test.setFixedSearchResults(searchingTAIds);
        List<LookupSearchResult> lookupSearchResults = ManualTaskLookupRemote.searchTherapeutic('Test Area', selectedTAIds);
        Test.stopTest();

        LookupSearchResult expectedResult =
                new LookupSearchResult(searchingTA.Id, 'Therapeutic_Area__c', null, searchingTA.Name, '');

        assertThat(expectedResult, lookupSearchResults);
    }

    @IsTest
    static void searchSponsorTest() {
        //Mock data for search
        Account searchingAcc = new Account(Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME);
        insert searchingAcc;
        List<String> searchingAccIds = new List<String>();
        searchingAccIds.add(searchingAcc.Id);

        //Mock data already found
        Account selectedAcc = new Account(Name = 'Test');
        insert selectedAcc;
        List<String> selectedAccId = new List<String>();
        selectedAccId.add(selectedAcc.Id);

        Test.startTest();
        Test.setFixedSearchResults(searchingAccIds);
        List<LookupSearchResult> lookupSearchResults = ManualTaskLookupRemote.searchSponsor('Participant', selectedAccId);
        Test.stopTest();

        LookupSearchResult expectedResult =
                new LookupSearchResult(searchingAcc.Id, 'Account', null, searchingAcc.Name, '');

        assertThat(expectedResult, lookupSearchResults);
    }

    @IsTest
    static void searchCountriesTest() {
        //Mock data for search
        List<String> selectedCountries = new List<String>();
        selectedCountries.add('CA');

        Test.startTest();
        List<LookupSearchResult> lookupSearchResults =
                ManualTaskLookupRemote.searchCountries('France', selectedCountries);
        Test.stopTest();

        LookupSearchResult expectedResult =
                new LookupSearchResult('FR', 'Country', null, 'France', '');

        assertThat(expectedResult, lookupSearchResults);
    }

    @IsTest
    static void searchStudyTest() {
        //Mock data for search
        Therapeutic_Area__c ta = new Therapeutic_Area__c(Name = 'Test Area');
        insert ta;
        Clinical_Trial_Profile__c searchingTrial = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'Prot-333',
                NCT_Number__c = 'NCT02804789',
                Therapeutic_Area__c = ta.Id,
                Synch_with_TMDH__c = true,
                Tasks_Are_Available__c = true
        );
        insert searchingTrial;
        List<String> searchingTrialIds = new List<String>();
        searchingTrialIds.add(searchingTrial.Id);

        //Mock data already found
        Therapeutic_Area__c ta2 = new Therapeutic_Area__c(Name = 'Test Area 2');
        insert ta2;
        Clinical_Trial_Profile__c selectedTrial = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'Prot-222',
                NCT_Number__c = 'NCT01111111',
                Therapeutic_Area__c = ta2.Id,
                Synch_with_TMDH__c = true,
                Tasks_Are_Available__c = true
        );
        insert selectedTrial;
        List<String> selectedTrialIds = new List<String>();
        selectedTrialIds.add(selectedTrial.Id);

        Test.startTest();
        Test.setFixedSearchResults(searchingTrialIds);
        List<LookupSearchResult> lookupSearchResults =
                ManualTaskLookupRemote.searchStudy('NCT02804789', selectedTrialIds);
        Test.stopTest();

        Clinical_Trial_Profile__c searchingTrialFromDB = [
                SELECT Id, Name
                FROM Clinical_Trial_Profile__c
                WHERE Id = :searchingTrial.Id
        ].get(0);
        LookupSearchResult expectedResult = new LookupSearchResult(
                searchingTrialFromDB.Id,
                'Clinical_Trial_Profile__c',
                null,
                searchingTrialFromDB.Name,
                'Code name ' + searchingTrial.Study_Code_Name__c
        );

        assertThat(expectedResult, lookupSearchResults);
    }

    @IsTest
    static void searchSiteTest() {
        //Mock data for search
        Therapeutic_Area__c ta = new Therapeutic_Area__c(Name = 'Test Area');
        insert ta;
        Clinical_Trial_Profile__c trial = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'Prot-333',
                NCT_Number__c = 'NCT02804789',
                Therapeutic_Area__c = ta.Id,
                Synch_with_TMDH__c = true,
                Tasks_Are_Available__c = true
        );
        insert trial;

        Account clinic = new Account(Name = 'Clinic');
        insert clinic;
        Contact pi = new Contact(
                FirstName = 'Joseph',
                LastName = 'Davis PI And HCP',
                Email = 'jdavis@somemail.com',
                AccountId = clinic.Id
        );
        insert pi;

        CommunityService.setMock(new CommunityServiceMock());

        Study_Site__c searchingSite = new Study_Site__c(
                Name = 'Test SS1',
                Clinical_Trial_Profile__c =  trial.Id,
                Site__c =  clinic.Id,
                Principal_Investigator__c =  pi.Id,
                Override_PI_Referral_Status__c = 'Invitation Sent',
                Study_Site_Key__c = '12132123132313',
                Study_Site_Phone__c =  '+1(232) 222-3434'
        );
        insert searchingSite;
        List<String> searchingSSIds = new List<String>();
        searchingSSIds.add(searchingSite.Id);

        //Mock data already found
        Therapeutic_Area__c ta2 = new Therapeutic_Area__c(Name = 'Test Area 2');
        insert ta2;
        Clinical_Trial_Profile__c trial2 = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'Prot-222',
                NCT_Number__c = 'NCT01111111',
                Therapeutic_Area__c = ta2.Id,
                Synch_with_TMDH__c = true,
                Tasks_Are_Available__c = true
        );
        insert trial2;

        Account clinic2 = new Account(Name = 'Clinic 2');
        insert clinic2;
        Contact sam = new Contact(
                FirstName = 'Samuel',
                LastName = 'Rodriguez PI',
                Email = 'srodriguez@somemail.com',
                AccountId = clinic2.Id
        );
        insert sam;

        Study_Site__c selectedSite = new Study_Site__c(
                Name = 'Test SS2',
                Clinical_Trial_Profile__c =  trial2.Id,
                Site__c =  clinic2.Id,
                Principal_Investigator__c =  sam.Id,
                Override_PI_Referral_Status__c = 'Invitation Sent',
                Study_Site_Key__c = '66666623132313',
                Study_Site_Phone__c =  '+1(232) 222-7777'
        );
        insert selectedSite;
        List<String> selectedSSIds = new List<String>();
        selectedSSIds.add(selectedSite.Id);

        Test.startTest();
        Test.setFixedSearchResults(searchingSSIds);
        List<LookupSearchResult> lookupSearchResults = ManualTaskLookupRemote.searchSite('Test SS1', selectedSSIds);
        Test.stopTest();

        LookupSearchResult expectedResult =
                new LookupSearchResult(searchingSite.Id, 'Study_Site__c', null, searchingSite.Name, '');

        assertThat(expectedResult, lookupSearchResults);
    }

    private static void assertThat(LookupSearchResult expectedResult, List<LookupSearchResult> lookupSearchResults) {
        System.assertEquals(expectedResult.id, lookupSearchResults.get(0).id);
        System.assertEquals(expectedResult.sObjectType, lookupSearchResults.get(0).sObjectType);
        //System.assertEquals(expectedResult.title, lookupSearchResults.get(0).title);
        System.assertEquals(expectedResult.subtitle, lookupSearchResults.get(0).subtitle);
    }
}