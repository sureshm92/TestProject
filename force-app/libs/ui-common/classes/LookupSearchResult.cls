/**
* Class used to serialize a single Lookup search result item
* The Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning
*/
public class LookupSearchResult {
    
    @AuraEnabled public String id;
    @AuraEnabled public String sObjectType;
    @AuraEnabled public String icon;
    @AuraEnabled public String title;
    @AuraEnabled public String subtitle;

    public LookupSearchResult(String id, String sObjectType, String icon, String title, String subtitle) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
    }
    
}