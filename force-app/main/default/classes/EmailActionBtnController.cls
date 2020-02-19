/**
 * Created by RAMukhamadeev on 2019-04-26.
 */

global without sharing class EmailActionBtnController {

    global String buttonURLString { get; set; }
    global String caseIdString { get; set; }
    global Id resourceIdString { get; set; }

    public String getResultURL() {
        String result = buttonURLString;
        if (String.isBlank(caseIdString)) {
            if (result == null) result = '';

            if (!result.containsIgnoreCase('http')) {
                if (!String.isBlank(result) && !result.startsWith('/')) result = '/' + result;
                result = getCurrentCommunityURL() + result;
            }
        } else {
            result = Url.getOrgDomainUrl().toExternalForm() + '/' + caseIdString;
        }

        return result;
    }

    private String getCurrentCommunityURL() {
        List<Network> currCommunities;
        if (resourceIdString != null && resourceIdString.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
            Participant_Enrollment__c pe = [
                    SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                    FROM Participant_Enrollment__c
                    WHERE Id = :resourceIdString
            ];
            if (pe.Clinical_Trial_Profile__r.CommunityTemplate__c == 'GSK') {
                currCommunities = [SELECT Id FROM Network WHERE Name = 'GSK Community'];
            } else {
                currCommunities = [SELECT Id FROM Network WHERE Name = 'IQVIA Referral Hub'];
            }
        } else if (resourceIdString != null && resourceIdString.getSobjectType() == Clinical_Trial_Profile__c.getSObjectType()) {
            Clinical_Trial_Profile__c ctp = [
                    SELECT Id, CommunityTemplate__c
                    FROM Clinical_Trial_Profile__c
                    WHERE Id = :resourceIdString
            ];
            if (ctp.CommunityTemplate__c == 'GSK') {
                currCommunities = [SELECT Id FROM Network WHERE Name = 'GSK Community'];
            } else {
                currCommunities = [SELECT Id FROM Network WHERE Name = 'IQVIA Referral Hub'];
            }
        } else {
            currCommunities = [SELECT Id FROM Network WHERE Name = 'IQVIA Referral Hub'];
        }
        String urlStr;
        if (currCommunities.size() > 0) {
            urlStr = Network.getLoginUrl(currCommunities[0].Id);
            List<String> urlParts = urlStr.split('//');
            String startUrl = urlParts[0];
            urlParts = urlParts[1].split('/');
            urlStr = startUrl + '//' + urlParts[0];
        }
        return urlStr;
    }
}