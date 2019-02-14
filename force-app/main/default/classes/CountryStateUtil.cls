/**
 * Created by Leonid Bartenev
 */

public class CountryStateUtil {
    
    public static final Map<String, String> COUNTRY_MAP = new Map<String, String>();
    public static final Map<String, String> COUNTRY_CODE_BY_NAME_MAP = new Map<String, String>();
    public static final Map<String, Map<String, String>> STATES_NAME_BY_CODE_MAP = new Map<String, Map<String, String>>();
    public static final Map<String, Map<String, String>> STATES_CODE_BY_NAME_MAP = new Map<String, Map<String, String>>();
    
    public static final Map<String, List<LabelValueItem>> DEPENDENT_STATES_MAP = new FieldDescribeUtil().controllingToDependentValues(User.CountryCode, User.StateCode);
    
    static {
        for( Schema.PicklistEntry field :  User.CountryCode.getDescribe().getPicklistValues()){
            COUNTRY_MAP.put(field.getValue(), field.getLabel());
            COUNTRY_CODE_BY_NAME_MAP.put(field.getLabel(), field.getValue());
        }
    }
    
    public static Map<String, String> getStateNameByCodeMap(String countryCode){
        Map<String, String> resMap = STATES_NAME_BY_CODE_MAP.get(countryCode);
        if(resMap == null){
            resMap = new Map<String, String>();
            List<LabelValueItem> items = DEPENDENT_STATES_MAP.get(countryCode);
            if(items != null){
                for(LabelValueItem item : items){
                    resMap.put(item.value, item.label);
                }
                STATES_NAME_BY_CODE_MAP.put(countryCode, resMap);
            }
        }
        return resMap;
    }
    
    public static Map<String, String> getStateCodeByNameMap(String countryCode){
        Map<String, String> resMap = STATES_CODE_BY_NAME_MAP.get(countryCode);
        if(resMap == null){
            resMap = new Map<String, String>();
            List<LabelValueItem> items = DEPENDENT_STATES_MAP.get(countryCode);
            if(items != null){
                for(LabelValueItem item : items){
                    resMap.put(item.label, item.value);
                }
                STATES_CODE_BY_NAME_MAP.put(countryCode, resMap);
            }
        }
        return resMap;
    }
    
    public static String getCountryName(String countryCode){
        return COUNTRY_MAP.get(countryCode);
    }
    
    public static String getCountryCode(String countryName){
        return COUNTRY_CODE_BY_NAME_MAP.get(countryName);
    }
    
    public static String getStateName(String countryCode, String stateCode){
        return getStateNameByCodeMap(countryCode).get(stateCode);
    }
    
    public static String getStateCode(String countryCode, String stateName){
        return getStateCodeByNameMap(countryCode).get(stateName);
    }
    
    public static List<LabelValueItem> getCountries(){
        List<LabelValueItem> countries = new List<LabelValueItem>();
        for(String countryCode : COUNTRY_MAP.keySet()) countries.add(new LabelValueItem(COUNTRY_MAP.get(countryCode), countryCode));
        return countries;
    }
    
    public static Map<String, List<LabelValueItem>> getStatesByCountryMap(){
        return DEPENDENT_STATES_MAP;
    }
    
}