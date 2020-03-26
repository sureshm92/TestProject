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
        System.assert('1/1/2001 12:00 AM' == dtStr);
        System.assert('1/1/2001' == dateStr);
    }
}