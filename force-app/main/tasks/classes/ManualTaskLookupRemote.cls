/**
 * Created by Igor Malyuta on 04.03.2019.
 */

public with sharing class ManualTaskLookupRemote {

    public static final Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchTherapeutic(String searchTerm, List<String> selectedIds) {
        try {
            // Prepare query paramters
            searchTerm += '*';

            // Execute search query
            List<List<SObject>> searchResults = [
                    FIND :searchTerm
                    IN ALL FIELDS
                            RETURNING
                            Therapeutic_Area__c (Id, Name WHERE id NOT IN :selectedIds)
                    LIMIT :MAX_RESULTS
            ];

            List<LookupSearchResult> results = new List<LookupSearchResult>();

            String icon = 'custom:custom18';

            Therapeutic_Area__c [] studies = ((List<Therapeutic_Area__c>) searchResults[0]);
            for (Therapeutic_Area__c area : studies) {
                results.add(new LookupSearchResult(
                        area.Id,
                        'Therapeutic_Area__c',
                        icon,
                        area.Name,
                        '')
                );
            }

            return results;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }

    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchSponsor(String searchTerm, List<String> selectedIds) {
        try {
            // Prepare query paramters
            searchTerm += '*';

            // Execute search query
            List<List<SObject>> searchResults = [
                    FIND :searchTerm
                    IN ALL FIELDS
                            RETURNING
                            Account (Id, Name WHERE id NOT IN :selectedIds)
                    LIMIT :MAX_RESULTS
            ];

            List<LookupSearchResult> results = new List<LookupSearchResult>();

            String accountIcon = 'standard:account';

            Account [] accounts = ((List<Account>) searchResults[0]);
            for (Account account : accounts) {
                results.add(new LookupSearchResult(
                        account.Id,
                        'Account',
                        accountIcon,
                        account.Name,
                        '')
                );
            }
            return results;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }

    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchCountries(String searchTerm, List<String> selectedIds) {
        try {
            String icon = 'custom:custom68';

            List<LookupSearchResult> results = new List<LookupSearchResult>();

            List<LabelValueItem> allCountries = CountryStateUtil.getCountries();
            for (LabelValueItem item : allCountries) {
                //not dublicate
                if (selectedIds.contains(item.value)) continue;

                if (item.label.containsIgnoreCase(searchTerm)) {
                    results.add(new LookupSearchResult(
                            item.value,
                            'Country',
                            icon,
                            item.label,
                            ''
                    ));
                }

                if (results.size() >= MAX_RESULTS) break;
            }
            return results;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }


    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchStudy(String searchTerm, List<String> selectedIds) {
        try {
            // Prepare query paramters
            searchTerm += '*';
            String icon = 'custom:custom86';

            List<List<SObject>> searchResults = [
                    FIND :searchTerm
                    IN ALL FIELDS
                            RETURNING
                            Clinical_Trial_Profile__c (Id, Name, Study_Code_Name__c WHERE id NOT IN :selectedIds AND Tasks_Are_Available__c = TRUE)
                    LIMIT :MAX_RESULTS
            ];

            // Prepare results
            List<LookupSearchResult> results = new List<LookupSearchResult>();

            Clinical_Trial_Profile__c [] studies = ((List<Clinical_Trial_Profile__c>) searchResults[0]);
            for (Clinical_Trial_Profile__c study : studies) {
                results.add(new LookupSearchResult(
                        study.Id,
                        'Clinical_Trial_Profile__c',
                        icon,
                        study.Name,
                        'Code name ' + study.Study_Code_Name__c)
                );
            }
            return results;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }

    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchSite(String searchTerm, List<String> selectedIds) {
        try {
            // Prepare query paramters
            searchTerm += '*';

            String icon = 'custom:custom16';

            List<List<SObject>> searchResults = [
                    FIND :searchTerm
                    IN ALL FIELDS
                            RETURNING
                            Study_Site__c (Id, Name WHERE id NOT IN :selectedIds AND Clinical_Trial_Profile__r.Tasks_Are_Available__c = TRUE)
                    LIMIT :MAX_RESULTS
            ];

            Study_Site__c [] sites = ((List<Study_Site__c>) searchResults[0]);

            List<LookupSearchResult> results = new List<LookupSearchResult>();
            for (Study_Site__c site : sites) {
                results.add(new LookupSearchResult(
                        site.Id,
                        'Study_Site__c',
                        icon,
                        site.Name,
                        '')
                );
            }
            return results;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }
}