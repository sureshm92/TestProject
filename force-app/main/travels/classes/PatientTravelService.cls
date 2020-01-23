/**
 * Created by Yulia Yakushenkova on 1/21/2020.
 */

public with sharing class PatientTravelService {

    public static final String TRAVEL_MODE_CONFIRMED = 'Confirmed';
    public static final String TRAVEL_MODE_DECLINED = 'Declined';
    public static final String TRAVEL_MODE_PENDING = 'Pending';
    public static final String TRAVEL_MODE_ALL = 'All';
    private static User CURRENT_USER;

    public List<TravelWrapper> getTravelWrappers(String visitMode) {
        return this.getTravelWrappers(visitMode, null);
    }

    public List<TravelWrapper> getTravelWrappers(String visitMode, Integer limitNumber) {
        return this.getTravelWrappers(this.getTravels(visitMode, limitNumber));
    }

    @TestVisible
    private List<Booking__c> getTravels(String travelMode, Integer limitNumber) {
        ParticipantService.ParticipantState pState =
                ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
        if (pState == null || pState.pe == null || !pState.showVisits) return null;

        List<String> fields = new List<String>{
                'Name',
                'Type__c',
                'Title__c',
                'Status__c',
                'Booking_DateTime__c',
                'Patient_Visit__r.Visit__r.Patient_Portal_Name__c',
                'Participant_Enrollment__r.Participant_Contact__c',
                'Travel_Vendor__r.Link_Vendor__c'
        };
        String filter = DatabaseService.fieldEqual('Participant_Enrollment__c', pState.pe.Id);
        if (travelMode != TRAVEL_MODE_ALL) {
            filter += 'AND';
            if(travelMode == TRAVEL_MODE_CONFIRMED) filter += DatabaseService.fieldEqual('Status__c', TRAVEL_MODE_CONFIRMED);
            if(travelMode == TRAVEL_MODE_DECLINED) filter += DatabaseService.fieldEqual('Status__c', TRAVEL_MODE_DECLINED);
            if(travelMode == TRAVEL_MODE_PENDING) filter += DatabaseService.fieldEqual('Status__c', TRAVEL_MODE_PENDING);
        }
        String order = 'Patient_Visit__r.Visit__r.Visit_Number__c ';// + (VISIT_MODE_PAST == visitMode ? ' DESC ' : 'ASC') + ' NULLS LAST';
        Integer limitVisits = (limitNumber != null ? limitNumber : null);

        List<Booking__c> travels = (List<Booking__c>)
                DatabaseService.query(fields, Booking__c.getSObjectType(), filter, order, limitVisits);
        TranslateHelper.translate(travels, IRBParticipantService.getSuitableLanguageForIRBTranslation(pState.pe.Id));
        return travels;
    }

    private List<TravelWrapper> getTravelWrappers(List<Booking__c> travels) {
        List<TravelWrapper> travelWrappers = new List<TravelWrapper>();
        if (travels == null || travels.isEmpty()) return travelWrappers;

        List<User> users = [SELECT Id, LocaleSidKey, TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        CURRENT_USER = users.get(0);
        TimeZone timeZone = TimeZone.getTimeZone(CURRENT_USER.TimeZoneSidKey);

        Set<Id> uniqueId = new Set<Id>();
        for (Booking__c travel : travels) {
//            if (travel.Booking_DateTime__c != null) {
//                travel.Booking_DateTime__c = DateTimeConverterUtil.getUserDatetime(timeZone, travel.Booking_DateTime__c).date();
//            }

            if (uniqueId.add(travel.Id)) travelWrappers.add(new TravelWrapper(travel));
        }
        return travelWrappers;
    }

    public class TravelWrapper {

        @AuraEnabled
        public String visitName;
        @AuraEnabled
        public Date bookingDate;
        @AuraEnabled
        public Time bookingTime;
        @AuraEnabled
        public Booking__c booking;
        @AuraEnabled
        public String icon;
        @AuraEnabled
        public String link;

        public TravelWrapper(Booking__c booking) {
            this.visitName = booking.Patient_Visit__r.Visit__r.Patient_Portal_Name__c;
            this.booking = booking;
            Datetime bookDateTime = DateTimeConverterUtil.getUserDatetime(TimeZone.getTimeZone(CURRENT_USER.TimeZoneSidKey), booking.Booking_DateTime__c);
            this.bookingDate = bookDateTime.date();
            this.bookingTime = booking.Booking_DateTime__c.timeGmt();

            switch on booking.Type__c {
                when 'Airplane' {
                    this.icon = 'icon-airplane';
                }
                when 'Car' {
                    this.icon = 'icon-car';
                }
                when 'Hotel' {
                    this.icon = 'icon-bed';
                }
            }
            this.link = booking.Travel_Vendor__r.Link_Vendor__c;
        }
    }
}