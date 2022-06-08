public without sharing class TelevisitMeetBannerController {
    @AuraEnabled
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }
    @AuraEnabled
    public static String getVisits() {
        Datetime currentDateTime = Datetime.now();
        Datetime next24HoursDateTime = Datetime.now().addHours(24);
        List<Televisit_Attendee__c > allVisitis = [select Televisit__r.Id,Televisit__r.Title__c,Televisit__r.Visit_Date_Time__c,
                    Televisit__r.Visit_Link_Activation_End_Time__c,Televisit__r.Visit_Link_Activation_Start_Time__c,Televisit__r.Meeting_URL__c,
                    Televisit__r.Participant_Enrollment__r.Participant_Name__c,Televisit__r.Duration__c,Televisit__r.Visit_End_Date_Time__c
                    from Televisit_Attendee__c where User__c  =:UserInfo.getUserId() and Televisit__r.Visit_Link_Activation_End_Time__c >=:currentDateTime 
                    and Televisit__r.Visit_Link_Activation_End_Time__c <=:next24HoursDateTime 
                    and Televisit__r.Status__c = 'Scheduled'];

        return JSON.serialize(allVisitis);
    }
    @AuraEnabled
    public static String getUserTimeZoneOffset() {
        TimeZone tzone = UserInfo.getTimeZone();
        //Milliseconds to Day
        //return String.valueOf(tzone.getOffset(DateTime.now()) / (1000 * 3600 * 24.0));
        return String.valueOf(tzone);
    }
}