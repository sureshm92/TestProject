/**
 * Created by D.Yasinskyi on 08.06.2018
 */
public without sharing class ShareModalController {

    @AuraEnabled
    public static void sendEmail(String whatId, String fromId, String email) {
        try{
            if(fromId == null)fromId = CommunityService.getUserContact().Id;
            SendEmailTemplate.sendShareEmail(whatId, fromId, email);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}