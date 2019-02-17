/**
 * Created by Leonid Bartenev
 */
({
    doSwitchCollapse: function (component) {
        component.set('v.isCollapsed', !component.get('v.isCollapsed'));
    }
})