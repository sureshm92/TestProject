/**
 * Created by Yulia Yakushenkova on 1/31/2020.
 */

public without sharing class TravelSupportRemote {

    public static String TYPE_PLANE = 'Airlines';
    public static String TYPE_TAXI = 'taxi';

    @AuraEnabled
    public static List<TravelVendor__c> getAvailableVendorsForSS() {
        try {
            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            return TravelSupportHelper.getVendors(ps.pe.Study_Site__c);
        } catch (Exception e) {
            return (List<TravelVendor__c>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<TravelWrapper> getTravelVendors(String clientId, String clientSecret, Boolean isHomePage) {
        try {
            List<TravelWrapper> travelWrappers =
                    ((TravelSupportRemote) ClassFactory.newInstance(TravelSupportRemote.class)).getTravelVendorsRemotely(clientId, clientSecret, isHomePage);
            return travelWrappers;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    public List<TravelWrapper> getTravelVendorsRemotely(String clientId, String clientSecret, Boolean isHomePage) {
        return this.getTravelWrappersRemotely(this.getTravelsRemotely(clientId, clientSecret), isHomePage);
    }

    @TestVisible
    private RemoteCall_GetTravelBookingDetails.BookingResponse getTravelsRemotely(String clientId, String clientSecret) {
        RemoteCall_GetTravelBookingDetails remoteCall = new RemoteCall_GetTravelBookingDetails(clientId, clientSecret);
        RemoteCall_GetTravelBookingDetails.BookingResponse bookingResponse =
                (RemoteCall_GetTravelBookingDetails.BookingResponse) remoteCall.execute();
        if (remoteCall.log.Success__c) {
            return bookingResponse;
        } else {
            return null;
        }
    }

    @TestVisible
    private List<TravelWrapper> getTravelWrappersRemotely(RemoteCall_GetTravelBookingDetails.BookingResponse bookingResponse, Boolean isHomePage) {
        List<TravelWrapper> travelWrappers = new List<TravelWrapper>();
        if (bookingResponse == null) return travelWrappers;
        for(RemoteCall_GetTravelBookingDetails.TravelBooking travelBooking : bookingResponse.travelBookings) {
            System.debug(travelWrappers.size());
            if (travelBooking.departures != null) travelWrappers.add(new TravelWrapper(travelBooking.departures, travelBooking.visitname, travelBooking.status));
            if (travelBooking.accommodations != null) travelWrappers.add(new TravelWrapper(travelBooking.accommodations, travelBooking.visitname, travelBooking.status));
            if (isHomePage && travelWrappers.size() == 5) {
                break;
            } else {
                if (travelBooking.returns != null) travelWrappers.add(new TravelWrapper(travelBooking.returns, travelBooking.visitname, travelBooking.status));
            }
        }
        return travelWrappers;
    }

    public class TravelWrapper {

        @AuraEnabled public String visitName;
        @AuraEnabled public String visitId;
        @AuraEnabled public String style = 'background:';
        @AuraEnabled public String status;
        @AuraEnabled public String statusIcon;
        @AuraEnabled public String bgc;
        @AuraEnabled public String title;
        @AuraEnabled public Datetime dateAndTime;
        @AuraEnabled public String icon;
        @AuraEnabled public String link;
        @AuraEnabled public Boolean isAccommodation = false;

        public TravelWrapper(Object obj, String visitName, String status) {
            this.visitName = visitName;
            //this.visitId = departure.visitid;
            if (status == '1') {
                this.bgc = '#E20000';
                this.style += '#E20000;';
                this.status = Label.Home_Page_Travel_Support_Filter_Declined;
                statusIcon = 'icon-close-circle';
            } else if (status == '2') {
                this.bgc = '#FF9300';
                this.style += '#FF9300;';
                this.status = Label.Home_Page_Travel_Support_Filter_Pending;
                statusIcon = 'icon-clock';
            } else if (status == '3') {
                this.bgc = '#00C221';
                this.style += '#00C221;';
                this.status = Label.Home_Page_Travel_Support_Filter_Confirmed;
                statusIcon = 'check-circle';
            } else this.style += '#7F888D;';

            this.link = 'https://www.hotels.com/';

            if (obj instanceof RemoteCall_GetTravelBookingDetails.Departure) {
                RemoteCall_GetTravelBookingDetails.Departure departure = (RemoteCall_GetTravelBookingDetails.Departure) obj;
                this.title = departure.company;
                this.dateAndTime = Datetime.valueOf(departure.datetime_from);
                if (departure.title == TYPE_TAXI) this.icon = 'car-retro';
                if (departure.title == TYPE_PLANE) {
                    this.icon = 'plane-take-off';
                }
            }
            if (obj instanceof RemoteCall_GetTravelBookingDetails.ReturnInfo) {
                RemoteCall_GetTravelBookingDetails.ReturnInfo returnInfo = (RemoteCall_GetTravelBookingDetails.ReturnInfo) obj;
                this.title = returnInfo.company;
                this.dateAndTime = Datetime.valueOf(returnInfo.datetime_from);
                if (returnInfo.title == TYPE_TAXI) this.icon = 'car-retro';
                if (returnInfo.title == TYPE_PLANE) {
                    this.icon = 'plane-take-off';
                }
            }
            if (obj instanceof RemoteCall_GetTravelBookingDetails.Accommodation) {
                RemoteCall_GetTravelBookingDetails.Accommodation accommodation = (RemoteCall_GetTravelBookingDetails.Accommodation) obj;
                this.title = accommodation.hotel_name;
                try{
                    this.dateAndTime = Datetime.valueOf(accommodation.check_in_date);
                } catch (Exception e) {
                    this.dateAndTime = Datetime.newInstanceGmt(Date.valueOf(accommodation.check_in_date), Time.newInstance(12, 0, 0, 0));
                }
                this.icon = 'hotel-bed';
                this.isAccommodation = true;
            }
        }
    }
    
    //@Krishna Mahto - PEH-2179 - Start 
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method will return the current communityName
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @Method:   getCommunityName
    * @param:    NA   
    * @return:   Strings  
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    @auraEnabled
    public static String getCommunityName(){
		String communityName=FindCommunityName.getCommunityName();
        return communityName;
    }
    
    //@Krishna Mahto - PEH-2179 - End
}