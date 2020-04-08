/**
 * Created by Nargiz Mamedova on 4/7/2020.
 */

public with sharing class Batch_UpdateIconDetailsOnVisitPlans implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([SELECT Id, Name, (SELECT Name FROM Icons_Details__r) FROM Visit_Plan__c]);
    }

    public void execute(Database.BatchableContext param1, List<Visit_Plan__c> visitPlans) {
        PageReference pr = new PageReference('/resource/Icons_legend/icons.svg');
        String xml = pr.getContent().toString();
        Dom.Document document = new Dom.Document();
        document.load(xml);

        List<String> iconIds = new List<String>();
        for(Dom.XmlNode symbolElement: document.getRootElement().getChildElements()) {
            if(symbolElement.getName() == 'symbol') {
                iconIds.add(symbolElement.getAttribute('id', null));
            }
        }

        List<Icon_Details__c> newIcons = new List<Icon_Details__c>();
        for(Visit_Plan__c visitPlan : visitPlans) {
            if(visitPlan.Icons_Details__r.size() < iconIds.size()) {
                List<String> iconDetailsListForVP = new List<String>();
                for(Icon_Details__c iconDetail : visitPlan.Icons_Details__r){
                    iconDetailsListForVP.add(iconDetail.Name);
                }

                for(String iconD : iconIds) {
                    if(!iconDetailsListForVP.contains(iconD)) {
                        newIcons.add(new Icon_Details__c(Visit_Plan__c = visitPlan.Id, Name = iconD));
                    }
                }
            }
        }
        insert newIcons;
    }

    public void finish(Database.BatchableContext param1) {
    }
}