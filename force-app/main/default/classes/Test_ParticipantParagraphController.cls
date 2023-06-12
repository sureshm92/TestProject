/**
 * Created by Sandeep on 20.10.2020.
 */

@IsTest
public class Test_ParticipantParagraphController {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    public static void runTest2() {
        TestData testData = new TestData();
        Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.Description = 'description';
        newCase.ContactId = testData.piContact.Id;
        insert newCase;

        Task ta = new Task();
        ta.Community_Template_Name__c = 'PatientPortal';
        ta.OwnerId = testData.participantUser.Id;
        insert ta;

        TemplatePropertiesService taobj = new TemplatePropertiesService(null);
        taobj.defineTemplateName(testData.pe.Id, CommunityModeService.USER_MODE_PARTICIPANT);
        taobj.defineTemplateName(testData.ctp.Id, CommunityModeService.USER_MODE_PARTICIPANT);
        taobj.defineTemplateName(newCase.Id, CommunityModeService.USER_MODE_PARTICIPANT);
        taobj.defineTemplateName(ta.Id, CommunityModeService.USER_MODE_PARTICIPANT);
        ta.WhatId = testData.pe.Id;
        ta.Community_Template_Name__c = null;

        update ta;
        taobj.defineTemplateName(ta.Id, CommunityModeService.USER_MODE_PARTICIPANT);

        ta.WhatId = null;

        update ta;
        taobj.defineTemplateName(ta.Id, CommunityModeService.USER_MODE_PARTICIPANT);
        TemplatePropertiesService taObj2 = new TemplatePropertiesService(
            ta.Id,
            CommunityModeService.USER_MODE_PARTICIPANT
        );
    }

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

        ParagraphController controller1 = new ParagraphController();
        controller1.labelName = System.Label.AL_Body_PRT_Become_Adult_Delegate;
        controller1.outputMode = 'HTML';
        controller1.getLabelValue();
    }
}
