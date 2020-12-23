public without sharing class SiteListPageRemote {
    @AuraEnabled
    public static void getSearchResult() {
        try {
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
