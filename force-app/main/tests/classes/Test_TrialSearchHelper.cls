/**
 * Created by Vitalii Aheienko on 9/20/2019.
 */

@IsTest
private class Test_TrialSearchHelper {

    @TestSetup
    static void setup() {
        TestDataFactory.createInitData();
    }

    @IsTest
    static void isCtpEnrolling_Test() {
        Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(), new Map<String, Object>{
                'Override_Recruitment_Status__c' => TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING
        });
        TrialSearchHelper helper = new TrialSearchHelper();
        System.assert(helper.isCtpEnrolling(ctp));

        ctp.Override_Recruitment_Status__c = null;
        ctp.Recruitment_Status__c = TrialSearchWhereClauseFactory.OPEN_TO_ENROLLMENT;
        System.assert(helper.isCtpEnrolling(ctp));
    }

    @IsTest
    static void createTrialNotification_test() {
        User usr = [SELECT Id FROM User WHERE Contact.LastName = 'HCP'];
        Clinical_Trial_Profile__c ctp = [SELECT Id FROM Clinical_Trial_Profile__c LIMIT 1];
        System.runAs(usr) {
            new TrialSearchHelper().createTrialNotification(ctp.Id);
        }

        List<Trial_Notification__c> notifications = selectTrialNotifications();

        System.assertEquals(1, notifications.size());
        System.assertEquals(ctp.Id, notifications[0].Clinical_Trial_Profile__c);
    }

    @IsTest
    static void getFilteredTherapeuticAreas_test() {

        Id coiRecTypeId = Schema.SObjectType.Therapeutic_Area__c.getRecordTypeInfosByDeveloperName().get('Condition_of_Interests').getRecordTypeId();
        List<Therapeutic_Area__c> cois = new List<Therapeutic_Area__c>{
                (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType(), new Map<String, Object> {
                        'Name' => 'coi1',
                        'RecordTypeId' => coiRecTypeId
                }),
                (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType(), new Map<String, Object> {
                        'Name' => 'coi2',
                        'RecordTypeId' => coiRecTypeId
                })
        };
        insert cois;

        List<Therapeutic_Area__c> filteredCois = new TrialSearchHelper().getFilteredTherapeuticAreas('coi', new List<Id>{cois[0].Id});
        System.assertEquals(1, filteredCois.size());
        System.assertEquals(cois[1].Id, filteredCois[0].Id);
    }

    @IsTest
    static void createCaseAndSendNotification_test() {

        Participant__c participant = [SELECT Id, First_Name__c, Last_Name__c, Phone_Type__c, Gender__c, Phone__c, Email__c, Mailing_Country_Code__c, Mailing_Zip_Postal_Code__c, Mailing_State_Code__c, Date_of_Birth__c FROM Participant__c];

        Clinical_Trial_Profile__c ctp = [SELECT Id, NCT_Number__c FROM Clinical_Trial_Profile__c];

        new TrialSearchHelper().createCaseAndSendNotification(participant, ctp);

        System.assertEquals(1, [SELECT Id FROM Case].size()
        );

    }

    @IsTest
    static void getInitTrialSearchContainer_test() {
        Therapeutic_Area__c ta = [SELECT Id, Name FROM Therapeutic_Area__c LIMIT 1];
        Therapeutic_Area__c coi = (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType(), new Map<String, Object> {
            'Name' => 'coi1',
            'Therapeutic_Area__c' => ta.Id,
            'RecordTypeId' => Schema.SObjectType.Therapeutic_Area__c.getRecordTypeInfosByDeveloperName().get('Condition_of_Interests').getRecordTypeId()
        });
        insert coi;
        Participant__c participant = [SELECT Id, Contact__c FROM Participant__c LIMIT 1];
        Therapeutic_Area_Patient__c tap = (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(Therapeutic_Area_Patient__c.getSObjectType(), new Map<String, Object> {
            'Condition_Of_Interest_Order__c' => 1,
            'Therapeutic_Area__c' => coi.Id,
            'Participant__c' => participant.Id
        });
        insert tap;
        User usr = [SELECT Id FROM User WHERE ContactId = :participant.Contact__c];
        TrialSearchContainerRemote.TrialSearchContainer container;
        Test.startTest();
        System.runAs(usr){
            container = new TrialSearchHelper().getInitTrialSearchContainer();
        }
        Test.stopTest();

        System.assertEquals(1, container.trialTDOs.size());
    }


    private static List<Trial_Notification__c> selectTrialNotifications() {
        return [
                SELECT Id
                , Contact__c
                , Clinical_Trial_Profile__c
                FROM Trial_Notification__c
        ];
    }

}