/**
 * Created by Leonid Bartenev
 */
({
    doSwitchCollapse: function (component) {
        component.set('v.isCollapsed', !component.get('v.isCollapsed'));
    },
    doSwitchShowMore: function (component) {
        component.set('v.showMore', !component.get('v.showMore'));
    }
})