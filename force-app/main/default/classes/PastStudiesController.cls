/**
 * Created by user on 11-Sep-19.
 */

public without sharing class PastStudiesController {

    @AuraEnabled
    public static List<ContactService.PastStudyWrapper> getPastStudyRecords(){
        try{
            return ContactService.getPastStudyWrappers(CommunityService.getUserContact().Id);
        }catch (Exception e){
            return (List<ContactService.PastStudyWrapper>)AuraHelper.throwException(e);
        }
    }

}