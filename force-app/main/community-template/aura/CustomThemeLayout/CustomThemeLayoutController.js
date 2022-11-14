/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if (communityService.isInitialized()) {
            component.set('v.communityServ', communityService);
            communityService.executeAction(component, 'checkStudyMessage', null, function (
                returnValue
            ) {
                component.set('v.hasMessage', returnValue);
            });
            setTimeout(
                $A.getCallback(function () {
                    helper.init(component);
                }),
                1000
            );
        } else {
            communityService.initialize(component);
        }
    },

    doRefresh: function (component, event, helper) {
        helper.init(component);
        if (component.get('v.communityName') !== 'IQVIA Patient Portal') {
            component.find('navigation').refresh();
            component.find('navigationMobile').refresh();
            component.find('alerts').refresh();
        }
        else{
            component.find('ppMenu')?.forceRefresh();
            component.find('ppFooter')?.forceRefresh();
            component.find('ppAlerts')?.forceRefresh();            
        }
    },

    switchSideMenu: function (component) {
        component.set('v.showSideMenu', !component.get('v.showSideMenu'));
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    },
    doNavigate: function (component, event) {
        var page = event.getParam('page');
        communityService.navigateToPage(page);
    },
    verifyIncentive: function (component, event) {
        let isPartOfincentive = event.getParam('parOfIncentiveProgram');
        component.set('v.isIncentive',isPartOfincentive);
    },
    //Added as per REF-1343 by Vikrant Sharma for Help icon adjacent to User Profile for PI and HCP
    onClickHelp: function () {
        communityService.navigateToPage('help');
    },
    handleClick: function (component, event, helper) {
        var showHide = component.get('v.isPPonPhone');
        if (showHide == false) {
            component.set('v.isPPonPhone', true);
        } else {
            component.set('v.isPPonPhone', false);
        }
    },
    closePPMobileMenu: function (component, event, helper) {
        if (component.get('v.isPPonPhone')) {
            component.set('v.isPPonPhone', false);
        }
    },
    onClickSite: function (component, event) {        
        if (!component.get('v.isSitecal')) {
            component.set('v.isSitecal', true);
        } else {
            component.set('v.isSitecal', false);
        }
    },
});