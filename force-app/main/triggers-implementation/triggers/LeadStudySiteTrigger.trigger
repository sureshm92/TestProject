trigger LeadStudySiteTrigger on Lead(before insert, before update) {
    Set<String> missingProtocolNumber = new Set<String>();
    Set<String> missingStudyNumber = new Set<String>();
    List<lead> lstLeadmissingProtocol = new List<lead> (); 
    
    for (Lead l : Trigger.new) {
        if (l.Study_Site__c == null &&
            l.Protocol_Number__c != null &&
            l.Study_Site_Number__c != null)
        {
            missingProtocolNumber.add(l.Protocol_Number__c);
            missingStudyNumber.add(l.Study_Site_Number__c);
        }
        else if(l.HCP_Referral_Source__c != Null && l.HCP_Referral_Source__c.contains('ACOE Data')
                && (l.Protocol_Number__c == Null || l.Study_Site_Number__c == Null)) {
                    lstLeadmissingProtocol.add(l);
                }
    }
    if(!lstLeadmissingProtocol.isEmpty()){
        showProtocolIdError(lstLeadmissingProtocol);
    }
    Map<String, Map<String, Id>> studyByProtocolAndNumber = new Map<String, Map<String, Id>>();
    List<Lead> lstLeadIncorrectProtocol = new List<Lead> ();
    for (Study_Site__c site : [
        SELECT Id, Protocol_ID__c, Study_Site_Number__c
        FROM Study_Site__c
        WHERE
        Protocol_ID__c IN :missingProtocolNumber
        AND Study_Site_Number__c IN :missingStudyNumber
    ]) {
        if (studyByProtocolAndNumber.get(site.Protocol_ID__c) == null) {
            studyByProtocolAndNumber.put(site.Protocol_ID__c, new Map<String, Id>());
        }
        studyByProtocolAndNumber.get(site.Protocol_ID__c).put(site.Study_Site_Number__c, site.Id);
    }
    for (Lead l : Trigger.new) {
        /* if (
l.Study_Site__c == null &&
l.Protocol_Number__c != null &&
l.Study_Site_Number__c != null &&
studyByProtocolAndNumber.containsKey(l.Protocol_Number__c) &&
studyByProtocolAndNumber.get(l.Protocol_Number__c).containsKey(l.Study_Site_Number__c)
) {
l.Study_Site__c = studyByProtocolAndNumber.get(l.Protocol_Number__c)
.get(l.Study_Site_Number__c);
} */
        if (l.Study_Site__c == null &&
            l.Protocol_Number__c != null &&
            l.Study_Site_Number__c != null){
                if(studyByProtocolAndNumber.containsKey(l.Protocol_Number__c) &&
                   studyByProtocolAndNumber.get(l.Protocol_Number__c).containsKey(l.Study_Site_Number__c))
                {
                    l.Study_Site__c = studyByProtocolAndNumber.get(l.Protocol_Number__c)
                        .get(l.Study_Site_Number__c);
                }
                else if(l.HCP_Referral_Source__c != Null && l.HCP_Referral_Source__c.contains('ACOE Data')){
                    lstLeadIncorrectProtocol.add(l);
                } 
            } 
    }
    if(!lstLeadIncorrectProtocol.isEmpty()){
        studySitenotFoundError(lstLeadIncorrectProtocol);
    }
    private static void showProtocolIdError(List<lead> lstLeadmissingProtocol)
    { 
        for(lead objlead : lstLeadmissingProtocol){
            objlead.addError('Protocol Number and Study Site Number are mandatory');
        }
    }
    private static void studySitenotFoundError(List<lead> lstLeadIncorrectProtocol)
    { 
        for(lead objlead : lstLeadIncorrectProtocol){
            objlead.addError('Either study site number or Protocol Number is not correct');
        }
    }
}