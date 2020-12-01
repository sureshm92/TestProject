/*
 * created by Krishna Mahto
 */
public without sharing class FindCommunityName {
    @auraEnabled
    public static String getCommunityName() {
        String communityName = TranslateHelper.getLabelValue(
            UserContext.getTemplateProperty('CommunityBrandName')
        );
        communityName = communityName.replace('<i>', '');
        communityName = communityName.replace('</i>', '');
        return communityName;
    }
}
