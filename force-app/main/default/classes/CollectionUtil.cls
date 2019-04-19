public with sharing class CollectionUtil {

    public static List<String> getListOfIdsWrappedInApostrophes(Set<Id> idsSet) {

        return CollectionUtil.getListOfIdsWrappedInApostrophes(CollectionUtil.getStringsSetFromIdsSet(idsSet));
    }

    public static List<String> getListOfIdsWrappedInApostrophes(Set<String> idsSet) {

        List<String> result = new List<String>();
        for(String singleId : idsSet) {
            result.add('\'' + singleId + '\'');
        }
        return result;
    }

    public static Set<String> getStringsSetFromIdsSet(Set<Id> idsSet) {
        Set<String> result = new Set<String>();
        for(Id singleId : idsSet) {
            result.add(singleId);
        }
        return result;
    }
}