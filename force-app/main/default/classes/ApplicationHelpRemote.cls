/**
 * Created by Kryvolap on 05.12.2018.
 */

public without sharing class ApplicationHelpRemote {
    
    public class InitData {
        String videoLink;
        String userManual;
        String quickReference;
    }
    
    @AuraEnabled
    public static String getInitData(String userMode) {
        try {
            InitData initData = new InitData();
            String userLanguage = UserInfo.getLanguage();
            List<Guides_Setting__mdt> guidesSettings = [
                    SELECT Language__c, HCP_Quick_Reference__c, HCP_User_Manual__c, HCP_Video_Guide__c,
                            PI_Quick_Reference__c, PI_User_Manual__c, PI_Video_Guide__c,
                            Participant_Quick_Reference__c, Participant_User_Manual__c, Participant_Video_Guide__c
                    FROM Guides_Setting__mdt
                    WHERE Language__c = :userLanguage OR Language__c = 'en_US'
            ];
            if (!guidesSettings.isEmpty()) {
                Guides_Setting__mdt setting = guidesSettings[0];
                for (Guides_Setting__mdt gs : guidesSettings) {
                    if (gs.Language__c == userLanguage) {
                        setting = gs;
                        break;
                    }
                }
                if (userMode == 'HCP') {
                    initData.videoLink = setting.HCP_Video_Guide__c;
                    initData.userManual = setting.HCP_User_Manual__c;
                    initData.quickReference = setting.HCP_Quick_Reference__c;
                } else if (userMode == 'PI') {
                    initData.videoLink = setting.PI_Video_Guide__c;
                    initData.userManual = setting.PI_User_Manual__c;
                    initData.quickReference = setting.PI_Quick_Reference__c;
                } else {
                    initData.videoLink = setting.Participant_Video_Guide__c;
                    initData.userManual = setting.Participant_User_Manual__c;
                    initData.quickReference = setting.Participant_Quick_Reference__c;
                }
                if (setting.Language__c != userLanguage) {
                    initData.videoLink = null;
                }
            }
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}