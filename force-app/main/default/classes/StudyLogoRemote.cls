/**
 * Created by Leonid Bartenev
 */

public class StudyLogoRemote {
    
    @AuraEnabled
    public static String getStudyPicture(Id studyId){
        Clinical_Trial_Profile__c clinicalTrialProfile = [
                SELECT Profile_Picture__c
                FROM Clinical_Trial_Profile__c
                WHERE Id =: studyId
        ];
        return clinicalTrialProfile.Profile_Picture__c;
    }
    
    @AuraEnabled
    public static void updateProfilePicture(Id studyId, String pictureSrc){
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c(
                Id = studyId,
                Profile_Picture__c = pictureSrc
        );
        update ctp; 
    }

}