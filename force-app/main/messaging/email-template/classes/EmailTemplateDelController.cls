/**
 * Created by Igor Malyuta on 31.03.2020.
 */
global without sharing class EmailTemplateDelController {

    global Id recipId { get; set; }
    global String contactLanguage { get; set; }
    global String commTemplateStr { get ;set; }
    
    public List<DelegateLevelWrapper> getPiDelegateLevels() {
        List<Site_Staff__c> siteStaffs = [
                SELECT toLabel(Delegate_Level__c),
                        Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c,
                        Study_Site__r.Principal_Investigator__r.Full_Name__c,
                        Study_Site__r.Name
                FROM Site_Staff__c
                WHERE Site_Contact__c = :EmailTemplateProviderService.getProvider().getRecipientId()
                AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = :commTemplateStr
        ];
        TranslateHelper.translate(siteStaffs, EmailTemplateProviderService.getProvider().getUserLanguage());

        List<DelegateLevelWrapper> piDelegateLevels = new List<DelegateLevelWrapper>();
        for (Site_Staff__c siteStaff : siteStaffs) {
            piDelegateLevels.add(new DelegateLevelWrapper(
                    siteStaff.Delegate_Level__c,
                    siteStaff.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c + ' ('
                            + siteStaff.Study_Site__r.Name + ')'
            ));
        }
        piDelegateLevels.sort();
        return piDelegateLevels;
    }

    public List<DelegateLevelWrapper> getHCPDelegateLevels() {
        List<RP_Delegate_Relationship__c> rpDelegates = [
                SELECT toLabel(Delegate_Access_Level__c),
                        Referring_Provider__r.Full_Name__c
                FROM RP_Delegate_Relationship__c
                WHERE Delegate__c = :EmailTemplateProviderService.getProvider().getRecipientId()
        ];
        TranslateHelper.translate(rpDelegates, EmailTemplateProviderService.getProvider().getUserLanguage());

        List<DelegateLevelWrapper> hcpDelegateLevels = new List<DelegateLevelWrapper>();
        for (RP_Delegate_Relationship__c delegate : rpDelegates) {
            hcpDelegateLevels.add(new DelegateLevelWrapper(
                    delegate.Delegate_Access_Level__c,
                    delegate.Referring_Provider__r.Full_Name__c
            ));
        }
        hcpDelegateLevels.sort();
        return hcpDelegateLevels;
    }
}
