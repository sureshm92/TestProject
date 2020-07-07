//Created by Sumit/Sabir/Mari for Covid 19
public with sharing class CPDonorReferralFormHelper 
{
    public static SObject getCleanSObject(SObject so, String sobjectName)
    {
        Set<String> fieldsSet = getFieldApIName(sobjectName);
        SObject newSO = System.Schema.getGlobalDescribe().get(sobjectName).newSObject();
        for(String field : fieldsSet)
        {
            if(so.get(field) != null)
            {
                newSO.put(field,so.get(field));
            }
        }
        return newSO;
    }

    //Get field API name
    private static Set<String> getFieldApIName(String sobjectName)
    {
        Set<String> fieldAPIList = new Set<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(sobjectName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) 
        {
            fieldAPIList.add(fieldName);
        }
        return fieldAPIList;
    }
    
    //Check Scheduled Maintenance Active or not 
    public static boolean checkScheduledMaintenance()
    {
        List<Scheduled_Maintenance_Covid__mdt> encryptionMetadata = [SELECT IsActive__c FROM Scheduled_Maintenance_Covid__mdt WHERE label = 'CheckScheduledMaintenance' limit 1];
        if(encryptionMetadata == null)
        {
            return false;
        }
        return encryptionMetadata[0].IsActive__c;
    }
}