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
        component.set('v.handleTelevistBanner', loadTelevisitBanner);
        component.find('spinner').hide();
    },
    doRefresh: function (component, event, helper) {
        helper.init(component);
        if (component.find('ppMenu')) component.find('ppMenu').forceRefresh();
        if (component.find('ppFooter')) component.find('ppFooter').forceRefresh();
        if (component.find('ppAlerts')) component.find('ppAlerts').forceRefresh();
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    },
    //Added as per REF-1343 by Vikrant Sharma for Help icon adjacent to User Profile for PI and HCP
    onClickHelp: function () {
        communityService.navigateToPage('help');
    },
    handleClick: function (component, event, helper) {
        if (component.find('ppMenu')) {
            component.find('ppMenu').handleClick();
        }
    },
    handleClickCloseNavMenu: function (component, event, helper) {
        if (
            $A.get('$Browser.formFactor') != 'DESKTOP' &&
            !component.get('v.stopLoading') &&
            component.find('ppMenu')
        ) {
            component.find('ppMenu').handleCloseHamberungMenu();
            component.set('v.stopLoading', true);
        }
    },
    handleHamberungTouchEnd: function (component, event, helper) {
        if ($A.get('$Browser.formFactor') != 'DESKTOP' && component.get('v.stopLoading')) {
            component.set('v.stopLoading', false);
        }
    }
});