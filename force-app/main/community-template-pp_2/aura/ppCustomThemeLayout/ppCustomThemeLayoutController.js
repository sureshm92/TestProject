({
    doInit: function (component, event, helper) {
        if (communityService.isInitialized()) {
            component.set('v.communityServ', communityService);
            helper.init(component);
            helper.handleOrientationInit(component);
            helper.registerOrientationChange(component);
        } else {
            communityService.initialize(component);
        }
    },
    handleRouteChange: function (component, event, helper) {
        var perRecId = communityService.getUrlParameter('perId');
        var contactRecId = communityService.getUrlParameter('contactId');
        var targetRec = communityService.getUrlParameter('targetRecId');
        var isPast = communityService.getUrlParameter('ispast');
        var perContId = communityService.getUrlParameter('perContactId');
        if (contactRecId != null) {
            communityService.executeAction(
                component,
                'updateContact',
                {
                    peId: perRecId,
                    recId: contactRecId,
                    peContactId: perContId
                },
                function (returnValue) {
                    if (sessionStorage.getItem('isPushNotification') == null) {
                        communityService.loadPage();
                    }
                    var pageurl = communityService.getFullPageName();
                    if (pageurl.includes('messages')) {
                        communityService.navigateToPage('messages');
                    } else if (pageurl.includes('televisit')) {
                        communityService.navigateToPage('televisit?ispast=' + isPast);
                    } else if (pageurl.includes('results')) {
                        if (returnValue)
                            communityService.navigateToPage('past-studies?per=' + perRecId);
                        else communityService.navigateToPage('results?vrlist&pvId=' + targetRec);
                    } else {
                        communityService.navigateToPage('');
                    }
                }
            );
        }
    },

    handleLoadTelevisitBanner: function (component, event, helper) {
        let loadTelevisitBanner = event.getParam('loadTelevisitBanner');
        component.set('v.handleTelevistBanner', loadTelevisitBanner);
        if (component.find('spinner')) {
            component.find('spinner').hide();
        }
    },
    handleMessageNotification: function (component, event, helper) {
        let messages = event.getParam('message');
        if (messages != null) {
            component.set('v.hasMessage', true);
        } else {
            component.set('v.hasMessage', false);
        }
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
        helper.handleClickCloseNavMenu(component);
    },
    handleHamberungTouchEnd: function (component, event, helper) {
        if ($A.get('$Browser.formFactor') != 'DESKTOP' && component.get('v.stopLoading')) {
            component.set('v.stopLoading', false);
        }
    },

    handleMessage: function (component, event, helper) {
        // Read the message argument to get the values in the message payload
        if (event != null && event.getParams() != null) {
            const message = event.getParam('mediaContent');
            component.set('v.mediaContent', message);
            helper.handleOrientationInit(component);
        }
    }
});
