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
    },

    setBrowserHistory: function (component) {
        if(!component.get('v.isInitialized')) return;
        var params = [];
        var currentTab = component.get('v.currentTab');
        if(component.get('v.studyDetail.trial.Id')) params.push('id=' + component.get('v.studyDetail.trial.Id'));
        if(component.get('v.currentTab')) params.push('tab=' + component.get('v.currentTab'));
        if(component.get('v.taskMode') && currentTab === 'tab-tasks') params.push('taskmode=' + component.get('v.taskMode'));
        if(component.get('v.resourceMode') && currentTab === 'tab-resources') params.push('resourcemode=' + component.get('v.resourceMode'));
        var paramsStr = '';
        if(params.length > 0) paramsStr = params.join('&');
        history.pushState(null, '',
            communityService.getCommunityURLPathPrefix() + '/study-workspace?' + paramsStr);

    }

})