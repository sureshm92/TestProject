/**
 * Created by Leonid Bartenev
 */
({

    doInit: function (component, event, helper) {
        if(communityService.isInitialized()){
            helper.init(component);
        }else{
            communityService.initialize(component);
        }
    },

    doRefresh: function(component, event, helper){
        helper.init(component);
        component.find('navigation').refresh();
        component.find('navigationMobile').refresh();
        component.find('profileMenu').refresh();
        component.find('alerts').refresh();
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
});