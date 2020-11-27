/**
 * Created by Sravani Dasari on 4-Nov-20.
 */

public without sharing class Batch_SiteStaff_Invited_Update implements Database.Batchable<SObject> {
    private String query;

    public Batch_SiteStaff_Invited_Update() {
        this.query = 'select id,is_Invited__c,Site_Contact__c from Site_Staff__c';
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        List<Site_Staff__c> SS = new List<Site_Staff__c>();
        List<Site_Staff__c> updSSlst = new List<Site_Staff__c>();
        List<Id> conId = new List<Id>();
        List<Id> userConid = new List<Id>();
        List<user> userlst = new List<user>();
        try {
            for (Site_Staff__c siteStaff : (List<Site_Staff__c>) records) {
                conId.add(siteStaff.Site_Contact__c);
                SS.add(siteStaff);
            }
            Userlst = [SELECT ContactId, Id, IsActive FROM User WHERE ContactId IN :conId];
            if (Userlst.size() > 0) {
                for (user u : Userlst) {
                    userConid.add(u.ContactId);
                }
                for (Site_Staff__c s : SS) {
                    if (userConid.contains(s.Site_Contact__c)) {
                        Site_Staff__c siteStaff = new Site_Staff__c();
                        siteStaff.id = s.id;
                        siteStaff.is_Invited__c = true;
                        updSSlst.add(siteStaff);
                    }
                }
            }
            if (updSSlst.size() > 0 && updSSlst != null) {
                update updSSlst;
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
