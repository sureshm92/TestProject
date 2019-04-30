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

    public static String upsertParticipants(String participantJSON, String participantId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:External_Patients_Database');
        if(getParticipants('USA', participantId).isEmpty()){
            request.setMethod('POST');
        } else {
            request.setMethod('PUT');
        }
        request.setHeader('Content-Type', 'application/json');
        request.setBody(participantJSON);
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        System.debug(response.getStatus());
        return response.getStatus();
    }

    public static String formatDate(String dateString){
        List<String> mountNames = new List<String>{
          'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUT', 'SEP', 'OCT', 'NOV', 'DEC'
        };
        Date newDate = Date.valueOf(dateString);
        String dayString = '' + newDate.day();
        if(dayString.length() == 1){
            dayString = '0' + dayString;
        }
        return dayString + '-' + mountNames[newDate.month() - 1] +
                 '-' + newDate.year();
    }

    public class ExternalParticipant{
        @AuraEnabled public String patientId;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String initials;
        @AuraEnabled public String dob;
        @AuraEnabled public String subjectId;
        @AuraEnabled public String gender;
        @AuraEnabled public String addressLine1;
        @AuraEnabled public String addressLine2;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String zipcode;
        @AuraEnabled public String country;
        @AuraEnabled public String countryCode;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String mobile;
    }
}