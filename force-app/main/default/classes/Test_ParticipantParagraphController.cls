/**
 * Created by Sandeep on 20.10.2020.
 */

@IsTest
public class Test_ParticipantParagraphController {
    @IsTest
    public static void runTest() {
        Contact recipient = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@mail.com'
        );
        insert recipient;
        EmailTemplateProviderService.setProviderType(
            '',
            recipient.Id,
            recipient.Name,
            'en_US',
            'Default',
            recipient.Id,
            '',
            ''
        );
        ParticipantParagraphController controller = new ParticipantParagraphController();
        controller.learnmoreLabelValue = System.Label.Learn_more_about_study;
        controller.discoverLabelValue = System.Label.Discover_future_Clinical;
        controller.trackLabelValue = System.Label.Track_your_study;
        controller.communityNameHelpLabelValue = System.Label.The_Patient_Portal_Help;
        controller.outputMode = 'HTML';
        controller.getLearnValue();
        controller.getdiscoverValue();
        controller.getTrackValue();
        controller.getCommunityHelpValue();
        controller.getisRTL();
    }
}
