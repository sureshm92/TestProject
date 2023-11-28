public with sharing class ppNewRestrictedSourceConfigCon {
    
    @AuraEnabled(cacheable = false)
    public static Integer getRestrictedSourceConfigData(String recordId) {
        Integer noOfConfigRecrds = 
            [SELECT COUNT() FROM Restricted_Source_Config__c WHERE Study__c =: recordId];
        return noOfConfigRecrds;
    }

    @AuraEnabled(cacheable = false)
    public static Restricted_Source_Config__c getRestrictedSourceConfigRecord(String recordId) {
        list<Restricted_Source_Config__c> restrictedRecrd = 
            [SELECT Id,Sponsor__c,Study__c,Referral_Resource__c FROM Restricted_Source_Config__c WHERE Study__c =: recordId];
        if(restrictedRecrd!=null && restrictedRecrd.size()>0){
             return restrictedRecrd[0];
        }
        return null;
    }
    
    @AuraEnabled (cacheable=true)
    public static String getFieldsFromFieldSet(String strObjectApiName, String strfieldSetName){
        if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName)){   
            Map<String, String> returnMap = new Map<String, String>();

            //get fields from FieldSet
            SObject sObj = (SObject)(Type.forName('Schema.'+ strObjectApiName)?.newInstance());
            List<Schema.FieldSetMember> lstFSMember = 
                sObj?.getSObjectType()?.getDescribe()?.fieldSets.getMap().get(strfieldSetName)?.getFields();
                
            returnMap.put('FIELD_LIST',JSON.serialize(lstFSMember));
            returnMap.put('OBJECT_LABEL', sObj?.getSObjectType()?.getDescribe()?.getLabel());

            return JSON.serialize(returnMap);
        }                                                                 
        return null;
    }
}