({
    doInit: function (component, event, helper) {
        if (communityService.isInitialized()) {
            component.set('v.communityServ', communityService);
            helper.init(component);
        } else {
            communityService.initialize(component);
        }
    },

    handleLoadTelevisitBanner: function (component, event, helper) {
        let loadTelevisitBanner = event.getParam('loadTelevisitBanner');
        //  component.set('v.handleTelevistBanner', loadTelevisitBanner);
        component.find('spinner').hide();
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
    handlecloseNavigationMenu: function (component, event, helper) {
        component.set('v.isPPonPhone', false);
    },
    closePPMobileMenu: function (component, event, helper) {
        if (component.get('v.isPPonPhone')) {
            component.set('v.isPPonPhone', false);
        }
    }
});
