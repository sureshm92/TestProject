/**
 * Created by Slav on 31.10.2019.
 */

public class XLF_RemoteActionResult {
    @AuraEnabled public Boolean success;
    @AuraEnabled public String  jobId;
    @AuraEnabled public String  message;
    @AuraEnabled public String  zip;
    @AuraEnabled public List<Object> records;
    
    public XLF_RemoteActionResult (Boolean success, String jobId, String message, String zip, List<Object> records) {
        this.success = success;
        this.jobId   = jobId;
        this.message = message;
        this.zip     = zip;
        this.records = records;
    }
}
