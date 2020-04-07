/**
 * Created by Igor Malyuta on 23.03.2020.
 */

public without sharing class EmailTemplateInitialFactory {

    public static EmailTemplateInitial getTemplateInitial(Map<String, String> templateLabels, Id whatId, Id recipientId,
            String recipientName, String recipientLanguage, String outputMode, String communityTemplateName
    ) {
        EmailTemplateInitial emailTemplateInitial;

        if (recipientId.getSobjectType() == User.getSObjectType() && recipientId == whatId) {
            Contact recipientContact;
            if (recipientId.getSobjectType() == User.getSObjectType()) {
                User user = [
                        SELECT ContactId,
                                Contact.UserCommunityIsDelegate__c,
                                Contact.userCommunityMode__c
                        FROM User WHERE Id = :recipientId
                ];
                recipientContact = user.Contact;
            } else {
                recipientContact = [
                        SELECT Id, UserCommunityIsDelegate__c, userCommunityMode__c
                        FROM Contact WHERE Id = :recipientId
                ];
            }
            String userMode = recipientContact.userCommunityMode__c;
            Boolean isDelegate = recipientContact.UserCommunityIsDelegate__c;
//            switch on userMode {
//                when 'PI' {
//                    emailTemplateInitial = isDelegate ?
//                            new EmailTemplateInitialPIDel(templateLabels, recipientContact.Id, outputMode)
//                            : new EmailTemplateInitialPI(templateLabels, recipientContact.Id, outputMode);
//                }
//                when 'HCP' {
//                    emailTemplateInitial = isDelegate ?
//                            new EmailTemplateInitialHCPDel(templateLabels, recipientContact.Id, outputMode)
//                            : new EmailTemplateInitialHCP(templateLabels, recipientContact.Id, outputMode);
//                }
//                when else {
//                    emailTemplateInitial = isDelegate ?
//                            new EmailTemplateInitialPTDel(templateLabels, recipientContact.Id, outputMode, communityTemplateName)
//                            : new EmailTemplateInitialPT(templateLabels, recipientContact.Id, outputMode, communityTemplateName);
//                }
//            }
        } else {
            emailTemplateInitial = new EmailTemplateInitialDefault(
                    templateLabels, whatId, recipientId, recipientName, recipientLanguage, outputMode, communityTemplateName
            );
        }
        return emailTemplateInitial;
    }
}