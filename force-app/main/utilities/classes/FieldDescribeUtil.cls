/**
 * Created by Leonid Bartenev
 */

public class FieldDescribeUtil {

    public static Map<String, List<String>> getDependentOptionsImpl(Schema.SObjectField theField, Schema.SObjectField ctrlField) {
        Map<String, List<String>> result = new Map<String, List<String>>();
        Map<String, List<LabelValueItem>> dependentLVMap = new FieldDescribeUtil().controllingToDependentValues(ctrlField, theField);
        for(String code : dependentLVMap.keySet()){
            List<String> dependentItems = new List<String>();
            for(LabelValueItem item : dependentLVMap.get(code)){
                dependentItems.add(item.value);
            }
            result.put(code, dependentItems);
        }
        return result;
    }
    
    private static final String BASE_64_CHARS = ''
            + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            + 'abcdefghijklmnopqrstuvwxyz'
            + '0123456789+/';
    
    private class PicklistEntryBean {
        public Boolean active {get; set;}
        public String value {get; set;}
        public String label {get; set;}
        public String validFor {get; set;}
    }
    
    private Map<String, Set<Integer>> cache = new Map<String, Set<Integer>>();

    
    public Map<String, List<LabelValueItem>> controllingToDependentValues(SObjectField controlling, SObjectField dependent) {
        Map<String, List<LabelValueItem>> results = new Map<String, List<LabelValueItem>>();
        if (controlling != null && dependent != null) {
            //controlling field process
            List<String> controllingValues = new List<String>();
            for (PicklistEntry pe : controlling.getDescribe().getPicklistValues()) {
                if (pe.isActive()) {
                    results.put(pe.getValue(), new List<LabelValueItem>());
                    controllingValues.add(pe.getValue());
                }
            }
            //depended field process
            for (PicklistEntryBean pe : picklistEntryBeans(dependent.getDescribe().getPicklistValues())) {
                if (pe.active) {
                    for (Integer index : validForToIndices(pe.validFor)) {
                        results.get(controllingValues.get(index)).add(new LabelValueItem(pe.label, pe.value));
                    }
                }
            }
        }
        return results;
    }
    
    public  Set<Integer> validForToIndices(String validFor) {
        Set<Integer> indices = cache.get(validFor);
        if (indices == null) {
            indices = new Set<Integer>();
            String validForBits = base64ToBits(validFor);
            for (Integer i = validForBits.indexOf('1'); i >= 0; i = validForBits.indexOf('1', i + 1)) {
                indices.add(i);
            }
            cache.put(validFor, indices);
        }
        return indices;
    }
    
    private static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    private static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE_64_CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }
    
    private static PicklistEntryBean[] picklistEntryBeans(List<PicklistEntry> pes) {
        return (List<PicklistEntryBean>) JSON.deserialize(JSON.serialize(pes), List<PicklistEntryBean>.class);
    }
}