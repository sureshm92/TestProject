/**
 * Created by Denis on 15.04.2019.
 */

@IsTest
private class Test_ReferringRemote {

    public class TrialServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getTrialFromId'){
                return new Clinical_Trial_Profile__c();
            }
            return null;
        }
    }

    public class HCPEnrollmentServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getHCPEnrollment'){
                return new HCP_Enrollment__c();
            }
            return null;
        }
    }

    public class ParticipantEnrollmentServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getEnrollment'){
                return new Participant_Enrollment__c();
            } else if(stubbedMethodName == 'createNewParticipantEnrollment'){
                return new Participant_Enrollment__c();
            } else if(stubbedMethodName == 'getPendingParticipantEnrollmentList'){
                return new List<Participant_Enrollment__c>();
            }
            return null;
        }
    }

    public class StudySiteServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getSiteFilter'){
                return new StudySiteService.SiteFilterData();
            } else if(stubbedMethodName == 'getStudySitesWithDistanceByTrialId'){
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
    static void getgetInitData() {
        CommunityService.setMock(new CommunityServiceMock());
        StudySiteService.setMock(new StudySiteServiceMock());
        ParticipantEnrollmentService.setMock(new ParticipantEnrollmentServiceMock());
        HCPEnrollmentService.setMock(new HCPEnrollmentServiceMock());
        TrialService.setMock(new TrialServiceMock());
        Account acc = new Account();
        acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
        insert acc;
        Participant__c participant = new Participant__c();
        Participant_Enrollment__c enrollment = new Participant_Enrollment__c();
        insert enrollment;
        ReferringRemote.getInitData(null, null, null, null);
        Contact contact = new Contact();
        contact.LastName = '123';
        insert contact;
        participant.Contact__c = contact.Id;
        ReferringRemote.saveParticipant(null, null, JSON.serialize(enrollment), JSON.serialize(participant));
        ReferringRemote.setfailedReferral(null, null);
    }

}