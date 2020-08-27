public without sharing class ServiceLookupController {
 
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value) {
        try {
          set<Id> existingSerResourceUserids = new set<Id>();
         for(ServiceResource sr: [SELECT RelatedRecordId FROM ServiceResource WHERE RelatedRecordId != NULL  LIMIT 10000])
             existingSerResourceUserids.add(sr.RelatedRecordId);
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' AND ContactId != null AND Id !=: existingSerResourceUserids  LIMIT 49999';
            } else {
                query += ' WHERE '+filterField+
                        ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND ContactId != null AND id!=: existingSerResourceUserids LIMIT 49999';
            }
            system.debug(query);
            for(SObject s : Database.query(query)) {
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
            }
            
         
      /*   List<RecordsData> recordsResult = new List<RecordsData>();
         for(RecordsData rd: recordsDataList) 
            if(!existingSerResourceUserids.contains(rd.value))
                recordsResult.add(rd);
            */
            
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
 
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled 
     public static string createServiceResource(String uId) {
         User u = [SELECT id,Name,contactId FROM User WHERE Id =: uId];
         ServiceResource sr = new ServiceResource(Name = u.Name, isActive= true, ResourceType = 'T' , RelatedRecordId = u.Id,contact__c = u.contactId);
         Insert sr;
         permissionsetAssignment(uId);
         return sr.id;
     }
     @future
     public static void permissionsetAssignment(String uId) {
         PermissionSet ps = [SELECT id FROM PermissionSet WHERE name = 'Lightning_Schedular'];
         PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = uId);
         insert psa;  
     
     
     
     }
}