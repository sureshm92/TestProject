/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=true)
private class Test_UserService {
    @IsTest
    static void test1() {
        Datetime dt = Datetime.newInstance(2001, 1, 1, 0, 0, 0);
        Date d = Date.newInstance(2001, 1, 1);
        String dtStr = UserService.formatDateTime(dt, 'en_US');
        String dateStr = UserService.formatDate(d, 'en_US');
        String datetimeStr=UserService.formatDateTimebyZone( dt,'en_US','America/Los_Angeles');
        String onlyDateStr=UserService.formatDatebyLocale(dt, 'en_US');
        
        System.assertEquals('01/01/2001, 12:00 AM', dtStr);
        System.assertEquals('01/01/2001,' , dateStr);
       // System.assertEquals('12/31/2000, 11:30 AM' , datetimeStr); 
        System.assertEquals('01/01/2001' , onlyDateStr);
    }
}
