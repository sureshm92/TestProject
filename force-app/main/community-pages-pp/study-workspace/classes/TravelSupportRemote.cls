/**
 * Created by Yulia Yakushenkova on 1/31/2020.
 */

public without sharing class TravelSupportRemote {
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
    public static List<TravelWrapper> getTravelVendors(String clientId, String clientSecret) {
        try {
            List<TravelWrapper> travelWrappers =
                    ((TravelSupportRemote) ClassFactory.newInstance(TravelSupportRemote.class)).getTravelVendorsRemotely(clientId, clientSecret);
            return travelWrappers;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    public List<TravelWrapper> getTravelVendorsRemotely(String clientId, String clientSecret) {
        return this.getTravelWrappersRemotely(this.getTravelsRemotely(clientId, clientSecret));
    }

    @TestVisible
    private RemoteCall_GetTravelBookingDetails.TravelBookingResponse getTravelsRemotely(String clientId, String clientSecret) {
        RemoteCall_GetTravelBookingDetails remoteCall = new RemoteCall_GetTravelBookingDetails(clientId, clientSecret);
        RemoteCall_GetTravelBookingDetails.TravelBookingResponse travelBookingResponse =
                (RemoteCall_GetTravelBookingDetails.TravelBookingResponse) remoteCall.execute();
        if (remoteCall.log.Success__c) {
            return travelBookingResponse;
        } else {
            return null;
        }
    }

    private List<TravelWrapper> getTravelWrappersRemotely(RemoteCall_GetTravelBookingDetails.TravelBookingResponse bookingResponse) {
        List<TravelWrapper> travelWrappers = new List<TravelWrapper>();
        if (bookingResponse == null) return travelWrappers;
        if (bookingResponse.departures != null) travelWrappers.add(new TravelWrapper(bookingResponse.departures, bookingResponse.visitname, bookingResponse.status));
        if (bookingResponse.accommodations != null) travelWrappers.add(new TravelWrapper(bookingResponse.accommodations, bookingResponse.visitname, bookingResponse.status));
        if (bookingResponse.returns != null) travelWrappers.add(new TravelWrapper(bookingResponse.returns, bookingResponse.visitname, bookingResponse.status));
        return travelWrappers;
    }

    public class TravelWrapper {

        @AuraEnabled
        public String visitName;
        @AuraEnabled
        public String visitId;
        @AuraEnabled
        public String style = 'background:';
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String bgc;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public Datetime dateAndTime;
        @AuraEnabled
        public String icon;
        @AuraEnabled
        public String link;

        public TravelWrapper(Object obj, String visitName, String status) {
            this.visitName = visitName;
            //this.visitId = departure.visitid;
            if (status == '1') {
                this.bgc = '#E20000';
                this.style += '#E20000;';
                this.status = 'Declined';

            } else if (status == '2') {
                this.bgc = '#FF9300';
                this.style += '#FF9300;';
                this.status = 'Pending';
            } else if (status == '3') {
                this.bgc = '#00C221';
                this.style += '#00C221;';
                this.status = 'Confirmed';
            } else this.style += '#7F888D;';

            this.link = 'https://www.hotels.com/';

            if (obj instanceof RemoteCall_GetTravelBookingDetails.Departure) {
                RemoteCall_GetTravelBookingDetails.Departure departure = (RemoteCall_GetTravelBookingDetails.Departure) obj;
                this.title = departure.company;
                this.dateAndTime = Datetime.valueOf(departure.datetime_from);
                if (departure.title == 'taxi') this.icon = 'car-retro';
                if (departure.title == 'plane') {
                    this.icon = 'plane';
                    this.style += 'transform: rotate(-20deg);';
                }
            }
            if (obj instanceof RemoteCall_GetTravelBookingDetails.ReturnInfo) {
                RemoteCall_GetTravelBookingDetails.ReturnInfo returnInfo = (RemoteCall_GetTravelBookingDetails.ReturnInfo) obj;
                this.title = returnInfo.company;
                this.dateAndTime = Datetime.valueOf(returnInfo.datetime_from);
                if (returnInfo.title == 'taxi') this.icon = 'car-retro';
                if (returnInfo.title == 'plane') {
                    this.icon = 'plane';
                    this.style += 'transform: rotate(-20deg);';
                }
            }
            if (obj instanceof RemoteCall_GetTravelBookingDetails.Accommodation) {
                RemoteCall_GetTravelBookingDetails.Accommodation accommodation = (RemoteCall_GetTravelBookingDetails.Accommodation) obj;
                this.title = accommodation.hotel_name;
                this.dateAndTime = Datetime.newInstanceGmt(Date.valueOf(accommodation.check_in_date), Time.newInstance(9, 0, 0, 0));
                this.icon = 'icon-bed';
            }
        }
    }
}