/**
 * Created by D.Yasinskyi on 08.06.2018
 */
public without sharing class ShareModalController {

    @AuraEnabled
    public static void sendEmail(String hcpeId, String hcpContactId, String email) {
        try{
            SendEmailTemplate.sendShareEmail(hcpeId, hcpContactId, email);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}