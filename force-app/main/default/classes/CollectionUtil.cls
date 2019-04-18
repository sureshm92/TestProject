public with sharing class CollectionUtil {

    public static List<String> getListOfIdsWrappedInApostrophes(Set<Id> idsSet) {

        List<String> result = new List<String>();
        if (idsSet.isEmpty()) {
            return result;
        }
        for(String singleId : idsSet) {
            result.add('\'' + singleId + '\'');
        }
        return result;
    }
}