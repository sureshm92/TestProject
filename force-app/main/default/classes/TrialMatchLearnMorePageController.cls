/**
 * Created by Sandeep Kiran on 17.12.2020.
 */
public without sharing class TrialMatchLearnMorePageController {
    
   public String htmlformattedString {get;set;}
   public String studyTitle {get;set;}
   public String CTPId {get;set;}
   public String imgUrl {get;set;}
   public TrialMatchLearnMorePageController()
   {
       
      CTPId= System.currentPagereference().getParameters().get('CTPId');
   //  Clinical_Trial_Profile__c cobj=  [Select Id,Study_Content__c,Study_Title__c  from Clinical_Trial_Profile__c where Id=: VId];a0A1D000005RPuhUAG
       if(CTPId != ''){
        Clinical_Trial_Profile__c cobj=  [Select Id,Study_Content__c,Study_Title__c,CommunityTemplate__c  from Clinical_Trial_Profile__c where Id=: CTPId limit 1];
        htmlformattedString=cobj.Study_Content__c;
        imgUrl=cobj.CommunityTemplate__c + '.png';
        studyTitle=cobj.Study_Title__c;
      }
           
   }
   
    public Boolean getisRTL() {
        return (System.Label.RTL_Languages).contains(UserInfo.getLanguage()) ;
    }
    

}