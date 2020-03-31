/**
 * Created by Igor Malyuta on 24.03.2020.
 */

public without sharing class EmailTemplateProviderPI extends EmailTemplateProviderAbstract {

    private List<DelegateLevelWrapper> piDelegateLevels = new List<DelegateLevelWrapper>();

    public EmailTemplateProviderPI(Id sourceId, Id recipientId, String recipientName, String recipientLanguage,
            String parametersProviderName, String outputMode
    ) {
        super(sourceId, recipientId, recipientName, recipientLanguage, parametersProviderName, outputMode);

        Study_Site__c ss = [
                SELECT
                        Principal_Investigator__r.Name,
                        Principal_Investigator__r.Salutation
                FROM Study_Site__c
                WHERE Id = :sourceId
        ];
        parameters.put('PIName', getFullContactName(ss.Principal_Investigator__r));
        initDelegates();
    }

    public List<DelegateLevelWrapper> getPIDelegateLevels() {
        return piDelegateLevels;
    }

    private void initDelegates() {
        //delegated by PI
        List<Site_Staff__c> siteStaffs = [
                SELECT toLabel(Delegate_Level__c),
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c,
                        Study_Site__r.Principal_Investigator__r.Full_Name__c,
                        Study_Site__r.Name
                FROM Site_Staff__c
                WHERE Site_Contact__c = :recipientContactId
        ];
        TranslateHelper.translate(siteStaffs, recipientLanguage);

        for (Site_Staff__c siteStaff : siteStaffs) {
            piDelegateLevels.add(new DelegateLevelWrapper(
                    siteStaff.Delegate_Level__c,
                    siteStaff.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c + ' (' + siteStaff.Study_Site__r.Name + ')'
            ));
        }
        piDelegateLevels.sort();
    }
}