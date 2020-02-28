/**
 * Created by Leonid Bartenev
 */
({
    setTabInitialized: function (component) {
        switch (component.get('v.currentTab')) {
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
        if (!component.get('v.isInitialized')) return;
        var params = [];
        var currentTab = component.get('v.currentTab');
        if (component.get('v.studyDetail.trial.Id')) params.push('id=' + component.get('v.studyDetail.trial.Id'));
        if (component.get('v.currentTab')) params.push('tab=' + component.get('v.currentTab'));
        if (component.get('v.taskMode') && currentTab === 'tab-tasks') params.push('taskmode=' + component.get('v.taskMode'));
        if (component.get('v.resourceMode') && currentTab === 'tab-resources') params.push('resourcemode=' + component.get('v.resourceMode'));
        var paramsStr = '';
        if (params.length > 0) paramsStr = params.join('&');
        history.pushState(null, '',
            communityService.getCommunityURLPathPrefix() + '/study-workspace?' + paramsStr);

    },

    mailSendMessage: function (component) {
        let urlShare = component.get('v.studyDetail.trial.Share_URL__c');
        let messageShare = $A.get("$Label.c.Resources_social");
        if (urlShare && messageShare) {
            if (!String.format) {
                String.format = function (format) {
                    var args = Array.prototype.slice.call(arguments, 1);
                    return format.replace(/{(\d+)}/g, function (match, number) {
                        return typeof args[number] != 'undefined'
                            ? args[number]
                            : match
                            ;
                    });
                };
            }
            messageShare = String.format(messageShare, urlShare);
            component.set('v.shareMessage', messageShare);
        }
    },

    setTabActions: function (component) {
        var tabs = component.get('v.studyDetail.tabs');
        if(!tabs) {
            return;
        }
        var currTab = component.get('v.currentTab');
        for(var i = 0; i < tabs.length; i++) {
            if(tabs[i].id === currTab) {
                component.set('v.currentActions', tabs[i].studyActions);
                if (tabs[i].id === 'tab-about-the-study') {
                    component.set('v.shareButtons', component.get('v.studyDetail.shareActions'));
                }
                break;
            }
        }
    }

})