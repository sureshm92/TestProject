/**
 * Created by Igor Malyuta on 10.09.2019.
 */

public without sharing class DateTimeConverterUtil {

    public static final Integer MS_IN_HOUR = 3600000;

    public class DateTimeException extends Exception{}

    public static Map<Id, TimeZone> getUsersTimezoneMap(Set<Id> contactIds) {
        List<User> users = [
                SELECT Id, TimeZoneSidKey
                FROM User
                WHERE ContactId IN:contactIds
                AND IsActive = TRUE
        ];
        Map<Id, TimeZone> userMap = new Map<Id, TimeZone>();
        for (User u : users) userMap.put(u.Id, TimeZone.getTimeZone(u.TimeZoneSidKey));

        return userMap;
    }

    public static TimeZone getUserTimeZone(Id contactId) {
        Map<Id, TimeZone> timeZonesByIds = getUsersTimezoneMap(new Set<Id>{contactId});
        if(timeZonesByIds.values().isEmpty()) throw new DateTimeException('Contact has no user!');

        return timeZonesByIds.values().get(0);
    }

    public static Datetime getUserDatetime(TimeZone timezone, Datetime moment) {
        if (moment == null) moment = Datetime.now();

        String nowFormat = moment.format('YYYY-MM-dd HH:mm:ss', timezone.toString());
        return Datetime.valueOfGmt(nowFormat);
    }

    public static Datetime getUserDatetime(TimeZone timezone, Date someDate) {
        Datetime moment;

        if(someDate == null) {
            moment = Datetime.now();
        } else {
            moment = Datetime.newInstance(
                    someDate.year(),
                    someDate.month(),
                    someDate.day()
            );
        }

        String nowFormat = moment.format('YYYY-MM-dd HH:mm:ss', timezone.toString());
        return Datetime.valueOfGmt(nowFormat);
    }

    public static Datetime convertUserDatetimeToGMT(Datetime moment, TimeZone tz) {
        Integer offset = tz.getOffset(Datetime.now()) / MS_IN_HOUR;
        Datetime momentInGMT = moment.addHours( -offset );

        return momentInGMT;
    }

    public static Datetime addDaysInUserTimeZone(Datetime moment, TimeZone tz, Integer days) {
        Time gmtTime = moment.timeGmt();
        Date gmtDate = moment.date().addDays(days);
        Datetime gmtDT = Datetime.newInstanceGmt(gmtDate, gmtTime);

        return gmtDT;
    }

    public static Datetime addDaysInUserTimeZone(Datetime moment, Id contactId, Integer days) {
        return addDaysInUserTimeZone(moment, getUserTimeZone(contactId), days);
    }

    public static Boolean isSameMoment(Datetime firstDT, TimeZone firstTZ, Datetime secondDT, TimeZone secondTZ) {
        return convertUserDatetimeToGMT(firstDT, firstTZ) == convertUserDatetimeToGMT(secondDT, secondTZ);
    }
}