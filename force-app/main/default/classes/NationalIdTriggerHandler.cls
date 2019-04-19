/**
 * Refactored by Leonid Bartenev
 */

public without sharing class NationalIdTriggerHandler {
    
    // Handlers: -------------------------------------------------------------------------------------------------------
    
    public class PrepareCityStateFieldsHandler extends TriggerHandler{
        
        public override void beforeInsert(List<SObject> newList) {
            prepareCityStateFields(newList, null);
        }
        
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            prepareCityStateFields(newList, (Map<Id, National_ID__c>)oldMap);
        }
    }
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void prepareCityStateFields(List<National_ID__c> newList, Map<Id, National_ID__c> oldMap) {
        for (National_ID__c natId : newList) {
        
            String countryName = natId.Country__c;
            String countryCode = natId.Country_Code_Text__c;
            String stateName = natId.State__c;
            String stateCode = natId.State_Code__c;
            if (oldMap == null) {
                if ((countryName == null && countryCode == null)) {
                    natId.addError('Country information required');
                } else if (countryCode == null && countryName != null) {
                    natId.Country_Code_Text__c = CountryStateUtil.getCountryCode(countryName);
                    if (natId.Country_Code_Text__c == null) {
                        natId.addError('Invalid Country');
                    }
                } else if (countryCode != null && countryName == null) {
                    natId.Country__c = CountryStateUtil.getCountryName(countryCode);
                    if (natId.Country__c == null) {
                        natId.addError('Invalid Country Code');
                    }
                } else if (countryCode != null && countryName != null) {
                    if (countryCode != CountryStateUtil.getCountryCode(countryName)) {
                        natId.addError('Invalid County and Country Code');
                    }
                }
                if (stateCode == null && stateName != null) {
                    natId.State_Code__c = CountryStateUtil.getStateCode(natId.Country_Code_Text__c, stateName);
                    if (natId.State_Code__c == null) {
                        natId.addError('Mismatch between state and country values');
                    }
                } else if (stateCode != null && stateName == null) {
                    natId.State__c = CountryStateUtil.getStateName(natId.Country_Code_Text__c, stateCode);
                    if (natId.State__c == null) {
                        natId.addError('Mismatch between state and country values');
                    }
                } else if (stateCode != null && stateName != null) {
                    if (stateCode != CountryStateUtil.getStateCode(natId.Country_Code_Text__c, stateName)) {
                        natId.addError('Mismatch between state and country values');
                    }
                }
            }
            if (oldMap != null) {
                if(countryName == null){
                    countryName = oldMap.get(natId.Id).Country__c;
                    natId.Country__c = countryName;
                }
                if(countryCode == null){
                    countryCode = oldMap.get(natId.Id).Country_Code_Text__c;
                    natId.Country_Code_Text__c = countryCode;
                }
                Boolean countryNameChanged = oldMap.get(natId.Id).Country__c != countryName;
                Boolean countryCodeChanged = oldMap.get(natId.Id).Country_Code_Text__c != countryCode;
                Boolean stateNameChanged = oldMap.get(natId.Id).State__c != stateName;
                Boolean stateCodeChanged = oldMap.get(natId.Id).State_Code__c != stateCode;
                if (countryCodeChanged && !countryNameChanged) {
                    natId.Country__c = CountryStateUtil.getCountryName(countryCode);
                    if (natId.Country__c == null && countryCode != null) {
                        natId.addError('Invalid Country Code');
                    }
                } else if (!countryCodeChanged && countryNameChanged) {
                    natId.Country_Code_Text__c = CountryStateUtil.getCountryCode(countryName);
                    if (natId.Country_Code_Text__c == null && countryName != null) {
                        natId.addError('Invalid Country');
                    }
                } else if (countryCodeChanged && countryNameChanged) {
                    if (countryCode != CountryStateUtil.getCountryCode(countryName)) {
                        natId.addError('Invalid County and Country Code');
                    }
                }
                if (stateCodeChanged && !stateNameChanged) {
                    natId.State__c = CountryStateUtil.getStateName(natId.Country_Code_Text__c, stateCode);
                    if (natId.State__c == null && stateCode != null) {
                        natId.addError('Mismatch between state and country values');
                    }
                } else if (!stateCodeChanged && stateNameChanged) {
                    natId.State_Code__c = CountryStateUtil.getStateCode(natId.Country_Code_Text__c, stateName);
                    if (natId.State_Code__c == null && stateName != null) {
                        natId.addError('Mismatch between state and country values');
                    }
                } else if (stateCodeChanged && stateNameChanged) {
                    if (stateCode != CountryStateUtil.getStateCode(natId.Country_Code_Text__c, stateName)) {
                        natId.addError('Mismatch between state and country values');
                    }
                } else if (countryCodeChanged || countryNameChanged) {
                    if (stateCode != CountryStateUtil.getStateCode(natId.Country_Code_Text__c, stateName)) {
                        natId.addError('Mismatch between state and country values');
                    }
                }
            }
        }
    }
}