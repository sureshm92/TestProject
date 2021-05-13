/**
 * Created by Kryvolap on 05.12.2018.
 */

public without sharing class ApplicationHelpRemote {
    public static final String TECH_SUPPORT_QUEUE_NAME = 'Tech_Support_Case_Queue';
    public static final String CASE_TYPE_TECHSUPPORT = 'Technical Support';
    public static final String CASE_ORIGIN_HELP = 'Help';
    
    
    
    public class InitData {
        String videoLink;
        String userManual;
        String quickReference;
        List<LabelValueItem> yearOfBirth;
        String currentYearOfBirth;
        Contact myContact;
        Participant__c participant;
        String usrName;
        String usrEmail;

    }

    @AuraEnabled
    public static String getInitData(String userMode) {
        try {
            InitData initData = new InitData();
            String userLanguage = UserInfo.getLanguage();
            ParticipantService.ParticipantState state = ParticipantService.getInstance().getState();
            initData.myContact = AccountSettingsController.getCurrentContact();
            if (initData.myContact.userCommunityDelegateId__c != null) {
                initData.myContact = ContactService.getContact(
                    initData.myContact.userCommunityDelegateId__c
                );
            }
            system.debug('userContact-->' + initData.myContact);
            if(initData.myContact.Id != NULL){
                if(UserContext.isParticipant()){
                initData.participant = [SELECT Id,Birth_Year__c FROM Participant__c WHERE Contact__c = :initData.myContact.Id][0];
                }
                }
            String communityTemplateName = UserContext.getCurrentCommunityTemplate().templateName;
            List<Guides_Setting__mdt> guidesSettings = [
                SELECT
                    Language__c,
                    Community_Template__c,
                    HCP_Quick_Reference__c,
                    HCP_User_Manual__c,
                    HCP_Video_Guide__c,
                    PI_Quick_Reference__c,
                    PI_User_Manual__c,
                    PI_Video_Guide__c,
                    Participant_Quick_Reference__c,
                    Participant_Quick_Reference_GSK__c,
                    Participant_User_Manual__c,
                    Participant_Video_Guide__c
                FROM Guides_Setting__mdt
                WHERE
                    (Language__c = :userLanguage
                    OR Language__c = 'en_US')
                    AND (Community_Template__c = :CommunityTemplateService.TEMPLATE_DEFAULT
                    OR Community_Template__c = :communityTemplateName)
            ];
            if (!guidesSettings.isEmpty()) {
                Guides_Setting__mdt setting = guidesSettings[0];
                for (Guides_Setting__mdt gs : guidesSettings) {
                    if (
                        gs.Language__c == userLanguage &&
                        gs.Community_Template__c == communityTemplateName
                    ) {
                        setting = gs;
                        break;
                    } else if (gs.Community_Template__c == communityTemplateName) {
                        setting = gs;
                    }
                }
                if (userMode == 'HCP') {
                    initData.videoLink = setting.HCP_Video_Guide__c;
                    initData.userManual = setting.HCP_User_Manual__c;
                    initData.quickReference = setting.HCP_Quick_Reference__c;
                } else if (userMode == 'PI') {
                    initData.videoLink = setting.PI_Video_Guide__c;
                    initData.userManual = setting.PI_User_Manual__c;
                    initData.quickReference = setting.PI_Quick_Reference__c;
                } else {
                    initData.videoLink = setting.Participant_Video_Guide__c;
                    initData.userManual = setting.Participant_User_Manual__c;
                    initData.quickReference = setting.Participant_Quick_Reference__c;
                    initData.yearOfBirth = ParticipantService.getYearofBirthList();
                    initData.usrName = UserInfo.getUserName();
                    initData.usrEmail = UserInfo.getUserEmail();
                    if(!String.isEmpty(state.participant.Date_of_Birth__c)){
                      initData.currentYearOfBirth = state.participant.Date_of_Birth__c.split('-')[0];
                    }
                    else if(initData.participant != NULL && initData.participant.Birth_Year__c != NULL){
                        initData.currentYearOfBirth = initData.participant.Birth_Year__c;
                    }else{
                        initData.currentYearOfBirth = ' '; 
                    }
                    
                }
                if (setting.Language__c != userLanguage) {
                    initData.videoLink = null;
                }
            }
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String validateAgeOfMajority(String birthYear) {
      ParticipantService.ParticipantState state = ParticipantService.getInstance().getState();
      Boolean isAdult = false;
      if (!String.isEmpty(birthYear)) {
            List<Age_of_Majority__mdt> ageOfMajorities = [
                SELECT DeveloperName, Country_Code__c, State_Code__c, Age__c
                FROM Age_of_Majority__mdt
       ];
      Map<String, Integer> ageByCountryCode = new Map<String, Integer>();
            for (Age_of_Majority__mdt ageOfMajority : ageOfMajorities) {
                if (ageOfMajority.Age__c != null) {
                    ageByCountryCode.put(
                        ageOfMajority.DeveloperName,
                        ageOfMajority.Age__c.intValue()
                    );
                }
            }

           Integer participantAge = (Date.Today().Year()) - (Integer.valueof(birthYear));

            if (
                ageByCountryCode.get(
                    state.participant.Mailing_Country_Code__c +
                    '_' +
                    state.participant.Mailing_State_Code__c
                ) != null
            ) {
                isAdult =
                    participantAge >=
                    ageByCountryCode.get(
                        state.participant.Mailing_Country_Code__c +
                        '_' +
                        state.participant.Mailing_State_Code__c
                    );
            } else if (ageByCountryCode.get(state.participant.Mailing_Country_Code__c) != null) {
                isAdult =
                    participantAge >= ageByCountryCode.get(state.participant.Mailing_Country_Code__c);
            } else {
                isAdult = participantAge >= 18;
            }
        }

        return '' + isAdult;

        
    }
    
    @AuraEnabled
    public static List<LabelValueItem> validateUsername() {
        List<LabelValueItem> userNames = new List<LabelValueItem>();
        //Contact con = AccountSettingsController.getCurrentContact();
        //List<User> loggedInUser = [Select Id,Email,Username from User where Email = :con.Email];
        List<User> loggedInUser = [Select Id,Email,Username,createddate from User where Email = :UserInfo.getUserEmail() order by createddate];
        for(User usr:loggedInUser){
            userNames.add(new LabelValueItem(usr.Username,usr.Username));
        }
        return userNames;
    }
    @AuraEnabled
    public static void createYOBCase(String yob,Boolean username,String userEmail,String currentYob){
        List<Case> caseList = new List<Case>();
        String descValue = '';
        String sub='';
        List<User> usr = [Select Id ,ContactId from User where Id=:UserInfo.getUserId()];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id =:usr[0].ContactId LIMIT 1];
            List<Group> groupList = [
                SELECT Id, Name
                FROM Group
                WHERE developerName = :TECH_SUPPORT_QUEUE_NAME
                LIMIT 1
            ];
        String separator = '';
        
        if (!conList.isEmpty() && !groupList.isEmpty()) {
            if(!String.isEmpty(yob)){
                if(currentYob == null){
                    currentYob = '';
                }
                if(username!= null && username == true){
                   separator = ','; 
                }
                   descValue = Label.PP_ChangeYOB_DntTranslate+' '+currentYob+' '+Label.PP_To_DntTranslate+' '+yob + separator; 
                   sub = Label.PP_YOBUpdateDntTranslate;
            }
               
            if(username!= null && username == true){
                if(userEmail == null){
                    userEmail= UserInfo.getUserName();
                }
                
                descValue += ' '+ Label.PP_ChangeUsrname_DntTranslate+' '+userEmail+ ' '+Label.PP_ToEmailAddressDntTranslate+' '+UserInfo.getUserEmail();
                sub = Label.PP_UsrNameUpdateDntTranslate;
            }
             if(!String.isEmpty(yob) && username!= null && username == true){
                
                sub = Label.PP_YOBUsrUpdateDntTranslate;
            }   
            Case yobCase = new Case(
                subject = sub,
                ContactId = conList[0].Id,
                Description = descValue,
                ownerId = groupList[0].Id,
                Type = sub,
                Origin = CASE_ORIGIN_HELP
            );
            caseList.add(yobCase);
        }
        insert caseList;
        
    }
    
   

    /*@AuraEnabled
	   public static String getPdfDonload(String titleName) {
	    Id recId =[Select Id FROM Resource__c WHERE Title__c=: titleName].Id;
	    Id docId =[SELECT ContentDocumentId,LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =:recId].ContentDocumentId;
	    return docId;
	   }*/
}