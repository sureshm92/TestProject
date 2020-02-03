/**
 * Created by Leonid Bartenev
 */
({

    doInit: function (component, event, helper) {
        if(communityService.isInitialized()){
            component.set('v.allModes', communityService.getAllUserModes());
            component.set('v.currentMode', communityService.getCurrentCommunityMode());
            component.set('v.isInitialized', true);
            component.set('v.showModeSwitcher', !(communityService.getAllUserModes().length === 1 && communityService.getAllUserModes()[0].subModes.length <= 1));
            component.set('v.isArabic', communityService.getLanguage() === 'ar' );
            component.set('v.logoURL', communityService.getTemplateProperty('CommunityLogo'));
            component.set('v.themeCSS', communityService.getTemplateProperty('ThemeCSS'));

        }else{
            communityService.initialize(component);
        }
    },

    doModeChanged: function (component){
        component.find('navigation').refresh();
        component.find('navigationMobile').refresh();
        component.find('profileMenu').refresh();
    },

   switchSideMenu: function (component) {
        component.set('v.showSideMenu', !component.get('v.showSideMenu'));
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    },




})