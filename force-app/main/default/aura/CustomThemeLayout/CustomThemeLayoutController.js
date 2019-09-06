/**
 * Created by Leonid Bartenev
 */
({

    doInit: function (component, event, helper) {
        if(communityService.isInitialized()){
            component.set('v.allModes', communityService.getAllUserModes());
            component.set('v.currentMode', communityService.getCurrentCommunityMode());
            component.find('spinner').hide();
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