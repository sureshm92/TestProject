/**
 * Created by Leonid Bartenev
 */
({
    setTabInitialized: function (component, currentTab) {
        switch (component.get('v.currentTab')){
            case 'tab-referred-clinics':
                component.set('v.isReferringClinicsTabInitialized', true);
                break;
            case 'tab-referred-study-sites':
                component.set('v.isStudySitesTabInitialized', true);
                break;
            case 'tab-referred-patients':
                component.set('v.isReferredPatientsTabInitialized', true);
                break;
            case 'tab-medical-record-review-log':
                component.set('v.isMRRTabInitialized', true);
                break;
            case 'tab-referrals':
                component.set('v.isReferralsTabInitialized', true);
                break;
            case 'tab-reports':
                component.set('v.isReportsTabInitialized', true);
                break;
        }
    }
})