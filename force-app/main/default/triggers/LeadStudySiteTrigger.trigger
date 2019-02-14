trigger LeadStudySiteTrigger on Lead (before insert, before update) {
    Set<String> missingProtocolNumber = new Set<String>();
    Set<String> missingStudyNumber = new Set<String>();

    for (Lead l : Trigger.new) {
        if (l.Study_Site__c == null && l.Protocol_Number__c != null && l.Study_Site_Number__c != null) {
            missingProtocolNumber.add(l.Protocol_Number__c);
            missingStudyNumber.add(l.Study_Site_Number__c);
        }
    }
    Map<String, Map<String, Id>> studyByProtocolAndNumber = new Map<String, Map<String, Id>>();
    for (Study_Site__c site : [SELECT Id, Protocol_ID__c,Study_Site_Number__c FROM Study_Site__c WHERE (Protocol_ID__c IN :missingProtocolNumber) AND (Study_Site_Number__c IN :missingStudyNumber)]) {
        if (studyByProtocolAndNumber.get(site.Protocol_ID__c) == null) {
            studyByProtocolAndNumber.put(site.Protocol_ID__c, new Map<String, Id>());
        }
        studyByProtocolAndNumber.get(site.Protocol_ID__c).put(site.Study_Site_Number__c, site.Id);
    }
    for (Lead l : Trigger.new) {
        if (l.Study_Site__c == null
                && l.Protocol_Number__c != null
                && l.Study_Site_Number__c != null
                && studyByProtocolAndNumber.containsKey(l.Protocol_Number__c)
                && studyByProtocolAndNumber.get(l.Protocol_Number__c).containsKey(l.Study_Site_Number__c)) {
            l.Study_Site__c = studyByProtocolAndNumber.get(l.Protocol_Number__c).get(l.Study_Site_Number__c);
        }
    }

}