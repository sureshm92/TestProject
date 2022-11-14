@isTest
public class Test_RH_eConsentTrigger {
   @isTest
    public static void RH_eConsentTrigger_Test(){
       
        Date d = Date.today();
        Datetime dt = DateTime.newInstance(2004, 1, 27, 4, 1, 2);
        Time t = dt.time();
        test.startTest();
        RH_eConsent__e eConsentEvent = new RH_eConsent__e ();
        eConsentEvent.Subject_Id__c= 'REF2026455';
        eConsentEvent.Subject_Consent_Status__c= 'Needs to re-consent';
        eConsentEvent.Subject_Consent_Date__c= String.valueOf(d);
        EventBus.publish(eConsentEvent);
        test.stopTest();
    }
}