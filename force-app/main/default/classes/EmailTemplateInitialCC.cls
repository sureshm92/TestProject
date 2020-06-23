/**
 * Created by Akanksha
 */
public without sharing class EmailTemplateInitialCC extends EmailTemplateInitial {

    public EmailTemplateInitialCC(Id recipientContactId, String outputMode) {
        super(recipientContactId, outputMode, null);
        userMode = 'CC';
    }
}