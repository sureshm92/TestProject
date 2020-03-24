public with sharing class CollectionUtil {

    public class CollectionUtilException extends Exception {
    }
    public class SortingException extends Exception {
    }

    public static final List<String> ALLOWED_FIELD_TYPES = new List<String>{
            'ID',
            'INTEGER',
            'PICKLIST',
            'REFERENCE',
            'STRING'
    };

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

    public static List<Id> getObjectIds(List<SObject> sObjects) {
        List<Id> ids = new List<Id>();
        for (SObject obj : sObjects) ids.add(obj.Id);

        return ids;
    }

    public static Map<String, SObject> getSObjectMap(List<SObject> sObjects, String keyField) {
        Schema.SObjectField field = (SObjectField) sObjects.get(0).getSObjectType().getDescribe().fields.getMap().get(keyField);
        Schema.DisplayType fieldType = field.getDescribe().getType();
        if (!ALLOWED_FIELD_TYPES.contains(String.valueOf(fieldType))) {
            throw new CollectionUtilException('Field type not supported as key');
        }

        Map<String, SObject> sObjectsMap = new Map<String, SObject>();
        for (SObject obj : sObjects) {
            sObjectsMap.put(obj.get(keyField).toString(), obj);
        }

        return sObjectsMap;
    }

    public static void sortByField(List<SObject> objs, String fieldName, Boolean reverseSort) {
        if (objs.size() < 2) return;

        Schema.SObjectField field = objs.getSObjectType().getDescribe().fields.getMap().get(fieldName);
        if (field == null) throw new SortingException('No such field ' + fieldName);

        Schema.DescribeFieldResult fieldDesc = field.getDescribe();
        if (!fieldDesc.isSortable()) throw new SortingException('Type not sortable: ' + fieldDesc.getType());

        quickSortByField(objs, 0, objs.size() - 1, field, fieldDesc.getType());

        if(reverseSort) {
            List<SObject> reversed = new List<SObject>(objs);
            objs.clear();
            for(Integer i = reversed.size() - 1; i >= 0; i--) objs.add(reversed.get(i));
        }
    }

    private static void quickSortByField(List<SObject> arr, Integer startIndex, Integer endIndex, Schema.SObjectField field, Schema.DisplayType type) {
        Integer low = startIndex;
        Integer high = endIndex;
        if (low >= high) return;

        if (low == (high - 1)) {
            if (compareFields(arr[low], arr[high], field, type) > 0) {
                SObject obj = arr[low];
                arr[low] = arr[high];
                arr[high] = obj;
            }
            return;
        }

        SObject pivot = arr[(low + high) / 2];
        arr[(low + high) / 2] = arr[high];
        arr[high] = pivot;
        while (low < high) {
            while (compareFields(arr[low], pivot, field, type) < 1 && low < high) low++;
            while (compareFields(pivot, arr[high], field, type) < 1 && low < high) high--;
            if (low < high) {
                SObject obj = arr[low];
                arr[low] = arr[high];
                arr[high] = obj;
            }
        }
        arr[endIndex] = arr[high];
        arr[high] = pivot;
        quickSortByField(arr, startIndex, low - 1, field, type);
        quickSortByField(arr, high + 1, endIndex, field, type);
    }

    /**
     *  Determines the type of primitive the field represents, then returns the appropriate comparison
    */
    private static Integer compareFields(SObject a, SObject b, Schema.SObjectField field, Schema.DisplayType type) {
        if (type == Schema.DisplayType.EMAIL || type == Schema.DisplayType.ID || type == Schema.DisplayType.PHONE || type == Schema.DisplayType.PICKLIST
                || type == Schema.DisplayType.REFERENCE || type == Schema.DisplayType.STRING || type == Schema.DisplayType.URL) {
            // compareTo method does the same thing as the compare methods below for Numbers and Time
            // compareTo method on Strings is case-sensitive. Use following line for case-sensitivity
            // return String.valueOf(a.get(field)).compareTo(String.valueOf(b.get(field)));
             return String.valueOf(a.get(field)).toLowerCase().compareTo(String.valueOf(b.get(field)).toLowerCase());
        } else if (type == Schema.DisplayType.CURRENCY || type == Schema.DisplayType.DOUBLE
                || type == Schema.DisplayType.INTEGER || type == Schema.DisplayType.PERCENT) {
            return compareNumbers(Double.valueOf(a.get(field)), Double.valueOf(b.get(field)));
        } else if (type == Schema.DisplayType.DATE || type == Schema.DisplayType.DATETIME || type == Schema.DisplayType.TIME) {
            return compareTime((Datetime)a.get(field), (Datetime)b.get(field));
        } else {
            throw new SortingException('Type not sortable: ' + type);
        }
    }

    private static Integer compareNumbers(Double a, Double b) {
        if (a < b) {
            return -1;
        } else if (a > b) {
            return 1;
        } else {
            return 0;
        }
    }

    private static Integer compareTime(Datetime a, Datetime b) {
        if (a < b) {
            return -1;
        } else if (a > b) {
            return 1;
        } else {
            return 0;
        }
    }
}