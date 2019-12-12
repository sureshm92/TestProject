/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_SystemService {
    
    @IsTest
    static void testIsScratch() {
        SystemService.markAsScratchOrg();
        System.assert(SystemService.isScratchOrg());
    }
    
    @IsTest
    static void testIsNonScratch() {
        System.assert(!SystemService.isScratchOrg());
    }
}