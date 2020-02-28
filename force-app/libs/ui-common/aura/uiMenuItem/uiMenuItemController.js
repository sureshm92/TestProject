/**
 * Created by Leonid Bartenev
 */
({
    doOnClick: function (component) {
        component.getEvent('onclick').fire();
        if(component.get('v.closeAfterClick')){
            component.closeMenu();
        }
    },

    doCloseMenu: function (component) {
        var menuSelectEvent = component.getEvent('menuSelect');
        menuSelectEvent.setParams({
            selectedItem: component,
            'hideMenu': true
        });
        menuSelectEvent.fire();
    }

})