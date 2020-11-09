/**
 * Created by Sravani Dasari on 4-Nov-20.
 */

public without sharing  class Batch_SiteStaff_Invited_Update implements Database.Batchable<SObject> {
    private String query;

    public Batch_SiteStaff_Invited_Update(){
        this.query = 'select id,is_Invited__c from Site_Staff__c';
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        for(Site_Staff__c siteStaff : (List<Site_Staff__c>)records){
            siteStaff.is_Invited__c = true;
        }
         try {
              update records;
        } catch(Exception e) {
            System.debug(e);
        }
      
    }

    public void finish(Database.BatchableContext bc) {}
}