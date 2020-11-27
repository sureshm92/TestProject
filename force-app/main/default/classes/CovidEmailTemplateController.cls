public without sharing class CovidEmailTemplateController {
    public static final String nybcLogoDocument = 'Nybc_logo';
    public static final String covid19CommunityName = 'Covid-19';
    public String fileName { get; set; }
    public String emailRecipientId { get; set; }
    public String emailRelatedtoId { get; set; }
    public String CommunityURL { get; set; }
    public String userMode;
    public String userLanguageCode;
    public String delegateMailCheck { get; set; }
    public Map<String, String> contactDetails = new Map<String, String>();
    public Map<String, String> getContactDetails() {
        try {
            if (contactDetails.isEmpty()) {
                Integration_Patient_Referral__c IPR = [
                    SELECT
                        Participant_Enrollment__r.Participant_Contact__r.Language__c,
                        Participant_Enrollment__r.Participant_Contact__r.userCommunityMode__c,
                        Participant_Enrollment__r.Participant_Contact__c,
                        Participant_Enrollment__r.Participant__c
                    FROM Integration_Patient_Referral__c
                    WHERE id = :emailRelatedtoId
                    LIMIT 1
                ];
                List<Patient_Delegate__c> PD = [
                    SELECT Contact__c
                    FROM Patient_Delegate__c
                    WHERE Participant__c = :IPR.Participant_Enrollment__r.Participant__c
                    LIMIT 1
                ];
                contactDetails.put(
                    'ContactId',
                    IPR.Participant_Enrollment__r.Participant_Contact__c
                );
                contactDetails.put(
                    'UserMode',
                    IPR.Participant_Enrollment__r.Participant_Contact__r.userCommunityMode__c
                );
                contactDetails.put(
                    'Language',
                    IPR.Participant_Enrollment__r.Participant_Contact__r.Language__c
                );
                if (!PD.isEmpty()) {
                    contactDetails.put('DelegateContact', PD.get(0).Contact__c);
                }
            }
        } catch (Exception e) {
            EmailService.sendException(e, null);
        }
        return contactDetails;
    }

    public String getUserLanguageCode() {
        //+
        try {
            if (userLanguageCode == null)
                userLanguageCode = getContactDetails().get('Language');
            return userLanguageCode;
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return null;
        }
    }

    public Id recipientcntId {
        get {
            try {
                if (delegateMailCheck == 'Yes')
                    recipientcntId = getContactDetails().get('DelegateContact');
                else if (recipientcntId == null)
                    recipientcntId = getContactDetails().get('ContactId');
                return recipientcntId;
            } catch (Exception e) {
                System.debug('exception e--' + e);
                EmailService.sendException(e, null);
                return null;
            }
        }
        set;
    }

    public String getuserMode() {
        //+
        try {
            if (userMode == null)
                userMode = getContactDetails().get('UserMode');
            return userMode;
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return null;
        }
    }

    public String getImageUrl() {
        List<Document> doc = [
            SELECT Id, LastModifiedDate
            FROM Document
            WHERE DeveloperName = :nybcLogoDocument
            LIMIT 1
        ];
        if (doc == null || doc.isEmpty()) {
            return null;
        } else {
            return Url.getSalesforceBaseUrl().toExternalForm() +
                '/servlet/servlet.ImageServer?id=' +
                doc[0].Id +
                '&oid=' +
                UserInfo.getOrganizationId();
        }
    }
    public String getEmailCommunityURL() {
        return CommunityTemplateService.getCommunityURL(covid19CommunityName);
    }
}
