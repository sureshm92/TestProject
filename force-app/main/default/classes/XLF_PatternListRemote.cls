/**
 * Created by Slav on 28.10.2019.
 */

public without sharing class XLF_PatternListRemote implements Metadata.DeployCallback {
    private static Pattern alphaNumericPattern = Pattern.compile('[^a-zA-Z0-9]');
    private static String algorithm = 'AES128';
    private static String privateKey = '683d1f6bde01bd47';
    private static Metadata.DeployResult deployResult;
    
    public class RuntimeException extends Exception {
    }
    
    @AuraEnabled
    public static List<SObject> getRecords (String mode){
        List<SObject> records = new List<SObject>();
        if (mode.equalsIgnoreCase('WHITE')) {
            records = [SELECT Id, DeveloperName, MasterLabel, Active__c, Pattern__c FROM XLF_White_List__mdt WHERE Active__c = TRUE];
        } else if (mode.equalsIgnoreCase('BLACK')) {
            records = [SELECT Id, DeveloperName, MasterLabel, Active__c, Pattern__c FROM XLF_Black_List__mdt WHERE Active__c = TRUE];
        }
        records.sort();
        return records;
    }
    
    @AuraEnabled
    public static Metadata.DeployResult getDeployResult () {
        // Please note: this method may be useless if invoked from Lightning controller in a separate transaction
        // It is so because this controller is stateless, it doesn't keep the static values assigned in previous transactions
        // So, this method would always return null
        return deployResult;
    }
    
    @AuraEnabled
    public static String saveRecords ( List<XLF_White_List__mdt> records, String mode ) {
        // Please note: in this method we receive submitted records as a List of XLF_White_List__mdt objects
        // We use this object type for both XLF_White_List__mdt and XLF_Black_List__mdt metadata types since they are similar on structure
        // By doing this we eliminate some difficulties related to dealing with SObject types
        try {
            Map<Id, SObject> existentRecords;
            if (mode.equalsIgnoreCase('WHITE')) {
                existentRecords = new Map<Id, SObject> ([SELECT Id, Active__c, DeveloperName FROM XLF_White_List__mdt]);
            } else if (mode.equalsIgnoreCase('BLACK')) {
                existentRecords = new Map<Id, SObject> ([SELECT Id, Active__c, DeveloperName FROM XLF_Black_List__mdt]);
            } else {
                throw new RuntimeException('Invalid mode specified: \"' + mode + '\". Allowed either WHITE or BLACK.');
            }
    
            Metadata.DeployContainer container = new Metadata.DeployContainer();

            for (SObject record : records) {
                if (String.isBlank(record.Id)) {
                    // new record
                    if (String.isBlank((String)record.get('Pattern__c'))) {
                        // if no Pattern specified for this new record then ignore it
                        continue;
                    } else {
                        record.put('Active__c',true);
                    }
                } else {
                    // existent record
                    if (String.isBlank((String)record.get('Pattern__c'))) {
                        // Pattern cannot be blank
                        continue;
                    }
                }

                Blob tempBlob = Crypto.encryptWithManagedIV(algorithm, Blob.valueOf(privateKey), Blob.valueOf((String)record.get('Pattern__c')));
                String nameValue = EncodingUtil.base64Encode(tempBlob);
                Matcher matcher = alphaNumericPattern.matcher(nameValue);
                nameValue = matcher.replaceAll('');
                if (nameValue.length() > 39) nameValue = nameValue.substring(0, 39);
                nameValue = mode.substring(0, 1) + nameValue;
                
                Metadata.CustomMetadata custMetadata = new Metadata.CustomMetadata();
                String objName = mode.equalsIgnoreCase('WHITE') ? 'XLF_White_List__mdt.' : 'XLF_Black_List__mdt.';
                if (existentRecords.keySet().contains(record.Id)) {
                    custMetadata.fullName = objName + existentRecords.get(record.Id).get('DeveloperName');
                } else {
                    custMetadata.fullName = objName + nameValue;
                }
                custMetadata.label = nameValue;
                
                Metadata.CustomMetadataValue pattern = new Metadata.CustomMetadataValue();
                pattern.field = 'Pattern__c';
                pattern.value = record.get('Pattern__c');
                custMetadata.values.add(pattern);
                
                Metadata.CustomMetadataValue active = new Metadata.CustomMetadataValue();
                active.field = 'Active__c';
                active.value = record.get('Active__c');
                custMetadata.values.add(active);
                
                container.addMetadata(custMetadata);
            }

            if (container.getMetadata().isEmpty()) {
                return 'No records were found for deploy. Please check there is no conflict in your actions';
            }
            
            Id jobId = Metadata.Operations.enqueueDeployment(container, new XLF_PatternListRemote());
            return 'Records have been successfully submitted for deployment. Click the "Refresh" button to update the list.';
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    public void handleResult (Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        deployResult = result;
        if (result.status == Metadata.DeployStatus.Succeeded) {
            // Successful deployment
        } else {
            // Deployment failed
        }
    }
}