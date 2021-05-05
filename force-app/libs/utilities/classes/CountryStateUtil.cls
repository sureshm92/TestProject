/**
 * Created by Leonid Bartenev
 */

public class CountryStateUtil {
    public static final Map<String, String> COUNTRY_MAP = new Map<String, String>();
    public static final Map<String, String> COUNTRY_CODE_BY_NAME_MAP = new Map<String, String>();
    public static final Map<String, Map<String, String>> STATES_NAME_BY_CODE_MAP = new Map<String, Map<String, String>>();
    public static final Map<String, Map<String, String>> STATES_CODE_BY_NAME_MAP = new Map<String, Map<String, String>>();
	public static final Map<String, String> COUNTRY_CODE_BY_NAME_MAP_Mdt = new Map<String, String>(); 
    public static final Map<String, Map<String, String>> STATES_CODE_BY_NAME_MAP_Mdt = new Map<String, Map<String, String>>(); 
    public static final Map<String, String> COUNTRY_NAME_By_CODE_MAP_Mdt = new Map<String, String>();
    public static final Map<String, Map<String, String>> STATES_NAME_By_CODE_MAP_Mdt = new Map<String, Map<String, String>>();
    public static final Map<String, String> COUNTRY_CODE_TO_NAME = new Map<String, String>(); 
    public static final Map<String, String> COUNTRY_NAME_TO_CODE= new Map<String, String>();

    public static final Map<String, List<LabelValueItem>> DEPENDENT_STATES_MAP = new FieldDescribeUtil()
        .controllingToDependentValues(User.CountryCode, User.StateCode);

    static {
        for (Schema.PicklistEntry field : User.CountryCode.getDescribe().getPicklistValues()) {
            COUNTRY_MAP.put(field.getValue(), field.getLabel());
            COUNTRY_CODE_BY_NAME_MAP.put(field.getLabel(), field.getValue());
        }
		//Call this method to create Maps of the country Code VS Country Name and State Code VS State name from Custome metadata to fix the language translation issue for State and country
		createCountryStateMapfromMetadata();
    }

    public static Map<String, String> getStateNameByCodeMap(String countryCode) {
        Map<String, String> resMap = STATES_NAME_BY_CODE_MAP.get(countryCode);
        if (resMap == null) {
            resMap = new Map<String, String>();
            List<LabelValueItem> items = DEPENDENT_STATES_MAP.get(countryCode);
            if (items != null) {
                for (LabelValueItem item : items) {
                    resMap.put(item.value, item.label);
                }
                STATES_NAME_BY_CODE_MAP.put(countryCode, resMap);
            }
        }
        return resMap;
    }

    public static Map<String, String> getStateCodeByNameMap(String countryCode) {
        Map<String, String> resMap = STATES_CODE_BY_NAME_MAP.get(countryCode);
        if (resMap == null) {
            resMap = new Map<String, String>();
            List<LabelValueItem> items = DEPENDENT_STATES_MAP.get(countryCode);
            if (items != null) {
                for (LabelValueItem item : items) {
                    resMap.put(item.label, item.value);
                }
                STATES_CODE_BY_NAME_MAP.put(countryCode, resMap);
            }
        }
        return resMap;
    }

    public static String getCountryName(String countryCode) {
        return COUNTRY_MAP.get(countryCode);
    }

    public static String getCountryCode(String countryName) {
        return COUNTRY_CODE_BY_NAME_MAP.get(countryName);
    }

    public static String getStateName(String countryCode, String stateCode) {
        return getStateNameByCodeMap(countryCode).get(stateCode);
    }

    public static String getStateCode(String countryCode, String stateName) {
        return getStateCodeByNameMap(countryCode).get(stateName);
    }

    public static List<LabelValueItem> getCountries() {
        List<LabelValueItem> countries = new List<LabelValueItem>();
        for (String countryCode : COUNTRY_MAP.keySet())
            countries.add(new LabelValueItem(COUNTRY_MAP.get(countryCode), countryCode));
        return countries;
    }

    public static Map<String, List<LabelValueItem>> getStatesByCountryMap() {
        return DEPENDENT_STATES_MAP;
    }
	
	public static void createCountryStateMapfromMetadata(){    
        for(RH_State_Code_By_Country_Name__mdt md: [Select Id, State_Code__c,State_Name__c,IsVisible__c,RH_Country_Name__c,RH_Country_Name__r.Country_Name__c, RH_Country_Name__r.Country_Code__c,RH_Country_Name__r.IsVisible__c from RH_State_Code_By_Country_Name__mdt]){
             String countryCode = '';
             String countryName = '';
             String StateCode = '';
             String StateName = '';
            //Null checks 
			Boolean isNotNull = (!String.isEmpty(md.RH_Country_Name__c) && !String.isEmpty(md.RH_Country_Name__r.Country_Code__c) && !String.isEmpty(md.RH_Country_Name__r.Country_Name__c) && !String.isEmpty(md.State_Code__c) && !String.isEmpty(md.State_Name__c) && md.IsVisible__c && md.RH_Country_Name__r.IsVisible__c);
            if(isNotNull){
                 countryCode = md.RH_Country_Name__r.Country_Code__c;
                 countryName = md.RH_Country_Name__r.Country_Name__c;
                 StateCode   = md.State_Code__c;
                 StateName   = md.State_Name__c;
                //Put Country code corresponding to country Name in Map and vice Versa.
                COUNTRY_CODE_BY_NAME_MAP_Mdt.put(countryName,countryCode);
                COUNTRY_NAME_By_CODE_MAP_Mdt.put(countryCode,countryName);
                //Put State code corresponding to State Name in Map corresponding to each Country Code.
                if(STATES_CODE_BY_NAME_MAP_Mdt.containsKey(countryCode)){
                    Map<String,String> StateNameCodeMap = STATES_CODE_BY_NAME_MAP_Mdt.get(countryCode);
                    StateNameCodeMap.put(StateName,StateCode);
                    STATES_CODE_BY_NAME_MAP_Mdt.put(countryCode,StateNameCodeMap);
                }else{
                    Map<String,String> StateNameCodeMap = New Map<String,String>();
                    StateNameCodeMap.put(StateName,StateCode);
                    STATES_CODE_BY_NAME_MAP_Mdt.put(countryCode,StateNameCodeMap);
                }	
                //Put State Name corresponding to State Code in Map corresponding to each Country Code.
                if(STATES_NAME_By_CODE_MAP_Mdt.containsKey(countryCode)){
                    Map<String,String> StateCodeNameMap = STATES_NAME_By_CODE_MAP_Mdt.get(countryCode);
                    StateCodeNameMap.put(StateCode,StateName);
                    STATES_NAME_By_CODE_MAP_Mdt.put(countryCode,StateCodeNameMap);
                }else{
                    Map<String,String> StateCodeNameMap = New Map<String,String>();
                    StateCodeNameMap.put(StateCode,StateName);
                    STATES_NAME_By_CODE_MAP_Mdt.put(countryCode,StateCodeNameMap);
                }	

            }
        } 
        List<RH_Country_Name__mdt> countryMetaLst = [SELECT id,Country_Code__c,Country_Name__c,IsVisible__c FROM RH_Country_Name__mdt];
        for(RH_Country_Name__mdt meta: countryMetaLst){
            if(meta.IsVisible__c == true){
                COUNTRY_CODE_TO_NAME.put(meta.Country_Name__c,meta.Country_Code__c);
                COUNTRY_NAME_TO_CODE.put(meta.Country_Code__c,meta.Country_Name__c);
            }
        }  
    }
}