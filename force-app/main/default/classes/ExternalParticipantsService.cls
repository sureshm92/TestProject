/**
 * Created by user on 23-Apr-19.
 */

public with sharing class ExternalParticipantsService {

    public static List<ExternalParticipant> getParticipants(String countryCode, String patientId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String params = '?countryCode=' + countryCode;
        if(!String.isBlank(patientId)){
            params += '&patientId=' + patientId;
        }
        request.setEndpoint('callout:External_Patients_Database' + params);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            List<ExternalParticipant> patients = new List<ExternalParticipant>();
            patients = (List<ExternalParticipant>) JSON.deserialize(response.getBody().remove('_'), List<ExternalParticipant>.class);
            return patients;
        } else {
            return null;
        }
    }

    public static String upsertParticipants(String participantJSON, String method){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:External_Patients_Database');
        request.setMethod(method);
        request.setBody(participantJSON);
        HttpResponse response = http.send(request);
        return response.getStatus();
    }

    public class ExternalParticipant{
        public String patientId;
        public String firstName;
        public String lastName;
        public String initials;
        public Date dob;
        public String subjectId;
        public String gender;
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String state;
        public String zipcode;
        public String country;
        public String countryCode;
        public String email;
        public String phone;
        public String mobile;
    }
}