/**
 * Created by RAMukhamadeev on 2019-04-26.
 */

global without sharing class EmailActionBtnController {
    private String commUrl;
    global String communityURL {
        get {
            if (commUrl == null) {
                commUrl = getCurrentCommunityURL();
            }
            return commUrl;
        }
        set;
    }

    private String getCurrentCommunityURL() {
        String redundantUrlEnd = '/s/login';
        List<Network> currCommunities = [SELECT Id FROM Network WHERE Name = 'IQVIA Referral Hub'];
        String currCommunityUrl;
        if (currCommunities.size() > 0) {
            currCommunityUrl = Network.getLoginUrl(currCommunities[0].Id);
            if (currCommunityUrl.endsWith(redundantUrlEnd)) {
                currCommunityUrl = currCommunityUrl.removeEnd(redundantUrlEnd);
            }
        }
        if (currCommunityUrl == null) {
            currCommunityUrl = Label.CommunityURL;
        }

        return currCommunityUrl;
    }
}