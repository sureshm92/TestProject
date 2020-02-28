/**
 * Created by user on 11-Sep-19.
 */

public without sharing class PastStudiesController {

    @AuraEnabled
    public static List<ContactService.PastStudyWrapper> getPastStudyRecords(){
        try{
            Id contactId = CommunityService.getUserContact().userCommunityDelegateId__c;
            if(contactId == null) contactId = CommunityService.getUserContact().Id;
            return ContactService.getPastStudyWrappers(contactId);
        }catch (Exception e){
            return (List<ContactService.PastStudyWrapper>)AuraHelper.throwException(e);
        }
    }

}