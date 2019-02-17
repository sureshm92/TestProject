/**
 * Created by Leonid Bartenev
 */
({
    doInit: function(component, event, helper){
        communityService.executeAction(component, 'getInitData', null, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.showOnStartupMap', initData.showOnLogin);
            component.set('v.tourNamesMap', initData.systemTourNames);
            component.set('v.isInitialized', true);
            communityService.setShowOnLoginMap(initData.showOnLogin);
            communityService.setIsNewSession(initData.isNewSession);
            $A.get('e.c:OnboardingSlideTourStartupModeChanged').fire();
            window.addEventListener('resize', $A.getCallback(function() {
                helper.scrollToPage(component, event, helper, component.get('v.currentPage'));
            }));

            if(communityService.showTourOnLogin() && initData.isNewSession){
                communityService.showTour();
            }
        })
    },

    handleChangeCurrentPage: function(component, event, helper) {
        helper.updateDots(component, event, helper);
    },

    handleClickDot: function(component, event, helper) {
        var page = parseInt(event.target.dataset.page, 10);
        helper.scrollToPage(component, event, helper, page);
    },

    handleClickPrevious: function(component, event, helper) {
        var newPage;
        var currentPage = component.get('v.currentPage');
        var lastPageIndex = component.get('v.slides').length - 1;

        if (currentPage > 0) {
            newPage = currentPage - 1;
        } else {
            newPage = lastPageIndex;
        }

        helper.scrollToPage(component, event, helper, newPage);
    },

    handleClickNext: function(component, event, helper) {
        var newPage;
        var currentPage = component.get('v.currentPage');
        var lastPageIndex = component.get('v.slides').length - 1;

        if (currentPage < lastPageIndex) {
            newPage = currentPage + 1;
        } else {
            newPage = 0;
        }

        helper.scrollToPage(component, event, helper, newPage);
    },

    doShow: function (component, event, helper) {
        var tourName = event.getParam('tourName');
        helper.show(component, tourName);
    },

    doHide: function (component) {
        component.set('v.visible', false);
    },

    doSwitchShowOnLoginMode: function (component) {
        var showOnLoing = component.get('v.showOnLogin');
        var action = component.find('switchShowOnLoginModeAction');
        action.execute(showOnLoing);
    }

})