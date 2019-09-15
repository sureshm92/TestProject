/**
 * Created by Kryvolap on 26.03.2019.
 */

public without sharing class DistanceHelper {
    public static final Set<String> MILE_LOCALES = new Set<String>{
            'en_US', 'en_GB', 'es_US'
    };
    private static String unitsOfMeasurement;
    private static Location userLocation;
    private static User communityUser;
    @TestVisible private static Boolean alreadyInit = false;
    public static String getUnitsOfMeasurement() {
        if (!alreadyInit) {
            init();
        }
        return unitsOfMeasurement;
    }
    public static String getUnitsOfMeasurementLabel() {
        if (!alreadyInit) {
            init();
        }

        return (unitsOfMeasurement == 'mi' ? Label.UOM_Miles : Label.UOM_Kilometers);
    }
    public static Location getUserLocation() {
        if (!alreadyInit) {
            init();
        }
        return userLocation;
    }

    public static String roundDouble(Double rawDouble) {
        return ((rawDouble * 10).round() / 10.0).format();
    }

    public static Double calculateDistanceTo(Account site) {
        if (site == null || site.BillingLatitude == null || site.BillingLongitude == null || getUserLocation() == null) {
            return null;
        }
        Location siteLocation = Location.newInstance(site.BillingLatitude, site.BillingLongitude);
        return getUserLocation().getDistance(siteLocation, getUnitsOfMeasurement());
    }

    private static void init() {
        if (communityUser == null) {
            communityUser = [SELECT Id, LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        }

        if (MILE_LOCALES.contains(communityUser.LocaleSidKey)) {
            unitsOfMeasurement = 'mi';
        } else {
            unitsOfMeasurement = 'km';
        }
        Contact communityContact = CommunityService.getUserContact();
        if (communityContact.MailingLatitude != null && communityContact.MailingLongitude != null) {
            userLocation = Location.newInstance(communityContact.MailingLatitude, communityContact.MailingLongitude);
        }
        alreadyInit = true;
    }
}