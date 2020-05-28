/**
 * Created by Leonid Bartenev
 */

public without sharing class StudyResourceVisibilityService {
    
    public static Boolean isResourceVisibleForPE(
            Res_study__c resStudy, Participant_Enrollment__c pe, List<String> contentLangs, String userMode, Boolean isDelegate){
        Boolean isVisible = true;
        if(userMode.contains(CommunityService.USER_MODE_PARTICIPANT)){
            isVisible = resStudy.Visible_To_Participant__c;
            if(resStudy.Active_On_Status__c != null){
                Integer resStudyStatusOrder = PEStatusState.PE_ORDERED_STATUSES.get(resStudy.Active_On_Status__c);
                Integer peStatusOrder = PEStatusState.PE_ORDERED_STATUSES.get(pe.Participant_Status__c);
                isVisible = isVisible && (peStatusOrder >= resStudyStatusOrder);
            }
            if(resStudy.Expires_On_Status__c != null){
                Integer expireStatusOrder = PEStatusState.PE_ORDERED_STATUSES.get(resStudy.Expires_On_Status__c);
                Integer peStatusOrder = PEStatusState.PE_ORDERED_STATUSES.get(pe.Participant_Status__c);
                isVisible = isVisible && (peStatusOrder < expireStatusOrder);
            }
            if(isDelegate != null && isDelegate){
                isVisible = isVisible && resStudy.Visible_To_Delegates__c;
            }
            if(resStudy.Active_After_Days__c != null){
                isVisible = isVisible &&
                        pe.Days_After_Enrolled__c != null &&
                        pe.Days_After_Enrolled__c >= resStudy.Active_After_Days__c;
                if(resStudy.Expires_After_Days__c != null){
                    isVisible = isVisible && pe.Days_After_Enrolled__c < (resStudy.Active_After_Days__c + resStudy.Expires_After_Days__c);
                }
            }
            if(PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pe.Participant_Status__c)){
                isVisible = isVisible && resStudy.Visible_In_Alumni__c;
            }

            if(!String.isEmpty(pe.Study_Site__r.Approved_Lng__c)) {
                if(contentLangs == null || contentLangs.isEmpty()) {
                    isVisible = false;
                } else {
                    Boolean isLangContains = false;
                    for(String lng : pe.Study_Site__r.Approved_Lng__c.split(';')) {
                        if(contentLangs.contains(lng)) {
                            if(resStudy.Resource__r.Content_Type__c  == ResourceService.RESOURCE_TYPE_RELEVANT_LINK
                                    && !resStudy.Resource__r.Languages__c.contains(lng)){
                                isLangContains = false;
                            } else {
                                isLangContains = true;
                                break;
                            }
                        }
                    }
                    if(resStudy.Resource__r.Content_Type__c == ResourceService.RESOURCE_TYPE_RELEVANT_LINK
                            && resStudy.Resource__r.Countries__c != null && pe.Study_Site__r.Site__r.BillingCountryCode != null
                            && !resStudy.Resource__r.Countries__c.contains(pe.Study_Site__r.Site__r.BillingCountryCode)) {
                        isVisible = false;
                    }
                    isVisible = isVisible && isLangContains;
                }
            }
        }else if(userMode.contains(CommunityService.USER_MODE_PI)){
            isVisible = resStudy.Visible_To_PI__c;
        }else{
            isVisible = resStudy.Visible_To_RP__c;
        }

        return isVisible;
    }

}