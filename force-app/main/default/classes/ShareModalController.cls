/**
 * Created by D.Yasinskyi on 08.06.2018
 */
public without sharing class ShareModalController {

    @AuraEnabled
    public static void sendEmail(String whatId, String fromId, String email, String emailType) {
        try {
            if (fromId == null) fromId = CommunityService.getUserContact().Id;
            if (emailType == 'SOCIAL_SHARING') {
                SendEmailTemplate.sendShareEmail(whatId, fromId, email, 'Share_Social_Study_Template');
            } else {
                Id sourceId = whatId;
                if(sourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()){
                    SendEmailTemplate.sendShareEmail(whatId, fromId, email, 'Share_Study_From_PE_Template');
                }else if(sourceId.getSobjectType() == HCP_Enrollment__c.getSObjectType()){
                    SendEmailTemplate.sendShareEmail(whatId, fromId, email, 'Share_Study_From_HCPE_Template');
                }else{
                    SendEmailTemplate.sendShareEmail(whatId, fromId, email, null);
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}