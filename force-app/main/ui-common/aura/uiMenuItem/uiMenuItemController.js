/**
 * Created by Leonid Bartenev
 */
({
    doOnClick: function (component) {
        component.getEvent('onclick').fire();
        var menuSelectEvent = component.getEvent('menuSelect');
        menuSelectEvent.setParams({
            selectedItem: component,
            'hideMenu': true
        });
        menuSelectEvent.fire();
    }

})