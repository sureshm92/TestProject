/**
 * Created by RAMukhamadeev on 2019-04-26.
 */

global without sharing class EmailActionBtnController {
    
    global String buttonURLString {get; set;}
    global String caseIdString {get; set;}

    public String getResultURL(){
        String result = buttonURLString;
        if (String.isBlank(caseIdString)) {
            if(result == null) result = '';

            if(!result.containsIgnoreCase('http')){
                if(!String.isBlank(result) && !result.startsWith('/')) result = '/' + result;
                result = getCurrentCommunityURL() + result;
            }
        } else {
            result = Url.getOrgDomainUrl().toExternalForm() + '/' + caseIdString;
        }

        return result;
    }

    private String getCurrentCommunityURL() {
        List<Network> currCommunities = [SELECT Id FROM Network WHERE Name = 'IQVIA Referral Hub'];
        String urlStr;
        if (currCommunities.size() > 0) {
            urlStr = Network.getLoginUrl(currCommunities[0].Id);
            List<String> urlParts = urlStr.split('//');
            String startUrl = urlParts[0];
            urlParts = urlParts[1].split('/');
            urlStr = startUrl + '//' +urlParts[0];
        }
        return urlStr;
    }
}