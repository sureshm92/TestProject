/**
 * Created by Yulia Yakushenkova on 1/30/2020.
 */

@IsTest
private class Test_RemoteCall_GetTravelBookingDetails {
    @IsTest
    static void testParseResponse() {
        String responses =
                '{ "code": 200, "response": [ { "visitname": "visit 1", "visitid": "8", "trialid": "3", "departure_date": "2019-09-28", "departing_from": "London", "returning_to": "New York", "round_trip": 0, "return_date": "2019-09-30", "first_name": "Test", "last_name": "One", "need_accommodation": 1, "need_travel": 1, "need_carer_accommodation": 1, "need_carer_travel": 1, "is_smoker_travel": 1, "is_smoker_accommodation": 1, "mobility_aid_requirements": "need a wheelchair", "additional_info_travel": "need regular stops", "additional_info_accommodation": "wide doors needed", "travel_type": 1, "room_type": 1, "special_requirements_travel": "", "special_requirements_accommodation": "", "status": 3, "options": [ { "accommodation": { "accommodation": 1, "check_in_date": "2019-04-26", "check_out_date": "2019-04-30", "hotel_name": "Hotel Test", "hotel_address": "1 street", "hotel_city": "London", "hotel_postcode": "WC1", "hotel_state": "N/A", "hotel_country": "UK", "smoking_preference": 2, "occupancy_type": 1, "note": "make some notes about the travel here", "accommodation_info": "accommodation specific info will go here", "tp_status": 2, "booked": 0, "concluded": 0, "tp_id": 1 }, "departure": [ { "id": 1, "travel_proposal_id": 1, "type": 3, "journey": 1, "company": "uber", "ticket_reference": "", "datetime_from": "2019-04-26 11:00:00", "datetime_to": "2019-04-26 12:00:00", "duration_minutes": 0, "title": "taxi", "details": "you will receive a text at pickup time", "transfer_info": "", "departure_location": "home", "arrival_location": "at hospital", "seq": 1 } ], "return": [ { "id": 2, "travel_proposal_id": 1, "type": 3, "journey": 0, "company": "uber", "ticket_reference": "", "datetime_from": "2019-04-26 18:00:00", "datetime_to": "2019-04-26 19:00:00", "duration_minutes": 0, "title": "taxi", "details": "call 0123 123 123 when ready to be picked up", "transfer_info": "", "departure_location": "hospital", "arrival_location": "home", "seq": 2 } ] } ] } ] }';
        RemoteCall_GetTravelBookingDetails remoteCall = new RemoteCall_GetTravelBookingDetails('1234', '1234');
        remoteCall.buildRequestBody();
        remoteCall.getType();
        RemoteCall_GetTravelBookingDetails.BookingResponse travelBookingResponse = (RemoteCall_GetTravelBookingDetails.BookingResponse)remoteCall.parseResponse(responses);
        System.debug(JSON.serializePretty(travelBookingResponse.travelBookings));
    }
}