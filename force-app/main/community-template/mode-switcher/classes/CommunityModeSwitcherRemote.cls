/**
 * Created by Nargiz Mamedova on 6/11/2020.
 */

public without sharing class CommunityModeSwitcherRemote {
    public class CommunityModesWrapper {
        public User user;
        public Boolean hasProfilePic;
        public CommunityMode currentMode;
        public CommunityModes communityModes;
    }

    @AuraEnabled
    public static String getSwitcherInitData() {
        CommunityModesWrapper result = new CommunityModesWrapper();
        result.communityModes = new CommunityModes();
        List<User> currentUser = [
            SELECT Id, Contact.FirstName, Contact.LastName, SmallPhotoUrl, Username
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        ContactService.applyRelevantNames(currentUser);
        result.user = currentUser[0];
        result.hasProfilePic = !currentUser[0].SmallPhotoUrl.contains('profilephoto/005/T');
        Contact userContact = UserContext.getUserContact();
        result.communityModes.rhModeItems = CommunityModeService.getReferralModeItems(
            userContact.Id
        );
        result.communityModes.ppModeItems = CommunityModeService.getParticipantModeItems(
            userContact.Id
        );
        result.communityModes.type = CommunityModeService.getSwitcherType(
            result.communityModes.rhModeItems,
            result.communityModes.ppModeItems
        );
        CommunityModeService.getCurrentItemMode(userContact, result.communityModes);
        return JSON.serialize(result);
    }

    @AuraEnabled
    public static String getLogoutURL() {
        Contact userContact = UserContext.getUserContact();
        userContact.Current_Participant_Enrollment__c = null;
        update userContact;
        List<LoginHistory> userLoginHistory = [
            SELECT Id, UserId, LoginTime, LoginUrl
            FROM LoginHistory
            WHERE UserId = :UserInfo.getUserId()
            ORDER BY LoginTime DESC
            LIMIT 1
        ];
        return userLoginHistory.isEmpty()
            ? Site.getBaseUrl()
            : 'https://' +
              userLoginHistory.get(0)
                  .LoginUrl.substringAfter('https://')
                  .substringBefore('/s')
                  .trim();
    }

    @AuraEnabled
    public static CommunityFacadeRemote.CommunityUserVisibility getCommunityUserVisibility() {
        return CommunityFacadeRemote.getCommunityUserVisibility();
    }

    @AuraEnabled
    public static String changeMode(
        String mode,
        Id delegateId,
        Id peId,
        String communityModes,
        String communityName
    ) {
        CommunityModesWrapper result = new CommunityModesWrapper();
        Contact resContact = CommunityFacadeRemote.changeMode(
            mode,
            delegateId,
            peId,
            communityName
        );
        List<CommunityMode> allModes = CommunityModeService.getUserCommunityModes(resContact.Id);
        result.currentMode = CommunityModeService.findMode(
            CommunityModeService.generateModeKey(resContact),
            allModes
        );
        result.communityModes = (CommunityModes) JSON.deserialize(
            communityModes,
            CommunityModes.class
        );
        CommunityModeService.getCurrentItemMode(resContact, result.communityModes);
        return JSON.serialize(result);
    }
}
