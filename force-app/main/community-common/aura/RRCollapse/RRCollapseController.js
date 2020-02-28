/**
 * Created by Leonid Bartenev
 */
({
    doSwitch: function (component) {
        var isCollapsed = component.get('v.isCollapsed');
        component.set('v.isCollapsed', !isCollapsed);
    }
})