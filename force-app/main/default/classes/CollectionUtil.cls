public with sharing class CollectionUtil {

    public static List<String> wrapInApostrophes(Set<Id> idsSet) {
        return CollectionUtil.wrapInApostrophes(CollectionUtil.getStringsSetFromIdsSet(idsSet));
    }

    public static List<String> wrapInApostrophes(List<String> valuesList) {
        return CollectionUtil.wrapInApostrophes(new Set<String>(valuesList));
    }

    public static List<String> wrapInApostrophes(Set<String> valuesSet) {

        List<String> result = new List<String>();
        for (String singleValue : valuesSet) {
            result.add('\'' + singleValue + '\'');
        }
        return result;
    }

    public static Set<String> getStringsSetFromIdsSet(Set<Id> idsSet) {
        Set<String> result = new Set<String>();
        for (Id singleId : idsSet) {
            result.add(singleId);
        }
        return result;
    }

    public static String joinByComa(List<String> listOfStrings) {
        return String.join(listOfStrings, ',');
    }
    public static List<String> split(String valueString, String separator) {
        return valueString.split(separator);
    }
}