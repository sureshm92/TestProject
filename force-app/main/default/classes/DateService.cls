public with sharing class DateService {

    private static final Map<Integer, String> monthNamesByNumbers = new Map<Integer, String> {
        1 => 'Jan',
        2 => 'Feb',
        3 => 'Mar',
        4 => 'Apr',
        5 => 'May',
        6 => 'Jun',
        7 => 'Jul',
        8 => 'Aug',
        9 => 'Sep',
        10 => 'Oct',
        11 => 'Nov',
        12 => 'Dec'


    };

    public static String format(Date dateToFormat, String dateFormat) {

        String day = String.valueOf(dateToFormat.day());
        String month = String.valueOf(dateToFormat.month());
        String result = dateFormat.replace('DD', day.length() < 2 ? '0' + day : day);
        result = result.replace('D', day);
        result = result.replace('MMM', String.valueOf(monthNamesByNumbers.get(dateToFormat.month())));
        result = result.replace('MM', month.length() < 2 ? '0' + month : month);
        result = result.replace('YYYY', String.valueOf(dateToFormat.year()));
        result = result.replace('YY', String.valueOf(dateToFormat.year()).substring(2, 4));

        return result;
    }
}