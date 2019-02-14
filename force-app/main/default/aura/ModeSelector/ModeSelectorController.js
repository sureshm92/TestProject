/**
 * Created by Leonid Bartenev
 */
({

    doChangeMode: function (component, event, helper){
        var currentMode = component.get('v.currentMode');
        var label = helper.getLabel(component, currentMode);
        component.set('v.currentLabel', label);
    },

    switchMenuVisibility: function (component) {
        var isVisible = component.get('v.showMenu');
        component.set('v.showMenu', !isVisible);
        component.find("modeMenu").getElement().focus();
    },

    hideMenu: function (component) {
        component.set('v.showMenu', false);
    },

    selectItem: function (component, event, helper) {
        var mode = event.target.dataset.menuItemId;
        if (mode) {
            component.set('v.currentMode', mode);
            component.set('v.currentLabel', helper.getLabel(component, mode));
            communityService.setUserMode(mode);
            communityService.navigateToPage('');
            if(communityService.showTourOnLogin() && ! communityService.isTourAlreadyShowed()  && communityService.isNewSession()) {
                communityService.showTour();
            }
            communityService.executeAction(component, 'changeMode', {
                mode: mode
            }, function (returnValue) {
                console.log('Community mode changed: ' + communityService.getUserMode());
            })
        }
    }

})