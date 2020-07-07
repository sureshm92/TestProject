/**
 * Created by Leonid Bartenev
 */

public without sharing class OnboardingSlideTourRemote {

    public class SlideData{
        public String title;
        public String subTitle;
        public String body;
        public String imageURL;

        public SlideData(Onboarding_Slide__mdt slide, StaticResource staticResource){
            title = slide.Title__c;
            subTitle = slide.Sub_Title__c;
            body = slide.Body__c;
            if(staticResource != null) imageURL = '/resource/' + staticResource.SystemModStamp.getTime() + '/' + staticResource.Name;
        }
    }

    //TODO unused?
    public class InitData{
        public Map<String, String> systemTourNames;
        public Map<String, Boolean> showOnLogin;
        public Boolean isNewSession;
    }

    public class Tour{
        public Boolean showOnStartup;
        public Boolean isNewSession;
        public String title;
        public List<SlideData> slides;
    }

    @AuraEnabled
    public static String getSlides(String userMode, String formFactor, Boolean multimode){
        try{
            Map<String, String> tourNamesMap = getTourNamesMap();

            String tourName = tourNamesMap.get(userMode);
            List<Onboarding_Tour_Slides__mdt> tourList = [
                    SELECT Id, Order__c,
                            Onboarding_Tour__r.Title__c,
                            Onboarding_Slide__r.Title__c,
                            Onboarding_Slide__r.Sub_Title__c,
                            Onboarding_Slide__r.Body__c,
                            Onboarding_Slide__r.Static_Resource__c
                    FROM Onboarding_Tour_Slides__mdt
                    WHERE Onboarding_Tour__r.DeveloperName =: tourName
                    AND (Onboarding_Slide__r.Multimode_Only__c = FALSE OR Onboarding_Slide__r.Multimode_Only__c =: multimode)
                    ORDER BY Order__c
            ];

            List<String> staticResourceNames = new List<String>();
            for(Onboarding_Tour_Slides__mdt tourItem : tourList) {
//                if(formFactor == 'PHONE'){
//                    staticResourceNames.add(tourItem.Onboarding_Slide__r.Static_Resource__c + '_mobile');
//                }else{
                    staticResourceNames.add(tourItem.Onboarding_Slide__r.Static_Resource__c);
//                }
            }
            List<StaticResource> staticResources = [
                    SELECT Id, SystemModstamp, Name
                    FROM StaticResource
                    WHERE Name IN: staticResourceNames
            ];
            Map<String, StaticResource> staticResourceMap = new Map<String, StaticResource>();
            for(StaticResource sr : staticResources) staticResourceMap.put(sr.Name, sr);

            List<SlideData> outputSlides = new List<SlideData>();
            for(Onboarding_Tour_Slides__mdt tourItem : tourList){
                String resourceName = tourItem.Onboarding_Slide__r.Static_Resource__c;
//                if(formFactor == 'PHONE') resourceName += '_mobile';
                TranslateHelper.prepareLabelFields(tourItem.Onboarding_Slide__r, new Set<String>{
                        'Title__c',
                        'Sub_Title__c',
                        'Body__c'
                });
                outputSlides.add(new SlideData(
                        tourItem.Onboarding_Slide__r,
                        staticResourceMap.get(resourceName)
                ));
            }

            Tour tour = new Tour();
            if(tourList.size() > 0) {
                TranslateHelper.prepareLabelFields(tourList[0].Onboarding_Tour__r, new Set<String>{
                        'Title__c'
                });
                String communityName = TranslateHelper.getLabelValue(UserContext.getTemplateProperty('CommunityWelcome'));
                tour.title = tourList[0].Onboarding_Tour__r.Title__c.replace('##CommunityWelcome', communityName);
            }
            tour.slides = outputSlides;
            tour.showOnStartup = showOnStartup(userMode);
            tour.isNewSession = isNewSession();

            return JSON.serializePretty(tour);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void switchShowOnLogin(String userMode, Boolean showOnLogin){
        try{
            Set<String> roles = new Set<String>();
            Contact userContact = CommunityService.getUserContact();
            if(userContact.userCommunity_ShowTour__c != null) roles = new Set<String>(userContact.userCommunity_ShowTour__c.split(';'));
            if(showOnLogin) {
                roles.add(userMode);
            }else{
                roles.remove(userMode);
            }
            userContact.userCommunity_ShowTour__c = String.join(new List<String>(roles), ';');
            upsert userContact;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static Map<String, String> getTourNamesMap(){
        Boolean isParticipant = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant().size() > 0;
        List<Study_Site__c> piSSListWithDelegates = StudySiteService.getStudySitesCommon(CommunityService.USER_MODE_PI, null, false);
        List<Study_Site__c> piSSListWithoutDelegates = StudySiteService.getStudySitesCommon(CommunityService.USER_MODE_PI, null, true);
        Boolean isPI = piSSListWithoutDelegates.size() > 0;
        Boolean isPIDelegate = piSSListWithDelegates.size() > piSSListWithoutDelegates.size();
        List<HCP_Enrollment__c> hcpListWithDelegates = HCPEnrollmentService.getHCPEnrollmentsCommon(CommunityService.USER_MODE_HCP, null, false);
        List<HCP_Enrollment__c> hcpListWithoutDelegates = HCPEnrollmentService.getHCPEnrollmentsCommon(CommunityService.USER_MODE_HCP, null, true);
        Boolean isHCP = hcpListWithoutDelegates.size() > 0;
        Boolean isHCPDelegate = hcpListWithDelegates.size() > hcpListWithoutDelegates.size();
        String piTourName;
        if(isPI){
            piTourName = 'PI';
        }else if(isPIDelegate){
            piTourName = 'PI_Delegate';
        }

        String hcpTourName = 'HCP';
        if(isHCPDelegate){
            hcpTourName = 'HCP_Delegate';
        }

        String participantTourName = UserContext.getTemplateProperty('SlideTour');

        return new Map<String, String>{
                CommunityService.USER_MODE_PARTICIPANT => participantTourName,
                CommunityService.USER_MODE_PI => piTourName,
                CommunityService.USER_MODE_HCP => hcpTourName
        };
    }

    private static Boolean showOnStartup(String userMode){
        Contact userContact = CommunityService.getUserContact();
        List<String> showOnLoginList = new List<String>();
        if(CommunityService.getUserContact().userCommunity_ShowTour__c != null) {
            showOnLoginList = userContact.userCommunity_ShowTour__c.split(';');
        }
        return showOnLoginList.contains(userMode);
    }

    private static Boolean isNewSession(){
        Contact userContact = CommunityService.getUserContact();
        Boolean isNewSession = UserInfo.getSessionId() != userContact.Last_Session_Id__c;
        if(isNewSession) {
            userContact.Last_Session_Id__c = UserInfo.getSessionId();
            update userContact;
        }
        return isNewSession;
    }

}
