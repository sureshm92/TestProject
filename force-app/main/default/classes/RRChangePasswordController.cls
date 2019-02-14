/**
 * Created by Leonid Bartenev
 */

public without sharing class RRChangePasswordController {
    public String photolink{get;set;}
    
    //The binary data of the image uploaded by the user
    public transient Blob blobValue {get; set;}

    //The content type, determined by Salesforce, of the image uploaded by the user
    public transient String contentType {get; set;}
    
    // The name of the image file uploaded by the user
    public transient String filename {get; set;}
 
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}

    public Boolean isPaswordsEquals {get; set;}
    public Account account {get; set;}
    public Contact contact {get; set;}
    public User userVal {get; set;}

    public String userLocale {get; set;}
    public transient String userLanguage {get; set;}

    public Boolean isProfileView {get; set;}
    public String tcText {get; set;}
    public String tcId {get; set;}
    public Boolean isParticipant {get; set;}
    public Participant__c participant {get; set;}

    public Translation__c translation {get; set;}
    public String browserLanguage {get; set;}
    
    public RRChangePasswordController() {
        translation = new Translation__c();
        init();
        if(!contact.Is_First_Logon__c) translation.Language__c = userVal.LanguageLocaleKey;
    }

    private void init(){
        Id userId = UserInfo.getUserId();
        userVal = [
                SELECT Id, Name, Username, FirstName, LastName, FullPhotoUrl,
                        Contact.FirstName,
                        Contact.LastName,
                        Contact.MailingAddress,
                        Contact.Is_First_Logon__c,
                        LanguageLocaleKey,
                        LocaleSidKey
                FROM User WHERE Id =: userId
        ];
        contact = userVal.Contact;
        
        Contact cont = [
                SELECT Id, Account.Name, Account.Phone, Account.BillingStreet,
                        Account.BillingCity, Account.BillingState, Account.Fax,
                        Account.BillingCountry, Account.BillingPostalCode,
                        Account.BillingCountryCode
                FROM Contact WHERE Id =: contact.Id
        ];
        account = cont.Account;
        account.BillingCountry = TranslateHelper.getPickListLabel(User.CountryCode, account.BillingCountryCode);
        photolink = userVal.FullPhotoUrl;
        isProfileView = true;
        isPaswordsEquals = true;

        tcText = '';
        Terms_And_Conditions__c portalTC = TermsAndConditions.getPortalTC();
        if(portalTC != null){
            tcText = portalTC.T_C_Text__c;
            tcId = portalTC.Id;
        }
        
        isParticipant = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant().size() > 0;
        if(isParticipant) {
            participant = [
                    SELECT Id, Name, First_Name__c, Last_Name__c, Phone__c,
                            Mailing_Country__c, Mailing_State__c, Mailing_Zip_Postal_Code__c,
                            Mailing_Country_Code__c, Mailing_State_Code__c

                    FROM Participant__c
                    WHERE Contact__c = :contact.Id
            ];
            updateTranslations();
        }
    }

    public PageReference changePassword() {
        try{
            PageReference pr = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
            contact.Is_First_Logon__c = false;
            update contact;
            if(translation.Language__c != null) {
                userVal.LanguageLocaleKey = translation.Language__c;
                update userVal;
            }

            if (tcId!=null) {           
                Terms_And_Conditions_Acceptance__c tca = new Terms_And_Conditions_Acceptance__c();
                tca.Accepted_Date__c = Datetime.now();
                tca.Terms_And_Conditions__c = tcId;
                tca.User__c = UserInfo.getUserId();
                insert tca;
            }

            return pr;
        }catch (Exception e){
            isProfileView = true;
            ApexPages.addMessages(e);
            return null;
        }
    }

    public void showProfileAction(){
        isProfileView = true;
    }

    public void checkPasswords(){
        Site.validatePassword(userVal, newPassword, verifyNewPassword);
        if(ApexPages.getMessages().size() == 0) isProfileView = false;
    }

    public void upload() {
        ConnectApi.BinaryInput photoFileInput = new ConnectApi.BinaryInput(blobValue, contentType, filename);
        ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), userVal.Id, photoFileInput);
        photolink = ConnectApi.UserProfiles.getPhoto(Network.getNetworkId(), userVal.Id).fullEmailPhotoUrl;
    }
    
    public void updatePhotoURL(){
    }

    public void updateTranslations(){
        if(isParticipant){
            //translate country:
            participant.Mailing_Country__c = CountryStateUtil.getCountryName(participant.Mailing_Country_Code__c);
            //translate state
            participant.Mailing_State__c = CountryStateUtil.getStateName(participant.Mailing_Country_Code__c, participant.Mailing_State_Code__c);
        }
    }

    public void updateBrowserLanguageAction(){
        translation.Language__c = TranslateHelper.convertBrowserLanguage((List<String>)JSON.deserialize(browserLanguage, List<String>.class));
        if(translation.Language__c == null) translation.Language__c = userVal.LanguageLocaleKey;
        updateLanguageAction();
    }
    
    public void updateLanguageAction(){
        update new User(
                Id = userVal.Id,
                LanguageLocaleKey = translation.Language__c
        );
        updateTranslations();
    }
    
    public void translateFieldsAction(){
        updateTranslations();
    }

}