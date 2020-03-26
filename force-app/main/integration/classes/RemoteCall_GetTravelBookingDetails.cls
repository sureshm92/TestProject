/**
 * Created by Yulia Yakushenkova on 1/29/2020.
 */

public with sharing class RemoteCall_GetTravelBookingDetails extends RemoteCall {

    public String clientId;
    public String clientSecret;

    public class BookingResponse {
        public List<TravelBooking> travelBookings = new List<TravelBooking>();
    }

    public class TravelBooking {
        public String visitname;
        public String visitid;
        public String status;
        public Accommodation accommodations;
        public Departure departures;
        public ReturnInfo returns;
    }

    public class Accommodation {
        public String check_in_date;
        public String hotel_name;
    }

    public class Departure {
        public String company;
        public String datetime_from;
        public String title;
    }

    public class ReturnInfo {
        public String company;
        public String datetime_from;
        public String title;
    }

    public RemoteCall_GetTravelBookingDetails(String clientId, String clientSecret) {
        this.endPointURL = 'callout:Travel_Bookings' + '?userid=' + clientId + '&token=' + clientSecret;
        this.httpMethod = METHOD_GET;
    }

    @TestVisible
    public override Type getType() {
        return RemoteCall_GetTravelBookingDetails.class;
    }

    @TestVisible
    protected override String buildRequestBody() {
        return null;
    }

    @TestVisible
    protected override Object parseResponse(String responseBody) {
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped((String) responseBody);

        BookingResponse responses = new BookingResponse();

        for (Object resp : (List<Object>) root.get('response')) {
            TravelBooking booking =
                    (TravelBooking) JSON.deserialize(JSON.serialize(resp), TravelBooking.class);
            Map<String, Object> element = (Map<String, Object>) resp;
            for (Object opt : (List<Object>) element.get('options')) {
                Map<String, Object> travels = (Map<String, Object>) opt;
                System.debug(JSON.serializePretty(opt));
                booking.accommodations =
                        (Accommodation) JSON.deserialize(JSON.serialize(travels.get('accommodation')), Accommodation.class);
                booking.departures =
                        ((List<Departure>) JSON.deserialize(JSON.serialize(travels.get('departure')), List<Departure>.class)).get(0);
                booking.returns =
                        ((List<ReturnInfo>) JSON.deserialize(JSON.serialize(travels.get('return')), List<ReturnInfo>.class)).get(0);
            }
            responses.travelBookings.add(booking);
        }
        return responses;
    }
}