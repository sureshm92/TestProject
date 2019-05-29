/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public with sharing class SurveyService {

    public class SurveyException extends Exception {}

    public static final List<String> PS_DEFAULT_FIELDS_LIST = new List<String> {
            'Expiration_Date__c',
            'Id',
            'Name',
            'Participant_Contact__c',
            'Participant_Study_Enrollment__c',
            'Show_Date__c',
            'Survey__c',
            'Survey__r.Name',
            'Visible_To_Delegates__c'
    };

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

    public Participant_Survey__c getParticipantSurvey(Id psId) {
        return (Participant_Survey__c) DatabaseService.getInstance().queryImpl(
                PS_DEFAULT_FIELDS_LIST,
                Participant_Survey__c.getSObjectType(),
                DatabaseService.fieldEqual('Id', psId)
        ).get(0);
    }

    public SurveyWrapper getSurveyWrapper(Id psId){
        Participant_Survey__c ps = getParticipantSurvey(psId);
        List<SurveyInvitation> invitation = [
                SELECT InvitationLink
                FROM SurveyInvitation
                WHERE ParticipantId =: ps.Participant_Contact__c
        ];

        return new SurveyWrapper(ps.Survey__r.Name, invitation.get(0).InvitationLink);
    }

    private SurveyInvitation generateInvitation(Participant_Survey__c ps) {
        SurveyInvitation invitation = new SurveyInvitation();
        invitation.CommunityId = CommunityService.getCommunityId(null);
        invitation.Name = ps.Survey__r.Name + ':' + ps.Participant_Study_Enrollment__c;
        invitation.ParticipantId = ps.Participant_Contact__c;
        invitation.SurveyId = ps.Survey__c;

        if(ps.Expiration_Date__c != null) {
            Datetime expiry = Datetime.newInstanceGmt(
                    ps.Expiration_Date__c.year(),
                    ps.Expiration_Date__c.month(),
                    ps.Expiration_Date__c.day()
            );

            invitation.InviteExpiryDateTime = expiry;
        }

        return invitation;
    }

    /**
     * Creates the objects SurveyInvitation associated with the participant contact.
     * <p>Sets the InviteExpiryDateTime when it is available on the Participant_Survey__c.
     * @author Igor Malyuta
     * @param psList List of Participant_Survey__c
     */
    public void generateInvitations(List<Participant_Survey__c> psList) {
        List<SurveyInvitation> invitations = new List<SurveyInvitation>();
        for(Participant_Survey__c ps : psList) {
            invitations.add(generateInvitation(ps));
        }

        insert invitations;
    }
}