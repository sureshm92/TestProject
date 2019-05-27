/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public with sharing class SurveyService {

    public class SurveyException extends Exception {}
    
    public class SurveyWrapper{
        public String name;
        public String url;
        
        public SurveyWrapper(String name, String url){
            this.name = name;
            this.url = url;
        }
    }

    private static SurveyService instance;

    public static SurveyService getInstance() {
        if(instance == null) instance = new SurveyService();
        return instance;
    }

    public static void setMock(StubProvider mock) {
        instance = (SurveyService) Test.createStub(SurveyService.class, mock);
    }
    
    public SurveyWrapper getSurveyLinkForCTP(Clinical_Trial_Profile__c ctp){
        if(ctp.Survey__c == null) {
            throw new SurveyService.SurveyException('Survey not available');
        }
        return getSurveyLink(ctp.Survey__c);
    }

    public SurveyWrapper getSurveyLink(Id surveyId) {
        List<SurveyInvitation> surveyInvitations = [
                SELECT Id, InvitationLink, Survey.Name
                FROM SurveyInvitation
                WHERE SurveyId = :surveyId
        ];
        if(surveyInvitations.isEmpty()) throw new SurveyService.SurveyException('SurveyInvitation not available');

        String link;
        String name;
        for(SurveyInvitation inv : surveyInvitations) {
            if(inv.InvitationLink.contains('.force.com')) {
                link = inv.InvitationLink;
                name = inv.Survey.Name;
                break;
            }
        }
        if(link == null) throw new SurveyService.SurveyException('Invitation link not found');

        return new SurveyWrapper(name, link);
    }


}