public with sharing class PatientOutreachLog {

        public String salesforceRequestID;
        public String muleTid;
        public List<Results> results;
    
        public class Results {
            public String participantId;
            public String studyCodeName;
            public String studySiteName;
            public String statusCode;
            public String statusMessage;
            public Object salesforceErrorMessages;
        }
    
        
        public static PatientOutreachLog parse(String json) {
            return (PatientOutreachLog) System.JSON.deserialize(json, PatientOutreachLog.class);
        }
}