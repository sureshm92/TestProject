public class TestDataFactory {

    private static final Map<SObjectType, Map<String, Object>> REQUIRED_FIELDS = new Map<SObjectType, Map<String, Object>>{
            Account.getSObjectType() => new Map<String, Object>{
                    'Name' => 'Test Name'
            },

            Clinical_Trial_Profile__c.getSObjectType() => new Map<String, Object>{
                    'Protocol_ID__c' => 'test protocol Id',
                    'Study_Title__c' => 'Test Study Title',
                    'Study_Code_Name__c' => 'Test Study Code Name',
                    'NCT_Number__c' => 'NCT00000000'
            },

            Contact.getSObjectType() => new Map<String, Object>{
                    'LastName' => 'Test Last Name'
            },

            ContentVersion.getSObjectType() => new Map<String, Object>{
                    'Title' => 'Test Title',
                    'VersionData' => Blob.valueOf('Test Data'),
                    'PathOnClient' => 'Test.pdf'
            },

            Participant_Enrollment__c.getSObjectType() => new Map<String, Object>{
                    'Medical_Record_Review_Status__c' => 'Pass',
                    'Pre_screening_Status__c' => 'Pass',
                    'Patient_ID__c' => '12345678',
                    'Participant_Status__c' => 'Referral Sent to PI',
                    'Referral_Source__c' => 'HCP'
            },

            Participant__c.getSObjectType() => new Map<String, Object>{
                    'First_Name__c' => 'Test Participant First Name',
                    'Last_Name__c' => 'Test Participant Last Name',
                    'Email__c' => 'test@test.com',
                    'Phone__c' => '13241321223',
                    'Mailing_Country_Code__c' => 'US',
                    'Mailing_State_Code__c' => 'NY',
                    'Mailing_Zip_Postal_Code__c' => '1234231234',
                    'Language_Preference_Code__c' => 'en_US'
            },

            Resource_Action__c.getSObjectType() => new Map<String, Object>{
                    'IsFavorite__c' => true,
                    'IsVoted__c' => true
            },

            Resource__c.getSObjectType() => new Map<String, Object>{
                    'Title__c' => 'Test subject',
                    'Description__c' => 'Test description',
                    'Language__c' => 'en_US',
                    'Posting_Date__c' => Date.today(),
                    'Expiration_Date__c' => Date.today().addDays(1)
            },

            Study_Site__c.getSObjectType() => new Map<String, Object>{
                    'Name' => 'Test Study Name',
                    'Study_Site_Key__c' => '12132123132313',
                    'Override_PI_Referral_Status__c' => 'Invitation Sent'
            },

            Therapeutic_Area_Patient__c.getSObjectType() => new Map<String, Object>{
                    'Condition_Of_Interest_Order__c' => 0
            },

            Therapeutic_Area__c.getSObjectType() => new Map<String, Object>{
                    'Name' => 'Test Name'
            }
    };

    public static Integer fakeId_num = 1;

    public static String getFakeId(Schema.SObjectType sObjectType) {
        String result = String.valueOf(fakeId_num++);
        return sObjectType.getDescribe().getKeyPrefix() +
                '0'.repeat(12 - result.length()) + result;
    }

    /*getter without parameters - with default values for required fields*/

    public static SObject getSObject(Schema.SObjectType sObjectType) {
        return TestDataFactory.getSObjectWithFilledFields(sObjectType.newSObject(), TestDataFactory.REQUIRED_FIELDS.get(sObjectType));
    }

    /*getter with parameters*/

    public static SObject getSObject(Schema.SObjectType sObjectType, Map<String, Object> fieldValuesByNames) {
        return TestDataFactory.getSObjectWithFilledFields(TestDataFactory.getSObject(sObjectType), fieldValuesByNames);
    }

    private static SObject getSObjectWithFilledFields(SObject record, Map<String, Object> fieldValuesByNames) {
        if (fieldValuesByNames == null) {
            System.debug('-------------------FIELD VALUES BY NAMES MAP IS EMPTY-----------------------');
            return record;
        }
        for (String fieldName : fieldValuesByNames.keySet()) {
            if (fieldName.containsIgnoreCase('__r')) {
                record.putSObject(fieldName, (SObject) fieldValuesByNames.get(fieldName));
            } else {
                record.put(fieldName, fieldValuesByNames.get(fieldName));
            }
        }
        return record;
    }
}