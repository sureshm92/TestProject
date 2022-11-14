global class Batch_CSVImportBatchJob implements Database.Batchable<SObject> {
      global Database.QueryLocator start(Database.BatchableContext context) {
          if(test.isRunningTest() == true){
              return Database.getQueryLocator('SELECT Id, Name, Body FROM Document WHERE Name = \'DemoCSV4\'');
          }else{
              return Database.getQueryLocator('SELECT Id, Name, Body FROM Document WHERE Name = \'Uploadinguser\'');
          }
        
    }
    
    global void execute(Database.BatchableContext context, List<SObject> records) {
        // Cast the first record as a Document object
        String[] filelines = new String[]{};
            String[] inputvalues = new String[]{};
            //set<Id>staffcontactId = new set<Id>();
        set<Id>ssId = new set<Id>();
        List<importData>importLST = new List<importData>();
        Document theDocument = (Document)records.get(0);
        String stringBody = theDocument.body.tostring();
        filelines =  stringBody.split('\n');
        for(Integer i=1;i<filelines.size();i++){
                inputvalues = filelines[i].split(',');
            importData impt = new importData();
            impt.allContactIdS = inputvalues[0];
            //impt.allstudySiteIds = inputvalues[1];
            importLST.add(impt);
        }
        import(importLST);
    } 
    
    global void finish(Database.BatchableContext context) {
        
    }
    public static void import(List<importData>importLST){
        List<importData>gettingImportLST = importLST;
        set<Id>staffcontactId = new set<Id>();
         for(importData im: gettingImportLST){
            staffcontactId.add(im.allContactIdS);
        }
        set<Id>StudSiteIds = new set<Id>();
        List<Site_Staff__c> PiAsDelsitestaff = [
            SELECT
            id,
            Delegate_Level__c,
            Study_Site__r.Clinical_Trial_Profile__c,
            Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
            Study_Site__c,
            Site_Contact__c,
            is_Invited__c
            FROM Site_Staff__c
            WHERE
            Site_Contact__c = :staffcontactId
            AND is_Invited__c = TRUE
        ];
        TriggerHandlerExecutor.bypassHandler(
            UserTriggerHandler.AssignPendingTasksHandler.class
        );
         TriggerHandlerExecutor.bypassHandler(
            UserTriggerHandler.UpdateLanguageOnRelatedContactsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            UserTriggerHandler.UpdateEmailOnRelatedContactsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            UserTriggerHandler.CreateCompleteYourProfileTaskHandler.class
        );
        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        if(!staffcontactId.isEmpty()){
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
            .createPortalUsers(staffcontactId);
        }
        for(Id conTd: staffcontactId){
            for (Site_Staff__c ss : PiAsDelsitestaff) {
                //StudSiteIds.add(ss.Study_Site__c);
                 String IQVIAREFERRALHUB = 'Default';
                 String GSKPANONCOLOGY = 'GSK';
                 String JANSSEN = 'Janssen';
                if(conTd == ss.Site_Contact__c){     
                    if(ss.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c == GSKPANONCOLOGY){
                        actionAssignContactPermissions.addPermission(conTd,CommunityTemplateService.getTemplate(IQVIAREFERRALHUB).permissionSet);
                    }else{
                        actionAssignContactPermissions.addPermission(conTd,CommunityTemplateService.getTemplate(ss.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet);
                        
                    }
                }
            }
        }         
        TriggerHandlerExecutor.bypassHandler(
            UserTriggerHandler.AssignCommunityPermissionSetToUserHandler.class
        );
    }
      public class importData{
        public Id allContactIdS;
        //public Id allstudySiteIds;  
        public importData(){
            
        }
    }

}