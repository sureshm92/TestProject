/**
 * Created by Sneha on 13.06.2020.
 */

@IsTest
public class Test_PP_LanguageSwitcherRemote {

    @IsTest(seeAllData=true)
    public static void runTest () {
		TestData testData = new TestData();
		PP_LanguageSwitcherRemote.getInitData();
		System.runAs(testData.participantUser) {		
			PP_LanguageSwitcherRemote.changeLanguage('EN','India','Karnataka','560035','EN','EN','en_US','Asia/Kolkata');    
		}			
    }
		 		 
}