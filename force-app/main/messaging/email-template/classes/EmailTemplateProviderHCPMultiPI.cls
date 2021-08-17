/**
 * Created by Igor Malyuta on 06.05.2020.
 */
public without sharing class EmailTemplateProviderHCPMultiPI extends EmailTemplateProvider {
    public override void initState(
        Id recipientId,
        String recipientName,
        String recipientLanguage,
        String communityTemplateName,
        Id whatId,
        String outputMode,
        String shareTemplate
    ) {
        super.initState(
            recipientId,
            recipientName,
            recipientLanguage,
            communityTemplateName,
            whatId,
            outputMode,
            shareTemplate
        );
        parameters.put('PIName', getMultiplePINames(recipientContactId));
    }

    private String getMultiplePINames(Id hcpContId) {
        Set<Id> piIds = new Set<Id>();
        Map<Id,Participant__c> partPIIdAndName= new Map<Id,Participant__c>();
        List<HCP_Enrollment__c> hcpEnrollments = [
            SELECT Study_Site__r.Principal_Investigator__r.Id,Study_Site__r.Principal_Investigator__r.Salutation_With_Name__c
            FROM HCP_Enrollment__c
            WHERE HCP_Contact__c = :hcpContId
        ];
        for (HCP_Enrollment__c hcpE : hcpEnrollments) {
            piIds.add(hcpE.Study_Site__r.Principal_Investigator__r.Id);
        }
		List<Participant__c> partPINames = [
            SELECT Id,Salutation__c,Contact__c,Full_Name__c FROM Participant__c WHERE Contact__c IN :piIds
        ];
        for(Participant__c partPIName: partPINames){
            partPIIdAndName.put(partPIName.Contact__c, partPIName);
        }
        String piNames = '';
        for (HCP_Enrollment__c hcpE : hcpEnrollments) {
            if(partPIIdAndName.containsKey(hcpE.Study_Site__r.Principal_Investigator__r.Id)){
                String piName = '';
                Participant__c partPI = partPIIdAndName.get(hcpE.Study_Site__r.Principal_Investigator__r.Id);
                if(partPI.Salutation__c!=null){
                    piName = piName==null?partPI.Salutation__c: piName + partPI.Salutation__c;
                }
                if(partPI.Full_Name__c !=null){
                    piName = piName==null?partPI.Full_Name__c: piName + ' ' + partPI.Full_Name__c;
                }
                piNames += piName + ', ';
            }else{
                piNames += hcpE.Study_Site__r.Principal_Investigator__r.Salutation_With_Name__c + ', ';
            }
        }
        return piNames.removeEnd(', ');
    }
}
