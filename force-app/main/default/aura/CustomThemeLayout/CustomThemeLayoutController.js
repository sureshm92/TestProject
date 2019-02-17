/**
 * Created by Leonid Bartenev
 */
({

    doInit: function (component, event, helper) {
        if(communityService.isInitialized()){
            helper.setAvailableModes(component);
            component.set('v.isInitialized', true);
        }else{
            communityService.initialize(component);
        }
    },

   switchSideMenu: function (component) {
        component.set('v.showSideMenu', !component.get('v.showSideMenu'));
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    }


})