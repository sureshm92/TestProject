/**
 * Created by Leonid Bartenev
 */

public class RRPicklistLookupRemote {
    
    @AuraEnabled
    public static List<LookupSearchResult> getAllValues(String objectName, String fieldName, String iconName){
        try {
            SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
            SObjectField sObjectField = sObjectType.getDescribe().fields.getMap().get(fieldName);
            List<PicklistEntry> pleList = sObjectField.getDescribe().getPicklistValues();
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            for(PicklistEntry ple : pleList){
                resList.add(new LookupSearchResult(
                        ple.value,
                        null,
                        iconName,
                        ple.label,
                        null
                ));
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

}