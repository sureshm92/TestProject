/**
 * Created by Igor Malyuta on 23.03.2020.
 */

public without sharing class EmailTemplateInitialFactory {

    public static EmailTemplateInitial getTemplateInitial(Id whatId, Id recipientId,
            String recipientName, String recipientLanguage, String outputMode, String communityTemplateName
    ) {
        EmailTemplateInitial emailTemplateInitial;

        if (recipientId.getSobjectType() == User.getSObjectType() && recipientId == whatId) {
            User user = [
                    SELECT ContactId,
                            Contact.UserCommunityIsDelegate__c,
                            Contact.userCommunityMode__c
                    FROM User
                    WHERE Id = :recipientId
            ];
            String userMode = user.Contact.userCommunityMode__c;
            Boolean isDelegate = user.Contact.UserCommunityIsDelegate__c;

            switch on userMode {
                when 'PI' {
                    if(isDelegate) {
                        emailTemplateInitial = new EmailTemplateInitialPIDel(user.ContactId, outputMode);
                    } else {
                        emailTemplateInitial = new EmailTemplateInitialPI(user.ContactId, outputMode);
                    }
                }
                when 'HCP' {
                    if(isDelegate) {
                        emailTemplateInitial = new EmailTemplateInitialHCPDel(user.ContactId, outputMode);
                    } else {
                        emailTemplateInitial = new EmailTemplateInitialHCP(user.ContactId, outputMode);
                    }
                }
                when else {
                    if(isDelegate) {
                        emailTemplateInitial = new EmailTemplateInitialPTDel(user.ContactId, outputMode, communityTemplateName);
                    } else {
                        emailTemplateInitial = new EmailTemplateInitialPT(user.ContactId, outputMode, communityTemplateName);
                    }
                }
            }
        } else {
            emailTemplateInitial = new EmailTemplateInitialDefault(
                    whatId, recipientId, recipientName, recipientLanguage, outputMode, communityTemplateName
            );
        }
        return emailTemplateInitial;
    }
}