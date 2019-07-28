/**
 * Created by D.Yasinskyi on 03.05.2018
 */
public without sharing class MyTeamController {

    //TODO DEPRECATED CLASS!!!
//    @AuraEnabled
//    public static String getInitData(String userMode) {
//
//        Contact primaryContact = CommunityService.getUserContact();
//        MyTeamController.MyTeamDetail detail = new MyTeamController.MyTeamDetail();
//        if(primaryContact.primaryContact__c == null){
//            detail.delegates = getDelegates(primaryContact.Id);
//        }
//        detail.accessRights = CommunityService.getAccessRights(userMode);
//        detail.delegateOtions = getDelegateOptions(userMode);
//
//        return JSON.serialize(detail);
//    }
//
//    private static List<LabelValueItem> getDelegateOptions(String userMode){
//
//        List<LabelValueItem> delegateOtions = new List<LabelValueItem>();
//
//        if(userMode == CommunityService.USER_MODE_HCP){
//            for (Schema.PicklistEntry ple : Contact.HCP_DelegateAccessLevel__c.getDescribe().getPicklistValues()) {
//                delegateOtions.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
//            }
//        } else if(userMode == CommunityService.USER_MODE_PI){
//            for (Schema.PicklistEntry ple : Contact.PI_DelegateAccessLevel__c.getDescribe().getPicklistValues()) {
//                delegateOtions.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
//            }
//        }
//
//        return delegateOtions;
//    }
//
//    private static List<Contact> getDelegates(Id primaryContactId){
//
//        return [
//                SELECT Id
//                , FirstName
//                , LastName
//                , Email
//                , primaryContact__c
//                , HCP_DelegateAccessLevel__c
//                , PI_DelegateAccessLevel__c
//                FROM Contact
//                WHERE primaryContact__c = :primaryContactId
//        ];
//    }
//
//    public class MyTeamDetail {
//        public List<LabelValueItem> delegateOtions;
//        public List<Contact> delegates;
//        public String accessRights;
//        public MyTeamDetail() {
//            delegates = new List<Contact>();
//        }
//    }
}