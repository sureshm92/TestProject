/**
 * Created by Igor Malyuta on 23.03.2020.
 */

public without sharing class EmailTemplateInitialFactory {

    public static EmailTemplateInitial getTemplateInitial(Id userId, String outputMode, String communityTemplateName) {
        User user = [
                SELECT ContactId,
                        Contact.UserCommunityIsDelegate__c,
                        Contact.userCommunityMode__c
                FROM User
                WHERE Id = :userId
        ];
        String userMode = user.Contact.userCommunityMode__c;
        Boolean isDelegate = user.Contact.UserCommunityIsDelegate__c;

        EmailTemplateInitial emailTemplateInitial;
        switch on userMode {
            when 'PI' {
                if (isDelegate) {
                    emailTemplateInitial = new EmailTemplateInitialPIDel(user.ContactId, outputMode);
                } else {
                    emailTemplateInitial = new EmailTemplateInitialPI(user.ContactId, outputMode);
                }
            }
            when 'HCP' {
                if (isDelegate) {
                    emailTemplateInitial = new EmailTemplateInitialHCPDel(user.ContactId, outputMode);
                } else {
                    emailTemplateInitial = new EmailTemplateInitialHCP(user.ContactId, outputMode);
                }
            }
            //added by Akanksha
            when 'CC' {
                
                    emailTemplateInitial = new EmailTemplateInitialCC(user.ContactId, outputMode);
                
            }
            
            when else {
                if (isDelegate) {
                    emailTemplateInitial = new EmailTemplateInitialPTDel(user.ContactId, outputMode, communityTemplateName);
                } else {
                    emailTemplateInitial = new EmailTemplateInitialPT(user.ContactId, outputMode, communityTemplateName);
                }
            }
        }

        return emailTemplateInitial;
    }

 

}