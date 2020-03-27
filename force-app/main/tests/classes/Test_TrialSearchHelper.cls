/**
 * Created by Vitalii Aheienko on 9/20/2019.
 */

@IsTest
private class Test_TrialSearchHelper {

    @TestSetup
    static void setup() {
        Test.startTest();
        TestDataFactory.createInitData();
        Test.stopTest();
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
    static void getFilteredTherapeuticAreas_test() {

        Id coiRecTypeId = Schema.SObjectType.Therapeutic_Area__c.getRecordTypeInfosByDeveloperName().get('Condition_of_Interests').getRecordTypeId();
        List<Therapeutic_Area__c> cois = new List<Therapeutic_Area__c>{
                (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType(), new Map<String, Object>{
                        'Name' => 'coi1',
                        'RecordTypeId' => coiRecTypeId
                }),
                (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType(), new Map<String, Object>{
                        'Name' => 'coi2',
                        'RecordTypeId' => coiRecTypeId
                })
        };
        insert cois;

        List<Therapeutic_Area__c> filteredCois = new TrialSearchHelper().searchFilteredTherapeuticAreas('coi', new List<Id>{
                cois[0].Id
        });
        System.assertEquals(1, filteredCois.size());
        System.assertEquals(cois[1].Id, filteredCois[0].Id);
    }

    @IsTest
    static void getInitTrialSearchContainer_test() {
        Participant__c participant = [SELECT Id, Contact__c FROM Participant__c LIMIT 1];
        User usr = [SELECT Id FROM User WHERE ContactId = :participant.Contact__c];
        TrialSearchContainerRemote.TrialSearchContainer container;

        Test.startTest();
        System.runAs(usr) {
            container = new TrialSearchHelper().getInitTrialSearchContainer();
        }
        Test.stopTest();

        System.assertEquals(1, container.trialTDOs.size());
    }

    @IsTest
    static void createSubscribeConnectionTest() {
        Participant__c participant = [SELECT Id, Contact__c FROM Participant__c LIMIT 1];
        Clinical_Trial_Profile__c ctp = [SELECT Id FROM Clinical_Trial_Profile__c LIMIT 1];
        TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);

        Test.startTest();

        User usr = [SELECT Id FROM User WHERE ContactId = :participant.Contact__c];
        System.runAs(usr) {
            helper.createSubscribeConnection(ctp.Id);
        }
        Test.stopTest();

        Contact_Topic__c contactTopic = [SELECT Id, Topic__r.TopicId__c FROM Contact_Topic__c];
        System.assertEquals(ctp.Id, contactTopic.Topic__r.TopicId__c);
    }

    @IsTest
    static void createSubscribeConnectionByCOI_Test() {
        Participant__c participant = [SELECT Id, Contact__c FROM Participant__c LIMIT 1];

        Therapeutic_Area__c ta = [SELECT Id, Name FROM Therapeutic_Area__c LIMIT 1];
        Id coiRecTypeId = Schema.SObjectType.Therapeutic_Area__c.getRecordTypeInfosByDeveloperName().get('Condition_of_Interests').getRecordTypeId();
        List<Therapeutic_Area__c> COIs = new List<Therapeutic_Area__c>{
                (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType(), new Map<String, Object>{
                        'Name' => 'coi1',
                        'Therapeutic_Area__c' => ta.Id,
                        'RecordTypeId' => coiRecTypeId
                }),
                (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType(), new Map<String, Object>{
                        'Name' => 'coi2',
                        'Therapeutic_Area__c' => ta.Id,
                        'RecordTypeId' => coiRecTypeId
                })
        };
        insert COIs;

        List<Therapeutic_Area_Patient__c> TAPs = new List<Therapeutic_Area_Patient__c>{
                (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(Therapeutic_Area_Patient__c.getSObjectType(), new Map<String, Object>{
                        'Condition_Of_Interest_Order__c' => 1,
                        'Therapeutic_Area__c' => COIs[0].Id,
                        'Participant__c' => participant.Id
                }),
                (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(Therapeutic_Area_Patient__c.getSObjectType(), new Map<String, Object>{
                        'Condition_Of_Interest_Order__c' => 2,
                        'Therapeutic_Area__c' => COIs[1].Id,
                        'Participant__c' => participant.Id
                })
        };
        insert TAPs;

        TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);
        List<Contact_Topic__c> contactTopic;
        Test.startTest();
        User usr = [SELECT Id FROM User WHERE ContactId = :participant.Contact__c];
        System.runAs(usr) {
            helper.createSubscribeConnectionByCOI(TAPs);
        }
        contactTopic = [SELECT Id, Contact__c FROM Contact_Topic__c WHERE Contact__c =: participant.Contact__c];
        Test.stopTest();

        System.assert(contactTopic.size() == 2);
    }
}