public class TestDataFactory {

    private static final Map<String, Object> RESOURCE_REQUIRED_FIELDS = new Map<String, Object>{
            'Title__c' => 'Test subject',
            'Description__c' => 'Test description',
            'Posting_Date__c' => Date.today(),
            'Expiration_Date__c' => Date.today().addDays(1)
    };

    private static final Map<String, Object> CONTACT_REQUIRED_FIELDS = new Map<String, Object>{
            'LastName' => 'Test Last Name'
    };

    private static final Map<String, Object> PARTICIPANT_REQUIRED_FIELDS = new Map<String, Object>{};

    private static final Map<String, Object> RESOURCE_ACTION_REQUIRED_FIELDS = new Map<String, Object> {
            'IsFavorite__c' => true,
            'IsVoted__c' => true
    };

    private static final Map<String, Object> THERAPEUTIC_AREA_PATIENT_REQUIRED_FIELDS = new Map<String, Object>{
            'Condition_Of_Interest_Order__c' => 0
    };

    private static final Map<String, Object> THERAPEUTIC_AREA_REQUIRED_FIELDS = new Map<String, Object>{
            'Name' => 'Test'
    };

    public static Integer fakeId_num = 1;

    public static String getFakeId(Schema.SObjectType sObjectType) {
        String result = String.valueOf(fakeId_num++);
        return sObjectType.getDescribe().getKeyPrefix() +
                '0'.repeat(12-result.length()) + result;
    }

    /*getters without parameters - with default values for required fields*/

    public static Contact getContact() {
        return (Contact)getSObjectWithFilledFields(new Contact(), TestDataFactory.CONTACT_REQUIRED_FIELDS);
    }

    public static Resource__c getResource() {
        return (Resource__c)getSObjectWithFilledFields(new Resource__c(), TestDataFactory.RESOURCE_REQUIRED_FIELDS);
    }

    public static Participant__c getParticipant() {
        return (Participant__c)getSObjectWithFilledFields(new Participant__c(), TestDataFactory.PARTICIPANT_REQUIRED_FIELDS);
    }

    public static Resource_Action__c getResourceAction() {
        return (Resource_Action__c)getSObjectWithFilledFields(new Resource_Action__c(), TestDataFactory.RESOURCE_ACTION_REQUIRED_FIELDS);
    }

    public static Therapeutic_Area_Patient__c getTherapeuticAreaPatient() {
        return (Therapeutic_Area_Patient__c)getSObjectWithFilledFields(new Therapeutic_Area_Patient__c(), TestDataFactory.THERAPEUTIC_AREA_PATIENT_REQUIRED_FIELDS);
    }

    public static Therapeutic_Area__c getTherapeuticArea() {
        return (Therapeutic_Area__c)getSObjectWithFilledFields(new Therapeutic_Area__c(), TestDataFactory.THERAPEUTIC_AREA_REQUIRED_FIELDS);
    }

    /*getters with parameters*/

    public static Contact getContact(Map<String, Object> fieldsValuesByName) {
        return (Contact)getSObjectWithFilledFields(TestDataFactory.getContact(), fieldsValuesByName);
    }

    public static Resource__c getResource(Map<String, Object> fieldValuesByNames) {
        return (Resource__c)getSObjectWithFilledFields(TestDataFactory.getResource(), fieldValuesByNames);
    }

    public static Participant__c getParticipant(Map<String, Object> fieldValuesByNames) {
        return (Participant__c)getSObjectWithFilledFields(TestDataFactory.getParticipant(), fieldValuesByNames);
    }

    public static Therapeutic_Area_Patient__c getTherapeuticAreaPatient(Map<String, Object> fieldValuesByNames) {
        return (Therapeutic_Area_Patient__c)getSObjectWithFilledFields(TestDataFactory.getTherapeuticAreaPatient(), fieldValuesByNames);
    }

    public static Therapeutic_Area__c getTherapeuticArea(Map<String, Object> fieldValuesByNames) {
        return (Therapeutic_Area__c)getSObjectWithFilledFields(TestDataFactory.getTherapeuticArea(), fieldValuesByNames);
    }

    private static SObject getSObjectWithFilledFields(SObject record, Map<String, Object> fieldValuesByNames) {
        for(String fieldName : fieldValuesByNames.keySet()) {
            if(fieldName.containsIgnoreCase('__r')) {
                record.putSObject(fieldName, (SObject)fieldValuesByNames.get(fieldName));
            } else {
                record.put(fieldName, fieldValuesByNames.get(fieldName));
            }
        }
        return record;
    }
}