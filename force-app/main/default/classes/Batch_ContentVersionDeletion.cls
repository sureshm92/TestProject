/**
 * This batch for deleting PI bulk import error files which are more than 6 months old.
*/

global class Batch_ContentVersionDeletion implements Database.Batchable<sObject>{

    set<ID> bulkImportIds = new set<ID>();
    set<ID> contentDocumentLinkId = new set<ID>();
   
    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        String query = 'SELECT Id, File_Name__c, CreatedDate, Download_URL__c FROM Bulk_Import_History__c WHERE CreatedDate > LAST_N_MONTHS:6 AND Download_URL__c != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Bulk_Import_History__c> bulkImportsList) {
        try {
            if(bulkImportsList.size()>0){
                for(Bulk_Import_History__c bulkImp : bulkImportsList){
                    bulkImp.Download_URL__c = null;
                    bulkImportIds.add(bulkImp.Id);
                }
    
                List<ContentDocumentLink> contentDocLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM
                                                                ContentDocumentLink WHERE LinkedEntityId IN :bulkImportIds];
                for(ContentDocumentLink conDocLink :contentDocLinks){
                        contentDocumentLinkId.add(conDocLink.ContentDocumentId);
                    }
                List<ContentDocument> conDocToDelete = [SELECT Id from ContentDocument WHERE Id IN :contentDocumentLinkId];
                delete conDocToDelete;
                update bulkImportsList;
            }
           
        } catch (Exception  e) {
           System.debug('e.getMessage(): ' + e.getMessage());
           System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
        }
      
    }

    global void finish(Database.BatchableContext BC) {
       System.debug('In Finish Method');
    }
}