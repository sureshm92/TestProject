/**
 * Created by Nargiz Mamedova on 1/15/2020.
 */

public with sharing class SSMessageConfigResponse {
    @AuraEnabled public PaginationData pagination;
    @AuraEnabled public List<StudySiteItem> studySiteItems;
    @AuraEnabled public List<LabelValueItem> messageTypes;

    public static String TYPE_SMS = 'SMS';
    public static String TYPE_MESSAGE = 'Messages';

    public SSMessageConfigResponse(StudySiteFilter filter, PaginationData pagination) {
        this.pagination = pagination;
        List<Study_Site__c> ssList = SearchService.search(filter, this.pagination);
        messageTypes = getMessageTypes(null);
        studySiteItems = convertToSSItems(ssList, null);
    }

    private static List<LabelValueItem> getMessageTypes(String messageType) {
        List<LabelValueItem> messageTypes = new List<LabelValueItem>();
        if (messageType == null || messageType.contains(TYPE_SMS)) messageTypes.add(new LabelValueItem(TYPE_SMS, TYPE_SMS));
        if (messageType == null || messageType.contains(TYPE_MESSAGE)) messageTypes.add(new LabelValueItem(TYPE_MESSAGE, TYPE_MESSAGE));
        return messageTypes;
    }

    public static List<StudySiteItem> convertToSSItems(List<Study_Site__c> studySites, String messageType) {
        List<LabelValueItem> messageTypes = getMessageTypes(messageType);
        Map<Id, Map<String, Boolean>> ssMessageConfigurationBySSIdMap = getMessageConfigurationBySSIdMap(studySites);
        Set<Id> ssIdsWithConversations = getConversationsAvailability(studySites);
        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item = new StudySiteItem(new LabelValueItem(countryName, countryCode), ss.Name, ss);
            item.emptyAssignments = true;
            for (LabelValueItem mt : messageTypes) {
                Boolean value = ssMessageConfigurationBySSIdMap.get(ss.Id).get(mt.value);
                item.assignments.add(new ValueStateItem(mt.value, value));
                if (value) {
                    item.emptyAssignments = false;
                } else if (mt.value.equals(TYPE_MESSAGE) && ssIdsWithConversations.contains(ss.Id)) {
                    item.conversationsFound = true;
                }
            }
            studySiteItems.add(item);
        }
        return studySiteItems;
    }

    private static Map<Id, Map<String, Boolean>> getMessageConfigurationBySSIdMap(List<Study_Site__c> ssList) {
        List<Study_Site__c> studySites = [
                SELECT Id, SMS_Are_Available__c, Messages_Are_Available__c
                FROM Study_Site__c
                WHERE Id IN:ssList
        ];
        Map<Id, Map<String, Boolean>> vpListBySSIdMap = new Map<Id, Map<String, Boolean>>();
        for (Study_Site__c ss : studySites) {
            if (!vpListBySSIdMap.containsKey(ss.Id)) {
                vpListBySSIdMap.put(ss.Id, new Map<String, Boolean>());
            }
            vpListBySSIdMap.get(ss.Id).put(TYPE_SMS, ss.SMS_Are_Available__c);
            vpListBySSIdMap.get(ss.Id).put(TYPE_MESSAGE, ss.Messages_Are_Available__c);
        }
        return vpListBySSIdMap;
    }

    public static Set<Id> getConversationsAvailability(List<Study_Site__c> studySites){
        List<Conversation__c> conversations = [
                SELECT Id, Participant_Enrollment__r.Study_Site__c
                FROM Conversation__c
                WHERE Participant_Enrollment__r.Study_Site__c IN: studySites
        ];

        Set<Id> ssIdsWithConversations = new Set<Id>();
        for(Conversation__c c : conversations) ssIdsWithConversations.add(c.Participant_Enrollment__r.Study_Site__c);

        return ssIdsWithConversations;
    }
}