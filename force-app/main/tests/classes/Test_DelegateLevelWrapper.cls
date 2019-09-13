/**
 * Created by Slav on 21.08.2019.
 */

@IsTest
public class Test_DelegateLevelWrapper {
    
    @IsTest
    public static void runTest () {
        DelegateLevelWrapper wrapper = new DelegateLevelWrapper();
        wrapper.level       = 'level';
        wrapper.studyName   = '11111';
        
        DelegateLevelWrapper compareTo = new DelegateLevelWrapper();
        compareTo.level     = 'level2';
        compareTo.studyName = '22222';
        
        System.assertEquals(wrapper.compareTo(compareTo), -1);
        System.assertEquals(compareTo.compareTo(wrapper), 1);
        
        compareTo.level     = 'level1';
        compareTo.studyName = '11111';
        System.assertEquals(wrapper.compareTo(compareTo), 0);
    }

}
