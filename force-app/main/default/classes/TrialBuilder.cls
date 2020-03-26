/**
 * Created by AlexKetch on 5/17/2019.
 */

public abstract with sharing class TrialBuilder {
    
    protected TrialDetail trialDetail = new TrialDetail();
    protected String trialId;
    protected StudyActions studyAction;
    
    public void setTrial(String trialId) {
        this.trialId = trialId;
        trialDetail.trial = TrialService.getTrial(trialId);
        trialDetail.accountEnrollmentsList = new List<TrialDetail.ClinicWrapper>();
        trialDetail.isTCAccepted = trialDetail.trial.Terms_And_Conditions_ID__c == null ||
                TermsAndConditions.isTCAccepted(trialDetail.trial.Terms_And_Conditions_ID__c);
    }

    public abstract TrialDetail createTrial();

    protected abstract List<TrialDetail.StudyTab> getStudyTabs();

    protected abstract StudyActions getStudyActions();

    protected List<Account> getAccounts(Set<Id> accIds) {
        return [
                SELECT Id,
                        Name,
                        BillingStreet,
                        BillingState,
                        BillingPostalCode,
                        BillingCity,
                        BillingCountry,
                        BillingCountryCode,
                        BillingStateCode,
                        Phone,
                        BillingLongitude,
                        BillingLatitude,
            			Driving_Directions__c,
            			Parking_Instructions__c
                FROM Account
                WHERE Id IN :accIds
        ];
    }

    protected TrialDetail.ClinicWrapper createClinicWrapper(String name, Account acc, String hcpStatus, Id studySiteId) {
        TrialDetail.ClinicWrapper wrapper = new TrialDetail.ClinicWrapper();
        wrapper.clinic = acc;
        wrapper.name = name;
        List<String> addressList = new List<String>();
        if (acc.BillingCity != null) addressList.add(acc.BillingCity);
        if (acc.BillingState != null) addressList.add(acc.BillingState);
        if (acc.BillingPostalCode != null) addressList.add(acc.BillingPostalCode);
        wrapper.addrStreet = acc.BillingStreet;
        if (addressList.size() > 0) wrapper.addrCity = String.join(addressList, ', ');
        wrapper.studySiteId = studySiteId;
        wrapper.hcpStatus = hcpStatus;
        wrapper.hcpStatusLabel = TranslateHelper.getPickListLabel(HCP_Enrollment__c.Status__c, hcpStatus);
        wrapper.drivingDirection = acc.Driving_Directions__c;
        wrapper.otherGuidance = acc.Parking_Instructions__c;
        return wrapper;
    }

}