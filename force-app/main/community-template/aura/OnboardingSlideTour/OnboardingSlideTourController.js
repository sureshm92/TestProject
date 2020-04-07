/**
 * Created by Leonid Bartenev
 */
({
    doInitialShow: function(component, event, helper){
        var isInitialized = component.get('v.isInitialized');
        if(isInitialized){
            var showOnLogin = component.get('v.showOnLogin');
            var isNewSession = component.get('v.isNewSession');
            let mainDiv = component.find('tourContainer');
            if(showOnLogin && isNewSession) $A.util.removeClass(mainDiv, 'hidden');
        }else{
            component.set('v.showAfterInit', true);
        }
    },

    doInit: function(component, event, helper){
        component.set('v.showAfterInit', false);
        component.set('v.isInitialized', 'false');
        window.addEventListener('resize', $A.getCallback(function() {
            helper.scrollToPage(component, event, helper, component.get('v.currentPage'));
        }));
        component.find('spinner').show();
        communityService.executeAction(component, 'getSlides', {
            userMode: communityService.getUserMode(),
            formFactor: $A.get('$Browser.formFactor'),
            multimode: communityService.getAllUserModes().length > 1
        }, function (returnValue) {
            var tour = JSON.parse(returnValue);
            component.set('v.showOnLogin', tour.showOnStartup);
            communityService.setShowOnLogin(tour.showOnStartup);
            $A.get('e.c:OnboardingSlideTourStartupModeChanged').fire();
            component.set('v.currentPage', 0);
            component.set('v.title', tour.title);
            component.set('v.slides', tour.slides);
            component.set('v.isNewSession', tour.isNewSession);
            if(tour.slides.length > 0) component.set('v.currentSlide', tour.slides[0]);
            if(component.get('v.showAfterInit')) {
                let mainDiv = component.find('tourContainer');
                $A.util.removeClass(mainDiv, 'hidden');
            }
            component.find('spinner').hide();
            component.set('v.isInitialized', true);
            try{
                component.find('carouselBody').getElement().scrollLeft = 0;
            }catch (e) {}
        });
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
        if(component.get('v.isInitialized')){
            let mainDiv = component.find('tourContainer');
            $A.util.removeClass(mainDiv, 'hidden');
        }else{
            component.set('v.showAfterInit');
        }
    },

    doHide: function (component) {
        let mainDiv = component.find('tourContainer');
        $A.util.addClass(mainDiv, 'hidden');
    },

    doSwitchShowOnLoginMode: function (component) {
        var showOnLoing = component.get('v.showOnLogin');
        var action = component.find('switchShowOnLoginModeAction');
        action.execute(showOnLoing);
    },

    doSetCurrentShowOnLoginState: function (component) {
        component.set('v.showOnLogin', communityService.showTourOnLogin());
    }

})