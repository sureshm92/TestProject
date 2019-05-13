/**
 * Created by Denis on 15.04.2019.
 */

@IsTest(IsParallel=true)
private class Test_ReferringRemote {

    static Integer i = 0;

    public class TrialServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getTrialImpl'){
                return new Clinical_Trial_Profile__c(Link_to_Pre_screening__c = 'avc.com');
            }
            return null;
        }
    }

    public class HCPEnrollmentServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getHCPEnrollmentByIdImpl'){
                Account acc = new Account();
                acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
                insert acc;
                Clinical_Trial_Profile__c profile = new Clinical_Trial_Profile__c();
                Therapeutic_Area__c area = new Therapeutic_Area__c();
                insert area;
                profile.Therapeutic_Area__c = area.Id;
                profile.NCT_Number__c = 'NCT0000110' + i;
                i++;
                profile.Protocol_ID__c = 'Prot-33' + i;
                insert profile;
                Contact contact = new Contact();
                contact.LastName = '123';
                insert contact;
                Study_Site__c site = new Study_Site__c();
                site.Principal_Investigator__c = contact.Id;
                site.Clinical_Trial_Profile__c = profile.Id;
                site.Site__c = acc.Id;
                insert site;
                return new HCP_Enrollment__c(Study_Site__c = site.Id);
            }
            return null;
        }
    }

    public class ParticipantEnrollmentServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getParticipantEnrollmentImpl'){
                return new Participant_Enrollment__c();
            } else if(stubbedMethodName == 'createParticipantEnrollmentImpl'){
                return new Participant_Enrollment__c();
            } else if(stubbedMethodName == 'getPendingParticipantEnrollmentsImpl'){
                return new List<Participant_Enrollment__c>();
            }
            return null;
        }
    }

    public class StudySiteServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getSiteFilterDataImpl'){
                return new StudySiteService.SiteFilterData();
            } else if(stubbedMethodName == 'getStudySitesWithDistanceForHCPByTrialIdImpl'){
                return new List<StudySiteService.StudySiteDistanceWrapper>();
            }
            return null;
        }
    }

    public class CommunityServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getCurrentContactId'){
                Contact contact = new Contact();
                contact.LastName = 'Contact';
                insert contact;
                return contact.Id;
            }
            return null;
        }
    }

    @IsTest
    static void getInitData() {
        CommunityService.setMock(new CommunityServiceMock());
        StudySiteService.setMock(new StudySiteServiceMock());
        ParticipantEnrollmentService.setMock(new ParticipantEnrollmentServiceMock());
        HCPEnrollmentService.setMock(new HCPEnrollmentServiceMock());
        TrialService.setMock(new TrialServiceMock());

        ReferringRemote.getInitData(null, TestDataFactory.getFakeId(Participant_Enrollment__c.getSObjectType()), TestDataFactory.getFakeId(HCP_Enrollment__c.getSObjectType()), null);
        Participant__c participant = new Participant__c();
        Participant_Enrollment__c enrollment = new Participant_Enrollment__c();
        //enrollment.Clinical_Trial_Profile__c = profile.Id;
        insert enrollment;
        Contact contact = new Contact();
        contact.LastName = '123';
        insert contact;
        participant.Contact__c = contact.Id;
        participant.First_Name__c = 'FirstName';
        participant.Last_Name__c = 'LastName';
        participant.Email__c = '123@gm.com';
        ReferringRemote.saveParticipant(null, null, JSON.serialize(enrollment), JSON.serialize(participant));
        participant = new Participant__c();
        participant.Contact__c = contact.Id;
        participant.First_Name__c = 'FirstName';
        participant.Last_Name__c = 'LastName';
        participant.Email__c = '123@gm.com';
        try {
            ReferringRemote.saveParticipant(null, null, JSON.serialize(enrollment), JSON.serialize(participant));
        } catch (EmailException e){
            System.assertNotEquals(e, null);
        }
        ReferringRemote.setfailedReferral(JSON.serialize(enrollment), null);
    }

}