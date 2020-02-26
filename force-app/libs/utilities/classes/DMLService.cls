/**
 * Created by Leonid Bartenev
 */

public without sharing class DMLService {
    
    public class Lookup{
        public String lookupField;
        public SObject relatedObject;
        public SObject masterObject;
        
        public Lookup(String lookupField, SObject relatedObject, SObject masterObject){
            this.lookupField = lookupField;
            this.relatedObject = relatedObject;
            this.masterObject = masterObject;
        }
        
        public void updateLookupField(){
            relatedObject.put(lookupField, masterObject.Id);
        }
    }
    
    private static Map<String, List<SObject>> insertMap = new Map<String, List<SObject>>();
    private static Map<String, List<SObject>> updateMap = new Map<String, List<SObject>>();
    private static Map<String, List<SObject>> deleteMap = new Map<String, List<SObject>>();
    private static List<Lookup> lookups = new List<Lookup>();
    
    private static Boolean useDMLBuffer = false;
    
    public static void insertRecord(SObject record){
        insertRecords(new List<SObject>{record});
    }
    
    public static void insertRecords(List<SObject> records){
        if(useDMLBuffer){
            addRecordsToMap(records, insertMap);
        }else {
            updateLookups();
            insert records;
        }
    }
    
    public static void updateRecord(SObject record){
        updateRecords(new List<SObject>{record});
    }
    
    public static void updateRecords(List<SObject> records){
        if(useDMLBuffer){
            addRecordsToMap(records, updateMap);
        }else {
            updateLookups();
            update records;
        }
    }
    
    public static void deleteRecord(SObject record){
        deleteRecords(new List<SObject>{record});
    }
    
    public static void deleteRecords(List<SObject> records){
        if(useDMLBuffer){
            addRecordsToMap(records, deleteMap);
        }else {
            delete records;
        }
    }
    
    public static void useDMLBuffer(Boolean useBuffer){
        useDMLBuffer = useBuffer;
    }
    
    public static void pushDMLBuffer(){
        for(Lookup lookup : lookups){
            String masterSObjectType = lookup.masterObject.getSObjectType() + '';
            List<SObject> masterRecords = insertMap.get(masterSObjectType);
            if(masterRecords != null) {
                insert masterRecords;
                insertMap.remove(masterSObjectType);
            }
            masterRecords = updateMap.get(masterSObjectType);
            if(masterRecords != null) {
                update masterRecords;
                updateMap.remove(masterSObjectType);
            }
            lookup.updateLookupField();
        }
        lookups = new List<DMLService.Lookup>();
        
        for(String sObjectType : insertMap.keySet()){
            List<SObject> records = insertMap.get(sObjectType);
            if(records.size() > 0) insert records;
        }
        insertMap = new Map<String, List<SObject>>();
        
        for(String sObjectType : updateMap.keySet()){
            List<SObject> records = updateMap.get(sObjectType);
            if(records.size() > 0) update records;
        }
        updateMap = new Map<String, List<SObject>>();
        
        for(String sObjectType : deleteMap.keySet()){
            List<SObject> records = deleteMap.get(sObjectType);
            if(records.size() > 0) delete records;
        }
        deleteMap = new Map<String, List<SObject>>();
    }

    public static void resetLookup() {
        lookups = new List<Lookup>();
    }
    
    public static void setLookup(SObject relatedObject, String lookupField, SObject masterObject){
        lookups.add(new Lookup(lookupField, relatedObject, masterObject));
    }
    
    private static void addRecordToMap(SObject record, Map<String, List<SObject>> targetMap){
        String sObjectType = record.getSObjectType() + '';
        List<SObject> recordsList = targetMap.get(sObjectType);
        if(recordsList == null) recordsList = new List<SObject>();
        recordsList.add(record);
        targetMap.put(sObjectType, recordsList);
    }
    
    private static void addRecordsToMap(List<SObject> records, Map<String, List<SObject>> targetMap){
        for(SObject record : records){
            addRecordToMap(record, targetMap);
        }
    }
    
    private static void updateLookups(){
        for(Lookup lookup : lookups) lookup.updateLookupField();
    }

}