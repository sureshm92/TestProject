@isTest
public class Test_StudyLogoRemote {
    @isTest
    private static void getStudyPicture() {
        TestData.loadTestData();
        Test.startTest();
        Clinical_Trial_Profile__c clinicalTrialProfile = [
            SELECT Profile_Picture__c, id
            FROM Clinical_Trial_Profile__c
        ];
        StudyLogoRemote.updateProfilePicture(
            clinicalTrialProfile.Id,
            clinicalTrialProfile.Profile_Picture__c
        );
        StudyLogoRemote.getStudyPicture(clinicalTrialProfile.Id);
        Test.stopTest();
    }
}
