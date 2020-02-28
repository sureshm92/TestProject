/**
 * Created by Igor Malyuta on 23.11.2019.
 */

public without sharing class StudySiteItem {
    
    @AuraEnabled public LabelValueItem country;
    @AuraEnabled public String name;
    @AuraEnabled public Boolean emptyAssignments;
    @AuraEnabled public Boolean conversationsFound;
    @AuraEnabled public List<ValueStateItem> assignments;
    @AuraEnabled public Study_Site__c ss;

    public StudySiteItem() {
    }

    public StudySiteItem(LabelValueItem country, String ssName, Study_Site__c ss) {
        this.country = country;
        this.name = ssName;
        this.ss = ss;

        emptyAssignments = false;
        conversationsFound = false;
        assignments = new List<ValueStateItem>();
    }
}