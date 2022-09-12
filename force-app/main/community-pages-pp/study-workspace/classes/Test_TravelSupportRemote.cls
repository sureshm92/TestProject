/**
 * Created by Yulia Yakushenkova on 3/4/2020.
 */

@IsTest
private class Test_TravelSupportRemote {
    @IsTest
    static void test_getAvailableVendorsForSS() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        TestData tData = new TestData();
        //Test.startTest();
        System.runAs(tData.participantUser) {
            TravelSupportRemote.getAvailableVendorsForSS();
            TravelSupportRemote.getTravelVendors('1234', '1234', false);
            TravelSupportRemote.getCommunityName();
            TravelSupportRemote.getisTravelSupportEnabled();
        }
        //Test.stopTest();
    }

    @IsTest
    static void test_getTravelWrappersRemotely() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        TestData tData = new TestData();
        //Test.startTest();
        System.runAs(tData.participantUser) {
            String responses =
                '{ "code": 200, "response": [ ' +
                '{ "visitname": "visit 1", "visitid": "8", "status": 3, "options": [ { ' +
                '"accommodation": { "check_in_date": "2019-04-26", "check_out_date": "2019-04-30", "hotel_name": "Hotel Test" }, ' +
                '"departure": [ { "company": "uber", "datetime_from": "2019-04-26 11:00:00", "datetime_to": "2019-04-26 12:00:00", "title": "taxi" } ], ' +
                '"return": [ { "company": "uber", "datetime_from": "2019-04-26 18:00:00", "datetime_to": "2019-04-26 19:00:00", "title": "taxi"} ] } ' +
                '] }' +
                '] }';
            RemoteCall_GetTravelBookingDetails remoteCall = new RemoteCall_GetTravelBookingDetails(
                '1234',
                '1234'
            );
            remoteCall.buildRequestBody();
            remoteCall.getType();
            RemoteCall_GetTravelBookingDetails.BookingResponse travelBookingResponse = (RemoteCall_GetTravelBookingDetails.BookingResponse) remoteCall.parseResponse(
                responses
            );
            TravelSupportRemote travelSupportRemote = new TravelSupportRemote();
            System.debug(JSON.serializePretty(travelBookingResponse));
            travelSupportRemote.getTravelWrappersRemotely(travelBookingResponse, true);
        }
        //Test.stopTest();
    }
}
