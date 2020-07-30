public without sharing class CovidEmailTemplateController 
{
    public static final String nybcLogoDocument = 'Nybc_logo';
    public String fileName { get; set; }
    public String emailRecipientId { get; set; }
    public String emailRelatedtoId { get; set; }
    public String CommunityURL{ get; set;}
    public String userMode;
    public String userLanguageCode;
    public Map<String,String> contactDetails = new Map<String,String>();
    public Map<String,String> getContactDetails() {
        try{
            if(contactDetails.isEmpty())
            {
            Integration_Patient_Referral__c IPR = [Select Participant_Enrollment__r.Participant_Contact__r.Language__c,Participant_Enrollment__r.Participant_Contact__r.userCommunityMode__c,Participant_Enrollment__r.Participant_Contact__c from Integration_Patient_Referral__c where id=:emailRelatedtoId limit 1];
            contactDetails.put('ContactId',IPR.Participant_Enrollment__r.Participant_Contact__c );
            contactDetails.put('UserMode',IPR.Participant_Enrollment__r.Participant_Contact__r.userCommunityMode__c);
            contactDetails.put('Language',IPR.Participant_Enrollment__r.Participant_Contact__r.Language__c);
            }     
        }
        catch(exception e)
        {
            EmailService.sendException(e, null);
        }
        return contactDetails;
    }
    
    public String getUserLanguageCode() {//+
        try {
            if (userLanguageCode == null) userLanguageCode = getContactDetails().get('Language');
            return userLanguageCode;
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return null;
        }
    }
    
     public Id recipientcntId {
       get{
        try {
            if (recipientcntId == null) recipientcntId = getContactDetails().get('ContactId');
            return recipientcntId;
            }
         catch (Exception e) {
            System.debug('exception e--'+e);
            EmailService.sendException(e, null);
            return null;
            }
        }
         set;
    }
     public String getuserMode() {//+
        try {
            if (userMode == null) userMode = getContactDetails().get('UserMode');
            return userMode;
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return null;
        }
    }

    public String getImageUrl() 
    {
        List<Document> doc = [SELECT Id, LastModifiedDate FROM Document WHERE DeveloperName = :nybcLogoDocument Limit 1];
        if(doc == null || doc.isEmpty())
        {
            return null;
        }
        else
        {
            return Url.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+doc[0].Id+
                '&oid='+UserInfo.getOrganizationId();
        }  
    }
}