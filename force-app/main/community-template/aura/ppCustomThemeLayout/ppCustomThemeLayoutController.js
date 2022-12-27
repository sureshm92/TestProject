({
    doInit: function (component, event, helper) {
        if (communityService.isInitialized()) {
            component.set('v.communityServ', communityService);
            helper.init(component);
        } else {
            communityService.initialize(component);
        }
    },

    doRefresh: function (component, event, helper) {
        helper.init(component);

        component.find('ppMenu').forceRefresh();
        component.find('ppFooter').forceRefresh();
        component.find('ppAlerts').forceRefresh();
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    },
    //Added as per REF-1343 by Vikrant Sharma for Help icon adjacent to User Profile for PI and HCP
    onClickHelp: function () {
        communityService.navigateToPage('help');
    },
    handleClick: function (component, event, helper) {
        component.set('v.isPPonPhone', !component.get('v.isPPonPhone'));
    },
    closePPMobileMenu: function (component, event, helper) {
        if (component.get('v.isPPonPhone')) {
            component.set('v.isPPonPhone', false);
        }
    }
});
