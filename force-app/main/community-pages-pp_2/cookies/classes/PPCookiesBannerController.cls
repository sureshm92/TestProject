public without sharing class PPCookiesBannerController {
    public String userAccountSetting { get; set; }
    public List<AccountSettingsController.CookieSettings> cookieSettings { get; set; }
    public String cookieDescription { get; set; }
    public Contact currentContact { get; set; }
    public String userMode;
    public String userJsonString;

    public void fetchTheCookieData() {
        try {
            cookieSettings = AccountSettingsController.getCookieSettings();
            currentContact = AccountSettingsController.getCurrentContact();
            if (currentContact.Is_First_Logon__c) {
                currentContact.RRCookiesAllowedCookie__c = false;
                currentContact.RRLanguageAllowedCookie__c = false;
            }
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
        }
    }
    public void updateCookiePreferences() {
        update currentContact;
    }
}
